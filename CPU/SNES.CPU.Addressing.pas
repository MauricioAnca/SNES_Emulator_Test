unit SNES.CPU.Addressing;

interface

uses
   SNES.DataTypes, SNES.Memory, SNES.Globals;

type
   TAccessMode = Integer;

const
   // Constantes traduzidas do enum AccessMode
   ACC_NONE = 0;
   ACC_READ = 1;
   ACC_WRITE = 2;
   ACC_MODIFY = ACC_WRITE or ACC_READ;
   ACC_JUMP = 4 or ACC_READ;
   ACC_JSR = 8;

// Funções de Modo de Endereçamento
function Immediate8Slow(a: TAccessMode): Byte; inline;
function Immediate8(a: TAccessMode): Byte; inline;
function Immediate16Slow(a: TAccessMode): Word; inline;
function Immediate16(a: TAccessMode): Word; inline;
function RelativeSlow(a: TAccessMode): Cardinal; inline;
function Relative(a: TAccessMode): Cardinal; inline;
function RelativeLongSlow(a: TAccessMode): Cardinal; inline;
function RelativeLong(a: TAccessMode): Cardinal; inline;
function AbsoluteIndexedIndirectSlow(a: TAccessMode): Cardinal; inline;
function AbsoluteIndexedIndirect(a: TAccessMode): Cardinal; inline;
function AbsoluteIndirectLongSlow(a: TAccessMode): Cardinal; inline;
function AbsoluteIndirectLong(a: TAccessMode): Cardinal; inline;
function AbsoluteIndirectSlow(a: TAccessMode): Cardinal; inline;
function AbsoluteIndirect(a: TAccessMode): Cardinal; inline;
function AbsoluteSlow(a: TAccessMode): Cardinal; inline;
function Absolute(a: TAccessMode): Cardinal; inline;
function AbsoluteLongSlow(a: TAccessMode): Cardinal; inline;
function AbsoluteLong(a: TAccessMode): Cardinal; inline;
function DirectSlow(a: TAccessMode): Cardinal; inline;
function Direct(a: TAccessMode): Cardinal; inline;
function DirectIndirectSlow(a: TAccessMode): Cardinal; inline;
function DirectIndirectE0(a: TAccessMode): Cardinal; inline;
function DirectIndirectE1(a: TAccessMode): Cardinal; inline;
function DirectIndirectIndexedSlow(a: TAccessMode): Cardinal; inline;
function DirectIndirectIndexedE0X0(a: TAccessMode): Cardinal; inline;
function DirectIndirectIndexedE0X1(a: TAccessMode): Cardinal; inline;
function DirectIndirectIndexedE1(a: TAccessMode): Cardinal; inline;
function DirectIndirectLongSlow(a: TAccessMode): Cardinal; inline;
function DirectIndirectLong(a: TAccessMode): Cardinal; inline;
function DirectIndirectIndexedLongSlow(a: TAccessMode): Cardinal; inline;
function DirectIndirectIndexedLong(a: TAccessMode): Cardinal; inline;
function DirectIndexedXSlow(a: TAccessMode): Cardinal; inline;
function DirectIndexedXE0(a: TAccessMode): Cardinal; inline;
function DirectIndexedXE1(a: TAccessMode): Cardinal; inline;
function DirectIndexedYSlow(a: TAccessMode): Cardinal; inline;
function DirectIndexedYE0(a: TAccessMode): Cardinal; inline;
function DirectIndexedYE1(a: TAccessMode): Cardinal; inline;
function DirectIndexedIndirectSlow(a: TAccessMode): Cardinal; inline;
function DirectIndexedIndirectE0(a: TAccessMode): Cardinal; inline;
function DirectIndexedIndirectE1(a: TAccessMode): Cardinal; inline;
function AbsoluteIndexedXSlow(a: TAccessMode): Cardinal; inline;
function AbsoluteIndexedXX0(a: TAccessMode): Cardinal; inline;
function AbsoluteIndexedXX1(a: TAccessMode): Cardinal; inline;
function AbsoluteIndexedYSlow(a: TAccessMode): Cardinal; inline;
function AbsoluteIndexedYX0(a: TAccessMode): Cardinal; inline;
function AbsoluteIndexedYX1(a: TAccessMode): Cardinal; inline;
function AbsoluteLongIndexedXSlow(a: TAccessMode): Cardinal; inline;
function AbsoluteLongIndexedX(a: TAccessMode): Cardinal; inline;
function StackRelativeSlow(a: TAccessMode): Cardinal; inline;
function StackRelative(a: TAccessMode): Cardinal; inline;
function StackRelativeIndirectIndexedSlow(a: TAccessMode): Cardinal; inline;
function StackRelativeIndirectIndexed(a: TAccessMode): Cardinal; inline;

implementation

function Immediate8Slow(a: TAccessMode): Byte;
var
   val: Byte;
begin
   val := GetByte(ICPU.Registers.PCw.xPBPC);
   if (a and ACC_READ) <> 0 then
      ICPU.OpenBus := val;
   Inc(ICPU.Registers.PCw.PC.W);
   Result := val;
end;

function Immediate8(a: TAccessMode): Byte;
var
   val: Byte;
begin
   val := CPU.PCBase[ICPU.Registers.PCw.PC.W];
   if (a and ACC_READ) <> 0 then
      ICPU.OpenBus := val;
   CPU.Cycles := CPU.Cycles + CPU.MemSpeed;
   Inc(ICPU.Registers.PCw.PC.W);
   Result := val;
end;

function Immediate16Slow(a: TAccessMode): Word;
var
   val: Word;
begin
   val := GetWord(ICPU.Registers.PCw.xPBPC, WRAP_BANK);
   if (a and ACC_READ) <> 0 then
      ICPU.OpenBus := val shr 8;
   Inc(ICPU.Registers.PCw.PC.W, 2);
   Result := val;
end;

function Immediate16(a: TAccessMode): Word;
var
   val: Word;
begin
   val := PWord(CPU.PCBase + ICPU.Registers.PCw.PC.W)^;
   if (a and ACC_READ) <> 0 then
      ICPU.OpenBus := val shr 8;
   CPU.Cycles := CPU.Cycles + CPU.MemSpeedx2;
   Inc(ICPU.Registers.PCw.PC.W, 2);
   Result := val;
end;

function RelativeSlow(a: TAccessMode): Cardinal;
var
   offset: ShortInt;
begin
   offset := ShortInt(Immediate8Slow(a));
   Result := (SmallInt(ICPU.Registers.PCw.PC.W) + offset) and $ffff;
end;

function Relative(a: TAccessMode): Cardinal;
var
   offset: ShortInt;
begin
   offset := ShortInt(Immediate8(a));
   Result := (SmallInt(ICPU.Registers.PCw.PC.W) + offset) and $ffff;
end;

function RelativeLongSlow(a: TAccessMode): Cardinal;
var
   offset: SmallInt;
begin
   offset := SmallInt(Immediate16Slow(a));
   Result := (Integer(ICPU.Registers.PCw.PC.W) + offset) and $ffff;
end;

function RelativeLong(a: TAccessMode): Cardinal;
var
   offset: SmallInt;
begin
   offset := SmallInt(Immediate16(a));
   Result := (Integer(ICPU.Registers.PCw.PC.W) + offset) and $ffff;
end;

function AbsoluteIndexedIndirectSlow(a: TAccessMode): Cardinal;
var
   addr, addr2: Word;
begin
   addr := Immediate16Slow(ACC_READ);
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   addr := addr + ICPU.Registers.X.W;
   addr2 := GetWord(ICPU.ShiftedPB or addr, WRAP_BANK);
   ICPU.OpenBus := addr2 shr 8;
   Result := addr2;
end;

function AbsoluteIndexedIndirect(a: TAccessMode): Cardinal;
var
  addr, addr2: Word;
begin
  addr := Immediate16(ACC_READ);
  addr := addr + ICPU.Registers.X.W;
  addr2 := GetWord(ICPU.ShiftedPB or addr, WRAP_BANK);
  ICPU.OpenBus := addr2 shr 8;
  Result := addr2;
end;

function AbsoluteIndirectLongSlow(a: TAccessMode): Cardinal;
var
  addr: Word;
  addr2: Cardinal;
begin
  addr := Immediate16Slow(ACC_READ);
  addr2 := GetWord(addr, WRAP_NONE);
  ICPU.OpenBus := addr2 shr 8;
  addr2 := addr2 or (Cardinal(GetByte(addr + 2)) shl 16);
  ICPU.OpenBus := Byte(addr2 shr 16);
  Result := addr2;
end;

function AbsoluteIndirectLong(a: TAccessMode): Cardinal;
var
  addr: Word;
  addr2: Cardinal;
begin
  addr := Immediate16(ACC_READ);
  addr2 := GetWord(addr, WRAP_NONE);
  ICPU.OpenBus := addr2 shr 8;
  addr2 := addr2 or (Cardinal(GetByte(addr + 2)) shl 16);
  ICPU.OpenBus := Byte(addr2 shr 16);
  Result := addr2;
end;

function AbsoluteIndirectSlow(a: TAccessMode): Cardinal;
var
  addr2: Word;
begin
  addr2 := GetWord(Immediate16Slow(ACC_READ), WRAP_NONE);
  ICPU.OpenBus := addr2 shr 8;
  Result := addr2;
end;

function AbsoluteIndirect(a: TAccessMode): Cardinal;
var
  addr2: Word;
begin
  addr2 := GetWord(Immediate16(ACC_READ), WRAP_NONE);
  ICPU.OpenBus := addr2 shr 8;
  Result := addr2;
end;

function AbsoluteSlow(a: TAccessMode): Cardinal;
begin
  Result := ICPU.ShiftedDB or Immediate16Slow(a);
end;

function Absolute(a: TAccessMode): Cardinal;
begin
  Result := ICPU.ShiftedDB or Immediate16(a);
end;

function AbsoluteLongSlow(a: TAccessMode): Cardinal;
var
  addr: Cardinal;
begin
  addr := Immediate16Slow(ACC_READ);
  if a = ACC_JSR then
    ICPU.OpenBus := ICPU.Registers.PCw.PB;
  addr := addr or (Cardinal(Immediate8Slow(a)) shl 16);
  Result := addr;
end;

function AbsoluteLong(a: TAccessMode): Cardinal;
var
  addr: Cardinal;
begin
  addr := PCardinal(CPU.PCBase + ICPU.Registers.PCw.PC.W)^ and $00FFFFFF;
  CPU.Cycles := CPU.Cycles + CPU.MemSpeedx2 + CPU.MemSpeed;
  if (a and ACC_READ) <> 0 then
    ICPU.OpenBus := addr shr 16;
  Inc(ICPU.Registers.PCw.PC.W, 3);
  Result := addr;
end;

function DirectSlow(a: TAccessMode): Cardinal;
var
  addr: Word;
begin
  addr := Immediate8Slow(a) + ICPU.Registers.D.W;
  if ICPU.Registers.D.L <> 0 then
    CPU.Cycles := CPU.Cycles + Settings.OneCycle;
  Result := addr;
end;

function Direct(a: TAccessMode): Cardinal;
var
  addr: Word;
begin
  addr := Immediate8(a) + ICPU.Registers.D.W;
  if ICPU.Registers.D.L <> 0 then
    CPU.Cycles := CPU.Cycles + Settings.OneCycle;
  Result := addr;
end;

function DirectIndirectSlow(a: TAccessMode): Cardinal;
var
  addr: Cardinal;
  wrap: TWrapType;
begin
  if (ICPU.Registers.P.W and (1 shl Ord(cfEmulation)) = 0) or (ICPU.Registers.D.L > 0) then
    wrap := WRAP_BANK
  else
    wrap := WRAP_PAGE;

  addr := GetWord(DirectSlow(ACC_READ), wrap);
  if (a and ACC_READ) <> 0 then
    ICPU.OpenBus := addr shr 8;
  addr := addr or ICPU.ShiftedDB;
  Result := addr;
end;

function DirectIndirectE0(a: TAccessMode): Cardinal;
var
  addr: Cardinal;
begin
  addr := GetWord(Direct(ACC_READ), WRAP_NONE);
  if (a and ACC_READ) <> 0 then
    ICPU.OpenBus := addr shr 8;
  addr := addr or ICPU.ShiftedDB;
  Result := addr;
end;

function DirectIndirectE1(a: TAccessMode): Cardinal;
var
  addr: Cardinal;
  wrap: TWrapType;
begin
  if ICPU.Registers.D.L > 0 then
    wrap := WRAP_BANK
  else
    wrap := WRAP_PAGE;

  addr := GetWord(DirectSlow(ACC_READ), wrap);
  if (a and ACC_READ) <> 0 then
    ICPU.OpenBus := addr shr 8;
  addr := addr or ICPU.ShiftedDB;
  Result := addr;
end;

function DirectIndirectIndexedSlow(a: TAccessMode): Cardinal;
var
  addr: Cardinal;
begin
  addr := DirectIndirectSlow(a);
  if ((a and ACC_WRITE) <> 0) or
     ((ICPU.Registers.P.W and (1 shl Ord(cfIndexFlag))) = 0) or
     (((addr and $ff) + ICPU.Registers.Y.L) >= $100) then
    CPU.Cycles := CPU.Cycles + Settings.OneCycle;
  Result := addr + ICPU.Registers.Y.W;
end;

function DirectIndirectIndexedE0X0(a: TAccessMode): Cardinal;
begin
  Result := DirectIndirectE0(a) + ICPU.Registers.Y.W;
end;

function DirectIndirectIndexedE0X1(a: TAccessMode): Cardinal;
var
  addr: Cardinal;
begin
  addr := DirectIndirectE0(a);
  if ((a and ACC_WRITE) <> 0) or (((addr and $ff) + ICPU.Registers.Y.L) >= $100) then
    CPU.Cycles := CPU.Cycles + Settings.OneCycle;
  Result := addr + ICPU.Registers.Y.W;
end;

function DirectIndirectIndexedE1(a: TAccessMode): Cardinal;
var
  addr: Cardinal;
begin
  addr := DirectIndirectE1(a);
  if ((a and ACC_WRITE) <> 0) or (((addr and $ff) + ICPU.Registers.Y.L) >= $100) then
    CPU.Cycles := CPU.Cycles + Settings.OneCycle;
  Result := addr + ICPU.Registers.Y.W;
end;

function DirectIndirectLongSlow(a: TAccessMode): Cardinal;
var
  addr: Word;
  addr2: Cardinal;
begin
  addr := DirectSlow(ACC_READ);
  addr2 := GetWord(addr, WRAP_NONE);
  ICPU.OpenBus := addr2 shr 8;
  addr2 := addr2 or (Cardinal(GetByte(addr + 2)) shl 16);
  ICPU.OpenBus := Byte(addr2 shr 16);
  Result := addr2;
end;

function DirectIndirectLong(a: TAccessMode): Cardinal;
var
  addr: Word;
  addr2: Cardinal;
begin
  addr := Direct(ACC_READ);
  addr2 := GetWord(addr, WRAP_NONE);
  ICPU.OpenBus := addr2 shr 8;
  addr2 := addr2 or (Cardinal(GetByte(addr + 2)) shl 16);
  ICPU.OpenBus := Byte(addr2 shr 16);
  Result := addr2;
end;

function DirectIndirectIndexedLongSlow(a: TAccessMode): Cardinal;
begin
  Result := DirectIndirectLongSlow(a) + ICPU.Registers.Y.W;
end;

function DirectIndirectIndexedLong(a: TAccessMode): Cardinal;
begin
  Result := DirectIndirectLong(a) + ICPU.Registers.Y.W;
end;

function DirectIndexedXSlow(a: TAccessMode): Cardinal;
var
  addr: TPair;
begin
  addr.W := DirectSlow(a);
  if ((ICPU.Registers.P.W and (1 shl Ord(cfEmulation))) = 0) or (ICPU.Registers.D.L > 0) then
    addr.W := addr.W + ICPU.Registers.X.W
  else
    addr.L := addr.L + ICPU.Registers.X.L;
  CPU.Cycles := CPU.Cycles + Settings.OneCycle;
  Result := addr.W;
end;

function DirectIndexedXE0(a: TAccessMode): Cardinal;
var
  addr: Word;
begin
  addr := Direct(a) + ICPU.Registers.X.W;
  CPU.Cycles := CPU.Cycles + Settings.OneCycle;
  Result := addr;
end;

function DirectIndexedXE1(a: TAccessMode): Cardinal;
var
  addr: TPair;
begin
  if ICPU.Registers.D.L > 0 then
    Exit(DirectIndexedXE0(a));

  addr.W := Direct(a);
  addr.L := addr.L + ICPU.Registers.X.L;
  CPU.Cycles := CPU.Cycles + Settings.OneCycle;
  Result := addr.W;
end;

function DirectIndexedYSlow(a: TAccessMode): Cardinal;
var
  addr: TPair;
begin
  addr.W := DirectSlow(a);
  if ((ICPU.Registers.P.W and (1 shl Ord(cfEmulation))) = 0) or (ICPU.Registers.D.L > 0) then
    addr.W := addr.W + ICPU.Registers.Y.W
  else
    addr.L := addr.L + ICPU.Registers.Y.L;
  CPU.Cycles := CPU.Cycles + Settings.OneCycle;
  Result := addr.W;
end;

function DirectIndexedYE0(a: TAccessMode): Cardinal;
var
  addr: Word;
begin
  addr := Direct(a) + ICPU.Registers.Y.W;
  CPU.Cycles := CPU.Cycles + Settings.OneCycle;
  Result := addr;
end;

function DirectIndexedYE1(a: TAccessMode): Cardinal;
var
  addr: TPair;
begin
  if ICPU.Registers.D.L > 0 then
    Exit(DirectIndexedYE0(a));

  addr.W := Direct(a);
  addr.L := addr.L + ICPU.Registers.Y.L;
  CPU.Cycles := CPU.Cycles + Settings.OneCycle;
  Result := addr.W;
end;

function DirectIndexedIndirectSlow(a: TAccessMode): Cardinal;
var
  addr: Cardinal;
  wrap: TWrapType;
begin
  if ((ICPU.Registers.P.W and (1 shl Ord(cfEmulation))) = 0) or (ICPU.Registers.D.L > 0) then
    wrap := WRAP_BANK
  else
    wrap := WRAP_PAGE;
  addr := GetWord(DirectIndexedXSlow(ACC_READ), wrap);
  if (a and ACC_READ) <> 0 then
    ICPU.OpenBus := addr shr 8;
  Result := ICPU.ShiftedDB or addr;
end;

function DirectIndexedIndirectE0(a: TAccessMode): Cardinal;
var
  addr: Cardinal;
begin
  addr := GetWord(DirectIndexedXE0(ACC_READ), WRAP_NONE);
  if (a and ACC_READ) <> 0 then
    ICPU.OpenBus := addr shr 8;
  Result := ICPU.ShiftedDB or addr;
end;

function DirectIndexedIndirectE1(a: TAccessMode): Cardinal;
var
  addr: Cardinal;
  wrap: TWrapType;
begin
  if ICPU.Registers.D.L > 0 then
    wrap := WRAP_BANK
  else
    wrap := WRAP_PAGE;
  addr := GetWord(DirectIndexedXE1(ACC_READ), wrap);
  if (a and ACC_READ) <> 0 then
    ICPU.OpenBus := addr shr 8;
  Result := ICPU.ShiftedDB or addr;
end;

function AbsoluteIndexedXSlow(a: TAccessMode): Cardinal;
var
  addr: Cardinal;
begin
  addr := AbsoluteSlow(a);
  if ((a and ACC_WRITE) <> 0) or
     ((ICPU.Registers.P.W and (1 shl Ord(cfIndexFlag))) = 0) or
     (((addr and $ff) + ICPU.Registers.X.L) >= $100) then
    CPU.Cycles := CPU.Cycles + Settings.OneCycle;
  Result := addr + ICPU.Registers.X.W;
end;

function AbsoluteIndexedXX0(a: TAccessMode): Cardinal;
var
  addr: Cardinal;
begin
  addr := Absolute(a);
  CPU.Cycles := CPU.Cycles + Settings.OneCycle;
  Result := addr + ICPU.Registers.X.W;
end;

function AbsoluteIndexedXX1(a: TAccessMode): Cardinal;
var
  addr: Cardinal;
begin
  addr := Absolute(a);
  if ((a and ACC_WRITE) <> 0) or (((addr and $ff) + ICPU.Registers.X.L) >= $100) then
    CPU.Cycles := CPU.Cycles + Settings.OneCycle;
  Result := addr + ICPU.Registers.X.W;
end;

function AbsoluteIndexedYSlow(a: TAccessMode): Cardinal;
var
  addr: Cardinal;
begin
  addr := AbsoluteSlow(a);
  if ((a and ACC_WRITE) <> 0) or
     ((ICPU.Registers.P.W and (1 shl Ord(cfIndexFlag))) = 0) or
     (((addr and $ff) + ICPU.Registers.Y.L) >= $100) then
    CPU.Cycles := CPU.Cycles + Settings.OneCycle;
  Result := addr + ICPU.Registers.Y.W;
end;

function AbsoluteIndexedYX0(a: TAccessMode): Cardinal;
var
  addr: Cardinal;
begin
  addr := Absolute(a);
  CPU.Cycles := CPU.Cycles + Settings.OneCycle;
  Result := addr + ICPU.Registers.Y.W;
end;

function AbsoluteIndexedYX1(a: TAccessMode): Cardinal;
var
  addr: Cardinal;
begin
  addr := Absolute(a);
  if ((a and ACC_WRITE) <> 0) or (((addr and $ff) + ICPU.Registers.Y.L) >= $100) then
    CPU.Cycles := CPU.Cycles + Settings.OneCycle;
  Result := addr + ICPU.Registers.Y.W;
end;

function AbsoluteLongIndexedXSlow(a: TAccessMode): Cardinal;
begin
  Result := AbsoluteLongSlow(a) + ICPU.Registers.X.W;
end;

function AbsoluteLongIndexedX(a: TAccessMode): Cardinal;
begin
  Result := AbsoluteLong(a) + ICPU.Registers.X.W;
end;

function StackRelativeSlow(a: TAccessMode): Cardinal;
var
  addr: Word;
begin
  addr := Immediate8Slow(a) + ICPU.Registers.S.W;
  CPU.Cycles := CPU.Cycles + Settings.OneCycle;
  Result := addr;
end;

function StackRelative(a: TAccessMode): Cardinal;
var
  addr: Word;
begin
  addr := Immediate8(a) + ICPU.Registers.S.W;
  CPU.Cycles := CPU.Cycles + Settings.OneCycle;
  Result := addr;
end;

function StackRelativeIndirectIndexedSlow(a: TAccessMode): Cardinal;
var
  addr: Cardinal;
begin
  addr := GetWord(StackRelativeSlow(ACC_READ), WRAP_NONE);
  if (a and ACC_READ) <> 0 then
    ICPU.OpenBus := addr shr 8;
  addr := (addr + ICPU.Registers.Y.W + ICPU.ShiftedDB) and $ffffff;
  CPU.Cycles := CPU.Cycles + Settings.OneCycle;
  Result := addr;
end;

function StackRelativeIndirectIndexed(a: TAccessMode): Cardinal;
var
  addr: Cardinal;
begin
  addr := GetWord(StackRelative(ACC_READ), WRAP_NONE);
  if (a and ACC_READ) <> 0 then
    ICPU.OpenBus := addr shr 8;
  addr := (addr + ICPU.Registers.Y.W + ICPU.ShiftedDB) and $ffffff;
  CPU.Cycles := CPU.Cycles + Settings.OneCycle;
  Result := addr;
end;

end.