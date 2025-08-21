unit SNES.APU;

interface

uses
  SNES.DataTypes;

// --- Funções Públicas da Unit ---
function InitAPU: Boolean;
procedure DeinitAPU;
procedure ResetAPU;
procedure APUMainLoop;
procedure SetAPUControl(ByteValue: Byte);
function APUGetByte(Address: Word): Byte;
procedure APUSetByte(ByteValue: Byte; Address: Word);
function APUGetByteDP(Address: Byte): Byte;
procedure APUSetByteDP(ByteValue: Byte; Address: Byte);
procedure APUUnpackStatus; inline;
procedure APUPackStatus; inline;

implementation

uses
  System.SysUtils,
  SNES.Globals,
  SNES.Memory,
  SNES.CPU,
  SNES.APU.DSP,
  SNES.APU.SPC700;

const
  // Conteúdo da IPL ROM da APU
  APUROM: array[0..63] of Byte = (
    $CD, $EF, $BD, $E8, $00, $C6, $1D, $D0,
    $FC, $8F, $AA, $F4, $8F, $BB, $F5, $78,
    $CC, $F4, $D0, $FB, $2F, $19, $EB, $F4,
    $D0, $FC, $7E, $F4, $D0, $0B, $E4, $F5,
    $CB, $F4, $D7, $00, $FC, $D0, $F3, $AB,
    $01, $10, $EF, $7E, $F4, $10, $EB, $BA,
    $F6, $DA, $00, $BA, $F4, $C4, $F4, $DD,
    $5D, $D0, $DB, $1F, $00, $00, $C0, $FF
  );

// --- Implementação das Funções Públicas ---

function InitAPU: Boolean;
begin
   // ARAM é alocada dentro da variável global IAPU
   // Precisamos alocar o buffer para o SPC700
   GetMem(IAPU.RAM, $10000);
   if IAPU.RAM = nil then
   begin
      DeinitAPU;
      Exit(False);
   end;

   InitAPUDSP; // Chama a inicialização do DSP
   Result := True;
end;

procedure DeinitAPU;
begin
   if IAPU.RAM <> nil then
   begin
      FreeMem(IAPU.RAM);
      IAPU.RAM := nil;
   end;
end;

procedure ResetAPU;
var
   i: Integer;
begin
   Settings.APUEnabled := True;
   FillChar(IAPU.RAM^, $100, 0);
   FillChar(IAPU.RAM[$20], $20, $FF);
   FillChar(IAPU.RAM[$60], $20, $FF);
   FillChar(IAPU.RAM[$A0], $20, $FF);
   FillChar(IAPU.RAM[$E0], $20, $FF);

   for i := 1 to 255 do
      Move(IAPU.RAM^, IAPU.RAM[i shl 8], $100);

   FillChar(APU, SizeOf(SAPU), 0);
   FillChar(APU.OutPorts, SizeOf(APU.OutPorts), 0);

   IAPU.DirectPage := IAPU.RAM;
   Move(APUROM, IAPU.RAM[$FFC0], SizeOf(APUROM));
   Move(APUROM, APU.ExtraRAM, SizeOf(APUROM));

   IAPU.PC := IAPU.RAM + (IAPU.RAM[$FFFE] or (IAPU.RAM[$FFFF] shl 8));
   IAPU.Registers.PC := $FFC0;
   IAPU.Registers.YA.W := 0;
   IAPU.Registers.X := 0;
   IAPU.Registers.P := 2;
   IAPU.Registers.S := $EF;
   APUUnpackStatus;
   IAPU.Executing := Settings.APUEnabled;
   IAPU.WaitAddress1 := nil;
   IAPU.WaitAddress2 := nil;
   IAPU.WaitCounter := 1;

   EXT.t64Cnt := EXT.t64Cnt and not 7;
   EXT.APUTimerCounter := Cardinal(Int64(SNES_CYCLES_PER_SECOND shl FIXED_POINT_SHIFT) div 64000);
   EXT.APUTimerCounter_err := EXT.APUTimerCounter and FIXED_POINT_REMAINDER;
   EXT.NextAPUTimerPos := APU.Cycles + (EXT.APUTimerCounter shr FIXED_POINT_SHIFT);

   IAPU.RAM[$F0] := $0A; // timers_enabled & ram_writable
   IAPU.RAM[$F1] := $B0;
   APU.ShowROM := True;

   for i := 0 to 255 do
      APUCycles[i] := APUCycleLengths[i] * IAPU.OneCycle;

   ResetSound(True);
   SetEchoEnable(0);
   ResetAPUDSP;
end;

procedure APUTimerPulse;
var
   i: Integer;
begin
   EXT.t64Cnt := (EXT.t64Cnt + 1) and 7;

   if EXT.t64Cnt = 0 then
      i := 0
   else
      i := 2;

   for i := i to 2 do
   begin
      if APU.TimerEnabled[i] then
      begin
         Inc(APU.Timer[i]);
         if APU.Timer[i] >= APU.TimerTarget[i] then
         begin
            var pos := $FD + i;
            IAPU.RAM[pos] := (IAPU.RAM[pos] + 1) and $0F;
            APU.Timer[i] := APU.Timer[i] - APU.TimerTarget[i];
            IAPU.WaitCounter := 1;
            IAPU.Executing := Settings.APUEnabled;
         end;
      end;
   end;
end;

function APUGetCPUCycles: Integer;
begin
   Result := CPU.Cycles;
end;

procedure APUMainLoop;
begin
   while CPU.Cycles < EXT.NextAPUTimerPos do
   begin
      APUExecute; // Chama o loop de execução do SPC700
      APUTimerPulse;
      EXT.APUTimerCounter_err := EXT.APUTimerCounter_err + EXT.APUTimerCounter;
      EXT.NextAPUTimerPos := EXT.NextAPUTimerPos + (EXT.APUTimerCounter_err shr FIXED_POINT_SHIFT);
      EXT.APUTimerCounter_err := EXT.APUTimerCounter_err and FIXED_POINT_REMAINDER;
   end;
end;

procedure SetAPUControl(ByteValue: Byte);
var
  i, j: Integer;
  enableTimer: Boolean;
begin
  j := 1;
  for i := 0 to 2 do
  begin
    enableTimer := (ByteValue and j) <> 0;
    if enableTimer and not APU.TimerEnabled[i] then
    begin
      APU.Timer[i] := 0;
      IAPU.RAM[$FD + i] := 0;
      APU.TimerTarget[i] := IAPU.RAM[$FA + i];
      if APU.TimerTarget[i] = 0 then
        APU.TimerTarget[i] := $100;
    end;
    APU.TimerEnabled[i] := enableTimer;
    j := j shl 1;
  end;

  if (ByteValue and $10) <> 0 then
  begin
    if not Settings.SecretOfEvermoreHack then
      IAPU.RAM[$F4] := 0;
    IAPU.RAM[$F5] := 0;
  end;

  if (ByteValue and $20) <> 0 then
    IAPU.RAM[$F6] := IAPU.RAM[$F7];

  if (ByteValue and $80) <> 0 then
  begin
    if not APU.ShowROM then
    begin
      Move(APUROM, IAPU.RAM[$FFC0], SizeOf(APUROM));
      APU.ShowROM := True;
    end;
  end
  else if APU.ShowROM then
  begin
    Move(APU.ExtraRAM, IAPU.RAM[$FFC0], SizeOf(APUROM));
    APU.ShowROM := False;
  end;

  IAPU.RAM[$F1] := ByteValue;
end;

function APUSetByteCommon(ByteValue: Byte; Address: Word): Boolean;
begin
  Result := True;
  case Address of
    $F1: SetAPUControl(ByteValue);
    $F3: APUDSPIn(IAPU.RAM[$F2] and $7F, ByteValue);
    $F4, $F5, $F6, $F7: APU.OutPorts[Address and 3] := ByteValue;
    $FA, $FB, $FC:
      begin
        IAPU.RAM[Address] := ByteValue;
        APU.TimerTarget[Address - $FA] := iif(ByteValue = 0, $100, ByteValue);
      end;
    $FD, $FE, $FF: ; // Registradores somente leitura
  else
    Result := False;
  end;
end;

procedure APUSetByte(ByteValue: Byte; Address: Word);
begin
  if APUSetByteCommon(ByteValue, Address) then
    Exit;

  if Address < $FFC0 then
  begin
    IAPU.RAM[Address] := ByteValue;
    Exit;
  end;

  APU.ExtraRAM[Address - $FFC0] := ByteValue;
  if not APU.ShowROM then
    IAPU.RAM[Address] := ByteValue;
end;

procedure APUSetByteDP(ByteValue: Byte; Address: Byte);
begin
  if (IAPU.DirectPage = IAPU.RAM) and APUSetByteCommon(ByteValue, Address) then
    Exit;

  IAPU.DirectPage[Address] := ByteValue;
end;

function APUGetByte(Address: Word): Byte;
var
  r: Byte;
begin
  case Address of
    $F0, $F1, $FA, $FB, $FC: Result := 0; // Registradores somente escrita
    $F3:
      begin
        r := IAPU.RAM[$F2] and $7F;
        if (r and $0F) = APU_ENVX then
          Result := APU.DSP[r] and $7F
        else
          Result := APU.DSP[r];
      end;
    $F4, $F5, $F6, $F7:
      begin
        IAPU.WaitAddress2 := IAPU.WaitAddress1;
        IAPU.WaitAddress1 := IAPU.PC;
        Result := IAPU.RAM[Address];
      end;
    $FD, $FE, $FF:
      begin
        r := IAPU.RAM[Address] and 15;
        IAPU.WaitAddress2 := IAPU.WaitAddress1;
        IAPU.WaitAddress1 := IAPU.PC;
        IAPU.RAM[Address] := 0;
        Result := r;
      end;
  else
    Result := IAPU.RAM[Address];
  end;
end;

function APUGetByteDP(Address: Byte): Byte;
begin
  if IAPU.DirectPage = IAPU.RAM then
    Result := APUGetByte(Address)
  else
    Result := IAPU.DirectPage[Address];
end;

procedure APUUnpackStatus;
begin
  IAPU.Zero     := ((IAPU.Registers.P and APU_ZERO) = 0) or ((IAPU.Registers.P and APU_NEGATIVE) <> 0);
  ICPU.Carry    := (IAPU.Registers.P and APU_CARRY) <> 0;
  IAPU.Overflow := (IAPU.Registers.P and APU_OVERFLOW) <> 0;
end;

procedure APUPackStatus;
begin
  ICPU.Registers.P := ICPU.Registers.P and not (APU_ZERO or APU_NEGATIVE or APU_CARRY or APU_OVERFLOW);
  ICPU.Registers.P := ICPU.Registers.P or Ord(IAPU.Carry) or (Ord(not IAPU.Zero) shl 1) or (IAPU.Zero and $80) or (Ord(IAPU.Overflow) shl 6);
end;

end.
