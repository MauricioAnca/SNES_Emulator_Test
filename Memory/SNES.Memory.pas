unit SNES.Memory;

interface

uses
  System.SysUtils, System.AnsiStrings,
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
   SNES.PPU, SNES.CPU, SNES.GFX,
   SNES.APU;
//   SNES.Chips.DSP,
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
   if not Settings.GetSetDMATimingHacks and (CPU.InDMA or IPPU.HDMA) then
      Exit;
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

procedure DeinterleaveType1(size: Integer; base: PByte);
var
   i, j: Integer;
   blocks: array[0..255] of Byte;
   tmp: PByte;
   nblocks: Integer;
   b: Byte;
begin
   nblocks := size shr 15; // size / 32768
   if nblocks = 0 then
      Exit;

   j := 0;
   i := 0;
   while i < nblocks do
   begin
      blocks[i] := j + nblocks;
      blocks[i + 1] := j;
      Inc(j);
      Inc(i, 2); // Incrementa o contador 'i' por 2 a cada iteração
   end;

   GetMem(tmp, $8000);
   try
      for i := 0 to nblocks - 1 do
      begin
         for j := i to nblocks - 1 do
         begin
            if blocks[j] <> i then
               Continue;

            // Troca os blocos de memória para a ordem correta
            Move((base + blocks[j] * $8000)^, tmp^, $8000);
            Move((base + blocks[i] * $8000)^, (base + blocks[j] * $8000)^, $8000);
            Move(tmp^, (base + i * $8000)^, $8000);

            // Atualiza o array de controle da troca
            b := blocks[j];
            blocks[j] := blocks[i];
            blocks[i] := b;
            break; // Sai do loop interno 'j'
         end;
      end;
   finally
      FreeMem(tmp);
   end;
end;

procedure DeinterleaveGD24(size: Integer; base: PByte);
var
   tmp: PByte;
begin
   // Específico para ROMs de 24Mbit (como Star Ocean)
   if size <> $300000 then
      Exit;

   GetMem(tmp, $80000);
   try
      // Reorganiza os grandes blocos de 512KB
      Move((base + $180000)^, tmp^, $80000);
      Move((base + $200000)^, (base + $180000)^, $80000);
      Move((base + $280000)^, (base + $200000)^, $80000);
      Move(tmp^, (base + $280000)^, $80000);
   finally
      FreeMem(tmp);
   end;

   // Após a reorganização inicial, aplica o desentrelaçamento padrão
   DeinterleaveType1(size, base);
end;

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

procedure map_hirom(bank_s, bank_e, addr_s, addr_e, size: Cardinal);
var
   c, i, p, addr: Cardinal;
begin
   for c := bank_s to bank_e do
   begin
      i := addr_s;
      while i <= addr_e do
      begin
         p := (c shl 4) or (i shr 12);
         addr := c shl 16;
         Memory.Map[p] := Memory.ROM + map_mirror(size, addr);
         Memory.BlockIsROM[p] := 1;
         Memory.BlockIsRAM[p] := 0;
         Inc(i, MEMMAP_BLOCK_SIZE);
      end;
   end;
end;

procedure map_hirom_offset(bank_s, bank_e, addr_s, addr_e, size, offset: Cardinal);
var
   c, i, p, addr: Cardinal;
begin
   for c := bank_s to bank_e do
   begin
      i := addr_s;
      while i <= addr_e do
      begin
         p := (c shl 4) or (i shr 12);
         addr := (c - bank_s) shl 16;
         Memory.Map[p] := Memory.ROM + offset + map_mirror(size, addr);
         Memory.BlockIsROM[p] := 1;
         Memory.BlockIsRAM[p] := 0;
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

procedure map_HiROMSRAM;
begin
   // Mapeia a SRAM em bancos de $20-$3F e $A0-$BF, no range $6000-$7FFF
   map_index($20, $3F, $6000, $7FFF, MAP_HIROM_SRAM, 2); // 2 = MAP_TYPE_RAM
   map_index($A0, $BF, $6000, $7FFF, MAP_HIROM_SRAM, 2); // 2 = MAP_TYPE_RAM
end;

procedure map__XBAND;
var
   c: Integer;
begin
   // O modem XBAND mapeia sua própria RAM nos bancos $E0-$FF
   for c := 0 to $1FF do // Corresponde a 512 blocos de 4KB
   begin
      Memory.Map[c + $E00] := Pointer(MAP_XBAND);
      Memory.BlockIsRAM[c + $E00] := 1;
      Memory.BlockIsROM[c + $E00] := 0;
   end;
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

procedure Map_HiROMMap;
begin
   map_System; // Mapeia WRAM e registradores I/O básicos

   // Mapeia a ROM HiROM.
   // Bancos $00-$3F e $80-$BF, de $8000-$FFFF (metade superior dos bancos)
   map_hirom($00, $3F, $8000, $FFFF, Memory.CalculatedSize);
   map_hirom($80, $BF, $8000, $FFFF, Memory.CalculatedSize);

   // Bancos $40-$7F e $C0-$FF, de $0000-$FFFF (bancos inteiros)
   map_hirom($40, $7F, $0000, $FFFF, Memory.CalculatedSize);
   map_hirom($C0, $FF, $0000, $FFFF, Memory.CalculatedSize);

   // Verifica se há chips especiais que alteram o mapa
   if (Settings.Chip and CHIP_DSP) = CHIP_DSP then
      map_DSP
   else if (Settings.Chip and CHIP_XBAND) = CHIP_XBAND then
      map__XBAND;

   // Mapeia a SRAM
   map_HiROMSRAM;

   // Mapeia a WRAM sobrepondo as áreas necessárias
   map_WRAM;

   // Protege as áreas de ROM contra escrita
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

   if not InitAPU then
   begin
      DeinitMemory;
      Exit(False);
   end;

   Result := True;
end;

procedure DeinitMemory;
begin
   DeinitAPU;
   DeinitGFX;
   FillChar(Memory, SizeOf(TMemory), 0);
end;

procedure ParseSNESHeader(RomHeader: PByte);
var
   size_count: Cardinal;
   l, r, l2, r2: Integer;
begin
   if (Settings.Chip and CHIP_BS) = CHIP_BS then
   begin
      Memory.SRAMSize := $05;
      // strncpy equivalent
      System.SysUtils.StrLCopy(Memory.ROMName, PAnsiChar(RomHeader + $10), 17);
      FillChar(Memory.ROMName[17], ROM_NAME_LEN - 1 - 17, #0);
      Memory.ROMSpeed := RomHeader[$28];
      Memory.ROMType := $e5;
      Memory.ROMSize := 1;

      size_count := $800;
      while size_count < Memory.CalculatedSize do
      begin
         size_count := size_count shl 1;
         Inc(Memory.ROMSize);
      end;
   end
   else
   begin
      Memory.SRAMSize := RomHeader[$28];
      System.SysUtils.StrLCopy(Memory.ROMName, PAnsiChar(RomHeader + $10), ROM_NAME_LEN);
      Memory.ROMSpeed := RomHeader[$25];
      Memory.ROMType := RomHeader[$26];
      Memory.ROMSize := RomHeader[$27];
   end;

   Memory.ROMRegion := RomHeader[$29];
   Move((RomHeader + $02)^, Memory.ROMId[0], ROM_ID_LEN - 1);

   if RomHeader[$2A] <> $33 then
   begin
      Memory.CompanyId := ((RomHeader[$2A] shr 4) and $0F) * 36 + (RomHeader[$2A] and $0F);
   end
   else if IsLetterOrDigit(Char(RomHeader[$00])) and IsLetterOrDigit(Char(RomHeader[$01])) then
   begin
      l := Ord(UpCase(AnsiChar(RomHeader[$00])));
      r := Ord(UpCase(AnsiChar(RomHeader[$01])));
      if l > Ord('9') then
         l2 := l - Ord('7')
      else
         l2 := l - Ord('0');
      if r > Ord('9') then
         r2 := r - Ord('7')
      else
         r2 := r - Ord('0');
      Memory.CompanyId := l2 * 36 + r2;
   end;
end;

function LoadROM(const AGameData: TBytes; var AInfoBuffer: string): Boolean;
var
   TotalFileSize: Integer;
   SrcPtr: PByte;
   hi_score, lo_score: integer;
   // Variáveis para a lógica de desentrelaçamento (deinterleave)
   Interleaved: Boolean;
   Tales: Boolean;
   // Variável para a lógica de ROMs Jumbo (não portada ainda, mas preparada)
   // loromscore, hiromscore, swappedlorom, swappedhirom: Integer;
begin
   Result := False;
   TotalFileSize := Length(AGameData);
   if TotalFileSize = 0 then
      Exit;

   // A DeinitSPC7110() do C estaria aqui, se portada.

   Memory.CalculatedSize := 0;
   Memory.HeaderCount := 0;
   Memory.ExtendedFormat := 0; // NOPE

   SrcPtr := PByte(AGameData);

   // Lógica para detectar e remover o header SMC de 512 bytes
   if (TotalFileSize and $1FFF) = $200 then
   begin
      Dec(TotalFileSize, $200);
      Inc(SrcPtr, $200);
      Memory.HeaderCount := 1;
   end;

   if TotalFileSize > MAX_ROM_SIZE then
   begin
      AInfoBuffer := 'Erro: ROM excede o tamanho máximo suportado.';
      Exit;
   end;

   // Copia os dados da ROM para a memória do emulador
   Move(SrcPtr^, Memory.ROM^, TotalFileSize);

   // Arredonda o tamanho calculado para o múltiplo de $2000 mais próximo
   Memory.CalculatedSize := TotalFileSize and not $1FFF;

   // Zera o resto do espaço de ROM não utilizado para evitar dados "lixo"
   FillChar(Memory.ROM[Memory.CalculatedSize], MAX_ROM_SIZE - Memory.CalculatedSize, 0);

   // Pontua a ROM para determinar se é LoROM ou HiROM
   hi_score := ScoreHiROM(False, 0);
   lo_score := ScoreLoROM(False, 0);

   // TODO: Adicionar lógica para formatos extendidos (Jumbo ROMs) aqui, se necessário.
   // Por enquanto, seguimos a lógica simples.

   if lo_score >= hi_score then
      Memory.LoROM := True
   else
      Memory.LoROM := False;

   // Lógica de detecção de formato "interleaved" (entralaçado)
   Interleaved := False;
   Tales := False;
   if Memory.LoROM then
   begin
      if ((Memory.ROM[$7FD5] and $F0) = $20) or ((Memory.ROM[$7FD5] and $F0) = $30) then
         case (Memory.ROM[$7FD5] and $F) of
            5: Tales := True; // Tales of Phantasia
            1: Interleaved := True;
         end;
   end
   else // HiROM
   begin
      if ((Memory.ROM[$FFD5] and $F0) = $20) or ((Memory.ROM[$FFD5] and $F0) = $30) then
         case (Memory.ROM[$FFD5] and $F) of
            0, 3: Interleaved := True;
         end;
   end;

    if Interleaved then
   begin
      if Tales then // Tratamento especial para Tales of Phantasia
      begin
         // A lógica para 'Tales' é mais complexa devido ao formato Jumbo
         // E também inverte o tipo de mapa de memória
         // if Memory.ExtendedFormat = BIGFIRST then
         // begin
         //   DeinterleaveType1($400000, Memory.ROM);
         //   DeinterleaveType1(Memory.CalculatedSize - $400000, Memory.ROM + $400000);
         // end
         // else
         // begin
         //   DeinterleaveType1(Memory.CalculatedSize - $400000, Memory.ROM);
         //   DeinterleaveType1($400000, Memory.ROM + Memory.CalculatedSize - $400000);
         // end;
         Memory.LoROM := False; // Tales é HiROM após o processo
      end
      else if Memory.CalculatedSize = $300000 then // Star Ocean (GD24)
      begin
         Memory.LoROM := not Memory.LoROM;
         DeinterleaveGD24(Memory.CalculatedSize, Memory.ROM);
      end
      else // Formato padrão Type1
      begin
         Memory.LoROM := not Memory.LoROM;
         DeinterleaveType1(Memory.CalculatedSize, Memory.ROM);
      end;
   end;

   // Inicializa o mapa de memória e o hardware com base na ROM carregada
   InitROM;

   // TODO: Portar a lógica de `ApplyCheats` se for usar cheats.
   // ApplyCheats();

   // Reseta o estado do emulador para o novo jogo
   Reset;

   // TODO: Portar a função `ROMInfo` para preencher o buffer de informações.
   AInfoBuffer := 'ROM carregada com sucesso. (Info a ser implementada)';

   Result := True;
end;

procedure InitROM;
var
   RomHeader: PByte;
begin
   // --- Início da lógica de InitROM ---
   Settings.Chip := CHIP_NOCHIP;
   // SuperFX.nRomBanks := Memory.CalculatedSize shr 15; // Lógica do SuperFX será em sua própria unit

   // Define o ponteiro para o cabeçalho com base no formato da ROM
   RomHeader := @Memory.ROM[$7FB0];
   // if Memory.ExtendedFormat = BIGFIRST then Inc(RomHeader, $400000); // Lógica para ROMs Jumbo
   if not Memory.LoROM then
      Inc(RomHeader, $8000);

   FillChar(Memory.BlockIsRAM, SizeOf(Memory.BlockIsRAM), 0);
   FillChar(Memory.BlockIsROM, SizeOf(Memory.BlockIsROM), 0);
   Memory.ROMId[ROM_ID_LEN - 1] := #0;
   Memory.CompanyId := 0;

   // InitBSX(); // TODO: Portar lógica de detecção BSX
   ParseSNESHeader(RomHeader);

   // --- Detecção de Chips Especiais ---
   if Memory.ROMType = $03 then // DSP1/2/3/4
   begin
      if Memory.ROMSpeed = $30 then
         Settings.Chip := CHIP_DSP_4
      else
         Settings.Chip := CHIP_DSP_1;
   end
   else if Memory.ROMType = $05 then
   begin
      if Memory.ROMSpeed = $20 then
         Settings.Chip := CHIP_DSP_2
      else if (Memory.ROMSpeed = $30) and (RomHeader[$2a] = $b2) then
         Settings.Chip := CHIP_DSP_3
      else
         Settings.Chip := CHIP_DSP_1;
   end;

   // TODO: Portar a configuração do DSP (SetDSP/GetDSP) na unit do DSP
   // case Settings.Chip of
   //   CHIP_DSP_1: ...
   //   CHIP_DSP_2: ...
   // end;

   // Detecção baseada na combinação de Tipo e Velocidade
   case (Memory.ROMType shl 8) or Memory.ROMSpeed of
      $5535: begin
         Settings.Chip := CHIP_S_RTC;
         // InitSRTC();
      end;
      $F93A: begin
         Settings.Chip := CHIP_SPC7110RTC;
         // InitSPC7110();
      end;
      $F53A: begin
         Settings.Chip := CHIP_SPC7110;
         // InitSPC7110();
      end;
      $2530: Settings.Chip := CHIP_OBC_1;
      $3423, $3523: Settings.Chip := CHIP_SA_1;
      $1320, $1420, $1520, $1A20, $1330, $1430, $1530, $1A30:
      begin
         Settings.Chip := CHIP_GSU;
         if RomHeader[$2A] = $33 then // Corrigido de 0x7FDA para offset relativo
            Memory.SRAMSize := RomHeader[$0D] // 0x7FBD - 0x7FB0
         else
            Memory.SRAMSize := 5;
      end;
      $4332, $4532: Settings.Chip := CHIP_S_DD1;
      $F530:
      begin
         Settings.Chip := CHIP_ST_018;
         // SetSETA := @NullSet; GetSETA := @NullGet;
         Memory.SRAMSize := 2;
      end;
      $F630:
      begin
         if RomHeader[$27] = $09 then // 0x7FD7 - 0x7FB0
         begin
            Settings.Chip := CHIP_ST_011;
            // SetSETA := @NullSet; GetSETA := @NullGet;
         end
         else
         begin
            Settings.Chip := CHIP_ST_010;
            // SetSETA := @SetST010; GetSETA := @GetST010;
         end;
         Memory.SRAMSize := 2;
      end;
      $F320: Settings.Chip := CHIP_CX_4;
   end;

   // --- Seleção e Construção do Mapa de Memória ---
   Map_Initialize;

   if (Settings.Chip and CHIP_BS) = CHIP_BS then
   begin
      // Lógica para BS-X
   end
   else if Memory.LoROM then
   begin
      // if (Settings.Chip = CHIP_ST_010) or (Settings.Chip = CHIP_ST_011) then
      //   Map_SetaDSPLoROMMap
      // else if Settings.Chip = CHIP_GSU then
      //   Map_SuperFXLoROMMap
      // else if Settings.Chip = CHIP_SA_1 then
      //   Map_SA1LoROMMap
      // else if Settings.Chip = CHIP_S_DD1 then
      //   Map_SDD1LoROMMap
      // ... (outros mapas especiais LoROM)
      // else
      Map_LoROMMap; // O mapa padrão para LoROM
   end
   else // HiROM
   begin
      // if (Settings.Chip and CHIP_SPC7110) = CHIP_SPC7110 then
      //   Map_SPC7110HiROMMap
      // else if (Settings.Chip and CHIP_XBAND) = CHIP_XBAND then
      //   Map__XBAND
      // else
      Map_HiROMMap; // O mapa padrão para HiROM
   end;

   // --- Finalização ---
   Settings.PAL := ((Settings.Chip and CHIP_BS) <> CHIP_BS) and (((Memory.ROMRegion >= 2) and (Memory.ROMRegion <= 12)) or (Memory.ROMRegion = 18));

   // Garante que o nome da ROM seja nulo-terminado
   Memory.ROMName[High(Memory.ROMName)] := #0;

   // Remove espaços em branco do final do nome da ROM
   // (Lógica de trim omitida, mas pode ser adicionada se necessário)

   if Memory.SRAMSize > 0 then
      Memory.SRAMMask := ((1 shl (Memory.SRAMSize + 3)) * 128) - 1
   else
      Memory.SRAMMask := 0;

   SetMainLoop;
   // ApplyROMFixes; // TODO: Portar correções específicas de jogos
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
//      MAP__XBAND: Result := GetXBAND(Address);
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
//      MAP__XBAND: SetXBAND(ByteValue, Address);
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
  low_byte, high_byte: Byte;
begin
  mask := $FFFFFFFF; // Equivalente a MEMMAP_MAX_ADDRESS
  case w of
    WRAP_PAGE: mask := mask and $ff;
    WRAP_BANK: mask := mask and $ffff;
  end;

  // Primeiro, verifica se a leitura de 16-bits não cruzará uma fronteira de wrap.
  if (Address and mask) <> mask then
  begin
    // Se não cruza a fronteira, a leitura pode ser otimizada.
    block := (Address and $ffffff) shr MEMMAP_SHIFT;
    GetAddress := Memory.Map[block];

    // Se for um ponteiro de memória direto (RAM ou ROM), lê os 16 bits de uma vez.
    if NativeUInt(GetAddress) >= MAP_LAST then
    begin
      if Memory.BlockIsRAM[block] <> 0 then
        CPU.WaitPC := CPU.PCAtOpcodeStart;

      Result := PWord(NativeUInt(GetAddress) + (Address and $ffff))^;
      AddCyclesX2InMemAccess(Address);
      Exit;
    end;
  end;

  // Se a leitura cruza uma fronteira de wrap OU se é uma área de registradores, devemos ler byte por byte obrigatoriamente.
  low_byte := GetByte(Address);

  // Calcula o endereço do segundo byte, respeitando o wrap.
  case w of
    WRAP_PAGE:
    begin
      a.xPBPC := Address;
      Inc(a.PC.L); // Incrementa apenas o byte baixo do PC, mantendo o banco.
      high_byte := GetByte(a.xPBPC);
    end;
    WRAP_BANK:
    begin
      a.xPBPC := Address;
      Inc(a.PC.W); // Incrementa o Word do PC, mantendo o banco.
      high_byte := GetByte(a.xPBPC);
    end;
  else // WRAP_NONE
    high_byte := GetByte(Address + 1);
  end;

  Result := low_byte or (high_byte shl 8);
end;

procedure SetWord(WordValue: Word; Address: Cardinal; w: TWrapType; o: TWriteOrder);
var
  mask: Cardinal;
  a: TPC_t;
  block: Integer;
  SetAddress: Pointer;
  low_byte, high_byte: Byte;
  addr2: Cardinal;
begin
   mask := $FFFFFFFF; // Equivalente a MEMMAP_MAX_ADDRESS
   case w of
      WRAP_PAGE: mask := mask and $ff;
      WRAP_BANK: mask := mask and $ffff;
   end;

   // Prepara os bytes com base na ordem de escrita
   if o = WRITE_01 then // LSB primeiro, MSB depois
   begin
      low_byte := Byte(WordValue);
      high_byte := Byte(WordValue shr 8);
   end
   else // WRITE_10: MSB primeiro, LSB depois
   begin
      high_byte := Byte(WordValue);
      low_byte := Byte(WordValue shr 8);
   end;

   // Tenta o "caminho rápido" (escrita direta de 16 bits)
   // Isso só é possível se não cruzar uma fronteira de wrap e se o destino for memória direta.
   if (Address and mask) <> mask then
   begin
      CPU.WaitPC := 0;
      block := (Address and $ffffff) shr MEMMAP_SHIFT;
      SetAddress := Memory.WriteMap[block];

      // Verifica se o endereço aponta para RAM/SRAM (não ROM ou I/O)
      if NativeUInt(SetAddress) >= MAP_LAST then
      begin
         PWord(NativeUInt(SetAddress) + (Address and $ffff))^ := WordValue;
         AddCyclesX2InMemAccess(Address);
         Exit;
      end;
   end;

   // Se o caminho rápido não for possível, recorre ao "caminho seguro" (byte a byte)
   // Calcula o endereço do segundo byte, respeitando o wrap
   case w of
      WRAP_PAGE:
      begin
         a.xPBPC := Address;
         Inc(a.PC.L);
         addr2 := a.xPBPC;
      end;
      WRAP_BANK:
      begin
         a.xPBPC := Address;
         Inc(a.PC.W);
         addr2 := a.xPBPC;
      end;
      else // WRAP_NONE
         addr2 := Address + 1;
   end;

   // Escreve os bytes na ordem correta
   if o = WRITE_01 then
   begin
      SetByte(low_byte, Address);
      SetByte(high_byte, addr2);
   end
   else // WRITE_10
   begin
      SetByte(high_byte, Address);
      SetByte(low_byte, addr2);
   end;
end;

function GetBasePointer(Address: Cardinal): PByte;
var
   GetAddress: Pointer;
   block: Cardinal;
begin
   block := (Address and $FFFFFF) shr MEMMAP_SHIFT;
   GetAddress := Memory.Map[block];

   // Se o ponteiro for um endereço de memória real (maior que o último índice de mapa),
   // significa que é um bloco de RAM ou ROM, então retornamos o ponteiro base.
   if NativeUInt(GetAddress) >= MAP_LAST then
   begin
      Result := PByte(GetAddress);
      Exit;
   end;

   // Se for uma área mapeada especial, precisamos tratá-la.
   case NativeUInt(GetAddress) of
      MAP_CPU,
      MAP_PPU:
         // Acessos a registradores da CPU/PPU são mapeados para a FillRAM, que é uma área "falsa"
         // para conter os valores lidos. Não é um ponteiro de acesso direto real.
         Result := @Memory.FillRAM[0];
      MAP_LOROM_SRAM,
      MAP_HIROM_SRAM,
      MAP_RONLY_SRAM,
      MAP_SA1RAM:
         // Se a SRAM for contígua e totalmente mapeada, podemos retornar um ponteiro base.
         // Se a máscara não cobrir todo o espaço, o acesso não é linear, então não podemos.
         if (Memory.SRAMMask and MEMMAP_MASK) <> MEMMAP_MASK then
            Result := nil
         else
            Result := @Memory.SRAM[0];
      MAP_BWRAM: Result := Memory.BWRAM;
      MAP_SPC7110_DRAM: Result := @Memory.FillRAM[0]; // Obtenha o endereço do início do array da DRAM do SPC7110
      else
         // Para todos os outros casos (MAP_NONE, MAP_DSP, etc.), não há um ponteiro base
         // direto e contínuo que possa ser retornado com segurança.
         Result := nil;
   end;
end;

function GetMemPointer(Address: Cardinal): PByte;
var
   GetAddress: Pointer;
   block: Cardinal;
begin
   block := (Address and $FFFFFF) shr MEMMAP_SHIFT;
   GetAddress := Memory.Map[block];

   // Se for um ponteiro de memória real, calculamos o endereço exato.
   if NativeUInt(GetAddress) >= MAP_LAST then
   begin
      Result := PByte(NativeUInt(GetAddress) + (Address and MEMMAP_MASK));
      Exit;
   end;

   // Se for uma área mapeada especial, verificamos se podemos obter um ponteiro direto.
   case NativeUInt(GetAddress) of
      MAP_CPU,
      MAP_PPU:
         // Registradores não podem ser acessados via ponteiro direto. O valor é lido/escrito
         // através de Get/Set. No entanto, o C retornava um ponteiro para FillRAM.
         Result := @Memory.FillRAM[Address and $7FFF];
      MAP_LOROM_SRAM,
      MAP_HIROM_SRAM,
      MAP_RONLY_SRAM:
         // Só podemos retornar um ponteiro para a SRAM se ela estiver presente.
         if Memory.SRAMMask <> 0 then
            Result := @Memory.SRAM[Address and Memory.SRAMMask]
         else
            Result := nil;
      MAP_BWRAM: Result := @Memory.BWRAM[(Address and $7FFF) - $6000];
      MAP_SA1RAM: Result := @Memory.SRAM[Address and $FFFF];
      MAP_SPC7110_DRAM: Result := @Memory.FillRAM[Address and $FFFF];
      else
         // Para todos os outros casos, é mais seguro retornar nil para forçar o uso de GetByte/SetByte.
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