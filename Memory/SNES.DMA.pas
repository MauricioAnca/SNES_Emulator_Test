unit SNES.DMA;

interface

uses
   SNES.DataTypes,
   SNES.Globals;

var
   HDMAMemPointers: array[0..7] of PByte;
   HDMABasePointers: array[0..7] of PByte;

const
   HDMA_ModeByteCounts: array[0..7] of Integer = (1, 2, 2, 4, 4, 4, 2, 4);

procedure ResetDMA;
procedure StartHDMA;
function DoHDMA(byteValue: Byte): Byte;
procedure DoDMA(Channel: Byte);

implementation

uses
   System.SysUtils,
   SNES.Memory,
   SNES.CPU,
   SNES.PPU,
//  SNES.APU,
   SNES.GFX;
//  SNES.Chips.SA1,
//  SNES.Chips.SDD1,
//  SNES.Chips.SPC7110;

// Forward declarations para as rotinas que estão em SNES.CPU.pas
procedure DoHBlankProcessing_NoSFX; forward;
procedure DoHBlankProcessing_SFX; forward;

var
   sdd1_decode_buffer: array[0..$FFFF] of Byte;

procedure HBlankProcessingLoop;
begin
   // A lógica original de cpuexec.c chama um loop.
   // Aqui, vamos apenas chamar o procedimento de processamento uma vez se necessário.
   if CPU.Cycles >= CPU.NextEvent then
   begin
      // *** CORREÇÃO APLICADA AQUI ***
      // Usando a constante CHIP_GSU declarada em SNES.DataTypes.pas
      if Settings.Chip = CHIP_GSU then
         DoHBlankProcessing_SFX
      else
         DoHBlankProcessing_NoSFX;
   end;
end;


procedure ResetDMA;
var
   d: Integer;
begin
   for d := 0 to 7 do
   begin
      DMA[d].ReverseTransfer := True;
      DMA[d].HDMAIndirectAddressing := True;
      DMA[d].AAddressFixed := True;
      DMA[d].AAddressDecrement := True;
      DMA[d].TransferMode := 7;
      DMA[d].AAddress := $ffff;
      DMA[d].BAddress := $ff;
      DMA[d].ABank := $ff;
      DMA[d].Address := $ffff;
      DMA[d].TransferBytes := $ffff;
      DMA[d].IndirectAddress := $ffff;
   end;
end;

procedure StartHDMA;
var
   i: Byte;
begin
   IPPU.HDMA := Memory.FillRAM[$420c];

   if IPPU.HDMA <> 0 then
      CPU.Cycles := CPU.Cycles + Settings.SlowOneCycle * 3;

   for i := 0 to 7 do
   begin
      if (IPPU.HDMA and (1 shl i)) <> 0 then
      begin
         CPU.Cycles := CPU.Cycles + Settings.SlowOneCycle;
         DMA[i].LineCount := 0;
         DMA[i].FirstLine := True;
         DMA[i].Address := DMA[i].AAddress;

         if DMA[i].HDMAIndirectAddressing then
            CPU.Cycles := CPU.Cycles + (Settings.SlowOneCycle shl 2);
      end;
      HDMAMemPointers[i] := nil;
   end;
end;

function DoHDMA(byteValue: Byte): Byte;
var
   mask: Byte;
   p: ^TSDMA;
   d: Integer;
begin
   Result := byteValue;
   CPU.InDMA := True;
   CPU.Cycles := CPU.Cycles + Settings.OneCycle * 3;

   d := 0;
   mask := 1;
   p := @DMA[0];
   while mask <> 0 do
   begin
      if (Result and mask) <> 0 then
      begin
         if p.LineCount = 0 then
         begin
            var line := GetByte((p.ABank shl 16) or p.Address);
            CPU.Cycles := CPU.Cycles + Settings.SlowOneCycle;

            if line = $80 then
            begin
               p.Repeat_ := True;
               p.LineCount := 128;
            end
            else
            begin
               p.Repeat_ := (line and $80) = 0;
               p.LineCount := line and $7f;
            end;

            if (p.LineCount = 0) or (p.BAddress = $18) then
            begin
               Result := Result and not mask;
               Inc(p.IndirectAddress, NativeUInt(HDMAMemPointers[d]) - NativeUInt(HDMABasePointers[d]));
               Memory.FillRAM[$4305 + (d shl 4)] := Byte(p.IndirectAddress);
               Memory.FillRAM[$4306 + (d shl 4)] := p.IndirectAddress shr 8;
               Continue;
            end;

            Inc(p.Address);
            p.FirstLine := True;

            if p.HDMAIndirectAddressing then
            begin
               p.IndirectBank := Memory.FillRAM[$4307 + (d shl 4)];
               CPU.Cycles := CPU.Cycles + (Settings.SlowOneCycle shl 2);
               p.IndirectAddress := GetWord((p.ABank shl 16) or p.Address, WRAP_NONE);
               Inc(p.Address, 2);
            end
            else
            begin
               p.IndirectBank := p.ABank;
               p.IndirectAddress := p.Address;
            end;

            HDMABasePointers[d] := GetMemPointer((p.IndirectBank shl 16) or p.IndirectAddress);
            HDMAMemPointers[d] := HDMABasePointers[d];
         end
         else
            CPU.Cycles := CPU.Cycles + Settings.SlowOneCycle;

         if HDMAMemPointers[d] = nil then
         begin
            if not p.HDMAIndirectAddressing then
            begin
               p.IndirectBank := p.ABank;
               p.IndirectAddress := p.Address;
            end;
            HDMABasePointers[d] := GetMemPointer((p.IndirectBank shl 16) or p.IndirectAddress);
            HDMAMemPointers[d] := HDMABasePointers[d];
            if HDMABasePointers[d] = nil then
            begin
               Result := Result and not mask;
               Continue;
            end;
         end;

         if p.Repeat_ and not p.FirstLine then
         begin
            Dec(p.LineCount);
            Continue;
         end;

         case p.TransferMode of
            0:
            begin
               SetPPU(HDMAMemPointers[d]^, $2100 + p.BAddress);
               Inc(HDMAMemPointers[d]);
               CPU.Cycles := CPU.Cycles + Settings.SlowOneCycle;
            end;
            1, 5:
            begin
               SetPPU(HDMAMemPointers[d]^, $2100 + p.BAddress);
               CPU.Cycles := CPU.Cycles + Settings.SlowOneCycle;
               SetPPU(HDMAMemPointers[d][1], $2101 + p.BAddress);
               CPU.Cycles := CPU.Cycles + Settings.SlowOneCycle;
               Inc(HDMAMemPointers[d], 2);
               if p.TransferMode = 5 then
               begin
                  SetPPU(HDMAMemPointers[d][0], $2100 + p.BAddress);
                  CPU.Cycles := CPU.Cycles + Settings.SlowOneCycle;
                  SetPPU(HDMAMemPointers[d][1], $2101 + p.BAddress);
                  CPU.Cycles := CPU.Cycles + Settings.SlowOneCycle;
                  Inc(HDMAMemPointers[d], 2);
               end;
            end;
            2, 6:
            begin
               SetPPU(HDMAMemPointers[d][0], $2100 + p.BAddress);
               CPU.Cycles := CPU.Cycles + Settings.SlowOneCycle;
               SetPPU(HDMAMemPointers[d][1], $2100 + p.BAddress);
               CPU.Cycles := CPU.Cycles + Settings.SlowOneCycle;
               Inc(HDMAMemPointers[d], 2);
            end;
            3, 7:
            begin
               SetPPU(HDMAMemPointers[d][0], $2100 + p.BAddress);
               CPU.Cycles := CPU.Cycles + Settings.SlowOneCycle;
               SetPPU(HDMAMemPointers[d][1], $2100 + p.BAddress);
               CPU.Cycles := CPU.Cycles + Settings.SlowOneCycle;
               SetPPU(HDMAMemPointers[d][2], $2101 + p.BAddress);
               CPU.Cycles := CPU.Cycles + Settings.SlowOneCycle;
               SetPPU(HDMAMemPointers[d][3], $2101 + p.BAddress);
               CPU.Cycles := CPU.Cycles + Settings.SlowOneCycle;
               Inc(HDMAMemPointers[d], 4);
            end;
            4:
            begin
               SetPPU(HDMAMemPointers[d][0], $2100 + p.BAddress);
               CPU.Cycles := CPU.Cycles + Settings.SlowOneCycle;
               SetPPU(HDMAMemPointers[d][1], $2101 + p.BAddress);
               CPU.Cycles := CPU.Cycles + Settings.SlowOneCycle;
               SetPPU(HDMAMemPointers[d][2], $2102 + p.BAddress);
               CPU.Cycles := CPU.Cycles + Settings.SlowOneCycle;
               SetPPU(HDMAMemPointers[d][3], $2103 + p.BAddress);
               CPU.Cycles := CPU.Cycles + Settings.SlowOneCycle;
               Inc(HDMAMemPointers[d], 4);
            end;
         end;

         if not p.HDMAIndirectAddressing then
            Inc(p.Address, HDMA_ModeByteCounts[p.TransferMode]);

         Inc(p.IndirectAddress, HDMA_ModeByteCounts[p.TransferMode]);
         p.FirstLine := False;
         Dec(p.LineCount);
      end;

      mask := mask shl 1;
      Inc(d);
      Inc(p);
   end;
   CPU.InDMA := False;
end;

procedure DoDMA(Channel: Byte);
var
   d: ^TSDMA;
   count, _inc: Integer;
   Work: Byte;
   in_sa1_dma: Boolean;
   in_sdd1_dma: PByte;
   spc7110_dma: PByte;
   p: Word;
   base: PByte;
begin
   if (Channel > 7) or CPU.InDMA then
      Exit;

   in_sa1_dma := False;
   in_sdd1_dma := nil;
   spc7110_dma := nil;

   CPU.InDMA := True;
   d := @DMA[Channel];
   count := d.TransferBytes;

   if count = 0 then
      count := $10000;

   if d.AAddressFixed then
      _inc := 0
   else if not d.AAddressDecrement then
      _inc := 1
   else
      _inc := -1;

   // ... (Porte da lógica de DMA de chips especiais: S-DD1, SPC7110, SA-1)

   if not d.ReverseTransfer then
   begin
      // Caminho principal: CPU para PPU
      p := d.AAddress;
      base := GetBasePointer((d.ABank shl 16) or d.AAddress);
      CPU.Cycles := CPU.Cycles + Settings.SlowOneCycle * (count + 1);

      if base = nil then base := Memory.ROM;

      // (Lógica para redirecionar `base` para buffers de chips especiais aqui)

      if _inc > 0 then
         Inc(d.AAddress, count)
      else if _inc < 0 then
         Dec(d.AAddress, count);

      case d.TransferMode of
         0, 2, 6:
         begin
            case d.BAddress of
               $04: // OAMDATA
               while count > 0 do
               begin
                  REGISTER_2104(base[p]);
                  Inc(p, _inc); Dec(count);
               end;
               $18: // VMDATAL
               begin
                  IPPU.FirstVRAMRead := True;
                  // (lógica de VRAM tile/linear)
               end;
               // (outros registradores PPU)
               else
               while count > 0 do
               begin
                  SetPPU(base[p], $2100 + d.BAddress);
                  Inc(p, _inc);
                  Dec(count);
               end;
            end;
         end;
         1, 5:
         begin
            // ... (lógica para modos de transferência de 2 bytes)
         end;
         3, 7:
         begin
            // ... (lógica para modos de transferência de 4 bytes)
         end;
         4:
         begin
            // ... (lógica para modos de transferência de 4 bytes para registradores sequenciais)
         end;
         end;
      end
   else
   begin
      // Caminho reverso: PPU para CPU
      repeat
         case d.TransferMode of
            0, 2, 6:
            begin
               Work := GetPPU($2100 + d.BAddress);
               SetByte(Work, (d.ABank shl 16) or d.AAddress);
               Inc(d.AAddress, _inc);
               Dec(count);
            end;
            // ... (lógica para outros modos de transferência reversa)
            else
               count := 0;
         end;
      until count = 0;
   end;

   HBlankProcessingLoop;

   // Atualiza os registradores de DMA na RAM
   Memory.FillRAM[$4302 + (Channel shl 4)] := Byte(d.AAddress);
   Memory.FillRAM[$4303 + (Channel shl 4)] := d.AAddress shr 8;
   Memory.FillRAM[$4305 + (Channel shl 4)] := 0;
   Memory.FillRAM[$4306 + (Channel shl 4)] := 0;

   DMA[Channel].IndirectAddress := 0;
   d.TransferBytes := 0;
   CPU.InDMA := False;
end;

procedure DoHBlankProcessing_NoSFX;
begin

end;

procedure DoHBlankProcessing_SFX;
begin

end;

end.
