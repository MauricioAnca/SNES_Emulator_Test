unit SNES.Memory;

interface

uses
  System.SysUtils,
  SNES.DataTypes, SNES.Globals;

type
  TWrapType = (WRAP_NONE, WRAP_BANK, WRAP_PAGE);
  TWriteOrder = (WRITE_01, WRITE_10); // 01 = LSB then MSB, 10 = MSB then LSB

// --- Funções de Gerenciamento ---
function InitMemory: Boolean;
procedure DeinitMemory;
function LoadROM(const AGameData: TBytes; var AInfoBuffer: string): Boolean;
procedure InitROM;

// --- Funções de Acesso à Memória ---
function GetByte(Address: Cardinal): Byte;
function GetWord(Address: Cardinal; w: TWrapType): Word;
procedure SetByte(ByteValue: Byte; Address: Cardinal);
procedure SetWord(WordValue: Word; Address: Cardinal; w: TWrapType; o: TWriteOrder);
function GetBasePointer(Address: Cardinal): PByte;
function GetMemPointer(Address: Cardinal): PByte;
procedure SetPCBase(Address: Cardinal);

implementation

uses
  System.Classes, System.Character,
  SNES.PPU, SNES.CPU, SNES.GFX;
//  SNES.Chips.DSP,
//  SNES.Chips.SA1,
//  SNES.Chips.CX4,
//  SNES.Chips.OBC1,
//  SNES.Chips.SETA,
//  SNES.Chips.BSX,
//  SNES.Chips.XBAND,
//  SNES.Chips.SDD1,
//  SNES.Chips.SPC7110;

// Funções e variáveis "privadas" da unit (equivalentes às estáticas em C)
var
  ROMHeader: PByte;

function memory_speed(address: Cardinal): Integer;
begin
  if (address and $408000) <> 0 then
  begin
    if (address and $800000) <> 0 then
      Result := CPU.FastROMSpeed
    else
      Result := Settings.SlowOneCycle;
    Exit;
  end;

  if ((address + $6000) and $4000) <> 0 then
  begin
    Result := Settings.SlowOneCycle;
    Exit;
  end;

  if ((address - $4000) and $7e00) <> 0 then
  begin
    Result := Settings.OneCycle;
    Exit;
  end;

  Result := Settings.TwoCycles;
end;

procedure AddNumCyclesInMemAccess(cycles: Integer);
begin
  // if not Settings.GetSetDMATimingHacks and (CPU.InDMA or IPPU.HDMA) then
  //  Exit;
  CPU.Cycles := CPU.Cycles + cycles;
end;

procedure AddCyclesInMemAccess(address: Cardinal);
begin
  AddNumCyclesInMemAccess(memory_speed(address));
end;

procedure AddCyclesX2InMemAccess(address: Cardinal);
begin
  AddNumCyclesInMemAccess(memory_speed(address) shl 1);
end;

function AllASCII(b: PByte; size: Integer): Boolean;
var
  i: Integer;
begin
  for i := 0 to size - 1 do
  begin
    if (b[i] < 32) or (b[i] > 126) then
      Exit(False);
  end;
  Result := True;
end;

function ScoreHiROM(skip_header: Boolean; romoff: Integer): Integer;
var
   o: Integer;
begin
   Result := 0;
   o := romoff + $ff00;
   if skip_header then
      o := o + $200;

   // Check for extended HiROM expansion used in Mother 2 Deluxe et al.
   if (Memory.ROM[o + $d7] = 13) and (Memory.CalculatedSize > 1024 * 1024 * 4) then
      Result := Result + 5;

   if (Memory.ROM[o + $d5] and $1) <> 0 then
      Result := Result + 2;

   // Mode23 is SA-1
   if Memory.ROM[o + $d5] = $23 then
      Result := Result - 2;

   if Memory.ROM[o + $d4] = $20 then
      Result := Result + 2;

   if (Memory.ROM[o + $dc] + (Memory.ROM[o + $dd] shl 8) + Memory.ROM[o + $de] + (Memory.ROM[o + $df] shl 8)) = $ffff then
   begin
      Result := Result + 2;
      if (Memory.ROM[o + $de] + (Memory.ROM[o + $df] shl 8)) <> 0 then
         Result := Result + 1;
   end;

   if Memory.ROM[o + $da] = $33 then
      Result := Result + 2;

   if (Memory.ROM[o + $d5] and $f) < 4 then
      Result := Result + 2;

   if (Memory.ROM[o + $fd] and $80) = 0 then
      Result := Result - 6;

   if (Memory.ROM[o + $fc] or (Memory.ROM[o + $fd] shl 8)) > $ffb0 then
      Result := Result - 2;

   if Memory.CalculatedSize > 1024 * 1024 * 3 then
      Result := Result + 4;

   if (1 shl (Memory.ROM[o + $d7] - 7)) > 48 then
      Result := Result - 1;

   if not AllASCII(@Memory.ROM[o + $b0], 6) then
      Result := Result - 1;

   if not AllASCII(@Memory.ROM[o + $c0], ROM_NAME_LEN - 1) then
      Result := Result - 1;
end;

function ScoreLoROM(skip_header: Boolean; romoff: Integer): Integer;
var
   o: Integer;
begin
   Result := 0;
   o := romoff + $7f00;
   if skip_header then
      o := o + $200;

   if (Memory.ROM[o + $d5] and $1) = 0 then
      Result := Result + 3;

   // Mode23 is SA-1
   if Memory.ROM[o + $d5] = $23 then
      Result := Result + 2;

   if (Memory.ROM[o + $dc] + (Memory.ROM[o + $dd] shl 8) + Memory.ROM[o + $de] + (Memory.ROM[o + $df] shl 8)) = $ffff then
   begin
      Result := Result + 2;
      if (Memory.ROM[o + $de] + (Memory.ROM[o + $df] shl 8)) <> 0 then
         Result := Result + 1;
   end;

   if Memory.ROM[o + $da] = $33 then
      Result := Result + 2;

   if (Memory.ROM[o + $d5] and $f) < 4 then
      Result := Result + 2;

   if (Memory.ROM[o + $fd] and $80) = 0 then
      Result := Result - 6;

   if (Memory.ROM[o + $fc] or (Memory.ROM[o + $fd] shl 8)) > $ffb0 then
      Result := Result - 2;

   if Memory.CalculatedSize <= 1024 * 1024 * 16 then
      Result := Result + 2;

   if (1 shl (Memory.ROM[o + $d7] - 7)) > 48 then
      Result := Result - 1;

   if not AllASCII(@Memory.ROM[o + $b0], 6) then
      Result := Result - 1;

   if not AllASCII(@Memory.ROM[o + $c0], ROM_NAME_LEN - 1) then
      Result := Result - 1;
end;

// ... (Implementação de Deinterleave, etc. omitida para brevidade, mas deve ser portada)

procedure Map_Initialize;
var
   c: Integer;
begin
   for c := 0 to MEMMAP_NUM_BLOCKS - 1 do
   begin
      Memory.Map[c] := Pointer(MAP_NONE);
      Memory.WriteMap[c] := Pointer(MAP_NONE);
      Memory.BlockIsROM[c] := 0;
      Memory.BlockIsRAM[c] := 0;
   end;
end;

function map_mirror(size, pos: Cardinal): Cardinal;
var
   mask: Cardinal;
begin
   if size = 0 then
      Exit(0);
   if pos < size then
      Exit(pos);

   mask := Cardinal(1) shl 31;
   while (pos and mask) = 0 do
      mask := mask shr 1;

   if size <= (pos and mask) then
      Result := map_mirror(size, pos - mask)
   else
      Result := mask + map_mirror(size - mask, pos - mask);
end;

procedure map_lorom(bank_s, bank_e, addr_s, addr_e, size: Cardinal);
var
   c, i, p, addr: Cardinal;
begin
   for c := bank_s to bank_e do
   begin
      i := addr_s;
      while i <= addr_e do
      begin
         p := (c shl 4) or (i shr 12);
         addr := (c and $7f) * $8000;
         Memory.Map[p] := Memory.ROM + map_mirror(size, addr) - (i and $8000);
         Memory.BlockIsROM[p] := 1;
         Memory.BlockIsRAM[p] := 0;
         Inc(i, MEMMAP_BLOCK_SIZE);
      end;
   end;
end;

procedure map_space(bank_s, bank_e, addr_s, addr_e: Cardinal; data: PByte);
var
   c, i, p: Cardinal;
begin
   for c := bank_s to bank_e do
   begin
      i := addr_s;
      while i <= addr_e do
      begin
         p := (c shl 4) or (i shr 12);
         Memory.Map[p] := data;
         Memory.BlockIsROM[p] := 0;
         Memory.BlockIsRAM[p] := 1;
         Inc(i, MEMMAP_BLOCK_SIZE);
      end;
   end;
end;

procedure map_index(bank_s, bank_e, addr_s, addr_e: Cardinal; index: NativeUInt; map_type: Integer);
const
   MAP_TYPE_I_O = 0;
   MAP_TYPE_ROM = 1;
   MAP_TYPE_RAM = 2;
var
   c, i, p: Cardinal;
   isROM, isRAM: Boolean;
begin
   isROM := not (map_type in [MAP_TYPE_I_O, MAP_TYPE_RAM]);
   isRAM := not (map_type in [MAP_TYPE_I_O, MAP_TYPE_ROM]);

   for c := bank_s to bank_e do
   begin
      i := addr_s;
      while i <= addr_e do
      begin
         p := (c shl 4) or (i shr 12);
         Memory.Map[p] := Pointer(index);
         Memory.BlockIsROM[p] := Ord(isROM);
         Memory.BlockIsRAM[p] := Ord(isRAM);
         Inc(i, MEMMAP_BLOCK_SIZE);
      end;
   end;
end;

procedure map_System;
begin
   map_space($00, $3f, $0000, $1fff, @Memory.RAM);
   map_index($00, $3f, $2000, $3fff, MAP_PPU, 0);
   map_index($00, $3f, $4000, $5fff, MAP_CPU, 0);
   map_space($80, $bf, $0000, $1fff, @Memory.RAM);
   map_index($80, $bf, $2000, $3fff, MAP_PPU, 0);
   map_index($80, $bf, $4000, $5fff, MAP_CPU, 0);
end;

procedure map_WRAM;
begin
   map_space($7e, $7e, $0000, $ffff, @Memory.RAM);
   map_space($7f, $7f, $0000, $ffff, @Memory.RAM[$10000]);
end;

procedure map_LoROMSRAM;
var
   hi: Cardinal;
begin
   if (Memory.ROMSize > 11) or (Memory.SRAMSize > 5) then
      hi := $7fff
   else
      hi := $ffff;

   map_index($70, $7d, $0000, hi, MAP_LOROM_SRAM, 2);
   if Memory.SRAMSize > 0 then
      map_index($f0, $ff, $0000, hi, MAP_LOROM_SRAM, 2);
end;

procedure map_DSP;
begin
   // Porte da lógica de `map_DSP` de `memmap.c`
end;

procedure map_CX4;
begin
   map_index($00, $3f, $6000, $7fff, SNES.DataTypes.MAP_CX4, 0);
   map_index($80, $bf, $6000, $7fff, SNES.DataTypes.MAP_CX4, 0);
end;

procedure map_OBC1;
begin
   map_index($00, $3f, $6000, $7fff, MAP_OBC_RAM, 0);
   map_index($80, $bf, $6000, $7fff, MAP_OBC_RAM, 0);
end;

procedure map_WriteProtectROM;
var
   c: Integer;
begin
   Move(Memory.Map, Memory.WriteMap, SizeOf(Memory.Map));
   for c := 0 to MEMMAP_NUM_BLOCKS - 1 do
   begin
      if Memory.BlockIsROM[c] <> 0 then
         Memory.WriteMap[c] := Pointer(MAP_NONE);
   end;
end;

procedure Map_LoROMMap;
begin
   map_System;
   map_lorom($00, $3f, $8000, $ffff, Memory.CalculatedSize);
   map_lorom($40, $7f, $0000, $ffff, Memory.CalculatedSize);
   map_lorom($80, $bf, $8000, $ffff, Memory.CalculatedSize);
   map_lorom($c0, $ff, $0000, $ffff, Memory.CalculatedSize);

   if (Settings.Chip and CHIP_DSP) = CHIP_DSP then
      map_DSP
   else if Settings.Chip = CHIP_CX_4 then
      map_CX4
   else if Settings.Chip = CHIP_OBC_1 then
      map_OBC1;

   map_LoROMSRAM;
   map_WRAM;
   map_WriteProtectROM;
end;

// --- Implementação das Funções da Interface ---

function InitMemory: Boolean;
const
   FILL_RAM_SIZE = MAX_ROM_SIZE + $200 + $8000;
begin
   FillChar(Memory, SizeOf(TMemory), 0);
//   FillChar(Memory.FillRAM, FILL_RAM_SIZE, 0);

   // Configura os ponteiros internos para apontar para dentro do bloco FillRAM
   Memory._FillRAM_ptr := @Memory.FillRAM[0];
   Memory.ROM        := Memory._FillRAM_ptr + $8000;
   Memory.CX4RAM     := Memory.ROM + $400000 + 8192 * 8;
   Memory.OBC1RAM    := Memory.ROM + $6000;
   Memory.BIOSROM    := Memory.ROM + $300000;
   Memory.PSRAM      := Memory.ROM + $400000;

   // Inicializa o PPU e outros componentes que dependem da memória
   if not InitGFX then
   begin
      DeinitMemory;
      Exit(False);
   end;

//   if not InitAPU then
//   begin
//      DeinitMemory;
//      Exit(False);
//   end;

   Result := True;
end;

procedure DeinitMemory;
begin
//   DeinitAPU;
   DeinitGFX;
   FillChar(Memory, SizeOf(TMemory), 0);
end;

function LoadROM(const AGameData: TBytes; var AInfoBuffer: string): Boolean;
var
   TotalFileSize: Integer;
   SrcPtr: PByte;
   hi_score, lo_score: integer;
begin
   Result := False;
   TotalFileSize := Length(AGameData);
   SrcPtr := PByte(AGameData);

   if TotalFileSize = 0 then
      Exit;

   // Lógica para detectar e remover header SMC de 512 bytes
   if (TotalFileSize and $1FFF) = $200 then
   begin
      Dec(TotalFileSize, $200);
      Inc(SrcPtr, $200);
   end;

   if TotalFileSize > MAX_ROM_SIZE then
   begin
      // Lidar com erro de ROM muito grande
      Exit;
   end;

   // Copia os dados da ROM para a memória do emulador
   Move(SrcPtr^, Memory.ROM^, TotalFileSize);

   Memory.CalculatedSize := TotalFileSize and not $1FFF; // Arredonda para baixo

   // Zera o resto do espaço de ROM
   FillChar(Memory.ROM[Memory.CalculatedSize], MAX_ROM_SIZE - Memory.CalculatedSize, 0);

   // Lógica de `ScoreHiROM` e `ScoreLoROM` para detectar o tipo de mapa
   hi_score := ScoreHiROM(False, 0);
   lo_score := ScoreLoROM(False, 0);

   // (A lógica completa de detecção de formato estendido (Jumbo ROM) e desentrelaçamento (Deinterleave) seria portada aqui)

   if lo_score >= hi_score then
   begin
      Memory.LoROM := True;
      ROMHeader := Memory.ROM + $7FB0;
   end
   else
   begin
      Memory.LoROM := False;
      ROMHeader := Memory.ROM + $FFB0;
   end;

   InitROM;
   // ApplyCheats();
   Reset;

   // (A função `ROMInfo` seria chamada aqui para preencher o AInfoBuffer)
   AInfoBuffer := 'Informações da ROM...'; // Placeholder

   Result := True;
end;

procedure InitROM;
begin
   // Implementação completa de `InitROM` de `memmap.c`
   // 1. Zera BlockIsRAM/ROM
   FillChar(Memory.BlockIsRAM, SizeOf(Memory.BlockIsRAM), 0);
   FillChar(Memory.BlockIsROM, SizeOf(Memory.BlockIsROM), 0);

   // 2. Chama InitBSX para detectar se é um jogo de Satellaview
   // InitBSX();

   // 3. ParseSNESHeader(ROMHeader);
   // (A lógica de ParseSNESHeader seria portada aqui)

   // 4. Detecta e inicializa chips especiais
   // (O grande `switch` de `memmap.c` para detectar chips seria portado aqui)

   // 5. Chama a função de mapeamento apropriada
   Map_Initialize;
   if Memory.LoROM then
      Map_LoROMMap // Exemplo, a lógica real escolheria o mapa correto
   else
      ;// Map_HiROMMap;

   // 6. Configura PAL/NTSC
   Settings.PAL := (Memory.ROMRegion >= 2) and (Memory.ROMRegion <= 12);

   // 7. Calcula a máscara de SRAM
   if Memory.SRAMSize > 0 then
      Memory.SRAMMask := ((1 shl (Memory.SRAMSize + 3)) * 128) - 1
   else
      Memory.SRAMMask := 0;

   SetMainLoop;
   // 9. ApplyROMFixes;
end;

// --- Funções de Acesso à Memória Portadas de `getset.c` ---

function GetByte(Address: Cardinal): Byte;
var
   block: Integer;
   GetAddress: Pointer;
begin
   block := (Address and $ffffff) shr MEMMAP_SHIFT;
   GetAddress := Memory.Map[block];

   // Primeiro, verifica se é um ponteiro de memória direto.
   if NativeUInt(GetAddress) >= MAP_LAST then
   begin
      if Memory.BlockIsRAM[block] <> 0 then
         CPU.WaitPC := CPU.PCAtOpcodeStart;

      Result := PByte(NativeUInt(GetAddress) + (Address and $ffff))^;
      AddCyclesInMemAccess(Address);
      Exit;
   end;

   // Se não for, trata como um índice ordinal para o `case`.
   case NativeUInt(GetAddress) of
      MAP_CPU: Result := GetCPU(Address and $ffff);
      MAP_PPU: Result := GetPPU(Address and $ffff);
      MAP_LOROM_SRAM, MAP_SA1RAM: Result := Memory.SRAM[(((Address and $ff0000) shr 1) or (Address and $7fff)) and Memory.SRAMMask];
      MAP_HIROM_SRAM, MAP_RONLY_SRAM: Result := Memory.SRAM[((Address and $7fff) - $6000 + ((Address and $1f0000) shr 3)) and Memory.SRAMMask];
      MAP_BWRAM: Result := Memory.BWRAM[(Address and $7fff) - $6000];
//      MAP_DSP: Result := GetDSP(Address and $ffff);
//      MAP_SPC7110_ROM: Result := GetSPC7110Byte(Address);
//      MAP_SPC7110_DRAM:  Result := GetSPC7110($4800);
//      MAP_CX4: Result := GetCX4(Address and $ffff);
//      MAP_OBC_RAM: Result := GetOBC1(Address and $ffff);
//      MAP_SETA_DSP: Result := GetSETA(Address);
//      MAP_BSX: Result := GetBSX(Address);
//      MAP_XBAND: Result := GetXBAND(Address);
      else // MAP_NONE
         Result := ICPU.OpenBus;
   end;
   AddCyclesInMemAccess(Address);
end;

procedure SetByte(ByteValue: Byte; Address: Cardinal);
var
   block: Integer;
   SetAddress: Pointer;
begin
   block := (Address and $ffffff) shr MEMMAP_SHIFT;
   SetAddress := Memory.WriteMap[block];
   CPU.WaitPC := 0;

   if NativeUInt(SetAddress) >= MAP_LAST then
   begin
      PByte(NativeUInt(SetAddress) + (Address and $ffff))^ := ByteValue;
      AddCyclesInMemAccess(Address);
      Exit;
   end;

   case NativeUInt(SetAddress) of
      MAP_CPU: SetCPU(ByteValue, Address and $ffff);
      MAP_PPU: SetPPU(ByteValue, Address and $ffff);
      MAP_LOROM_SRAM:
         if Memory.SRAMMask <> 0 then
         begin
            Memory.SRAM[(((Address and $ff0000) shr 1) or (Address and $7fff)) and Memory.SRAMMask] := ByteValue;
            CPU.SRAMModified := True;
         end;
      MAP_HIROM_SRAM:
         if Memory.SRAMMask <> 0 then
         begin
            Memory.SRAM[((Address and $7fff) - $6000 + ((Address and $1f0000) shr 3)) and Memory.SRAMMask] := ByteValue;
            CPU.SRAMModified := True;
         end;
      MAP_BWRAM:
      begin
         Memory.BWRAM[(Address and $7fff) - $6000] := ByteValue;
         CPU.SRAMModified := True;
      end;
//      MAP_SA1RAM:
//      begin
//         Memory.SRAM[Address and $ffff] := ByteValue;
//         SA1.Executing := not SA1.Waiting;
//      end;
//      MAP_DSP: SetDSP(ByteValue, Address and $ffff);
//      MAP_CX4: SetCX4(ByteValue, Address and $ffff);
//      MAP_OBC_RAM: SetOBC1(ByteValue, Address and $ffff);
//      MAP_SETA_DSP: SetSETA(ByteValue, Address);
//      MAP_BSX: SetBSX(ByteValue, Address);
//      MAP_XBAND: SetXBAND(ByteValue, Address);
      else // MAP_NONE
         // Do nothing
   end;
      AddCyclesInMemAccess(Address);
end;

function GetWord(Address: Cardinal; w: TWrapType): Word;
var
  mask: Cardinal;
  a: TPC_t;
  block: Integer;
  GetAddress: Pointer;
begin
  mask := MEMMAP_MASK;
  case w of
    WRAP_PAGE: mask := mask and $ff;
    WRAP_BANK: mask := mask and $ffff;
  end;

  if (Address and mask) = mask then
  begin
    ICPU.OpenBus := GetByte(Address);
    Result := ICPU.OpenBus;
    case w of
      WRAP_PAGE:
      begin
        a.xPBPC := Address;
        Inc(a.PC.L);
        Result := Result or (GetByte(a.xPBPC) shl 8);
      end;
      WRAP_BANK:
      begin
        a.xPBPC := Address;
        Inc(a.PC.W);
        Result := Result or (GetByte(a.xPBPC) shl 8);
      end;
    else // WRAP_NONE
      Result := Result or (GetByte(Address + 1) shl 8);
    end;
    Exit;
  end;

  block := (Address and $ffffff) shr MEMMAP_SHIFT;
  GetAddress := Memory.Map[block];

  if NativeUInt(GetAddress) >= MAP_LAST then
  begin
    if Memory.BlockIsRAM[block] <> 0 then
      CPU.WaitPC := CPU.PCAtOpcodeStart;
    Result := PWord(NativeUInt(GetAddress) + (Address and $ffff))^;
    AddCyclesX2InMemAccess(Address);
    Exit;
  end;

  // Lógica de `case` para ponteiros especiais (omitida para brevidade, mas segue o padrão de GetByte)
  // ...
  Result := ICPU.OpenBus or (ICPU.OpenBus shl 8);
  AddCyclesX2InMemAccess(Address);
end;

procedure SetWord(WordValue: Word; Address: Cardinal; w: TWrapType; o: TWriteOrder);
var
  mask: Cardinal;
  a: TPC_t;
  block: Integer;
  SetAddress: Pointer;
begin
  mask := MEMMAP_MASK;
  case w of
    WRAP_PAGE: mask := mask and $ff;
    WRAP_BANK: mask := mask and $ffff;
  end;

  if (Address and mask) = mask then
  begin
    if o = WRITE_01 then
      SetByte(Byte(WordValue), Address)
    else
      SetByte(Byte(WordValue shr 8), Address + 1); // Simplificado, a lógica de wrap é mais complexa

    if o = WRITE_10 then
      SetByte(Byte(WordValue), Address)
    else
      SetByte(Byte(WordValue shr 8), Address + 1); // Simplificado

    Exit;
  end;

  CPU.WaitPC := 0;
  block := (Address and $ffffff) shr MEMMAP_SHIFT;
  SetAddress := Memory.WriteMap[block];

  if NativeUInt(SetAddress) >= MAP_LAST then
  begin
    PWord(NativeUInt(SetAddress) + (Address and $ffff))^ := WordValue;
    AddCyclesX2InMemAccess(Address);
    Exit;
  end;

  // Lógica de `case` para ponteiros especiais (omitida para brevidade, mas segue o padrão de SetByte)
  AddCyclesX2InMemAccess(Address);
end;

function GetBasePointer(Address: Cardinal): PByte;
var
  GetAddress: Pointer;
begin
  GetAddress := Memory.Map[(Address and $ffffff) shr MEMMAP_SHIFT];

  if NativeUInt(GetAddress) >= MAP_LAST then
  begin
    Result := PByte(GetAddress);
    Exit;
  end;

  case NativeUInt(GetAddress) of
    MAP_CPU, MAP_PPU: Result := @Memory.FillRAM[0];
    MAP_LOROM_SRAM:
      if (Memory.SRAMMask and MEMMAP_MASK) <> MEMMAP_MASK then
         Result := nil
      else
         Result := @Memory.SRAM[0];
    // ... e assim por diante para os outros tipos de mapa
  else
    Result := nil;
  end;
end;

function GetMemPointer(Address: Cardinal): PByte;
var
  GetAddress: Pointer;
begin
  GetAddress := Memory.Map[(Address and $ffffff) shr MEMMAP_SHIFT];

  if NativeUInt(GetAddress) >= MAP_LAST then
  begin
    Result := PByte(NativeUInt(GetAddress) + (Address and $ffff));
    Exit;
  end;

  case NativeUInt(GetAddress) of
    MAP_CPU, MAP_PPU: Result := @Memory.FillRAM[Address and $7fff];
    // ... e assim por diante para os outros tipos de mapa
  else
    Result := nil;
  end;
end;

procedure SetPCBase(Address: Cardinal);
begin
   ICPU.Registers.PCw.xPBPC := Address and $ffffff;
   ICPU.ShiftedPB := Address and $ff0000;
   CPU.MemSpeed := memory_speed(Address);
   CPU.MemSpeedx2 := CPU.MemSpeed shl 1;
   CPU.PCBase := GetBasePointer(Address);
end;

end.