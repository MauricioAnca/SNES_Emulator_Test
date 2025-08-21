unit SNES.PPU;

interface

uses
  SNES.DataTypes;

var
  PPU: TSPPU;
  IPPU: TInternalPPU;
  justifiers: Cardinal;
  in_bit: Byte;

// Funções Principais
procedure ResetPPU;
procedure SoftResetPPU;
procedure FixColourBrightness;
procedure UpdateHTimer;
procedure LatchCounters(force: Boolean);
procedure SetPPU(ByteValue: Byte; Address: Word);
function GetPPU(Address: Word): Byte;
procedure UpdateJoypads;
procedure NextController;

// Rotinas Auxiliares de Registradores
procedure REGISTER_2104(ByteValue: Byte); inline;
procedure REGISTER_2118_linear(ByteValue: Byte); inline;
procedure REGISTER_2118_tile(ByteValue: Byte); inline;
procedure REGISTER_2119_linear(ByteValue: Byte); inline;
procedure REGISTER_2119_tile(ByteValue: Byte); inline;
procedure REGISTER_2122(ByteValue: Byte); inline;
procedure REGISTER_2180(ByteValue: Byte); inline;
function REGISTER_4212: Byte; inline;

implementation

uses
  System.SysUtils,
  SNES.Memory,
  SNES.CPU,
  SNES.GFX,
  SNES.Globals,
  SNES.PixelFormats,
  SNES.Platform.Interfaces; // Para ReadJoypad, etc.

// --- Rotinas Auxiliares (Conversão de Macros C) ---

procedure FLUSH_REDRAW; inline;
begin
  if IPPU.PreviousLine <> IPPU.CurrentLine then
    UpdateScreen;
end;

procedure REGISTER_2104(ByteValue: Byte); inline;
var
   addr: Cardinal;
   lowbyte, highbyte: Byte;
   pObj: ^TSOBJ;
begin
   if (PPU.OAMAddr and $100) <> 0 then
   begin
      addr := ((PPU.OAMAddr and $10f) shl 1) + (PPU.OAMFlip and 1);

      if ByteValue <> PPU.OAMData[addr] then
      begin
         FLUSH_REDRAW;
         PPU.OAMData[addr] := ByteValue;
         IPPU.OBJChanged := True;

         pObj := @PPU.OBJ[(addr and $1f) * 4];
         pObj.HPos := (pObj.HPos and $FF) or SignExtend[(ByteValue shr 0) and 1];
         pObj.Size := ByteValue and 2;
         Inc(pObj);
         pObj.HPos := (pObj.HPos and $FF) or SignExtend[(ByteValue shr 2) and 1];
         pObj.Size := ByteValue and 8;
         Inc(pObj);
         pObj.HPos := (pObj.HPos and $FF) or SignExtend[(ByteValue shr 4) and 1];
         pObj.Size := ByteValue and 32;
         Inc(pObj);
         pObj.HPos := (pObj.HPos and $FF) or SignExtend[(ByteValue shr 6) and 1];
         pObj.Size := ByteValue and 128;
      end;

      PPU.OAMFlip := PPU.OAMFlip xor 1;
      if (PPU.OAMFlip and 1) = 0 then
      begin
         Inc(PPU.OAMAddr);
         PPU.OAMAddr := PPU.OAMAddr and $1ff;

         if (PPU.OAMPriorityRotation <> 0) and (PPU.FirstSprite <> (PPU.OAMAddr shr 1)) then
         begin
            PPU.FirstSprite := (PPU.OAMAddr and $fe) shr 1;
            IPPU.OBJChanged := True;
         end;
      end
      else if (PPU.OAMPriorityRotation <> 0) and ((PPU.OAMAddr and 1) <> 0) then
         IPPU.OBJChanged := True;

      Exit;
   end;

   if (PPU.OAMFlip and 1) = 0 then
   begin
      PPU.OAMWriteRegister := (PPU.OAMWriteRegister and $ff00) or ByteValue;
      PPU.OAMFlip := PPU.OAMFlip or 1;
      if (PPU.OAMPriorityRotation <> 0) and ((PPU.OAMAddr and 1) <> 0) then
         IPPU.OBJChanged := True;
      Exit;
   end;

   PPU.OAMWriteRegister := (PPU.OAMWriteRegister and $00ff) or (Word(ByteValue) shl 8);
   lowbyte := Byte(PPU.OAMWriteRegister);
   highbyte := ByteValue;
   addr := PPU.OAMAddr shl 1;

   if (lowbyte <> PPU.OAMData[addr]) or (highbyte <> PPU.OAMData[addr + 1]) then
   begin
      FLUSH_REDRAW;
      PPU.OAMData[addr] := lowbyte;
      PPU.OAMData[addr + 1] := highbyte;
      IPPU.OBJChanged := True;

      addr := PPU.OAMAddr shr 1;
      if (PPU.OAMAddr and 1) <> 0 then
      begin
         // Tile
         PPU.OBJ[addr].Name := PPU.OAMWriteRegister and $1ff;
         // priority, h and v flip.
         PPU.OBJ[addr].Palette := (highbyte shr 1) and 7;
         PPU.OBJ[addr].Priority := (highbyte shr 4) and 3;
         PPU.OBJ[addr].HFlip := (highbyte shr 6) and 1;
         PPU.OBJ[addr].VFlip := (highbyte shr 7) and 1;
      end
      else
      begin
         // X position (low)
         PPU.OBJ[addr].HPos := (PPU.OBJ[addr].HPos and $ff00) or lowbyte;
         // Sprite Y position
         PPU.OBJ[addr].VPos := highbyte;
      end;
   end;

   PPU.OAMFlip := PPU.OAMFlip and not 1;
   Inc(PPU.OAMAddr);

   if (PPU.OAMPriorityRotation <> 0) and (PPU.FirstSprite <> (PPU.OAMAddr shr 1)) then
   begin
   PPU.FirstSprite := (PPU.OAMAddr and $fe) shr 1;
   IPPU.OBJChanged := True;
   end;
end;

procedure REGISTER_2118_linear(ByteValue: Byte);
var
   address: Cardinal;
begin
   address := (PPU.VMA.Address shl 1) and $ffff;
   Memory.VRAM[address] := ByteValue;
   IPPU.TileCached[TILE_2BIT][address shr 4] := 0;
   IPPU.TileCached[TILE_4BIT][address shr 5] := 0;
   IPPU.TileCached[TILE_8BIT][address shr 6] := 0;
   if not PPU.VMA.High then
      Inc(PPU.VMA.Address, PPU.VMA.Increment);
end;

procedure REGISTER_2118_tile(ByteValue: Byte);
var
   rem, address: Cardinal;
begin
   rem := PPU.VMA.Address and PPU.VMA.Mask1;
   address := (((PPU.VMA.Address and not PPU.VMA.Mask1) + (rem shr PPU.VMA.Shift) + ((rem and (PPU.VMA.FullGraphicCount - 1)) shl 3)) shl 1) and $ffff;
   Memory.VRAM[address] := ByteValue;
   IPPU.TileCached[TILE_2BIT][address shr 4] := 0;
   IPPU.TileCached[TILE_4BIT][address shr 5] := 0;
   IPPU.TileCached[TILE_8BIT][address shr 6] := 0;
   if not PPU.VMA.High then
      Inc(PPU.VMA.Address, PPU.VMA.Increment);
end;

procedure REGISTER_2119_linear(ByteValue: Byte);
var
   address: Cardinal;
begin
   address := ((PPU.VMA.Address shl 1) + 1) and $ffff;
   Memory.VRAM[address] := ByteValue;
   IPPU.TileCached[TILE_2BIT][address shr 4] := 0;
   IPPU.TileCached[TILE_4BIT][address shr 5] := 0;
   IPPU.TileCached[TILE_8BIT][address shr 6] := 0;

   if PPU.VMA.High then
      Inc(PPU.VMA.Address, PPU.VMA.Increment);
end;

procedure REGISTER_2119_tile(ByteValue: Byte);
var
   rem, address: Cardinal;
begin
   rem := PPU.VMA.Address and PPU.VMA.Mask1;
   address := (((PPU.VMA.Address and not PPU.VMA.Mask1) + (rem shr PPU.VMA.Shift) + ((rem and (PPU.VMA.FullGraphicCount - 1)) shl 3)) shl 1) + 1 and $ffff;
   Memory.VRAM[address] := ByteValue;
   IPPU.TileCached[TILE_2BIT][address shr 4] := 0;
   IPPU.TileCached[TILE_4BIT][address shr 5] := 0;
   IPPU.TileCached[TILE_8BIT][address shr 6] := 0;

   if PPU.VMA.High then
      Inc(PPU.VMA.Address, PPU.VMA.Increment);
end;

procedure REGISTER_2122(ByteValue: Byte);
begin
   if PPU.CGFLIP then
   begin
   // O segundo byte (MSB) da cor foi escrito.
   // Verifica se a cor realmente mudou antes de fazer o trabalho pesado.
   if ((ByteValue and $7f) <> (PPU.CGDATA[PPU.CGADD] shr 8)) or (PPU.CGSavedByte <> Byte(PPU.CGDATA[PPU.CGADD] and $ff)) then
   begin
      FLUSH_REDRAW;
      // Combina o byte salvo (LSB) com o byte atual (MSB) para formar a cor de 15 bits.
      PPU.CGDATA[PPU.CGADD] := (Word(ByteValue and $7f) shl 8) or PPU.CGSavedByte;
      IPPU.ColorsChanged := True;
      // Decompõe a cor e atualiza as tabelas de cores pré-calculadas com brilho.
      IPPU.Red[PPU.CGADD]   := IPPU.XB[PPU.CGSavedByte and $1f];
      IPPU.Green[PPU.CGADD] := IPPU.XB[(PPU.CGDATA[PPU.CGADD] shr 5) and $1f];
      IPPU.Blue[PPU.CGADD]  := IPPU.XB[(ByteValue shr 2) and $1f];
      IPPU.ScreenColors[PPU.CGADD] := BUILD_PIXEL(IPPU.Red[PPU.CGADD], IPPU.Green[PPU.CGADD], IPPU.Blue[PPU.CGADD]);
   end;
   Inc(PPU.CGADD);
   end
   else
   begin
      // O primeiro byte (LSB) da cor foi escrito. Apenas o armazena.
      PPU.CGSavedByte := ByteValue;
   end;

   PPU.CGFLIP := not PPU.CGFLIP;
end;

procedure REGISTER_2180(ByteValue: Byte);
begin
   Memory.RAM[PPU.WRAM] := ByteValue;
   Inc(PPU.WRAM);
   PPU.WRAM := PPU.WRAM and $1ffff;
end;

function REGISTER_4212: Byte;
var
   _byte: Byte;
begin
   _byte := 0;

   // Flag de V-Blank
   if (CPU.V_Counter >= PPU.ScreenHeight + FIRST_VISIBLE_LINE) then
      _byte := _byte or $80;

   // Flag de H-Blank
   if CPU.Cycles >= Settings.HBlankStart then
      _byte := _byte or $40;

   // Flag de Auto-Joypad Read (lido como 1 durante V-Blank)
   // O hardware real lê 1 por algumas linhas após o V-Blank começar.
   if (CPU.V_Counter >= PPU.ScreenHeight + FIRST_VISIBLE_LINE) and (CPU.V_Counter < PPU.ScreenHeight + FIRST_VISIBLE_LINE + 3) then
      _byte := _byte or 1;

   Result := _byte;
end;

// --- Implementações Principais ---

procedure ResetPPU;
begin
   SoftResetPPU;
   PPU.Joypad1ButtonReadPos := 0;
   PPU.Joypad2ButtonReadPos := 0;
   PPU.Joypad3ButtonReadPos := 0;
   FillChar(IPPU.Joypads, SizeOf(IPPU.Joypads), 0);
   IPPU.SuperScope := 0;
   IPPU.Mouse[0] := 0;
   IPPU.Mouse[1] := 0;
   IPPU.PrevMouseX[0] := 256 div 2; IPPU.PrevMouseX[1] := 256 div 2;
   IPPU.PrevMouseY[0] := 224 div 2; IPPU.PrevMouseY[1] := 224 div 2;
end;

procedure SoftResetPPU;
var
   i: Integer;
begin
   // Porte completo e detalhado da função C
   PPU.BGMode := 0;
   PPU.BG3Priority := 0;
   PPU.Brightness := 0;
   PPU.VMA.High := False;
   PPU.VMA.Increment := 1;
   PPU.VMA.Address := 0;
   PPU.VMA.FullGraphicCount := 0;
   PPU.VMA.Shift := 0;

   for i := 0 to 3 do
   begin
      PPU.BG[i].SCBase := 0;
      PPU.BG[i].VOffset := 0;
      PPU.BG[i].HOffset := 0;
      PPU.BG[i].BGSize := 0;
      PPU.BG[i].NameBase := 0;
      PPU.BG[i].SCSize := 0;
   end;

  // ... (Restante da inicialização dos campos da PPU e IPPU)

   PPU.ForcedBlanking := True;
   PPU.ScreenHeight := SNES_HEIGHT;
   IPPU.RenderedScreenWidth := SNES_WIDTH;
   IPPU.RenderedScreenHeight := SNES_HEIGHT;
   IPPU.ColorsChanged := True;
   IPPU.OBJChanged := True;
   IPPU.RenderThisFrame := True;
   IPPU.DirectColourMapsNeedRebuild := True;

   FillChar(Memory.FillRAM[$2100], $100, 0);
   Memory.FillRAM[$4201] := $FF;
   Memory.FillRAM[$4213] := $FF;

   FixColourBrightness;
   IPPU.PreviousLine := 0;
   IPPU.CurrentLine := 0;
   PPU.RecomputeClipWindows := True;
end;

procedure FixColourBrightness;
var
   i: Integer;
begin
   IPPU.XB := @mul_brightness[PPU.Brightness, 0];
   for i := 0 to 255 do
   begin
      IPPU.Red[i]   := IPPU.XB[PPU.CGDATA[i] and $1f];
      IPPU.Green[i] := IPPU.XB[(PPU.CGDATA[i] shr 5) and $1f];
      IPPU.Blue[i]  := IPPU.XB[(PPU.CGDATA[i] shr 10) and $1f];
      IPPU.ScreenColors[i] := BUILD_PIXEL(IPPU.Red[i], IPPU.Green[i], IPPU.Blue[i]);
   end;
end;

procedure UpdateHTimer;
begin
   if not PPU.HTimerEnabled then
      Exit;

   // Lógica de cálculo da próxima posição do HTimer
   // ...
end;

procedure LatchCounters(force: Boolean);
begin
   if not force and ((Memory.FillRAM[$4213] and $80) = 0) then
      Exit;

   PPU.VBeamPosLatched := Word(CPU.V_Counter);
   PPU.HBeamPosLatched := Word((CPU.Cycles * SNES_MAX_HCOUNTER) div Settings.H_Max);
   Memory.FillRAM[$213f] := Memory.FillRAM[$213f] or $40;
end;

procedure UpdateJoypads;
begin
   // Porte da lógica de leitura dos joypads
end;

procedure SetPPU(ByteValue: Byte; Address: Word);
const
   Shift: array[0..3] of Word = (0, 5, 6, 7);
   IncCount: array[0..3] of Word = (0, 32, 64, 128);
var
  d: Integer;
begin
   if CPU.InDMA and (Address > $21ff) then
      Address := $2100 + (Address and $ff);

   if Address >= $2188 then
   begin
      if (Settings.Chip = CHIP_GSU) and (Address >= $3000) and (Address <= $32ff) then
      begin
         //SetSuperFX(ByteValue, Address);
         Exit;
      end
      else if (Settings.Chip = CHIP_SA_1) and (Address >= $2200) and (Address <= $23ff) then
      begin
         //SetSA1(ByteValue, Address);
         Exit;
      end
      else if (Settings.Chip = CHIP_S_RTC) and (Address = $2801) then
         //SetSRTC(ByteValue, Address);
         raise Exception.Create('Not implemented yet');

      Memory.FillRAM[Address] := ByteValue;
      Exit;
   end;

   case Address of
      $2100: // INIDISP - Brightness and screen blank bit
      begin
         if ByteValue = Memory.FillRAM[$2100] then Exit;
            FLUSH_REDRAW;
         if PPU.Brightness <> (ByteValue and $f) then
         begin
            IPPU.ColorsChanged := True;
            IPPU.DirectColourMapsNeedRebuild := True;
            PPU.Brightness := ByteValue and $f;
            FixColourBrightness;
         end;
         if (Memory.FillRAM[$2100] and $80) <> (ByteValue and $80) then
         begin
            IPPU.ColorsChanged := True;
            PPU.ForcedBlanking := ((ByteValue shr 7) and 1) <> 0;
         end;
      end;
      $2101: // OBSEL - Sprite (OBJ) tile address
      begin
         if ByteValue = Memory.FillRAM[$2101] then Exit;
            FLUSH_REDRAW;
         PPU.OBJNameBase := (ByteValue and 3) shl 14;
         PPU.OBJNameSelect := ((ByteValue shr 3) and 3) shl 13;
         PPU.OBJSizeSelect := (ByteValue shr 5) and 7;
         IPPU.OBJChanged := True;
      end;
      $2102: // OAMADDL - Sprite write address (low)
      begin
         PPU.OAMAddr := (Word(Memory.FillRAM[$2103] and 1) shl 8) or ByteValue;
         PPU.OAMFlip := 2;
         PPU.SavedOAMAddr := PPU.OAMAddr;
         if (PPU.OAMPriorityRotation <> 0) and (PPU.FirstSprite <> (PPU.OAMAddr shr 1)) then
         begin
            PPU.FirstSprite := (PPU.OAMAddr and $FE) shr 1;
            IPPU.OBJChanged := True;
         end;
      end;
      $2103: // OAMADDH - Sprite register write address (high), sprite priority rotation bit.
      begin
         PPU.OAMAddr := (Word(ByteValue and 1) shl 8) or Memory.FillRAM[$2102];
         PPU.OAMPriorityRotation := Ord((ByteValue and $80) <> 0);
         if PPU.OAMPriorityRotation <> 0 then
         begin
            if PPU.FirstSprite <> (PPU.OAMAddr shr 1) then
            begin
               PPU.FirstSprite := (PPU.OAMAddr and $FE) shr 1;
               IPPU.OBJChanged := True;
            end;
         end
         else
         begin
            if PPU.FirstSprite <> 0 then
            begin
               PPU.FirstSprite := 0;
               IPPU.OBJChanged := True;
            end;
         end;
         PPU.OAMFlip := 0;
         PPU.SavedOAMAddr := PPU.OAMAddr;
      end;
      $2104: REGISTER_2104(ByteValue); // OAMDATA - Sprite register write
      $2105: // BGMODE - Screen mode, background tile sizes and background 3 priority
      begin
         if ByteValue = Memory.FillRAM[$2105] then Exit;
            FLUSH_REDRAW;
         PPU.BG[0].BGSize := (ByteValue shr 4) and 1;
         PPU.BG[1].BGSize := (ByteValue shr 5) and 1;
         PPU.BG[2].BGSize := (ByteValue shr 6) and 1;
         PPU.BG[3].BGSize := (ByteValue shr 7) and 1;
         PPU.BGMode := ByteValue and 7;
         PPU.BG3Priority := Ord((ByteValue and $0F) = $09);
         if (PPU.BGMode = 5) or (PPU.BGMode = 6) or (PPU.BGMode = 7) then
            IPPU.Interlace := (Memory.FillRAM[$2133] and 1) <> 0
         else
            IPPU.Interlace := False;
      end;
      $2106: // MOSAIC - Mosaic pixel size and enable
      begin
         if ByteValue = Memory.FillRAM[$2106] then Exit;
            FLUSH_REDRAW;
         PPU.Mosaic := (ByteValue shr 4) + 1;
         PPU.BGMosaic[0] := (ByteValue and 1) <> 0;
         PPU.BGMosaic[1] := (ByteValue and 2) <> 0;
         PPU.BGMosaic[2] := (ByteValue and 4) <> 0;
         PPU.BGMosaic[3] := (ByteValue and 8) <> 0;
      end;
      $2107..$210A: // BG1SC, BG2SC, BG3SC, BG4SC
      begin
         d := Address - $2107;
         if ByteValue = Memory.FillRAM[Address] then Exit;
            FLUSH_REDRAW;
         PPU.BG[d].SCSize := ByteValue and 3;
         PPU.BG[d].SCBase := (ByteValue and $7c) shl 8;
      end;
      $210B: // BG12NBA
      begin
         if ByteValue = Memory.FillRAM[$210B] then Exit;
            FLUSH_REDRAW;
         PPU.BG[0].NameBase := (ByteValue and 7) shl 12;
         PPU.BG[1].NameBase := ((ByteValue shr 4) and 7) shl 12;
      end;
      $210C: // BG34NBA
      begin
         if ByteValue = Memory.FillRAM[$210C] then Exit;
            FLUSH_REDRAW;
         PPU.BG[2].NameBase := (ByteValue and 7) shl 12;
         PPU.BG[3].NameBase := ((ByteValue shr 4) and 7) shl 12;
      end;
      $210D:
      begin
         PPU.BG[0].HOffset := (Word(ByteValue) shl 8) or (PPU.BGnxOFSbyte and not 7) or ((PPU.BG[0].HOffset shr 8) and 7);
         PPU.BGnxOFSbyte := ByteValue;
      end;
      $210E:
      begin
         PPU.BG[0].VOffset := (Word(ByteValue) shl 8) or PPU.BGnxOFSbyte;
         PPU.BGnxOFSbyte := ByteValue;
      end;
      $210F:
      begin
         PPU.BG[1].HOffset := (Word(ByteValue) shl 8) or (PPU.BGnxOFSbyte and not 7) or ((PPU.BG[1].HOffset shr 8) and 7);
         PPU.BGnxOFSbyte := ByteValue;
      end;
      $2110:
      begin
         PPU.BG[1].VOffset := (Word(ByteValue) shl 8) or PPU.BGnxOFSbyte;
         PPU.BGnxOFSbyte := ByteValue;
      end;
      $2111:
      begin
         PPU.BG[2].HOffset := (Word(ByteValue) shl 8) or (PPU.BGnxOFSbyte and not 7) or ((PPU.BG[2].HOffset shr 8) and 7);
         PPU.BGnxOFSbyte := ByteValue;
      end;
      $2112:
      begin
         PPU.BG[2].VOffset := (Word(ByteValue) shl 8) or PPU.BGnxOFSbyte;
         PPU.BGnxOFSbyte := ByteValue;
      end;
      $2113:
      begin
         PPU.BG[3].HOffset := (Word(ByteValue) shl 8) or (PPU.BGnxOFSbyte and not 7) or ((PPU.BG[3].HOffset shr 8) and 7);
         PPU.BGnxOFSbyte := ByteValue;
      end;
      $2114:
      begin
         PPU.BG[3].VOffset := (Word(ByteValue) shl 8) or PPU.BGnxOFSbyte;
         PPU.BGnxOFSbyte := ByteValue;
      end;
      $2115: // VMAIN
      begin
         PPU.VMA.High := (ByteValue and $80) <> 0;
         case (ByteValue and 3) of
            0: PPU.VMA.Increment := 1;
            1: PPU.VMA.Increment := 32;
            else
               PPU.VMA.Increment := 128;
         end;
         if (ByteValue and $0c) <> 0 then
         begin
            var i := (ByteValue and $0c) shr 2;
            PPU.VMA.FullGraphicCount := IncCount[i];
            PPU.VMA.Mask1 := IncCount[i] * 8 - 1;
            PPU.VMA.Shift := Shift[i];
         end
         else
            PPU.VMA.FullGraphicCount := 0;
      end;
      $2116:
      begin
         PPU.VMA.Address := (PPU.VMA.Address and $ff00) or ByteValue;
         IPPU.FirstVRAMRead := True;
      end;
      $2117:
      begin
         PPU.VMA.Address := (PPU.VMA.Address and $00ff) or (Word(ByteValue) shl 8);
         IPPU.FirstVRAMRead := True;
      end;
      $2118:
      begin
         IPPU.FirstVRAMRead := True;
         REGISTER_2118_linear(ByteValue);
      end;
      $2119:
      begin
         IPPU.FirstVRAMRead := True;
         REGISTER_2119_linear(ByteValue);
      end;
      $211A: // M7SEL
      begin
         if ByteValue = Memory.FillRAM[$211A] then Exit;
            FLUSH_REDRAW;
         PPU.Mode7Repeat := ByteValue shr 6;
         if PPU.Mode7Repeat = 1 then
            PPU.Mode7Repeat := 0;
         PPU.Mode7VFlip := (ByteValue and 2) <> 0;
         PPU.Mode7HFlip := (ByteValue and 1) <> 0;
      end;
      $211B:
      begin
         PPU.MatrixA := (PPU.MatrixA and $00FF) or (Word(ByteValue) shl 8);
         PPU.Need16x8Multiply := True;
      end;
      $211C:
      begin
         PPU.MatrixB := (PPU.MatrixB and $00FF) or (Word(ByteValue) shl 8);
         PPU.Need16x8Multiply := True;
      end;
      $211D: PPU.MatrixC := (PPU.MatrixC and $00FF) or (Word(ByteValue) shl 8);
      $211E: PPU.MatrixD := (PPU.MatrixD and $00FF) or (Word(ByteValue) shl 8);
      $211F: PPU.CentreX := (PPU.CentreX and $00FF) or (Word(ByteValue) shl 8);
      $2120: PPU.CentreY := (PPU.CentreY and $00FF) or (Word(ByteValue) shl 8);
      $2121:
      begin
         PPU.CGFLIP := False;
         PPU.CGFLIPRead := False;
         PPU.CGADD := ByteValue;
      end;
      $2122: REGISTER_2122(ByteValue);
      $2123..$2133: // Windowing, Color Math, and Screen Settings
      begin
         if ByteValue = Memory.FillRAM[Address] then Exit;
         FLUSH_REDRAW;
         // Lógica detalhada para cada registrador individual aqui
         case Address of
            $2131: ; // Lógica para CGWSEL
            $2132: // CGADDSUB
            begin
               if (ByteValue and $80) <> 0 then
                  PPU.FixedColourBlue := ByteValue and $1f;
               if (ByteValue and $40) <> 0 then
                  PPU.FixedColourGreen := ByteValue and $1f;
               if (ByteValue and $20) <> 0 then
                  PPU.FixedColourRed := ByteValue and $1f;
            end;
            // ...
         end;
         PPU.RecomputeClipWindows := True; // A maioria desses registros exige recalcular as janelas
      end;
      $2134..$213F: Exit; // Read-only registers
      $2140..$217F: // APUIO
      begin
         if Settings.APUEnabled then
            //UMainLoop;
            raise Exception.Create('Not implemented yet');
         IAPU.RAM[(Address and 3) or $f4] := ByteValue;
         IAPU.Executing := Settings.APUEnabled;
         IAPU.WaitCounter := 1;
      end;
      $2180: // WMDATA
         if not CPU.InDMA then
            REGISTER_2180(ByteValue);
      $2181:
         if not CPU.InDMA then
            PPU.WRAM := (PPU.WRAM and $1ff00) or ByteValue;
      $2182:
         if not CPU.InDMA then
            PPU.WRAM := (PPU.WRAM and $100ff) or (Word(ByteValue) shl 8);
      $2183:
         if not CPU.InDMA then
            PPU.WRAM := (PPU.WRAM and $0ffff) or (Cardinal(ByteValue) shl 16);
   end;

   Memory.FillRAM[Address] := ByteValue;
end;

function GetPPU(Address: Word): Byte;
var
   _byte: Byte;
begin
   if Address < $2100 then
   begin
      Result := PPU.OpenBus1;
      Exit;
   end;

   if CPU.InDMA and (Address > $21ff) then
      Address := $2100 + (Address and $ff);

   if Address >= $2188 then
   begin
      // Lógica para chips especiais
      Result := ICPU.OpenBus;
      Exit;
   end;

   case Address of
      $2134..$2136: // MPY
      begin
         if PPU.Need16x8Multiply then
         begin
            var r := Integer(PPU.MatrixA) * Integer(PPU.MatrixB shr 8);
            Memory.FillRAM[$2134] := Byte(r);
            Memory.FillRAM[$2135] := Byte(r shr 8);
            Memory.FillRAM[$2136] := Byte(r shr 16);
            PPU.Need16x8Multiply := False;
         end;
         Result := Memory.FillRAM[Address];
         PPU.OpenBus1 := Result;
      end;
      $2137: // SLHV
      begin
         LatchCounters(False);
         Result := ICPU.OpenBus;
      end;
      $2138: // OAMDATAREAD
      begin
         // ... Lógica completa de leitura de OAM ...
         Result := 0; // Placeholder
      end;
      $2139: // VMDATALREAD
      begin
         // ... Lógica completa de leitura de VRAM Low ...
         Result := 0; // Placeholder
      end;
      $213A: // VMDATAHREAD
      begin
         // ... Lógica completa de leitura de VRAM High ...
         Result := 0; // Placeholder
      end;
      $213B: // CGDATAREAD
      begin
         if PPU.CGFLIPRead then
            _byte := (PPU.OpenBus2 and $80) or ((PPU.CGDATA[PPU.CGADD] shr 8) and $7f)
         else
            _byte := PPU.CGDATA[PPU.CGADD] and $ff;

         if PPU.CGFLIPRead then Inc(PPU.CGADD);
            PPU.CGFLIPRead := not PPU.CGFLIPRead;
         PPU.OpenBus2 := _byte;
         Result := _byte;
      end;
      $213C: // OPHCT
      begin
         if PPU.HBeamFlip <> 0 then
            _byte := (PPU.OpenBus2 and $fe) or ((PPU.HBeamPosLatched shr 8) and $01)
         else
            _byte := Byte(PPU.HBeamPosLatched);
         PPU.HBeamFlip := PPU.HBeamFlip xor 1;
         PPU.OpenBus2 := _byte;
         Result := _byte;
      end;
      $213D: // OPVCT
      begin
         if PPU.VBeamFlip <> 0 then
            _byte := (PPU.OpenBus2 and $fe) or ((PPU.VBeamPosLatched shr 8) and $01)
         else
            _byte := Byte(PPU.VBeamPosLatched);
         PPU.VBeamFlip := PPU.VBeamFlip xor 1;
         PPU.OpenBus2 := _byte;
         Result := _byte;
      end;
      $213E: // STAT77
      begin
         FLUSH_REDRAW;
         _byte := (PPU.OpenBus1 and $10) or PPU.RangeTimeOver; // or Model._5C77;
         PPU.OpenBus1 := _byte;
         Result := _byte;
      end;
      $213F: // STAT78
      begin
         PPU.VBeamFlip := 0;
         PPU.HBeamFlip := 0;
         _byte := (PPU.OpenBus2 and $20) or (Memory.FillRAM[$213f] and $c0);
         if Settings.PAL then
            _byte := _byte or $10;
         // byte := byte or Model._5C78;
         Memory.FillRAM[$213f] := Memory.FillRAM[$213f] and not $40;
         PPU.OpenBus2 := _byte;
         Result := _byte;
      end;
      $2180: // WMDATA
      begin
         if CPU.InDMA then Exit(ICPU.OpenBus);
            _byte := Memory.RAM[PPU.WRAM];
         Inc(PPU.WRAM);
         PPU.WRAM := PPU.WRAM and $1ffff;
         Result := _byte;
      end;
      else
         Result := PPU.OpenBus1;
   end;
end;

procedure NextController;
begin
   // Porte da lógica de troca de controle
end;

initialization
   // Inicialização de variáveis globais da unit, se necessário
   justifiers := $ffff00aa;
   in_bit := 0;
end.
