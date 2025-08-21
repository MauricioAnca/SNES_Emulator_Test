unit SNES.CPU.Opcodes;

interface

uses
   SNES.DataTypes;

const
   FLAG_CARRY = 1 shl Ord(cfCarry);
   FLAG_ZERO = 1 shl Ord(cfZero);
   FLAG_IRQ = 1 shl Ord(cfIRQ);
   FLAG_DECIMAL = 1 shl Ord(cfDecimal);
   FLAG_INDEX = 1 shl Ord(cfIndexFlag);
   FLAG_MEMORY = 1 shl Ord(cfMemoryFlag);
   FLAG_OVERFLOW = 1 shl Ord(cfOverflow);
   FLAG_NEGATIVE = 1 shl Ord(cfNegative);
   FLAG_EMULATION = 1 shl Ord(cfEmulation);

var
   // Tabelas com o tamanho em bytes de cada opcode para cada modo da CPU
   OpLengthsM1X1, OpLengthsM1X0, OpLengthsM0X1, OpLengthsM0X0: array[0..255] of Byte;
   // Tabelas de Opcodes
   OpcodesE1, OpcodesM1X1, OpcodesM1X0, OpcodesM0X1, OpcodesM0X0, OpcodesSlow: TOpcodeTable;

function CheckCarry: Boolean; inline;
function CheckZero: Boolean; inline;
function CheckIRQ: Boolean; inline;
function CheckDecimal: Boolean; inline;
function CheckIndex: Boolean; inline;
function CheckMem: Boolean; inline;
function CheckOverflow: Boolean; inline;
function CheckNegative: Boolean; inline;
function CheckEmulation: Boolean; inline;

// --- Rotinas Auxiliares de Manipulação de Flags ---
procedure PackStatus; inline;
procedure UnpackStatus; inline;
procedure FixCycles; inline;
procedure CheckForIRQ; inline;

// --- Declaração de todos os procedimentos de Opcodes ---
procedure Op00;
procedure Op01E0M1;
procedure Op01E1;
procedure Op01Slow;
procedure Op01E0M0;
procedure Op02;
procedure Op03M1;
procedure Op03M0;
procedure Op03Slow;
procedure Op04M1;
procedure Op04M0;
procedure Op04Slow;
procedure Op05M1;
procedure Op05M0;
procedure Op05Slow;
procedure Op06M1;
procedure Op06M0;
procedure Op06Slow;
procedure Op07M1;
procedure Op07M0;
procedure Op07Slow;
procedure Op08E1;
procedure Op08E0;
procedure Op08Slow;
procedure Op09M1;
procedure Op09M0;
procedure Op09Slow;
procedure Op0AM1;
procedure Op0AM0;
procedure Op0ASlow;
procedure Op0BE1;
procedure Op0BE0;
procedure Op0BSlow;
procedure Op0CM1;
procedure Op0CM0;
procedure Op0CSlow;
procedure Op0DM1;
procedure Op0DM0;
procedure Op0DSlow;
procedure Op0EM1;
procedure Op0EM0;
procedure Op0ESlow;
procedure Op0FM1;
procedure Op0FM0;
procedure Op0FSlow;
procedure Op10E1;
procedure Op10E0;
procedure Op10Slow;
procedure Op11E1;
procedure Op11E0M1X1;
procedure Op11E0M0X1;
procedure Op11E0M1X0;
procedure Op11E0M0X0;
procedure Op11Slow;
procedure Op12E1;
procedure Op12E0M1;
procedure Op12E0M0;
procedure Op12Slow;
procedure Op13M1;
procedure Op13M0;
procedure Op13Slow;
procedure Op14M1;
procedure Op14M0;
procedure Op14Slow;
procedure Op15E1;
procedure Op15E0M1;
procedure Op15E0M0;
procedure Op15Slow;
procedure Op16E1;
procedure Op16E0M1;
procedure Op16E0M0;
procedure Op16Slow;
procedure Op17M1;
procedure Op17M0;
procedure Op17Slow;
procedure Op18;
procedure Op19M1X1;
procedure Op19M0X1;
procedure Op19M1X0;
procedure Op19M0X0;
procedure Op19Slow;
procedure Op1AM1;
procedure Op1AM0;
procedure Op1ASlow;
procedure Op1B;
procedure Op1CM1;
procedure Op1CM0;
procedure Op1CSlow;
procedure Op1DM1X1;
procedure Op1DM0X1;
procedure Op1DM1X0;
procedure Op1DM0X0;
procedure Op1DSlow;
procedure Op1EM1X1;
procedure Op1EM0X1;
procedure Op1EM1X0;
procedure Op1EM0X0;
procedure Op1ESlow;
procedure Op1FM1;
procedure Op1FM0;
procedure Op1FSlow;
procedure Op20E1;
procedure Op20E0;
procedure Op20Slow;
procedure Op21E1;
procedure Op21E0M1;
procedure Op21E0M0;
procedure Op21Slow;
procedure Op22E1;
procedure Op22E0;
procedure Op22Slow;
procedure Op23M1;
procedure Op23M0;
procedure Op23Slow;
procedure Op24M1;
procedure Op24M0;
procedure Op24Slow;
procedure Op25M1;
procedure Op25M0;
procedure Op25Slow;
procedure Op26M1;
procedure Op26M0;
procedure Op26Slow;
procedure Op27M1;
procedure Op27M0;
procedure Op27Slow;
procedure Op28E1;
procedure Op28E0;
procedure Op28Slow;
procedure Op29M1;
procedure Op29M0;
procedure Op29Slow;
procedure Op2AM1;
procedure Op2AM0;
procedure Op2ASlow;
procedure Op2BE1;
procedure Op2BE0;
procedure Op2BSlow;
procedure Op2CM1;
procedure Op2CM0;
procedure Op2CSlow;
procedure Op2DM1;
procedure Op2DM0;
procedure Op2DSlow;
procedure Op2EM1;
procedure Op2EM0;
procedure Op2ESlow;
procedure Op2FM1;
procedure Op2FM0;
procedure Op2FSlow;
procedure Op30E1;
procedure Op30E0;
procedure Op30Slow;
procedure Op31E1;
procedure Op31E0M1X1;
procedure Op31E0M0X1;
procedure Op31E0M1X0;
procedure Op31E0M0X0;
procedure Op31Slow;
procedure Op32E1;
procedure Op32E0M1;
procedure Op32E0M0;
procedure Op32Slow;
procedure Op33M1;
procedure Op33M0;
procedure Op33Slow;
procedure Op34E1;
procedure Op34E0M1;
procedure Op34E0M0;
procedure Op34Slow;
procedure Op35E1;
procedure Op35E0M1;
procedure Op35E0M0;
procedure Op35Slow;
procedure Op36E1;
procedure Op36E0M1;
procedure Op36E0M0;
procedure Op36Slow;
procedure Op37M1;
procedure Op37M0;
procedure Op37Slow;
procedure Op38;
procedure Op39M1X1;
procedure Op39M0X1;
procedure Op39M1X0;
procedure Op39M0X0;
procedure Op39Slow;
procedure Op3AM1;
procedure Op3AM0;
procedure Op3ASlow;
procedure Op3B;
procedure Op3CM1X1;
procedure Op3CM0X1;
procedure Op3CM1X0;
procedure Op3CM0X0;
procedure Op3CSlow;
procedure Op3DM1X1;
procedure Op3DM0X1;
procedure Op3DM1X0;
procedure Op3DM0X0;
procedure Op3DSlow;
procedure Op3EM1X1;
procedure Op3EM0X1;
procedure Op3EM1X0;
procedure Op3EM0X0;
procedure Op3ESlow;
procedure Op3FM1;
procedure Op3FM0;
procedure Op3FSlow;
procedure Op40Slow;
procedure Op41E1;
procedure Op41E0M1;
procedure Op41E0M0;
procedure Op41Slow;
procedure Op42;
procedure Op43M1;
procedure Op43M0;
procedure Op43Slow;
procedure Op44X1;
procedure Op44X0;
procedure Op44Slow;
procedure Op45M1;
procedure Op45M0;
procedure Op45Slow;
procedure Op46M1;
procedure Op46M0;
procedure Op46Slow;
procedure Op47M1;
procedure Op47M0;
procedure Op47Slow;
procedure Op48E1;
procedure Op48E0M1;
procedure Op48E0M0;
procedure Op48Slow;
procedure Op49M1;
procedure Op49M0;
procedure Op49Slow;
procedure Op4AM1;
procedure Op4AM0;
procedure Op4ASlow;
procedure Op4BE1;
procedure Op4BE0;
procedure Op4BSlow;
procedure Op4C;
procedure Op4CSlow;
procedure Op4DM1;
procedure Op4DM0;
procedure Op4DSlow;
procedure Op4EM1;
procedure Op4EM0;
procedure Op4ESlow;
procedure Op4FM1;
procedure Op4FM0;
procedure Op4FSlow;
procedure Op50E1;
procedure Op50E0;
procedure Op50Slow;
procedure Op51E1;
procedure Op51E0M1X1;
procedure Op51E0M0X1;
procedure Op51E0M1X0;
procedure Op51E0M0X0;
procedure Op51Slow;
procedure Op52E1;
procedure Op52E0M1;
procedure Op52E0M0;
procedure Op52Slow;
procedure Op53M1;
procedure Op53M0;
procedure Op53Slow;
procedure Op54X1;
procedure Op54X0;
procedure Op54Slow;
procedure Op55E1;
procedure Op55E0M1;
procedure Op55E0M0;
procedure Op55Slow;
procedure Op56E1;
procedure Op56E0M1;
procedure Op56E0M0;
procedure Op56Slow;
procedure Op57M1;
procedure Op57M0;
procedure Op57Slow;
procedure Op58;
procedure Op59M1X1;
procedure Op59M0X1;
procedure Op59M1X0;
procedure Op59M0X0;
procedure Op59Slow;
procedure Op5AE1;
procedure Op5AE0X1;
procedure Op5AE0X0;
procedure Op5ASlow;
procedure Op5B;
procedure Op5C;
procedure Op5CSlow;
procedure Op5DM1X1;
procedure Op5DM0X1;
procedure Op5DM1X0;
procedure Op5DM0X0;
procedure Op5DSlow;
procedure Op5EM1X1;
procedure Op5EM0X1;
procedure Op5EM1X0;
procedure Op5EM0X0;
procedure Op5ESlow;
procedure Op5FM1;
procedure Op5FM0;
procedure Op5FSlow;
procedure Op60E1;
procedure Op60E0;
procedure Op60Slow;
procedure Op61E1;
procedure Op61E0M1;
procedure Op61E0M0;
procedure Op61Slow;
procedure Op62E1;
procedure Op62E0;
procedure Op62Slow;
procedure Op63M1;
procedure Op63M0;
procedure Op63Slow;
procedure Op64M1;
procedure Op64M0;
procedure Op64Slow;
procedure Op65M1;
procedure Op65M0;
procedure Op65Slow;
procedure Op66M1;
procedure Op66M0;
procedure Op66Slow;
procedure Op67M1;
procedure Op67M0;
procedure Op67Slow;
procedure Op68E1;
procedure Op68E0M1;
procedure Op68E0M0;
procedure Op68Slow;
procedure Op69M1;
procedure Op69M0;
procedure Op69Slow;
procedure Op6AM1;
procedure Op6AM0;
procedure Op6ASlow;
procedure Op6BE1;
procedure Op6BE0;
procedure Op6BSlow;
procedure Op6C;
procedure Op6CSlow;
procedure Op6DM1;
procedure Op6DM0;
procedure Op6DSlow;
procedure Op6EM1;
procedure Op6EM0;
procedure Op6ESlow;
procedure Op6FM1;
procedure Op6FM0;
procedure Op6FSlow;
procedure Op70E1;
procedure Op70E0;
procedure Op70Slow;
procedure Op71E1;
procedure Op71E0M1X1;
procedure Op71E0M0X1;
procedure Op71E0M1X0;
procedure Op71E0M0X0;
procedure Op71Slow;
procedure Op72E1;
procedure Op72E0M1;
procedure Op72E0M0;
procedure Op72Slow;
procedure Op73M1;
procedure Op73M0;
procedure Op73Slow;
procedure Op74E1;
procedure Op74E0M1;
procedure Op74E0M0;
procedure Op74Slow;
procedure Op75E1;
procedure Op75E0M1;
procedure Op75E0M0;
procedure Op75Slow;
procedure Op76E1;
procedure Op76E0M1;
procedure Op76E0M0;
procedure Op76Slow;
procedure Op77M1;
procedure Op77M0;
procedure Op77Slow;
procedure Op78;
procedure Op79M1X1;
procedure Op79M0X1;
procedure Op79M1X0;
procedure Op79M0X0;
procedure Op79Slow;
procedure Op7AE1;
procedure Op7AE0X1;
procedure Op7AE0X0;
procedure Op7ASlow;
procedure Op7B;
procedure Op7C;
procedure Op7CSlow;
procedure Op7DM1X1;
procedure Op7DM0X1;
procedure Op7DM1X0;
procedure Op7DM0X0;
procedure Op7DSlow;
procedure Op7EM1X1;
procedure Op7EM0X1;
procedure Op7EM1X0;
procedure Op7EM0X0;
procedure Op7ESlow;
procedure Op7FM1;
procedure Op7FM0;
procedure Op7FSlow;
procedure Op80E1;
procedure Op80E0;
procedure Op80Slow;
procedure Op81E1;
procedure Op81E0M1;
procedure Op81E0M0;
procedure Op81Slow;
procedure Op82;
procedure Op82Slow;
procedure Op83M1;
procedure Op83M0;
procedure Op83Slow;
procedure Op84X1;
procedure Op84X0;
procedure Op84Slow;
procedure Op85M1;
procedure Op85M0;
procedure Op85Slow;
procedure Op86X1;
procedure Op86X0;
procedure Op86Slow;
procedure Op87M1;
procedure Op87M0;
procedure Op87Slow;
procedure Op88X1;
procedure Op88X0;
procedure Op88Slow;
procedure Op89M1;
procedure Op89M0;
procedure Op89Slow;
procedure Op8AM1;
procedure Op8AM0;
procedure Op8ASlow;
procedure Op8BE1;
procedure Op8BE0;
procedure Op8BSlow;
procedure Op8CX1;
procedure Op8CX0;
procedure Op8CSlow;
procedure Op8DM1;
procedure Op8DM0;
procedure Op8DSlow;
procedure Op8EX1;
procedure Op8EX0;
procedure Op8ESlow;
procedure Op8FM1;
procedure Op8FM0;
procedure Op8FSlow;
procedure Op90E1;
procedure Op90E0;
procedure Op90Slow;
procedure Op91E1;
procedure Op91E0M1X1;
procedure Op91E0M0X1;
procedure Op91E0M1X0;
procedure Op91E0M0X0;
procedure Op91Slow;
procedure Op92E1;
procedure Op92E0M1;
procedure Op92E0M0;
procedure Op92Slow;
procedure Op93M1;
procedure Op93M0;
procedure Op93Slow;
procedure Op94E1;
procedure Op94E0X1;
procedure Op94E0X0;
procedure Op94Slow;
procedure Op95E1;
procedure Op95E0M1;
procedure Op95E0M0;
procedure Op95Slow;
procedure Op96E1;
procedure Op96E0X1;
procedure Op96E0X0;
procedure Op96Slow;
procedure Op97M1;
procedure Op97M0;
procedure Op97Slow;
procedure Op98M1;
procedure Op98M0;
procedure Op98Slow;
procedure Op99M1X1;
procedure Op99M0X1;
procedure Op99M1X0;
procedure Op99M0X0;
procedure Op99Slow;
procedure Op9A;
procedure Op9BX1;
procedure Op9BX0;
procedure Op9BSlow;
procedure Op9CM1;
procedure Op9CM0;
procedure Op9CSlow;
procedure Op9DM1X1;
procedure Op9DM0X1;
procedure Op9DM1X0;
procedure Op9DM0X0;
procedure Op9DSlow;
procedure Op9EM1X1;
procedure Op9EM0X1;
procedure Op9EM1X0;
procedure Op9EM0X0;
procedure Op9ESlow;
procedure Op9FM1;
procedure Op9FM0;
procedure Op9FSlow;
procedure OpA0X1;
procedure OpA0X0;
procedure OpA0Slow;
procedure OpA1E1;
procedure OpA1E0M1;
procedure OpA1E0M0;
procedure OpA1Slow;
procedure OpA2X1;
procedure OpA2X0;
procedure OpA2Slow;
procedure OpA3M1;
procedure OpA3M0;
procedure OpA3Slow;
procedure OpA4X1;
procedure OpA4X0;
procedure OpA4Slow;
procedure OpA5M1;
procedure OpA5M0;
procedure OpA5Slow;
procedure OpA6X1;
procedure OpA6X0;
procedure OpA6Slow;
procedure OpA7M1;
procedure OpA7M0;
procedure OpA7Slow;
procedure OpA8X1;
procedure OpA8X0;
procedure OpA8Slow;
procedure OpA9M1;
procedure OpA9M0;
procedure OpA9Slow;
procedure OpAAX1;
procedure OpAAX0;
procedure OpAASlow;
procedure OpABE1;
procedure OpABE0;
procedure OpABSlow;
procedure OpACX1;
procedure OpACX0;
procedure OpACSlow;
procedure OpADM1;
procedure OpADM0;
procedure OpADSlow;
procedure OpAEX1;
procedure OpAEX0;
procedure OpAESlow;
procedure OpAFM1;
procedure OpAFM0;
procedure OpAFSlow;
procedure OpB0E1;
procedure OpB0E0;
procedure OpB0Slow;
procedure OpB1E1;
procedure OpB1E0M1X1;
procedure OpB1E0M0X1;
procedure OpB1E0M1X0;
procedure OpB1E0M0X0;
procedure OpB1Slow;
procedure OpB2E1;
procedure OpB2E0M1;
procedure OpB2E0M0;
procedure OpB2Slow;
procedure OpB3M1;
procedure OpB3M0;
procedure OpB3Slow;
procedure OpB4E1;
procedure OpB4E0X1;
procedure OpB4E0X0;
procedure OpB4Slow;
procedure OpB5E1;
procedure OpB5E0M1;
procedure OpB5E0M0;
procedure OpB5Slow;
procedure OpB6E1;
procedure OpB6E0X1;
procedure OpB6E0X0;
procedure OpB6Slow;
procedure OpB7M1;
procedure OpB7M0;
procedure OpB7Slow;
procedure OpB8;
procedure OpB9M1X1;
procedure OpB9M0X1;
procedure OpB9M1X0;
procedure OpB9M0X0;
procedure OpB9Slow;
procedure OpBAX1;
procedure OpBAX0;
procedure OpBASlow;
procedure OpBBX1;
procedure OpBBX0;
procedure OpBBSlow;
procedure OpBCX1;
procedure OpBCX0;
procedure OpBCSlow;
procedure OpBDM1X1;
procedure OpBDM0X1;
procedure OpBDM1X0;
procedure OpBDM0X0;
procedure OpBDSlow;
procedure OpBEX1;
procedure OpBEX0;
procedure OpBESlow;
procedure OpBFM1;
procedure OpBFM0;
procedure OpBFSlow;
procedure OpC0X1;
procedure OpC0X0;
procedure OpC0Slow;
procedure OpC1E1;
procedure OpC1E0M1;
procedure OpC1E0M0;
procedure OpC1Slow;
procedure OpC2;
procedure OpC2Slow;
procedure OpC3M1;
procedure OpC3M0;
procedure OpC3Slow;
procedure OpC4X1;
procedure OpC4X0;
procedure OpC4Slow;
procedure OpC5M1;
procedure OpC5M0;
procedure OpC5Slow;
procedure OpC6M1;
procedure OpC6M0;
procedure OpC6Slow;
procedure OpC7M1;
procedure OpC7M0;
procedure OpC7Slow;
procedure OpC8X1;
procedure OpC8X0;
procedure OpC8Slow;
procedure OpC9M1;
procedure OpC9M0;
procedure OpC9Slow;
procedure OpCAX1;
procedure OpCAX0;
procedure OpCASlow;
procedure OpCB;
procedure OpCCX1;
procedure OpCCX0;
procedure OpCCSlow;
procedure OpCDM1;
procedure OpCDM0;
procedure OpCDSlow;
procedure OpCEM1;
procedure OpCEM0;
procedure OpCESlow;
procedure OpCFM1;
procedure OpCFM0;
procedure OpCFSlow;
procedure OpD0E1;
procedure OpD0E0;
procedure OpD0Slow;
procedure OpD1E1;
procedure OpD1E0M1X1;
procedure OpD1E0M0X1;
procedure OpD1E0M1X0;
procedure OpD1E0M0X0;
procedure OpD1Slow;
procedure OpD2E1;
procedure OpD2E0M1;
procedure OpD2E0M0;
procedure OpD2Slow;
procedure OpD3M1;
procedure OpD3M0;
procedure OpD3Slow;
procedure OpD4E1;
procedure OpD4E0;
procedure OpD4Slow;
procedure OpD5E1;
procedure OpD5E0M1;
procedure OpD5E0M0;
procedure OpD5Slow;
procedure OpD6E1;
procedure OpD6E0M1;
procedure OpD6E0M0;
procedure OpD6Slow;
procedure OpD7M1;
procedure OpD7M0;
procedure OpD7Slow;
procedure OpD8;
procedure OpD9M1X1;
procedure OpD9M0X1;
procedure OpD9M1X0;
procedure OpD9M0X0;
procedure OpD9Slow;
procedure OpDAE1;
procedure OpDAE0X1;
procedure OpDAE0X0;
procedure OpDASlow;
procedure OpDB;
procedure OpDC;
procedure OpDCSlow;
procedure OpDDM1X1;
procedure OpDDM0X1;
procedure OpDDM1X0;
procedure OpDDM0X0;
procedure OpDDSlow;
procedure OpDEM1X1;
procedure OpDEM0X1;
procedure OpDEM1X0;
procedure OpDEM0X0;
procedure OpDESlow;
procedure OpDFM1;
procedure OpDFM0;
procedure OpDFSlow;
procedure OpE0X1;
procedure OpE0X0;
procedure OpE0Slow;
procedure OpE1E1;
procedure OpE1E0M1;
procedure OpE1E0M0;
procedure OpE1Slow;
procedure OpE2;
procedure OpE2Slow;
procedure OpE3M1;
procedure OpE3M0;
procedure OpE3Slow;
procedure OpE4X1;
procedure OpE4X0;
procedure OpE4Slow;
procedure OpE5M1;
procedure OpE5M0;
procedure OpE5Slow;
procedure OpE6M1;
procedure OpE6M0;
procedure OpE6Slow;
procedure OpE7M1;
procedure OpE7M0;
procedure OpE7Slow;
procedure OpE8X1;
procedure OpE8X0;
procedure OpE8Slow;
procedure OpE9M1;
procedure OpE9M0;
procedure OpE9Slow;
procedure OpEA;
procedure OpEB;
procedure OpECX1;
procedure OpECX0;
procedure OpECSlow;
procedure OpEDM1;
procedure OpEDM0;
procedure OpEDSlow;
procedure OpEEM1;
procedure OpEEM0;
procedure OpEESlow;
procedure OpEFM1;
procedure OpEFM0;
procedure OpEFSlow;
procedure OpF0E1;
procedure OpF0E0;
procedure OpF0Slow;
procedure OpF1E1;
procedure OpF1E0M1X1;
procedure OpF1E0M0X1;
procedure OpF1E0M1X0;
procedure OpF1E0M0X0;
procedure OpF1Slow;
procedure OpF2E1;
procedure OpF2E0M1;
procedure OpF2E0M0;
procedure OpF2Slow;
procedure OpF3M1;
procedure OpF3M0;
procedure OpF3Slow;
procedure OpF4E1;
procedure OpF4E0;
procedure OpF4Slow;
procedure OpF5E1;
procedure OpF5E0M1;
procedure OpF5E0M0;
procedure OpF5Slow;
procedure OpF6E1;
procedure OpF6E0M1;
procedure OpF6E0M0;
procedure OpF6Slow;
procedure OpF7M1;
procedure OpF7M0;
procedure OpF7Slow;
procedure OpF8;
procedure OpF9M1X1;
procedure OpF9M0X1;
procedure OpF9M1X0;
procedure OpF9M0X0;
procedure OpF9Slow;
procedure OpFAE1;
procedure OpFAE0X1;
procedure OpFAE0X0;
procedure OpFASlow;
procedure OpFB;
procedure OpFCE1;
procedure OpFCE0;
procedure OpFCSlow;
procedure OpFDM1X1;
procedure OpFDM0X1;
procedure OpFDM1X0;
procedure OpFDM0X0;
procedure OpFDSlow;
procedure OpFEM1X1;
procedure OpFEM0X1;
procedure OpFEM1X0;
procedure OpFEM0X0;
procedure OpFESlow;
procedure OpFFM1;
procedure OpFFM0;
procedure OpFFSlow;

// --- Rotinas Especiais (BRK, NMI, IRQ) ---
procedure OpcodeNMI;
procedure OpcodeIRQ;


// Procedimento de inicialização para as tabelas de opcodes
procedure InitializeOpcodeTables;

implementation

uses
   System.SysUtils,
   SNES.Globals,
   SNES.CPU,
   SNES.Memory,
   SNES.CPU.Addressing;

// #################################
// ### ROTINAS AUXILIARES INLINE ###
// #################################

function CheckCarry: Boolean;
begin
   Result := ICPU.Carry;
end;

function CheckZero: Boolean;
begin
   Result := ICPU.Zero;
end;

function CheckIRQ: Boolean;
begin
   Result := (ICPU.Registers.P.L and FLAG_IRQ) <> 0;
end;

function CheckDecimal: Boolean;
begin
   Result := (ICPU.Registers.P.L and FLAG_DECIMAL) <> 0;
end;

function CheckIndex: Boolean;
begin
   Result := (ICPU.Registers.P.L and FLAG_INDEX) <> 0;
end;

function CheckMem: Boolean;
begin
   Result := (ICPU.Registers.P.L and FLAG_MEMORY) <> 0;
end;

function CheckOverflow: Boolean;
begin
   Result := ICPU.Overflow;
end;

function CheckNegative: Boolean;
begin
   Result := (ICPU.Negative and $80) <> 0;
end;

function CheckEmulation: Boolean; inline;
begin
   Result := (ICPU.Registers.P.W and FLAG_EMULATION) <> 0;
end;

procedure SetFlags(Flags: Cardinal); inline;
begin
   ICPU.Registers.P.W := ICPU.Registers.P.W or Word(Flags);
end;

procedure ClearFlags(Flags: Cardinal); inline;
begin
   ICPU.Registers.P.W := ICPU.Registers.P.W and not Word(Flags);
end;

procedure SetZN16(Work16: Word); inline;
begin
   ICPU.Zero := Work16 = 0;
   ICPU.Negative := Byte(Work16 shr 8);
end;

procedure SetZN8(Work8: Byte); inline;
begin
   ICPU.Zero := Work8 = 0;
   ICPU.Negative := Work8;
end;

procedure PackStatus; inline;
begin
   ICPU.Registers.P.L := ICPU.Registers.P.L and not (FLAG_ZERO or FLAG_NEGATIVE or FLAG_CARRY or FLAG_OVERFLOW);
   if ICPU.Carry then
      ICPU.Registers.P.L := ICPU.Registers.P.L or FLAG_CARRY;
   if ICPU.Zero then
      ICPU.Registers.P.L := ICPU.Registers.P.L or FLAG_ZERO;
   if ICPU.Overflow then
      ICPU.Registers.P.L := ICPU.Registers.P.L or FLAG_OVERFLOW;
   if (ICPU.Negative and $80) <> 0 then
      ICPU.Registers.P.L := ICPU.Registers.P.L or FLAG_NEGATIVE;
end;

procedure UnpackStatus; inline;
begin
   ICPU.Zero     := (ICPU.Registers.P.L and FLAG_ZERO) = 0;
   ICPU.Negative := ICPU.Registers.P.L and FLAG_NEGATIVE;
   ICPU.Carry    := (ICPU.Registers.P.L and FLAG_CARRY) <> 0;
   ICPU.Overflow := ((ICPU.Registers.P.L and FLAG_OVERFLOW) shr 6) <> 0;
end;

procedure FixCycles; inline;
begin
   if CheckEmulation then
   begin
      ICPU.Opcodes := @OpcodesE1;
      ICPU.OpLengths := @OpLengthsM1X1[0];
   end
   else if CheckMem then
   begin
      if CheckIndex then
      begin
         ICPU.Opcodes := @OpcodesM1X1;
         ICPU.OpLengths := @OpLengthsM1X1[0];
      end
      else
      begin
         ICPU.Opcodes := @OpcodesM1X0;
         ICPU.OpLengths := @OpLengthsM1X0[0];
      end;
   end
   else
   begin
      if CheckIndex then
      begin
         ICPU.Opcodes := @OpcodesM0X1;
         ICPU.OpLengths := @OpLengthsM0X1[0];
      end
      else
      begin
         ICPU.Opcodes := @OpcodesM0X0;
         ICPU.OpLengths := @OpLengthsM0X0[0];
      end;
   end;
end;

procedure CheckForIRQ; inline;
begin
   if (CPU.IRQActive <> 0) and ((ICPU.Registers.P.W and FLAG_IRQ) = 0) then
      OpcodeIRQ;
end;

// --- ADC (Add with Carry) ---
procedure ADC16(Work16: Word); inline;
var
   Ans32: Cardinal;
   Result, Carry: Cardinal;
begin
   if (ICPU.Registers.P.L and FLAG_DECIMAL) <> 0 then
   begin
      Carry := Ord(ICPU.Carry);
      Result := (ICPU.Registers.A.W and $000F) + (Work16 and $000F) + Carry;
      if Result > $0009 then
         Result := Result + $0006;
      Carry := Ord(Result > $000F);
      Result := (ICPU.Registers.A.W and $00F0) + (Work16 and $00F0) + (Result and $000F) + Carry * $10;
      if Result > $009F then
         Result := Result + $0060;
      Carry := Ord(Result > $00FF);
      Result := (ICPU.Registers.A.W and $0F00) + (Work16 and $0F00) + (Result and $00FF) + Carry * $100;
      if Result > $09FF then
         Result := Result + $0600;
      Carry := Ord(Result > $0FFF);
      Result := (ICPU.Registers.A.W and $F000) + (Work16 and $F000) + (Result and $0FFF) + Carry * $1000;

      if ((ICPU.Registers.A.W and $8000) = (Work16 and $8000)) and ((ICPU.Registers.A.W and $8000) <> (Result and $8000)) then
         ICPU.Overflow := True
      else
         ICPU.Overflow := False;

      if Result > $9FFF then
         Result := Result + $6000;
      ICPU.Carry := Result > $FFFF;
      ICPU.Registers.A.W := Word(Result);
   end
   else
   begin
      Ans32 := ICPU.Registers.A.W + Work16 + Ord(ICPU.Carry);
      ICPU.Carry := Ans32 > $FFFF;
      if (not (ICPU.Registers.A.W xor Work16) and (Work16 xor Word(Ans32))) and $8000 <> 0 then
         ICPU.Overflow := True
      else
         ICPU.Overflow := False;
      ICPU.Registers.A.W := Word(Ans32);
   end;
   SetZN16(ICPU.Registers.A.W);
end;

procedure ADC8(Work8: Byte); inline;
var
   Ans16: Word;
   Result, Carry: Cardinal;
begin
   if (ICPU.Registers.P.L and FLAG_DECIMAL) <> 0 then
   begin
      Carry := Ord(ICPU.Carry);
      Result := (ICPU.Registers.A.L and $0F) + (Work8 and $0F) + Carry;
      if Result > $09 then Result := Result + $06;
         Carry := Ord(Result > $0F);
      Result := (ICPU.Registers.A.L and $F0) + (Work8 and $F0) + (Result and $0F) + Carry * $10;

      if ((ICPU.Registers.A.L and $80) = (Work8 and $80)) and ((ICPU.Registers.A.L and $80) <> (Result and $80)) then
         ICPU.Overflow := True
      else
         ICPU.Overflow := False;

      if Result > $9F then Result := Result + $60;
         ICPU.Carry := Result > $FF;
      ICPU.Registers.A.L := Byte(Result);
   end
   else
   begin
      Ans16 := ICPU.Registers.A.L + Work8 + Ord(ICPU.Carry);
      ICPU.Carry := Ans16 > $FF;
      if (not (ICPU.Registers.A.L xor Work8) and (Work8 xor Byte(Ans16))) and $80 <> 0 then
         ICPU.Overflow := True
      else
         ICPU.Overflow := False;
      ICPU.Registers.A.L := Byte(Ans16);
   end;
   SetZN8(ICPU.Registers.A.L);
end;

// --- AND (Logical AND) ---
procedure AND16(Work16: Word); inline;
begin
   ICPU.Registers.A.W := ICPU.Registers.A.W and Work16;
   SetZN16(ICPU.Registers.A.W);
end;

procedure AND8(Work8: Byte); inline;
begin
   ICPU.Registers.A.L := ICPU.Registers.A.L and Work8;
   SetZN8(ICPU.Registers.A.L);
end;

// --- ASL (Arithmetic Shift Left) ---
procedure ASL16(OpAddress: Cardinal; w: TWrapType); inline;
var
   Work16: Word;
begin
   Work16 := GetWord(OpAddress, w);
   ICPU.Carry := (Work16 and $8000) <> 0;
   Work16 := Work16 shl 1;
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   SetWord(Work16, OpAddress, w, WRITE_10);
   ICPU.OpenBus := Work16 and $ff;
   SetZN16(Work16);
end;

procedure ASL8(OpAddress: Cardinal); inline;
var
   Work8: Byte;
begin
   Work8 := GetByte(OpAddress);
   ICPU.Carry := (Work8 and $80) <> 0;
   Work8 := Work8 shl 1;
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   SetByte(Work8, OpAddress);
   ICPU.OpenBus := Work8;
   SetZN8(Work8);
end;

// --- BIT (Test Bits) ---
procedure BIT16(Work16: Word); inline;
begin
   ICPU.Overflow := (Work16 and $4000) <> 0;
   ICPU.Negative := Byte(Work16 shr 8);
   ICPU.Zero := (Work16 and ICPU.Registers.A.W) = 0;
end;

procedure BIT8(Work8: Byte); inline;
begin
   ICPU.Overflow := (Work8 and $40) <> 0;
   ICPU.Negative := Work8;
   ICPU.Zero := (Work8 and ICPU.Registers.A.L) = 0;
end;

// --- CMP (Compare Accumulator) ---
procedure CMP16(val: Word); inline;
var
   Int32: Integer;
begin
   Int32 := SmallInt(ICPU.Registers.A.W) - SmallInt(val);
   ICPU.Carry := Int32 >= 0;
   SetZN16(Word(Int32));
end;

procedure CMP8(val: Byte); inline;
var
   Int16: SmallInt;
begin
   Int16 := SmallInt(ICPU.Registers.A.L) - SmallInt(val);
   ICPU.Carry := Int16 >= 0;
   SetZN8(Byte(Int16));
end;

// --- CPX (Compare X Register) ---
procedure CPX16(val: Word); inline;
var
   Int32: Integer;
begin
   Int32 := SmallInt(ICPU.Registers.X.W) - SmallInt(val);
   ICPU.Carry := Int32 >= 0;
   SetZN16(Word(Int32));
end;

procedure CPX8(val: Byte); inline;
var
   Int16: SmallInt;
begin
   Int16 := SmallInt(ICPU.Registers.X.L) - SmallInt(val);
   ICPU.Carry := Int16 >= 0;
   SetZN8(Byte(Int16));
end;

// --- CPY (Compare Y Register) ---
procedure CPY16(val: Word); inline;
var
   Int32: Integer;
begin
   Int32 := SmallInt(ICPU.Registers.Y.W) - SmallInt(val);
   ICPU.Carry := Int32 >= 0;
   SetZN16(Word(Int32));
end;

procedure CPY8(val: Byte); inline;
var
   Int16: SmallInt;
begin
   Int16 := SmallInt(ICPU.Registers.Y.L) - SmallInt(val);
   ICPU.Carry := Int16 >= 0;
   SetZN8(Byte(Int16));
end;

// --- DEC (Decrement) ---
procedure DEC16(OpAddress: Cardinal; w: TWrapType); inline;
var
   Work16: Word;
begin
   CPU.WaitPC := 0;
   Work16 := GetWord(OpAddress, w) - 1;
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   SetWord(Work16, OpAddress, w, WRITE_10);
   ICPU.OpenBus := Work16 and $ff;
   SetZN16(Work16);
end;

procedure DEC8(OpAddress: Cardinal); inline;
var
   Work8: Byte;
begin
   CPU.WaitPC := 0;
   Work8 := GetByte(OpAddress) - 1;
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   SetByte(Work8, OpAddress);
   ICPU.OpenBus := Work8;
   SetZN8(Work8);
end;

// --- EOR (Exclusive OR) ---
procedure EOR16(val: Word); inline;
begin
   ICPU.Registers.A.W := ICPU.Registers.A.W xor val;
   SetZN16(ICPU.Registers.A.W);
end;

procedure EOR8(val: Byte); inline;
begin
   ICPU.Registers.A.L := ICPU.Registers.A.L xor val;
   SetZN8(ICPU.Registers.A.L);
end;

// --- INC (Increment) ---
procedure INC16(OpAddress: Cardinal; w: TWrapType); inline;
var
   Work16: Word;
begin
   CPU.WaitPC := 0;
   Work16 := GetWord(OpAddress, w) + 1;
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   SetWord(Work16, OpAddress, w, WRITE_10);
   ICPU.OpenBus := Work16 and $ff;
   SetZN16(Work16);
end;

procedure INC8(OpAddress: Cardinal); inline;
var
   Work8: Byte;
begin
   CPU.WaitPC := 0;
   Work8 := GetByte(OpAddress) + 1;
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   SetByte(Work8, OpAddress);
   ICPU.OpenBus := Work8;
   SetZN8(Work8);
end;

// --- LDA (Load Accumulator) ---
procedure LDA16(val: Word); inline;
begin
   ICPU.Registers.A.W := val;
   SetZN16(ICPU.Registers.A.W);
end;

procedure LDA8(val: Byte); inline;
begin
   ICPU.Registers.A.L := val;
   SetZN8(ICPU.Registers.A.L);
end;

// --- LDX (Load X Register) ---
procedure LDX16(val: Word); inline;
begin
   ICPU.Registers.X.W := val;
   SetZN16(ICPU.Registers.X.W);
end;

procedure LDX8(val: Byte); inline;
begin
   ICPU.Registers.X.L := val;
   SetZN8(ICPU.Registers.X.L);
end;

// --- LDY (Load Y Register) ---
procedure LDY16(val: Word); inline;
begin
   ICPU.Registers.Y.W := val;
   SetZN16(ICPU.Registers.Y.W);
end;

procedure LDY8(val: Byte); inline;
begin
   ICPU.Registers.Y.L := val;
   SetZN8(ICPU.Registers.Y.L);
end;

// --- LSR (Logical Shift Right) ---
procedure LSR16(OpAddress: Cardinal; w: TWrapType); inline;
var
   Work16: Word;
begin
   Work16 := GetWord(OpAddress, w);
   ICPU.Carry := (Work16 and 1) <> 0;
   Work16 := Work16 shr 1;
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   SetWord(Work16, OpAddress, w, WRITE_10);
   ICPU.OpenBus := Work16 and $ff;
   SetZN16(Work16);
end;

procedure LSR8(OpAddress: Cardinal); inline;
var
   Work8: Byte;
begin
   Work8 := GetByte(OpAddress);
   ICPU.Carry := (Work8 and 1) <> 0;
   Work8 := Work8 shr 1;
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   SetByte(Work8, OpAddress);
   ICPU.OpenBus := Work8;
   SetZN8(Work8);
end;

// --- ORA (Logical OR) ---
procedure ORA16(val: Word); inline;
begin
   ICPU.Registers.A.W := ICPU.Registers.A.W or val;
   SetZN16(ICPU.Registers.A.W);
end;

procedure ORA8(val: Byte); inline;
begin
   ICPU.Registers.A.L := ICPU.Registers.A.L or val;
   SetZN8(ICPU.Registers.A.L);
end;

// --- ROL (Rotate Left) ---
procedure ROL16(OpAddress: Cardinal; w: TWrapType); inline;
var
   Work32: Cardinal;
begin
   Work32 := (Cardinal(GetWord(OpAddress, w)) shl 1) or Ord(ICPU.Carry);
   ICPU.Carry := Work32 > $ffff;
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   SetWord(Word(Work32), OpAddress, w, WRITE_10);
   ICPU.OpenBus := Work32 and $ff;
   SetZN16(Word(Work32));
end;

procedure ROL8(OpAddress: Cardinal); inline;
var
   Work16: Word;
begin
   Work16 := (Word(GetByte(OpAddress)) shl 1) or Ord(ICPU.Carry);
   ICPU.Carry := Work16 > $ff;
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   SetByte(Byte(Work16), OpAddress);
   ICPU.OpenBus := Work16 and $ff;
   SetZN8(Byte(Work16));
end;

// --- ROR (Rotate Right) ---
procedure ROR16(OpAddress: Cardinal; w: TWrapType); inline;
var
   Work32: Cardinal;
begin
   Work32 := Cardinal(GetWord(OpAddress, w)) or (Cardinal(Ord(ICPU.Carry)) shl 16);
   ICPU.Carry := (Work32 and 1) <> 0;
   Work32 := Work32 shr 1;
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   SetWord(Word(Work32), OpAddress, w, WRITE_10);
   ICPU.OpenBus := Work32 and $ff;
   SetZN16(Word(Work32));
end;

procedure ROR8(OpAddress: Cardinal); inline;
var
   Work16: Word;
begin
   Work16 := Word(GetByte(OpAddress)) or (Word(Ord(ICPU.Carry)) shl 8);
   ICPU.Carry := (Work16 and 1) <> 0;
   Work16 := Work16 shr 1;
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   SetByte(Byte(Work16), OpAddress);
   ICPU.OpenBus := Work16 and $ff;
   SetZN8(Byte(Work16));
end;

// --- SBC (Subtract with Carry) ---
procedure SBC16(Work16: Word); inline;
var
   Int32: Integer;
   Result: Integer;
   Carry: Integer;
   temp: Word;
begin
   if (ICPU.Registers.P.L and FLAG_DECIMAL) <> 0 then
   begin
      temp := Work16;
      Carry := Ord(ICPU.Carry);
      Result := (ICPU.Registers.A.W and $000F) - (temp and $000F) + Carry - 1;
      if Result < 0 then
      begin
         Result := Result - 6;
         Carry := 0;
      end
      else
      begin
         Carry := 1;
      end;
      Result := (ICPU.Registers.A.W and $00F0) - (temp and $00F0) + (Result and $000F) + (Carry - 1) * $10;
      if Result < 0 then
      begin
         Result := Result - $60;
         Carry := 0;
      end
      else
      begin
         Carry := 1;
      end;
      Result := (ICPU.Registers.A.W and $0F00) - (temp and $0F00) + (Result and $00FF) + (Carry - 1) * $100;
      if Result < 0 then
      begin
         Result := Result - $600;
         Carry := 0;
      end
      else
      begin
         Carry := 1;
      end;
      Result := (ICPU.Registers.A.W and $F000) - (temp and $F000) + (Result and $0FFF) + (Carry - 1) * $1000;

      if (((ICPU.Registers.A.W xor temp) and $8000) = 0) and (((ICPU.Registers.A.W xor Word(Result)) and $8000) <> 0) then
         ICPU.Overflow := True
      else
         ICPU.Overflow := False;

      if Result < 0 then
      begin
         Result := Result - $6000;
         ICPU.Carry := False;
      end
      else
      begin
         ICPU.Carry := True;
      end;

      ICPU.Registers.A.W := Word(Result);
      SetZN16(ICPU.Registers.A.W);
   end
   else
   begin
      Int32 := SmallInt(ICPU.Registers.A.W) - SmallInt(Work16) + Ord(ICPU.Carry) - 1;
      ICPU.Carry := Int32 >= 0;
      if ((ICPU.Registers.A.W xor Work16) and (ICPU.Registers.A.W xor Word(Int32))) and $8000 <> 0 then
         ICPU.Overflow := True
      else
         ICPU.Overflow := False;
      ICPU.Registers.A.W := Word(Int32);
      SetZN16(ICPU.Registers.A.W);
   end;
end;

procedure SBC8(Work8: Byte); inline;
var
   Int16: SmallInt;
   Result: Integer;
   Carry: Integer;
   temp: Byte;
begin
   if (ICPU.Registers.P.L and FLAG_DECIMAL) <> 0 then
   begin
      temp := Work8;
      Carry := Ord(ICPU.Carry);
      Result := (ICPU.Registers.A.L and $0F) - (temp and $0F) + Carry - 1;
      if Result < 0 then
      begin
         Result := Result - 6;
         Carry := 0;
      end
      else
      begin
         Carry := 1;
      end;
      Result := (ICPU.Registers.A.L and $F0) - (temp and $F0) + (Result and $0F) + (Carry - 1) * $10;

      if (((ICPU.Registers.A.L xor temp) and $80) = 0) and (((ICPU.Registers.A.L xor Byte(Result)) and $80) <> 0) then
         ICPU.Overflow := True
      else
         ICPU.Overflow := False;

      if Result < 0 then
      begin
         Result := Result - $60;
         ICPU.Carry := False;
      end
      else
      begin
         ICPU.Carry := True;
      end;

      ICPU.Registers.A.L := Byte(Result);
      SetZN8(ICPU.Registers.A.L);
   end
   else
   begin
      Int16 := SmallInt(ICPU.Registers.A.L) - SmallInt(Work8) + Ord(ICPU.Carry) - 1;
      ICPU.Carry := Int16 >= 0;
      if ((ICPU.Registers.A.L xor Work8) and (ICPU.Registers.A.L xor Byte(Int16))) and $80 <> 0 then
         ICPU.Overflow := True
      else
         ICPU.Overflow := False;
      ICPU.Registers.A.L := Byte(Int16);
      SetZN8(ICPU.Registers.A.L);
   end;
end;

// --- STA (Store Accumulator) ---
procedure STA16(OpAddress: Cardinal; w: TWrapType); inline;
begin
   SetWord(ICPU.Registers.A.W, OpAddress, w, WRITE_01);
   ICPU.OpenBus := ICPU.Registers.A.H;
end;

procedure STA8(OpAddress: Cardinal); inline;
begin
   SetByte(ICPU.Registers.A.L, OpAddress);
   ICPU.OpenBus := ICPU.Registers.A.L;
end;

// --- STX (Store X Register) ---
procedure STX16(OpAddress: Cardinal; w: TWrapType); inline;
begin
   SetWord(ICPU.Registers.X.W, OpAddress, w, WRITE_01);
   ICPU.OpenBus := ICPU.Registers.X.H;
end;

procedure STX8(OpAddress: Cardinal); inline;
begin
   SetByte(ICPU.Registers.X.L, OpAddress);
   ICPU.OpenBus := ICPU.Registers.X.L;
end;

// --- STY (Store Y Register) ---
procedure STY16(OpAddress: Cardinal; w: TWrapType); inline;
begin
   SetWord(ICPU.Registers.Y.W, OpAddress, w, WRITE_01);
   ICPU.OpenBus := ICPU.Registers.Y.H;
end;

procedure STY8(OpAddress: Cardinal); inline;
begin
   SetByte(ICPU.Registers.Y.L, OpAddress);
   ICPU.OpenBus := ICPU.Registers.Y.L;
end;

// --- STZ (Store Zero) ---
procedure STZ16(OpAddress: Cardinal; w: TWrapType); inline;
begin
   SetWord(0, OpAddress, w, WRITE_01);
   ICPU.OpenBus := 0;
end;

procedure STZ8(OpAddress: Cardinal); inline;
begin
   SetByte(0, OpAddress);
   ICPU.OpenBus := 0;
end;

// --- TSB (Test and Set Bits) ---
procedure TSB16(OpAddress: Cardinal; w: TWrapType); inline;
var
   Work16: Word;
begin
   Work16 := GetWord(OpAddress, w);
   ICPU.Zero := (Work16 and ICPU.Registers.A.W) = 0;
   Work16 := Work16 or ICPU.Registers.A.W;
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   SetWord(Work16, OpAddress, w, WRITE_10);
   ICPU.OpenBus := Work16 and $ff;
end;

procedure TSB8(OpAddress: Cardinal); inline;
var
   Work8: Byte;
begin
   Work8 := GetByte(OpAddress);
   ICPU.Zero := (Work8 and ICPU.Registers.A.L) = 0;
   Work8 := Work8 or ICPU.Registers.A.L;
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   SetByte(Work8, OpAddress);
   ICPU.OpenBus := Work8;
end;

// --- TRB (Test and Reset Bits) ---
procedure TRB16(OpAddress: Cardinal; w: TWrapType); inline;
var
   Work16: Word;
begin
   Work16 := GetWord(OpAddress, w);
   ICPU.Zero := (Work16 and ICPU.Registers.A.W) = 0;
   Work16 := Work16 and not ICPU.Registers.A.W;
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   SetWord(Work16, OpAddress, w, WRITE_10);
   ICPU.OpenBus := Work16 and $ff;
end;

procedure TRB8(OpAddress: Cardinal); inline;
var
   Work8: Byte;
begin
   Work8 := GetByte(OpAddress);
   ICPU.Zero := (Work8 and ICPU.Registers.A.L) = 0;
   Work8 := Work8 and not ICPU.Registers.A.L;
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   SetByte(Work8, OpAddress);
   ICPU.OpenBus := Work8;
end;

// --- Stack Operations (from cpuops.c) ---
procedure PushB(b: Byte); inline;
begin
   SetByte(b, ICPU.Registers.S.W);
   Dec(ICPU.Registers.S.W);
end;

procedure PushBE(b: Byte); inline;
begin
   SetByte(b, ICPU.Registers.S.W);
   Dec(ICPU.Registers.S.L);
end;

procedure PushW(w: Word); inline;
begin
   SetWord(w, ICPU.Registers.S.W - 1, WRAP_BANK, WRITE_10);
   Dec(ICPU.Registers.S.W, 2);
end;

procedure PushWE(w: Word); inline;
begin
   Dec(ICPU.Registers.S.L);
   SetWord(w, ICPU.Registers.S.W, WRAP_PAGE, WRITE_10);
   Dec(ICPU.Registers.S.L);
end;

function PullB: Byte; inline;
begin
   Inc(ICPU.Registers.S.W);
   Result := GetByte(ICPU.Registers.S.W);
end;

function PullBE: Byte; inline;
begin
   Inc(ICPU.Registers.S.L);
   Result := GetByte(ICPU.Registers.S.W);
end;

function PullW: Word; inline;
begin
   Inc(ICPU.Registers.S.W, 2);
   Result := GetWord(ICPU.Registers.S.W - 1, WRAP_BANK);
end;

function PullWE: Word; inline;
begin
   Inc(ICPU.Registers.S.L);
   Result := GetWord(ICPU.Registers.S.W, WRAP_PAGE);
   Inc(ICPU.Registers.S.L);
end;


// #############################################################################
// # IMPLEMENTAÇÃO DOS OPCODES (EXPANSÃO MANUAL de cpuops.c)
// #############################################################################

procedure Op00; // BRK
var
   emulation: Boolean;
   addr: Word;
begin
   CPU.Cycles := CPU.Cycles + CPU.MemSpeed;
   emulation := CheckEmulation;

   if emulation then
   begin
      PushWE(ICPU.Registers.PCw.PC.W + 1);
      PackStatus;
      PushBE(ICPU.Registers.P.L);
   end
   else
   begin
      PushB(ICPU.Registers.PCw.PB);
      PushW(ICPU.Registers.PCw.PC.W + 1);
      PackStatus;
      PushB(ICPU.Registers.P.L);
   end;

   ICPU.OpenBus := ICPU.Registers.P.L;
   ClearFlags(FLAG_DECIMAL);
   SetFlags(FLAG_IRQ);
   if emulation then
      addr := GetWord($FFFE, WRAP_NONE)
   else
      addr := GetWord($FFE6, WRAP_NONE);
   SetPCBase(addr);
   ICPU.OpenBus := addr shr 8;
end;

procedure Op01E0M1;
begin
   ICPU.OpenBus := GetByte(DirectIndexedIndirectE0(ACC_READ));
   ORA8(ICPU.OpenBus);
end;

procedure Op01E0M0;
begin
   var W := GetWord(DirectIndexedIndirectE0(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(W shr 8);
   ORA16(W);
end;

procedure Op01E1;
begin
   ICPU.OpenBus := GetByte(DirectIndexedIndirectE1(ACC_READ));
   ORA8(ICPU.OpenBus);
end;

procedure Op01Slow;
begin
   var addr := DirectIndexedIndirectSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      ORA8(ICPU.OpenBus);
   end
   else
   begin
      var W := GetWord(addr, WRAP_NONE);
      ICPU.OpenBus := Byte(W shr 8);
      ORA16(W);
   end;
end;

procedure Op02; // COP
var
   emulation: Boolean;
   addr: Word;
begin
   CPU.Cycles := CPU.Cycles + CPU.MemSpeed;
   emulation := CheckEmulation;

   if emulation then
   begin
      PushWE(ICPU.Registers.PCw.PC.W + 1);
      PackStatus;
      PushBE(ICPU.Registers.P.L);
   end
   else
   begin
      PushB(ICPU.Registers.PCw.PB);
      PushW(ICPU.Registers.PCw.PC.W + 1);
      PackStatus;
      PushB(ICPU.Registers.P.L);
   end;

   ICPU.OpenBus := ICPU.Registers.P.L;
   ClearFlags(FLAG_DECIMAL);
   SetFlags(FLAG_IRQ);
   if emulation then
      addr := GetWord($FFF4, WRAP_NONE)
   else
      addr := GetWord($FFE4, WRAP_NONE);
   SetPCBase(addr);
   ICPU.OpenBus := addr shr 8;
end;

procedure Op03M1;
begin
   ICPU.OpenBus := GetByte(StackRelative(ACC_READ));
   ORA8(ICPU.OpenBus);
end;

procedure Op03M0;
begin
   var W := GetWord(StackRelative(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(W shr 8);
   ORA16(W);
end;

procedure Op03Slow;
begin
   var addr := StackRelativeSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      ORA8(ICPU.OpenBus);
   end
   else
   begin
      var W := GetWord(addr, WRAP_NONE);
      ICPU.OpenBus := Byte(W shr 8);
      ORA16(W);
   end;
end;

procedure Op04M1;
begin
   TSB8(Direct(ACC_MODIFY));
end;

procedure Op04M0;
begin
   TSB16(Direct(ACC_MODIFY), WRAP_BANK);
end;

procedure Op04Slow;
begin
   if CheckMem then
      TSB8(DirectSlow(ACC_MODIFY))
   else
      TSB16(DirectSlow(ACC_MODIFY), WRAP_BANK);
end;

procedure Op05M1;
begin
   ICPU.OpenBus := GetByte(Direct(ACC_READ));
   ORA8(ICPU.OpenBus);
end;

procedure Op05M0;
begin
   var W := GetWord(Direct(ACC_READ), WRAP_BANK);
   ICPU.OpenBus := Byte(W shr 8);
   ORA16(W);
end;

procedure Op05Slow;
begin
   var addr := DirectSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      ORA8(ICPU.OpenBus);
   end
   else
   begin
      var W := GetWord(addr, WRAP_BANK);
      ICPU.OpenBus := Byte(W shr 8);
      ORA16(W);
   end;
end;

procedure Op06M1;
begin
   ASL8(Direct(ACC_MODIFY));
end;

procedure Op06M0;
begin
   ASL16(Direct(ACC_MODIFY), WRAP_BANK);
end;

procedure Op06Slow;
begin
   if CheckMem then
      ASL8(DirectSlow(ACC_MODIFY))
   else
      ASL16(DirectSlow(ACC_MODIFY), WRAP_BANK);
end;

procedure Op07M1;
begin
   ICPU.OpenBus := GetByte(DirectIndirectLong(ACC_READ));
   ORA8(ICPU.OpenBus);
end;

procedure Op07M0;
begin
   var W := GetWord(DirectIndirectLong(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(W shr 8);
   ORA16(W);
end;

procedure Op07Slow;
begin
   var addr := DirectIndirectLongSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      ORA8(ICPU.OpenBus);
   end
   else
   begin
      var W := GetWord(addr, WRAP_NONE);
      ICPU.OpenBus := Byte(W shr 8);
      ORA16(W);
   end;
end;

procedure Op08E1;
begin
   PackStatus;
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   PushBE(ICPU.Registers.P.L);
   ICPU.OpenBus := ICPU.Registers.P.L;
end;

procedure Op08E0;
begin
   PackStatus;
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   PushB(ICPU.Registers.P.L);
   ICPU.OpenBus := ICPU.Registers.P.L;
end;

procedure Op08Slow;
begin
   PackStatus;
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   if CheckEmulation then
      PushBE(ICPU.Registers.P.L)
   else
      PushB(ICPU.Registers.P.L);
   ICPU.OpenBus := ICPU.Registers.P.L;
end;

procedure Op09M1;
begin
   ORA8(Immediate8(ACC_READ));
end;

procedure Op09M0;
begin
   ORA16(Immediate16(ACC_READ));
end;

procedure Op09Slow;
begin
   if CheckMem then
      ORA8(Immediate8Slow(ACC_READ))
   else
      ORA16(Immediate16Slow(ACC_READ));
end;

procedure Op0AM1;
begin
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   ICPU.Carry := (ICPU.Registers.A.L and $80) <> 0;
   ICPU.Registers.A.L := ICPU.Registers.A.L shl 1;
   SetZN8(ICPU.Registers.A.L);
end;

procedure Op0AM0;
begin
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   ICPU.Carry := (ICPU.Registers.A.H and $80) <> 0;
   ICPU.Registers.A.W := ICPU.Registers.A.W shl 1;
   SetZN16(ICPU.Registers.A.W);
end;

procedure Op0ASlow;
begin
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   if CheckMem then
   begin
      ICPU.Carry := (ICPU.Registers.A.L and $80) <> 0;
      ICPU.Registers.A.L := ICPU.Registers.A.L shl 1;
      SetZN8(ICPU.Registers.A.L);
   end
   else
   begin
      ICPU.Carry := (ICPU.Registers.A.H and $80) <> 0;
      ICPU.Registers.A.W := ICPU.Registers.A.W shl 1;
      SetZN16(ICPU.Registers.A.W);
   end;
end;

procedure Op0BE1;
begin
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   PushW(ICPU.Registers.D.W);
   ICPU.OpenBus := ICPU.Registers.D.L;
   ICPU.Registers.S.H := 1;
end;

procedure Op0BE0;
begin
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   PushW(ICPU.Registers.D.W);
   ICPU.OpenBus := ICPU.Registers.D.L;
end;

procedure Op0BSlow;
begin
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   PushW(ICPU.Registers.D.W);
   ICPU.OpenBus := ICPU.Registers.D.L;
   if CheckEmulation then
      ICPU.Registers.S.H := 1;
end;

procedure Op0CM1;
begin
   TSB8(Absolute(ACC_MODIFY));
end;

procedure Op0CM0;
begin
   TSB16(Absolute(ACC_MODIFY), WRAP_NONE);
end;

procedure Op0CSlow;
begin
   if CheckMem then
      TSB8(AbsoluteSlow(ACC_MODIFY))
   else
      TSB16(AbsoluteSlow(ACC_MODIFY), WRAP_NONE);
end;

procedure Op0DM1;
begin
   ICPU.OpenBus := GetByte(Absolute(ACC_READ));
   ORA8(ICPU.OpenBus);
end;

procedure Op0DM0;
begin
   var W := GetWord(Absolute(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(W shr 8);
   ORA16(W);
end;

procedure Op0DSlow;
begin
   var addr := AbsoluteSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      ORA8(ICPU.OpenBus);
   end
   else
   begin
      var W := GetWord(addr, WRAP_NONE);
      ICPU.OpenBus := Byte(W shr 8);
      ORA16(W);
   end;
end;

procedure Op0EM1;
begin
   ASL8(Absolute(ACC_MODIFY));
end;

procedure Op0EM0;
begin
   ASL16(Absolute(ACC_MODIFY), WRAP_NONE);
end;

procedure Op0ESlow;
begin
   if CheckMem then
      ASL8(AbsoluteSlow(ACC_MODIFY))
   else
      ASL16(AbsoluteSlow(ACC_MODIFY), WRAP_NONE);
end;

procedure Op0FM1;
begin
   ICPU.OpenBus := GetByte(AbsoluteLong(ACC_READ));
   ORA8(ICPU.OpenBus);
end;

procedure Op0FM0;
begin
   var W := GetWord(AbsoluteLong(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(W shr 8);
   ORA16(W);
end;

procedure Op0FSlow;
begin
   var addr := AbsoluteLongSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      ORA8(ICPU.OpenBus);
   end
   else
   begin
      var  W := GetWord(addr, WRAP_NONE);
      ICPU.OpenBus := Byte(W shr 8);
      ORA16(W);
   end;
end;

procedure Op10E1;
var
   newPC: TPair;
begin
   newPC.W := Relative(ACC_JUMP);
   if not CheckNegative then
   begin
      CPU.Cycles := CPU.Cycles + Settings.OneCycle;
      if ICPU.Registers.PCw.PB <> newPC.H then
         CPU.Cycles := CPU.Cycles + Settings.OneCycle;
      if (ICPU.Registers.PCw.PC.W and not MEMMAP_MASK) <> (newPC.W and not MEMMAP_MASK) then
         SetPCBase(ICPU.ShiftedPB or newPC.W)
      else
         ICPU.Registers.PCw.PC.W := newPC.W;
      CPUShutdown;
   end;
end;

procedure Op10E0;
var
   newPC: TPair;
begin
   newPC.W := Relative(ACC_JUMP);
   if not CheckNegative then
   begin
      CPU.Cycles := CPU.Cycles + Settings.OneCycle;
      if (ICPU.Registers.PCw.PC.W and not MEMMAP_MASK) <> (newPC.W and not MEMMAP_MASK) then
         SetPCBase(ICPU.ShiftedPB or newPC.W)
      else
         ICPU.Registers.PCw.PC.W := newPC.W;
      CPUShutdown;
   end;
end;

procedure Op10Slow;
var
   newPC: TPair;
begin
   newPC.W := RelativeSlow(ACC_JUMP);
   if not CheckNegative then
   begin
      CPU.Cycles := CPU.Cycles + Settings.OneCycle;
      if CheckEmulation and (ICPU.Registers.PCw.PB <> newPC.H) then
         CPU.Cycles := CPU.Cycles + Settings.OneCycle;
      if (ICPU.Registers.PCw.PC.W and not MEMMAP_MASK) <> (newPC.W and not MEMMAP_MASK) then
         SetPCBase(ICPU.ShiftedPB or newPC.W)
      else
         ICPU.Registers.PCw.PC.W := newPC.W;
      CPUShutdown;
   end;
end;

procedure Op11E1;
begin
   ICPU.OpenBus := GetByte(DirectIndirectIndexedE1(ACC_READ));
   ORA8(ICPU.OpenBus);
end;

procedure Op11E0M1X1;
begin
   ICPU.OpenBus := GetByte(DirectIndirectIndexedE0X1(ACC_READ));
   ORA8(ICPU.OpenBus);
end;

procedure Op11E0M0X1;
begin
   var W := GetWord(DirectIndirectIndexedE0X1(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(W shr 8);
   ORA16(W);
end;

procedure Op11E0M1X0;
begin
   ICPU.OpenBus := GetByte(DirectIndirectIndexedE0X0(ACC_READ));
   ORA8(ICPU.OpenBus);
end;

procedure Op11E0M0X0;
begin
   var W := GetWord(DirectIndirectIndexedE0X0(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(W shr 8);
   ORA16(W);
end;

procedure Op11Slow;
begin
   var addr := DirectIndirectIndexedSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      ORA8(ICPU.OpenBus);
   end
   else
   begin
      var W := GetWord(addr, WRAP_NONE);
      ICPU.OpenBus := Byte(W shr 8);
      ORA16(W);
   end;
end;

procedure Op12E1;
begin
   ICPU.OpenBus := GetByte(DirectIndirectE1(ACC_READ));
   ORA8(ICPU.OpenBus);
end;

procedure Op12E0M1;
begin
   ICPU.OpenBus := GetByte(DirectIndirectE0(ACC_READ));
   ORA8(ICPU.OpenBus);
end;

procedure Op12E0M0;
begin
   var W := GetWord(DirectIndirectE0(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(W shr 8);
   ORA16(W);
end;

procedure Op12Slow;
begin
   var addr := DirectIndirectSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      ORA8(ICPU.OpenBus);
   end
   else
   begin
      var W := GetWord(addr, WRAP_NONE);
      ICPU.OpenBus := Byte(W shr 8);
      ORA16(W);
   end;
end;

procedure Op13M1;
begin
   ICPU.OpenBus := GetByte(StackRelativeIndirectIndexed(ACC_READ));
   ORA8(ICPU.OpenBus);
end;

procedure Op13M0;
begin
   var W := GetWord(StackRelativeIndirectIndexed(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(W shr 8);
   ORA16(W);
end;

procedure Op13Slow;
begin
   var addr := StackRelativeIndirectIndexedSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      ORA8(ICPU.OpenBus);
   end
   else
   begin
      var W := GetWord(addr, WRAP_NONE);
      ICPU.OpenBus := Byte(W shr 8);
      ORA16(W);
   end;
end;

procedure Op14M1;
begin
   TRB8(Direct(ACC_MODIFY));
end;

procedure Op14M0;
begin
   TRB16(Direct(ACC_MODIFY), WRAP_BANK);
end;

procedure Op14Slow;
begin
   if CheckMem then
      TRB8(DirectSlow(ACC_MODIFY))
   else
      TRB16(DirectSlow(ACC_MODIFY), WRAP_BANK);
end;

procedure Op15E1;
begin
   ICPU.OpenBus := GetByte(DirectIndexedXE1(ACC_READ));
   ORA8(ICPU.OpenBus);
end;

procedure Op15E0M1;
begin
   ICPU.OpenBus := GetByte(DirectIndexedXE0(ACC_READ));
   ORA8(ICPU.OpenBus);
end;

procedure Op15E0M0;
begin
   var W := GetWord(DirectIndexedXE0(ACC_READ), WRAP_BANK);
   ICPU.OpenBus := Byte(W shr 8);
   ORA16(W);
end;

procedure Op15Slow;
begin
   var addr := DirectIndexedXSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      ORA8(ICPU.OpenBus);
   end
   else
   begin
      var
      W := GetWord(addr, WRAP_BANK);
      ICPU.OpenBus := Byte(W shr 8);
      ORA16(W);
   end;
end;

procedure Op16E1;
begin
   ASL8(DirectIndexedXE1(ACC_MODIFY));
end;

procedure Op16E0M1;
begin
   ASL8(DirectIndexedXE0(ACC_MODIFY));
end;

procedure Op16E0M0;
begin
   ASL16(DirectIndexedXE0(ACC_MODIFY), WRAP_BANK);
end;

procedure Op16Slow;
begin
   if CheckMem then
      ASL8(DirectIndexedXSlow(ACC_MODIFY))
   else
      ASL16(DirectIndexedXSlow(ACC_MODIFY), WRAP_BANK);
end;

procedure Op17M1;
begin
   ICPU.OpenBus := GetByte(DirectIndirectIndexedLong(ACC_READ));
   ORA8(ICPU.OpenBus);
end;

procedure Op17M0;
begin
   var W := GetWord(DirectIndirectIndexedLong(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(W shr 8);
   ORA16(W);
end;

procedure Op17Slow;
begin
   var addr := DirectIndirectIndexedLongSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      ORA8(ICPU.OpenBus);
   end
   else
   begin
      var W := GetWord(addr, WRAP_NONE);
      ICPU.OpenBus := Byte(W shr 8);
      ORA16(W);
   end;
end;

procedure Op18; // CLC
begin
   ICPU.Carry := False;
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
end;

procedure Op19M1X1;
begin
   ICPU.OpenBus := GetByte(AbsoluteIndexedYX1(ACC_READ));
   ORA8(ICPU.OpenBus);
end;

procedure Op19M0X1;
begin
   var W := GetWord(AbsoluteIndexedYX1(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(W shr 8);
   ORA16(W);
end;

procedure Op19M1X0;
begin
   ICPU.OpenBus := GetByte(AbsoluteIndexedYX0(ACC_READ));
   ORA8(ICPU.OpenBus);
end;

procedure Op19M0X0;
begin
   var W := GetWord(AbsoluteIndexedYX0(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(W shr 8);
   ORA16(W);
end;

procedure Op19Slow;
begin
   var addr := AbsoluteIndexedYSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      ORA8(ICPU.OpenBus);
   end
   else
   begin
      var W := GetWord(addr, WRAP_NONE);
      ICPU.OpenBus := Byte(W shr 8);
      ORA16(W);
   end;
end;

procedure Op1AM1;
begin
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   CPU.WaitPC := 0;
   Inc(ICPU.Registers.A.L);
   SetZN8(ICPU.Registers.A.L);
end;

procedure Op1AM0;
begin
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   CPU.WaitPC := 0;
   Inc(ICPU.Registers.A.W);
   SetZN16(ICPU.Registers.A.W);
end;

procedure Op1ASlow;
begin
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   CPU.WaitPC := 0;
   if CheckMem then
   begin
      Inc(ICPU.Registers.A.L);
      SetZN8(ICPU.Registers.A.L);
   end
   else
   begin
      Inc(ICPU.Registers.A.W);
      SetZN16(ICPU.Registers.A.W);
   end;
end;

procedure Op1B; // TCS
begin
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   ICPU.Registers.S.W := ICPU.Registers.A.W;
   if CheckEmulation then
      ICPU.Registers.S.H := 1;
end;

procedure Op1CM1;
begin
   TRB8(Absolute(ACC_MODIFY));
end;

procedure Op1CM0;
begin
   TRB16(Absolute(ACC_MODIFY), WRAP_NONE);
end;

procedure Op1CSlow;
begin
   if CheckMem then
      TRB8(AbsoluteSlow(ACC_MODIFY))
   else
      TRB16(AbsoluteSlow(ACC_MODIFY), WRAP_NONE);
end;

procedure Op1DM1X1;
begin
   ICPU.OpenBus := GetByte(AbsoluteIndexedXX1(ACC_READ));
   ORA8(ICPU.OpenBus);
end;

procedure Op1DM0X1;
begin
   var W := GetWord(AbsoluteIndexedXX1(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(W shr 8);
   ORA16(W);
end;

procedure Op1DM1X0;
begin
   ICPU.OpenBus := GetByte(AbsoluteIndexedXX0(ACC_READ));
   ORA8(ICPU.OpenBus);
end;

procedure Op1DM0X0;
begin
   var W := GetWord(AbsoluteIndexedXX0(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(W shr 8);
   ORA16(W);
end;

procedure Op1DSlow;
begin
   var addr := AbsoluteIndexedXSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      ORA8(ICPU.OpenBus);
   end
   else
   begin
      var W := GetWord(addr, WRAP_NONE);
      ICPU.OpenBus := Byte(W shr 8);
      ORA16(W);
   end;
end;

procedure Op1EM1X1;
begin
   ASL8(AbsoluteIndexedXX1(ACC_MODIFY));
end;

procedure Op1EM0X1;
begin
   ASL16(AbsoluteIndexedXX1(ACC_MODIFY), WRAP_NONE);
end;

procedure Op1EM1X0;
begin
   ASL8(AbsoluteIndexedXX0(ACC_MODIFY));
end;

procedure Op1EM0X0;
begin
   ASL16(AbsoluteIndexedXX0(ACC_MODIFY), WRAP_NONE);
end;

procedure Op1ESlow;
begin
   if CheckMem then
      ASL8(AbsoluteIndexedXSlow(ACC_MODIFY))
   else
      ASL16(AbsoluteIndexedXSlow(ACC_MODIFY), WRAP_NONE);
end;

procedure Op1FM1;
begin
   ICPU.OpenBus := GetByte(AbsoluteLongIndexedX(ACC_READ));
   ORA8(ICPU.OpenBus);
end;

procedure Op1FM0;
begin
   var W := GetWord(AbsoluteLongIndexedX(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(W shr 8);
   ORA16(W);
end;

procedure Op1FSlow;
begin
   var addr := AbsoluteLongIndexedXSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      ORA8(ICPU.OpenBus);
   end
   else
   begin
      var W := GetWord(addr, WRAP_NONE);
      ICPU.OpenBus := Byte(W shr 8);
      ORA16(W);
   end;
end;

procedure Op20E1; // JSR Absolute
var
   addr: Word;
begin
   addr := Absolute(ACC_JSR);
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   PushWE(ICPU.Registers.PCw.PC.W - 1);
   SetPCBase(ICPU.ShiftedPB or addr);
end;

procedure Op20E0; // JSR Absolute
var
   addr: Word;
begin
   addr := Absolute(ACC_JSR);
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   PushW(ICPU.Registers.PCw.PC.W - 1);
   SetPCBase(ICPU.ShiftedPB or addr);
end;

procedure Op20Slow; // JSR Absolute
var
   addr: Word;
begin
   addr := AbsoluteSlow(ACC_JSR);
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   if CheckEmulation then
      PushWE(ICPU.Registers.PCw.PC.W - 1)
   else
      PushW(ICPU.Registers.PCw.PC.W - 1);
   SetPCBase(ICPU.ShiftedPB or addr);
end;

procedure Op21E1;
begin
   ICPU.OpenBus := GetByte(DirectIndexedIndirectE1(ACC_READ));
   AND8(ICPU.OpenBus);
end;

procedure Op21E0M1;
begin
   ICPU.OpenBus := GetByte(DirectIndexedIndirectE0(ACC_READ));
   AND8(ICPU.OpenBus);
end;

procedure Op21E0M0;
begin
   var W := GetWord(DirectIndexedIndirectE0(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(W shr 8);
   AND16(W);
end;

procedure Op21Slow;
begin
   var addr := DirectIndexedIndirectSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      AND8(ICPU.OpenBus);
   end
   else
   begin
      var W := GetWord(addr, WRAP_NONE);
      ICPU.OpenBus := Byte(W shr 8);
      AND16(W);
   end;
end;

procedure Op22E1; // JSL Absolute Long
var
   addr: Cardinal;
begin
   addr := AbsoluteLong(ACC_JSR);
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   PushB(ICPU.Registers.PCw.PB);
   PushW(ICPU.Registers.PCw.PC.W - 1);
   ICPU.Registers.S.H := 1;
   SetPCBase(addr);
end;

procedure Op22E0; // JSL Absolute Long
var
   addr: Cardinal;
begin
   addr := AbsoluteLong(ACC_JSR);
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   PushB(ICPU.Registers.PCw.PB);
   PushW(ICPU.Registers.PCw.PC.W - 1);
   SetPCBase(addr);
end;

procedure Op22Slow; // JSL Absolute Long
var
   addr: Cardinal;
begin
   addr := AbsoluteLongSlow(ACC_JSR);
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   PushB(ICPU.Registers.PCw.PB);
   PushW(ICPU.Registers.PCw.PC.W - 1);
   if CheckEmulation then
      ICPU.Registers.S.H := 1;
   SetPCBase(addr);
end;

procedure Op23M1;
begin
   ICPU.OpenBus := GetByte(StackRelative(ACC_READ));
   AND8(ICPU.OpenBus);
end;

procedure Op23M0;
begin
   var W := GetWord(StackRelative(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(W shr 8);
   AND16(W);
end;

procedure Op23Slow;
begin
   var addr := StackRelativeSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      AND8(ICPU.OpenBus);
   end
   else
   begin
      var W := GetWord(addr, WRAP_NONE);
      ICPU.OpenBus := Byte(W shr 8);
      AND16(W);
   end;
end;

procedure Op24M1;
begin
   ICPU.OpenBus := GetByte(Direct(ACC_READ));
   BIT8(ICPU.OpenBus);
end;

procedure Op24M0;
begin
   var W := GetWord(Direct(ACC_READ), WRAP_BANK);
   ICPU.OpenBus := Byte(W shr 8);
   BIT16(W);
end;

procedure Op24Slow;
begin
   var addr := DirectSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      BIT8(ICPU.OpenBus);
   end
   else
   begin
      var W := GetWord(addr, WRAP_BANK);
      ICPU.OpenBus := Byte(W shr 8);
      BIT16(W);
   end;
end;

procedure Op25M1;
begin
   ICPU.OpenBus := GetByte(Direct(ACC_READ));
   AND8(ICPU.OpenBus);
end;

procedure Op25M0;
begin
   var W := GetWord(Direct(ACC_READ), WRAP_BANK);
   ICPU.OpenBus := Byte(W shr 8);
   AND16(W);
end;

procedure Op25Slow;
begin
   var addr := DirectSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      AND8(ICPU.OpenBus);
   end
   else
   begin
      var W := GetWord(addr, WRAP_BANK);
      ICPU.OpenBus := Byte(W shr 8);
      AND16(W);
   end;
end;

procedure Op26M1;
begin
   ROL8(Direct(ACC_MODIFY));
end;

procedure Op26M0;
begin
   ROL16(Direct(ACC_MODIFY), WRAP_BANK);
end;

procedure Op26Slow;
begin
   if CheckMem then
      ROL8(DirectSlow(ACC_MODIFY))
   else
      ROL16(DirectSlow(ACC_MODIFY), WRAP_BANK);
end;

procedure Op27M1;
begin
   ICPU.OpenBus := GetByte(DirectIndirectLong(ACC_READ));
   AND8(ICPU.OpenBus);
end;

procedure Op27M0;
begin
   var W := GetWord(DirectIndirectLong(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(W shr 8);
   AND16(W);
end;

procedure Op27Slow;
begin
   var addr := DirectIndirectLongSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      AND8(ICPU.OpenBus);
   end
   else
   begin
      var W := GetWord(addr, WRAP_NONE);
      ICPU.OpenBus := Byte(W shr 8);
      AND16(W);
   end;
end;

procedure Op28E1;
begin
   CPU.Cycles := CPU.Cycles + Settings.TwoCycles;
   ICPU.Registers.P.L := PullBE;
   ICPU.OpenBus := ICPU.Registers.P.L;
   SetFlags(FLAG_MEMORY or FLAG_INDEX);
   UnpackStatus;
   FixCycles;
   CheckForIRQ;
end;

procedure Op28E0;
begin
   CPU.Cycles := CPU.Cycles + Settings.TwoCycles;
   ICPU.Registers.P.L := PullB;
   ICPU.OpenBus := ICPU.Registers.P.L;
   UnpackStatus;
   if CheckIndex then
   begin
      ICPU.Registers.X.H := 0;
      ICPU.Registers.Y.H := 0;
   end;
   FixCycles;
   CheckForIRQ;
end;

procedure Op28Slow;
begin
   CPU.Cycles := CPU.Cycles + Settings.TwoCycles;
   if CheckEmulation then
   begin
      ICPU.Registers.P.L := PullBE;
      ICPU.OpenBus := ICPU.Registers.P.L;
      SetFlags(FLAG_MEMORY or FLAG_INDEX);
   end
   else
   begin
      ICPU.Registers.P.L := PullB;
      ICPU.OpenBus := ICPU.Registers.P.L;
   end;
   UnpackStatus;
   if CheckIndex then
   begin
      ICPU.Registers.X.H := 0;
      ICPU.Registers.Y.H := 0;
   end;
   FixCycles;
   CheckForIRQ;
end;

procedure Op29M1;
begin
   AND8(Immediate8(ACC_READ));
end;

procedure Op29M0;
begin
   AND16(Immediate16(ACC_READ));
end;

procedure Op29Slow;
begin
   if CheckMem then
      AND8(Immediate8Slow(ACC_READ))
   else
      AND16(Immediate16Slow(ACC_READ));
end;

procedure Op2AM1;
begin
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   var W: Word := (Word(ICPU.Registers.A.L) shl 1) or Ord(ICPU.Carry);
   ICPU.Carry := W > $FF;
   ICPU.Registers.A.L := Byte(W);
   SetZN8(ICPU.Registers.A.L);
end;

procedure Op2AM0;
begin
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   var W: Cardinal := (Cardinal(ICPU.Registers.A.W) shl 1) or Ord(ICPU.Carry);
   ICPU.Carry := W > $FFFF;
   ICPU.Registers.A.W := Word(W);
   SetZN16(ICPU.Registers.A.W);
end;

procedure Op2ASlow;
begin
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   if CheckMem then
   begin
      var W: Word := (Word(ICPU.Registers.A.L) shl 1) or Ord(ICPU.Carry);
      ICPU.Carry := W > $FF;
      ICPU.Registers.A.L := Byte(W);
      SetZN8(ICPU.Registers.A.L);
   end
   else
   begin
      var W: Cardinal := (Cardinal(ICPU.Registers.A.W) shl 1) or Ord(ICPU.Carry);
      ICPU.Carry := W > $FFFF;
      ICPU.Registers.A.W := Word(W);
      SetZN16(ICPU.Registers.A.W);
   end;
end;

procedure Op2BE1;
begin
   CPU.Cycles := CPU.Cycles + Settings.TwoCycles;
   ICPU.Registers.D.W := PullW;
   SetZN16(ICPU.Registers.D.W);
   ICPU.OpenBus := ICPU.Registers.D.H;
   ICPU.Registers.S.H := 1;
end;

procedure Op2BE0;
begin
   CPU.Cycles := CPU.Cycles + Settings.TwoCycles;
   ICPU.Registers.D.W := PullW;
   SetZN16(ICPU.Registers.D.W);
   ICPU.OpenBus := ICPU.Registers.D.H;
end;

procedure Op2BSlow;
begin
   CPU.Cycles := CPU.Cycles + Settings.TwoCycles;
   ICPU.Registers.D.W := PullW;
   SetZN16(ICPU.Registers.D.W);
   ICPU.OpenBus := ICPU.Registers.D.H;
   if CheckEmulation then
      ICPU.Registers.S.H := 1;
end;

procedure Op2CM1;
begin
   ICPU.OpenBus := GetByte(Absolute(ACC_READ));
   BIT8(ICPU.OpenBus);
end;

procedure Op2CM0;
begin
   var W := GetWord(Absolute(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(W shr 8);
   BIT16(W);
end;

procedure Op2CSlow;
begin
   var addr := AbsoluteSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      BIT8(ICPU.OpenBus);
   end
   else
   begin
      var W := GetWord(addr, WRAP_NONE);
      ICPU.OpenBus := Byte(W shr 8);
      BIT16(W);
   end;
end;

procedure Op2DM1;
begin
   ICPU.OpenBus := GetByte(Absolute(ACC_READ));
   AND8(ICPU.OpenBus);
end;

procedure Op2DM0;
begin
   var W := GetWord(Absolute(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(W shr 8);
   AND16(W);
end;

procedure Op2DSlow;
begin
   var addr := AbsoluteSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      AND8(ICPU.OpenBus);
   end
   else
   begin
      var W := GetWord(addr, WRAP_NONE);
      ICPU.OpenBus := Byte(W shr 8);
      AND16(W);
   end;
end;

procedure Op2EM1;
begin
   ROL8(Absolute(ACC_MODIFY));
end;

procedure Op2EM0;
begin
   ROL16(Absolute(ACC_MODIFY), WRAP_NONE);
end;

procedure Op2ESlow;
begin
   if CheckMem then
      ROL8(AbsoluteSlow(ACC_MODIFY))
   else
      ROL16(AbsoluteSlow(ACC_MODIFY), WRAP_NONE);
end;

procedure Op2FM1;
begin
   ICPU.OpenBus := GetByte(AbsoluteLong(ACC_READ));
   AND8(ICPU.OpenBus);
end;

procedure Op2FM0;
begin
   var W := GetWord(AbsoluteLong(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(W shr 8);
   AND16(W);
end;

procedure Op2FSlow;
begin
   var addr := AbsoluteLongSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      AND8(ICPU.OpenBus);
   end
   else
   begin
      var W := GetWord(addr, WRAP_NONE);
      ICPU.OpenBus := Byte(W shr 8);
      AND16(W);
   end;
end;

procedure Op30E1;
var
   newPC: TPair;
begin
   newPC.W := Relative(ACC_JUMP);
   if CheckNegative then
   begin
      CPU.Cycles := CPU.Cycles + Settings.OneCycle;
      if ICPU.Registers.PCw.PB <> newPC.H then
         CPU.Cycles := CPU.Cycles + Settings.OneCycle;
      if (ICPU.Registers.PCw.PC.W and not MEMMAP_MASK) <> (newPC.W and not MEMMAP_MASK) then
         SetPCBase(ICPU.ShiftedPB or newPC.W)
      else
         ICPU.Registers.PCw.PC.W := newPC.W;
      CPUShutdown;
   end;
end;

procedure Op30E0;
var
   newPC: TPair;
begin
   newPC.W := Relative(ACC_JUMP);
   if CheckNegative then
   begin
      CPU.Cycles := CPU.Cycles + Settings.OneCycle;
      if (ICPU.Registers.PCw.PC.W and not MEMMAP_MASK) <> (newPC.W and not MEMMAP_MASK) then
         SetPCBase(ICPU.ShiftedPB or newPC.W)
      else
         ICPU.Registers.PCw.PC.W := newPC.W;
      CPUShutdown;
   end;
end;

procedure Op30Slow;
var
   newPC: TPair;
begin
   newPC.W := RelativeSlow(ACC_JUMP);
   if CheckNegative then
   begin
      CPU.Cycles := CPU.Cycles + Settings.OneCycle;
      if CheckEmulation and (ICPU.Registers.PCw.PB <> newPC.H) then
         CPU.Cycles := CPU.Cycles + Settings.OneCycle;
      if (ICPU.Registers.PCw.PC.W and not MEMMAP_MASK) <> (newPC.W and not MEMMAP_MASK) then
         SetPCBase(ICPU.ShiftedPB or newPC.W)
      else
         ICPU.Registers.PCw.PC.W := newPC.W;
      CPUShutdown;
   end;
end;

procedure Op31E1;
begin
   ICPU.OpenBus := GetByte(DirectIndirectIndexedE1(ACC_READ));
   AND8(ICPU.OpenBus);
end;

procedure Op31E0M1X1;
begin
   ICPU.OpenBus := GetByte(DirectIndirectIndexedE0X1(ACC_READ));
   AND8(ICPU.OpenBus);
end;

procedure Op31E0M0X1;
begin
   var W := GetWord(DirectIndirectIndexedE0X1(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(W shr 8);
   AND16(W);
end;

procedure Op31E0M1X0;
begin
   ICPU.OpenBus := GetByte(DirectIndirectIndexedE0X0(ACC_READ));
   AND8(ICPU.OpenBus);
end;

procedure Op31E0M0X0;
begin
   var W := GetWord(DirectIndirectIndexedE0X0(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(W shr 8);
   AND16(W);
end;

procedure Op31Slow;
begin
   var addr := DirectIndirectIndexedSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      AND8(ICPU.OpenBus);
   end
   else
   begin
      var W := GetWord(addr, WRAP_NONE);
      ICPU.OpenBus := Byte(W shr 8);
      AND16(W);
   end;
end;

procedure Op32E1;
begin
   ICPU.OpenBus := GetByte(DirectIndirectE1(ACC_READ));
   AND8(ICPU.OpenBus);
end;

procedure Op32E0M1;
begin
   ICPU.OpenBus := GetByte(DirectIndirectE0(ACC_READ));
   AND8(ICPU.OpenBus);
end;

procedure Op32E0M0;
begin
   var W := GetWord(DirectIndirectE0(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(W shr 8);
   AND16(W);
end;

procedure Op32Slow;
begin
   var addr := DirectIndirectSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      AND8(ICPU.OpenBus);
   end
   else
   begin
      var W := GetWord(addr, WRAP_NONE);
      ICPU.OpenBus := Byte(W shr 8);
      AND16(W);
   end;
end;

procedure Op33M1;
begin
   ICPU.OpenBus := GetByte(StackRelativeIndirectIndexed(ACC_READ));
   AND8(ICPU.OpenBus);
end;

procedure Op33M0;
begin
   var W := GetWord(StackRelativeIndirectIndexed(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(W shr 8);
   AND16(W);
end;

procedure Op33Slow;
begin
   var addr := StackRelativeIndirectIndexedSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      AND8(ICPU.OpenBus);
   end
   else
   begin
      var W := GetWord(addr, WRAP_NONE);
      ICPU.OpenBus := Byte(W shr 8);
      AND16(W);
   end;
end;

procedure Op34E1;
begin
   ICPU.OpenBus := GetByte(DirectIndexedXE1(ACC_READ));
   BIT8(ICPU.OpenBus);
end;

procedure Op34E0M1;
begin
   ICPU.OpenBus := GetByte(DirectIndexedXE0(ACC_READ));
   BIT8(ICPU.OpenBus);
end;

procedure Op34E0M0;
begin
   var W := GetWord(DirectIndexedXE0(ACC_READ), WRAP_BANK);
   ICPU.OpenBus := Byte(W shr 8);
   BIT16(W);
end;

procedure Op34Slow;
begin
   var addr := DirectIndexedXSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      BIT8(ICPU.OpenBus);
   end
   else
   begin
      var W := GetWord(addr, WRAP_BANK);
      ICPU.OpenBus := Byte(W shr 8);
      BIT16(W);
   end;
end;

procedure Op35E1;
begin
   ICPU.OpenBus := GetByte(DirectIndexedXE1(ACC_READ));
   AND8(ICPU.OpenBus);
end;

procedure Op35E0M1;
begin
   ICPU.OpenBus := GetByte(DirectIndexedXE0(ACC_READ));
   AND8(ICPU.OpenBus);
end;

procedure Op35E0M0;
begin
   var W := GetWord(DirectIndexedXE0(ACC_READ), WRAP_BANK);
   ICPU.OpenBus := Byte(W shr 8);
   AND16(W);
end;

procedure Op35Slow;
begin
   var addr := DirectIndexedXSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      AND8(ICPU.OpenBus);
   end
   else
   begin
      var W := GetWord(addr, WRAP_BANK);
      ICPU.OpenBus := Byte(W shr 8);
      AND16(W);
   end;
end;

procedure Op36E1;
begin
   ROL8(DirectIndexedXE1(ACC_MODIFY));
end;

procedure Op36E0M1;
begin
   ROL8(DirectIndexedXE0(ACC_MODIFY));
end;

procedure Op36E0M0;
begin
   ROL16(DirectIndexedXE0(ACC_MODIFY), WRAP_BANK);
end;

procedure Op36Slow;
begin
   if CheckMem then
      ROL8(DirectIndexedXSlow(ACC_MODIFY))
   else
      ROL16(DirectIndexedXSlow(ACC_MODIFY), WRAP_BANK);
end;

procedure Op37M1;
begin
   ICPU.OpenBus := GetByte(DirectIndirectIndexedLong(ACC_READ));
   AND8(ICPU.OpenBus);
end;

procedure Op37M0;
begin
   var W := GetWord(DirectIndirectIndexedLong(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(W shr 8);
   AND16(W);
end;

procedure Op37Slow;
begin
   var addr := DirectIndirectIndexedLongSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      AND8(ICPU.OpenBus);
   end
   else
   begin
      var W := GetWord(addr, WRAP_NONE);
      ICPU.OpenBus := Byte(W shr 8);
      AND16(W);
   end;
end;

procedure Op38; // SEC
begin
   ICPU.Carry := True;
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
end;

procedure Op39M1X1;
begin
   ICPU.OpenBus := GetByte(AbsoluteIndexedYX1(ACC_READ));
   AND8(ICPU.OpenBus);
end;

procedure Op39M0X1;
begin
   var W := GetWord(AbsoluteIndexedYX1(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(W shr 8);
   AND16(W);
end;

procedure Op39M1X0;
begin
   ICPU.OpenBus := GetByte(AbsoluteIndexedYX0(ACC_READ));
   AND8(ICPU.OpenBus);
end;

procedure Op39M0X0;
begin
   var W := GetWord(AbsoluteIndexedYX0(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(W shr 8);
   AND16(W);
end;

procedure Op39Slow;
begin
   var addr := AbsoluteIndexedYSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      AND8(ICPU.OpenBus);
   end
   else
   begin
      var W := GetWord(addr, WRAP_NONE);
      ICPU.OpenBus := Byte(W shr 8);
      AND16(W);
   end;
end;

procedure Op3AM1;
begin
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   CPU.WaitPC := 0;
   Dec(ICPU.Registers.A.L);
   SetZN8(ICPU.Registers.A.L);
end;

procedure Op3AM0;
begin
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   CPU.WaitPC := 0;
   Dec(ICPU.Registers.A.W);
   SetZN16(ICPU.Registers.A.W);
end;

procedure Op3ASlow;
begin
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   CPU.WaitPC := 0;
   if CheckMem then
   begin
      Dec(ICPU.Registers.A.L);
      SetZN8(ICPU.Registers.A.L);
   end
   else
   begin
      Dec(ICPU.Registers.A.W);
      SetZN16(ICPU.Registers.A.W);
   end;
end;

procedure Op3B; // TSC
begin
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   ICPU.Registers.A.W := ICPU.Registers.S.W;
   SetZN16(ICPU.Registers.A.W);
end;

procedure Op3CM1X1;
begin
   ICPU.OpenBus := GetByte(AbsoluteIndexedXX1(ACC_READ));
   BIT8(ICPU.OpenBus);
end;

procedure Op3CM0X1;
begin
   var W := GetWord(AbsoluteIndexedXX1(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(W shr 8);
   BIT16(W);
end;

procedure Op3CM1X0;
begin
   ICPU.OpenBus := GetByte(AbsoluteIndexedXX0(ACC_READ));
   BIT8(ICPU.OpenBus);
end;

procedure Op3CM0X0;
begin
   var W := GetWord(AbsoluteIndexedXX0(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(W shr 8);
   BIT16(W);
end;

procedure Op3CSlow;
begin
   var addr := AbsoluteIndexedXSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      BIT8(ICPU.OpenBus);
   end
   else
   begin
      var W := GetWord(addr, WRAP_NONE);
      ICPU.OpenBus := Byte(W shr 8);
      BIT16(W);
   end;
end;

procedure Op3DM1X1;
begin
   ICPU.OpenBus := GetByte(AbsoluteIndexedXX1(ACC_READ));
   AND8(ICPU.OpenBus);
end;

procedure Op3DM0X1;
begin
   var W := GetWord(AbsoluteIndexedXX1(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(W shr 8);
   AND16(W);
end;

procedure Op3DM1X0;
begin
   ICPU.OpenBus := GetByte(AbsoluteIndexedXX0(ACC_READ));
   AND8(ICPU.OpenBus);
end;

procedure Op3DM0X0;
begin
   var W := GetWord(AbsoluteIndexedXX0(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(W shr 8);
   AND16(W);
end;

procedure Op3DSlow;
begin
   var addr := AbsoluteIndexedXSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      AND8(ICPU.OpenBus);
   end
   else
   begin
      var W := GetWord(addr, WRAP_NONE);
      ICPU.OpenBus := Byte(W shr 8);
      AND16(W);
   end;
end;

procedure Op3EM1X1;
begin
   ROL8(AbsoluteIndexedXX1(ACC_MODIFY));
end;

procedure Op3EM0X1;
begin
   ROL16(AbsoluteIndexedXX1(ACC_MODIFY), WRAP_NONE);
end;

procedure Op3EM1X0;
begin
   ROL8(AbsoluteIndexedXX0(ACC_MODIFY));
end;

procedure Op3EM0X0;
begin
   ROL16(AbsoluteIndexedXX0(ACC_MODIFY), WRAP_NONE);
end;

procedure Op3ESlow;
begin
   if CheckMem then
      ROL8(AbsoluteIndexedXSlow(ACC_MODIFY))
   else
      ROL16(AbsoluteIndexedXSlow(ACC_MODIFY), WRAP_NONE);
end;

procedure Op3FM1;
begin
   ICPU.OpenBus := GetByte(AbsoluteLongIndexedX(ACC_READ));
   AND8(ICPU.OpenBus);
end;

procedure Op3FM0;
begin
   var W := GetWord(AbsoluteLongIndexedX(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(W shr 8);
   AND16(W);
end;

procedure Op3FSlow;
begin
   var addr := AbsoluteLongIndexedXSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      AND8(ICPU.OpenBus);
   end
   else
   begin
      var W := GetWord(addr, WRAP_NONE);
      ICPU.OpenBus := Byte(W shr 8);
      AND16(W);
   end;
end;

procedure Op40Slow; // RTI
begin
   CPU.Cycles := CPU.Cycles + Settings.TwoCycles;

   if not CheckEmulation then
   begin
      ICPU.Registers.P.L := PullB;
      UnpackStatus;
      ICPU.Registers.PCw.PC.W := PullW;
      ICPU.Registers.PCw.PB := PullB;
      ICPU.OpenBus := ICPU.Registers.PCw.PB;
      ICPU.ShiftedPB := Cardinal(ICPU.Registers.PCw.PB) shl 16;
   end
   else
   begin
      ICPU.Registers.P.L := PullBE;
      UnpackStatus;
      ICPU.Registers.PCw.PC.W := PullWE;
      ICPU.OpenBus := ICPU.Registers.PCw.PB; // PCh
      SetFlags(FLAG_MEMORY or FLAG_INDEX);
   end;

   SetPCBase(ICPU.Registers.PCw.xPBPC);
   if CheckIndex then
   begin
      ICPU.Registers.X.H := 0;
      ICPU.Registers.Y.H := 0;
   end;
   FixCycles;
   CheckForIRQ;
end;

procedure Op41E1;
begin
   ICPU.OpenBus := GetByte(DirectIndexedIndirectE1(ACC_READ));
   EOR8(ICPU.OpenBus);
end;

procedure Op41E0M1;
begin
   ICPU.OpenBus := GetByte(DirectIndexedIndirectE0(ACC_READ));
   EOR8(ICPU.OpenBus);
end;

procedure Op41E0M0;
begin
   var W := GetWord(DirectIndexedIndirectE0(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(W shr 8);
   EOR16(W);
end;

procedure Op41Slow;
begin
   var addr := DirectIndexedIndirectSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      EOR8(ICPU.OpenBus);
   end
   else
   begin
      var W := GetWord(addr, WRAP_NONE);
      ICPU.OpenBus := Byte(W shr 8);
      EOR16(W);
   end;
end;

procedure Op42; // WDM (Unused opcode, acts as 2-byte NOP)
begin
   Inc(ICPU.Registers.PCw.PC.W);
end;

procedure Op43M1;
begin
   ICPU.OpenBus := GetByte(StackRelative(ACC_READ));
   EOR8(ICPU.OpenBus);
end;

procedure Op43M0;
begin
   var W := GetWord(StackRelative(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(W shr 8);
   EOR16(W);
end;

procedure Op43Slow;
begin
   var addr := StackRelativeSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      EOR8(ICPU.OpenBus);
   end
   else
   begin
      var W := GetWord(addr, WRAP_NONE);
      ICPU.OpenBus := Byte(W shr 8);
      EOR16(W);
   end;
end;

procedure Op44X1; // MVP
var
   SrcBank: Cardinal;
begin
   ICPU.Registers.DB := Immediate8(ACC_NONE);
   ICPU.ShiftedDB := Cardinal(ICPU.Registers.DB) shl 16;
   ICPU.OpenBus := Byte(SrcBank);
   SrcBank := Immediate8(ACC_NONE);
   ICPU.OpenBus := GetByte((SrcBank shl 16) + ICPU.Registers.X.W);
   SetByte(ICPU.OpenBus, ICPU.ShiftedDB + ICPU.Registers.Y.W);
   Dec(ICPU.Registers.X.L);
   Dec(ICPU.Registers.Y.L);
   Dec(ICPU.Registers.A.W);
   if ICPU.Registers.A.W <> $FFFF then
      Dec(ICPU.Registers.PCw.PC.W, 3);
   CPU.Cycles := CPU.Cycles + Settings.TwoCycles;
end;

procedure Op44X0; // MVP
var
   SrcBank: Cardinal;
begin
   ICPU.Registers.DB := Immediate8(ACC_NONE);
   ICPU.ShiftedDB := Cardinal(ICPU.Registers.DB) shl 16;
   ICPU.OpenBus := Byte(SrcBank);
   SrcBank := Immediate8(ACC_NONE);
   ICPU.OpenBus := GetByte((SrcBank shl 16) + ICPU.Registers.X.W);
   SetByte(ICPU.OpenBus, ICPU.ShiftedDB + ICPU.Registers.Y.W);
   Dec(ICPU.Registers.X.W);
   Dec(ICPU.Registers.Y.W);
   Dec(ICPU.Registers.A.W);
   if ICPU.Registers.A.W <> $FFFF then
      Dec(ICPU.Registers.PCw.PC.W, 3);
   CPU.Cycles := CPU.Cycles + Settings.TwoCycles;
end;

procedure Op44Slow; // MVP
var
   SrcBank: Cardinal;
begin
   ICPU.OpenBus := ICPU.Registers.DB;
   ICPU.Registers.DB := Immediate8Slow(ACC_NONE);
   ICPU.ShiftedDB := Cardinal(ICPU.Registers.DB) shl 16;
   ICPU.OpenBus := Byte(SrcBank);
   SrcBank := Immediate8Slow(ACC_NONE);
   ICPU.OpenBus := GetByte((SrcBank shl 16) + ICPU.Registers.X.W);
   SetByte(ICPU.OpenBus, ICPU.ShiftedDB + ICPU.Registers.Y.W);
   if CheckIndex then
   begin
      Dec(ICPU.Registers.X.L);
      Dec(ICPU.Registers.Y.L);
   end
   else
   begin
      Dec(ICPU.Registers.X.W);
      Dec(ICPU.Registers.Y.W);
   end;
   Dec(ICPU.Registers.A.W);
   if ICPU.Registers.A.W <> $FFFF then
      Dec(ICPU.Registers.PCw.PC.W, 3);
   CPU.Cycles := CPU.Cycles + Settings.TwoCycles;
end;

procedure Op45M1;
begin
   ICPU.OpenBus := GetByte(Direct(ACC_READ));
   EOR8(ICPU.OpenBus);
end;

procedure Op45M0;
begin
   var W := GetWord(Direct(ACC_READ), WRAP_BANK);
   ICPU.OpenBus := Byte(W shr 8);
   EOR16(W);
end;

procedure Op45Slow;
begin
   var addr := DirectSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      EOR8(ICPU.OpenBus);
   end
   else
   begin
      var W := GetWord(addr, WRAP_BANK);
      ICPU.OpenBus := Byte(W shr 8);
      EOR16(W);
   end;
end;

procedure Op46M1;
begin
   LSR8(Direct(ACC_MODIFY));
end;

procedure Op46M0;
begin
   LSR16(Direct(ACC_MODIFY), WRAP_BANK);
end;

procedure Op46Slow;
begin
   if CheckMem then
      LSR8(DirectSlow(ACC_MODIFY))
   else
      LSR16(DirectSlow(ACC_MODIFY), WRAP_BANK);
end;

procedure Op47M1;
begin
   ICPU.OpenBus := GetByte(DirectIndirectLong(ACC_READ));
   EOR8(ICPU.OpenBus);
end;

procedure Op47M0;
begin
   var W := GetWord(DirectIndirectLong(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(W shr 8);
   EOR16(W);
end;

procedure Op47Slow;
begin
   var addr := DirectIndirectLongSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      EOR8(ICPU.OpenBus);
   end
   else
   begin
      var W := GetWord(addr, WRAP_NONE);
      ICPU.OpenBus := Byte(W shr 8);
      EOR16(W);
   end;
end;

procedure Op48E1;
begin
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   PushBE(ICPU.Registers.A.L);
   ICPU.OpenBus := ICPU.Registers.A.L;
end;

procedure Op48E0M1;
begin
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   PushB(ICPU.Registers.A.L);
   ICPU.OpenBus := ICPU.Registers.A.L;
end;

procedure Op48E0M0;
begin
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   PushW(ICPU.Registers.A.W);
   ICPU.OpenBus := ICPU.Registers.A.L;
end;

procedure Op48Slow;
begin
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   if CheckEmulation then
      PushBE(ICPU.Registers.A.L)
   else
      if CheckMem then
         PushB(ICPU.Registers.A.L)
      else
         PushW(ICPU.Registers.A.W);
   ICPU.OpenBus := ICPU.Registers.A.L;
end;

procedure Op49M1;
begin
   EOR8(Immediate8(ACC_READ));
end;

procedure Op49M0;
begin
   EOR16(Immediate16(ACC_READ));
end;

procedure Op49Slow;
begin
   if CheckMem then
      EOR8(Immediate8Slow(ACC_READ))
   else
      EOR16(Immediate16Slow(ACC_READ));
end;

procedure Op4AM1;
begin
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   ICPU.Carry := (ICPU.Registers.A.L and 1) <> 0;
   ICPU.Registers.A.L := ICPU.Registers.A.L shr 1;
   SetZN8(ICPU.Registers.A.L);
end;

procedure Op4AM0;
begin
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   ICPU.Carry := (ICPU.Registers.A.W and 1) <> 0;
   ICPU.Registers.A.W := ICPU.Registers.A.W shr 1;
   SetZN16(ICPU.Registers.A.W);
end;

procedure Op4ASlow;
begin
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   if CheckMem then
   begin
      ICPU.Carry := (ICPU.Registers.A.L and 1) <> 0;
      ICPU.Registers.A.L := ICPU.Registers.A.L shr 1;
      SetZN8(ICPU.Registers.A.L);
   end
   else
   begin
      ICPU.Carry := (ICPU.Registers.A.W and 1) <> 0;
      ICPU.Registers.A.W := ICPU.Registers.A.W shr 1;
      SetZN16(ICPU.Registers.A.W);
   end;
end;

procedure Op4BE1;
begin
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   PushBE(ICPU.Registers.PCw.PB);
   ICPU.OpenBus := ICPU.Registers.PCw.PB;
end;

procedure Op4BE0;
begin
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   PushB(ICPU.Registers.PCw.PB);
   ICPU.OpenBus := ICPU.Registers.PCw.PB;
end;

procedure Op4BSlow;
begin
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   if CheckEmulation then
      PushBE(ICPU.Registers.PCw.PB)
   else
      PushB(ICPU.Registers.PCw.PB);
   ICPU.OpenBus := ICPU.Registers.PCw.PB;
end;

procedure Op4C;
begin
   SetPCBase(ICPU.ShiftedPB or Absolute(ACC_JUMP));
end;

procedure Op4CSlow;
begin
   SetPCBase(ICPU.ShiftedPB or AbsoluteSlow(ACC_JUMP));
end;

procedure Op4DM1;
begin
   ICPU.OpenBus := GetByte(Absolute(ACC_READ));
   EOR8(ICPU.OpenBus);
end;

procedure Op4DM0;
begin
   var W := GetWord(Absolute(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(W shr 8);
   EOR16(W);
end;

procedure Op4DSlow;
begin
   var addr := AbsoluteSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      EOR8(ICPU.OpenBus);
   end
   else
   begin
      var W := GetWord(addr, WRAP_NONE);
      ICPU.OpenBus := Byte(W shr 8);
      EOR16(W);
   end;
end;

procedure Op4EM1;
begin
   LSR8(Absolute(ACC_MODIFY));
end;

procedure Op4EM0;
begin
   LSR16(Absolute(ACC_MODIFY), WRAP_NONE);
end;

procedure Op4ESlow;
begin
   if CheckMem then
      LSR8(AbsoluteSlow(ACC_MODIFY))
   else
      LSR16(AbsoluteSlow(ACC_MODIFY), WRAP_NONE);
end;

procedure Op4FM1;
begin
   ICPU.OpenBus := GetByte(AbsoluteLong(ACC_READ));
   EOR8(ICPU.OpenBus);
end;

procedure Op4FM0;
begin
   var W := GetWord(AbsoluteLong(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(W shr 8);
   EOR16(W);
end;

procedure Op4FSlow;
begin
   var addr := AbsoluteLongSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      EOR8(ICPU.OpenBus);
   end
   else
   begin
      var W := GetWord(addr, WRAP_NONE);
      ICPU.OpenBus := Byte(W shr 8);
      EOR16(W);
   end;
end;

procedure Op50E1;
var
   newPC: TPair;
begin
   newPC.W := Relative(ACC_JUMP);
   if not CheckOverflow then
   begin
      CPU.Cycles := CPU.Cycles + Settings.OneCycle;
      if ICPU.Registers.PCw.PB <> newPC.H then
         CPU.Cycles := CPU.Cycles + Settings.OneCycle;
      if (ICPU.Registers.PCw.PC.W and not MEMMAP_MASK) <> (newPC.W and not MEMMAP_MASK) then
         SetPCBase(ICPU.ShiftedPB or newPC.W)
      else
         ICPU.Registers.PCw.PC.W := newPC.W;
      CPUShutdown;
   end;
end;

procedure Op50E0;
var
   newPC: TPair;
begin
   newPC.W := Relative(ACC_JUMP);
   if not CheckOverflow then
   begin
      CPU.Cycles := CPU.Cycles + Settings.OneCycle;
      if (ICPU.Registers.PCw.PC.W and not MEMMAP_MASK) <> (newPC.W and not MEMMAP_MASK) then
         SetPCBase(ICPU.ShiftedPB or newPC.W)
      else
         ICPU.Registers.PCw.PC.W := newPC.W;
      CPUShutdown;
   end;
end;

procedure Op50Slow;
var
   newPC: TPair;
begin
   newPC.W := RelativeSlow(ACC_JUMP);
   if not CheckOverflow then
   begin
      CPU.Cycles := CPU.Cycles + Settings.OneCycle;
      if CheckEmulation and (ICPU.Registers.PCw.PB <> newPC.H) then
         CPU.Cycles := CPU.Cycles + Settings.OneCycle;
      if (ICPU.Registers.PCw.PC.W and not MEMMAP_MASK) <> (newPC.W and not MEMMAP_MASK) then
         SetPCBase(ICPU.ShiftedPB or newPC.W)
      else
         ICPU.Registers.PCw.PC.W := newPC.W;
      CPUShutdown;
   end;
end;

procedure Op51E1;
begin
   ICPU.OpenBus := GetByte(DirectIndirectIndexedE1(ACC_READ));
   EOR8(ICPU.OpenBus);
end;

procedure Op51E0M1X1;
begin
   ICPU.OpenBus := GetByte(DirectIndirectIndexedE0X1(ACC_READ));
   EOR8(ICPU.OpenBus);
end;

procedure Op51E0M0X1;
begin
   var W := GetWord(DirectIndirectIndexedE0X1(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(W shr 8);
   EOR16(W);
end;

procedure Op51E0M1X0;
begin
   ICPU.OpenBus := GetByte(DirectIndirectIndexedE0X0(ACC_READ));
   EOR8(ICPU.OpenBus);
end;

procedure Op51E0M0X0;
begin
   var W := GetWord(DirectIndirectIndexedE0X0(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(W shr 8);
   EOR16(W);
end;

procedure Op51Slow;
begin
   var addr := DirectIndirectIndexedSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      EOR8(ICPU.OpenBus);
   end
   else
   begin
      var W := GetWord(addr, WRAP_NONE);
      ICPU.OpenBus := Byte(W shr 8);
      EOR16(W);
   end;
end;

procedure Op52E1;
begin
   ICPU.OpenBus := GetByte(DirectIndirectE1(ACC_READ));
   EOR8(ICPU.OpenBus);
end;

procedure Op52E0M1;
begin
   ICPU.OpenBus := GetByte(DirectIndirectE0(ACC_READ));
   EOR8(ICPU.OpenBus);
end;

procedure Op52E0M0;
begin
   var W := GetWord(DirectIndirectE0(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(W shr 8);
   EOR16(W);
end;

procedure Op52Slow;
begin
   var addr := DirectIndirectSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      EOR8(ICPU.OpenBus);
   end
   else
   begin
      var W := GetWord(addr, WRAP_NONE);
      ICPU.OpenBus := Byte(W shr 8);
      EOR16(W);
   end;
end;

procedure Op53M1;
begin
   ICPU.OpenBus := GetByte(StackRelativeIndirectIndexed(ACC_READ));
   EOR8(ICPU.OpenBus);
end;

procedure Op53M0;
begin
   var W := GetWord(StackRelativeIndirectIndexed(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(W shr 8);
   EOR16(W);
end;

procedure Op53Slow;
begin
   var addr := StackRelativeIndirectIndexedSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      EOR8(ICPU.OpenBus);
   end
   else
   begin
      var W := GetWord(addr, WRAP_NONE);
      ICPU.OpenBus := Byte(W shr 8);
      EOR16(W);
   end;
end;

procedure Op54X1; // MVN
var
   SrcBank: Cardinal;
begin
   ICPU.Registers.DB := Immediate8(ACC_NONE);
   ICPU.ShiftedDB := Cardinal(ICPU.Registers.DB) shl 16;
   ICPU.OpenBus := Byte(SrcBank);
   SrcBank := Immediate8(ACC_NONE);
   ICPU.OpenBus := GetByte((SrcBank shl 16) + ICPU.Registers.X.W);
   SetByte(ICPU.OpenBus, ICPU.ShiftedDB + ICPU.Registers.Y.W);
   Inc(ICPU.Registers.X.L);
   Inc(ICPU.Registers.Y.L);
   Dec(ICPU.Registers.A.W);
   if ICPU.Registers.A.W <> $FFFF then
      Dec(ICPU.Registers.PCw.PC.W, 3);
   CPU.Cycles := CPU.Cycles + Settings.TwoCycles;
end;

procedure Op54X0; // MVN
var
   SrcBank: Cardinal;
begin
   ICPU.Registers.DB := Immediate8(ACC_NONE);
   ICPU.ShiftedDB := Cardinal(ICPU.Registers.DB) shl 16;
   ICPU.OpenBus := Byte(SrcBank);
   SrcBank := Immediate8(ACC_NONE);
   ICPU.OpenBus := GetByte((SrcBank shl 16) + ICPU.Registers.X.W);
   SetByte(ICPU.OpenBus, ICPU.ShiftedDB + ICPU.Registers.Y.W);
   Inc(ICPU.Registers.X.W);
   Inc(ICPU.Registers.Y.W);
   Dec(ICPU.Registers.A.W);
   if ICPU.Registers.A.W <> $FFFF then
      Dec(ICPU.Registers.PCw.PC.W, 3);
   CPU.Cycles := CPU.Cycles + Settings.TwoCycles;
end;

procedure Op54Slow; // MVN
var
   SrcBank: Cardinal;
begin
   ICPU.OpenBus := ICPU.Registers.DB;
   ICPU.Registers.DB := Immediate8Slow(ACC_NONE);
   ICPU.ShiftedDB := Cardinal(ICPU.Registers.DB) shl 16;
   ICPU.OpenBus := Byte(SrcBank);
   SrcBank := Immediate8Slow(ACC_NONE);
   ICPU.OpenBus := GetByte((SrcBank shl 16) + ICPU.Registers.X.W);
   SetByte(ICPU.OpenBus, ICPU.ShiftedDB + ICPU.Registers.Y.W);
   if CheckIndex then
   begin
      Inc(ICPU.Registers.X.L);
      Inc(ICPU.Registers.Y.L);
   end
   else
   begin
      Inc(ICPU.Registers.X.W);
      Inc(ICPU.Registers.Y.W);
   end;
   Dec(ICPU.Registers.A.W);
   if ICPU.Registers.A.W <> $FFFF then
      Dec(ICPU.Registers.PCw.PC.W, 3);
   CPU.Cycles := CPU.Cycles + Settings.TwoCycles;
end;

procedure Op55E1;
begin
   ICPU.OpenBus := GetByte(DirectIndexedXE1(ACC_READ));
   EOR8(ICPU.OpenBus);
end;

procedure Op55E0M1;
begin
   ICPU.OpenBus := GetByte(DirectIndexedXE0(ACC_READ));
   EOR8(ICPU.OpenBus);
end;

procedure Op55E0M0;
begin
   var W := GetWord(DirectIndexedXE0(ACC_READ), WRAP_BANK);
   ICPU.OpenBus := Byte(W shr 8);
   EOR16(W);
end;

procedure Op55Slow;
begin
   var addr := DirectIndexedXSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      EOR8(ICPU.OpenBus);
   end
   else
   begin
      var W := GetWord(addr, WRAP_BANK);
      ICPU.OpenBus := Byte(W shr 8);
      EOR16(W);
   end;
end;

procedure Op56E1;
begin
   LSR8(DirectIndexedXE1(ACC_MODIFY));
end;

procedure Op56E0M1;
begin
   LSR8(DirectIndexedXE0(ACC_MODIFY));
end;

procedure Op56E0M0;
begin
   LSR16(DirectIndexedXE0(ACC_MODIFY), WRAP_BANK);
end;

procedure Op56Slow;
begin
   if CheckMem then
      LSR8(DirectIndexedXSlow(ACC_MODIFY))
   else
      LSR16(DirectIndexedXSlow(ACC_MODIFY), WRAP_BANK);
end;

procedure Op57M1;
begin
   ICPU.OpenBus := GetByte(DirectIndirectIndexedLong(ACC_READ));
   EOR8(ICPU.OpenBus);
end;

procedure Op57M0;
begin
   var W := GetWord(DirectIndirectIndexedLong(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(W shr 8);
   EOR16(W);
end;

procedure Op57Slow;
begin
   var addr := DirectIndirectIndexedLongSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      EOR8(ICPU.OpenBus);
   end
   else
   begin
      var W := GetWord(addr, WRAP_NONE);
      ICPU.OpenBus := Byte(W shr 8);
      EOR16(W);
   end;
end;

procedure Op58; // CLI
begin
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   ClearFlags(FLAG_IRQ);
end;

procedure Op59M1X1;
begin
   ICPU.OpenBus := GetByte(AbsoluteIndexedYX1(ACC_READ));
   EOR8(ICPU.OpenBus);
end;

procedure Op59M0X1;
begin
   var W := GetWord(AbsoluteIndexedYX1(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(W shr 8);
   EOR16(W);
end;

procedure Op59M1X0;
begin
   ICPU.OpenBus := GetByte(AbsoluteIndexedYX0(ACC_READ));
   EOR8(ICPU.OpenBus);
end;

procedure Op59M0X0;
begin
   var W := GetWord(AbsoluteIndexedYX0(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(W shr 8);
   EOR16(W);
end;

procedure Op59Slow;
begin
   var addr := AbsoluteIndexedYSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      EOR8(ICPU.OpenBus);
   end
   else
   begin
      var W := GetWord(addr, WRAP_NONE);
      ICPU.OpenBus := Byte(W shr 8);
      EOR16(W);
   end;
end;

procedure Op5AE1;
begin
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   PushBE(ICPU.Registers.Y.L);
   ICPU.OpenBus := ICPU.Registers.Y.L;
end;

procedure Op5AE0X1;
begin
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   PushB(ICPU.Registers.Y.L);
   ICPU.OpenBus := ICPU.Registers.Y.L;
end;

procedure Op5AE0X0;
begin
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   PushW(ICPU.Registers.Y.W);
   ICPU.OpenBus := ICPU.Registers.Y.L;
end;

procedure Op5ASlow;
begin
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   if CheckEmulation then
      PushBE(ICPU.Registers.Y.L)
   else
      if CheckIndex then
         PushB(ICPU.Registers.Y.L)
      else
         PushW(ICPU.Registers.Y.W);
   ICPU.OpenBus := ICPU.Registers.Y.L;
end;

procedure Op5B; // TCD
begin
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   ICPU.Registers.D.W := ICPU.Registers.A.W;
   SetZN16(ICPU.Registers.D.W);
end;

procedure Op5C;
begin
   SetPCBase(AbsoluteLong(ACC_JUMP));
end;

procedure Op5CSlow;
begin
   SetPCBase(AbsoluteLongSlow(ACC_JUMP));
end;

procedure Op5DM1X1;
begin
   ICPU.OpenBus := GetByte(AbsoluteIndexedXX1(ACC_READ));
   EOR8(ICPU.OpenBus);
end;

procedure Op5DM0X1;
begin
   var W := GetWord(AbsoluteIndexedXX1(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(W shr 8);
   EOR16(W);
end;

procedure Op5DM1X0;
begin
   ICPU.OpenBus := GetByte(AbsoluteIndexedXX0(ACC_READ));
   EOR8(ICPU.OpenBus);
end;

procedure Op5DM0X0;
begin
   var W := GetWord(AbsoluteIndexedXX0(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(W shr 8);
   EOR16(W);
end;

procedure Op5DSlow;
begin
   var addr := AbsoluteIndexedXSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      EOR8(ICPU.OpenBus);
   end
   else
   begin
      var W := GetWord(addr, WRAP_NONE);
      ICPU.OpenBus := Byte(W shr 8);
      EOR16(W);
   end;
end;

procedure Op5EM1X1;
begin
   LSR8(AbsoluteIndexedXX1(ACC_MODIFY));
end;

procedure Op5EM0X1;
begin
   LSR16(AbsoluteIndexedXX1(ACC_MODIFY), WRAP_NONE);
end;

procedure Op5EM1X0;
begin
   LSR8(AbsoluteIndexedXX0(ACC_MODIFY));
end;

procedure Op5EM0X0;
begin
   LSR16(AbsoluteIndexedXX0(ACC_MODIFY), WRAP_NONE);
end;

procedure Op5ESlow;
begin
   if CheckMem then
      LSR8(AbsoluteIndexedXSlow(ACC_MODIFY))
   else
      LSR16(AbsoluteIndexedXSlow(ACC_MODIFY), WRAP_NONE);
end;

procedure Op5FM1;
begin
   ICPU.OpenBus := GetByte(AbsoluteLongIndexedX(ACC_READ));
   EOR8(ICPU.OpenBus);
end;

procedure Op5FM0;
begin
   var W := GetWord(AbsoluteLongIndexedX(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(W shr 8);
   EOR16(W);
end;

procedure Op5FSlow;
begin
   var addr := AbsoluteLongIndexedXSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      EOR8(ICPU.OpenBus);
   end
   else
   begin
      var W := GetWord(addr, WRAP_NONE);
      ICPU.OpenBus := Byte(W shr 8);
      EOR16(W);
   end;
end;

procedure Op60E1; // RTS
begin
   CPU.Cycles := CPU.Cycles + Settings.TwoCycles;
   ICPU.Registers.PCw.PC.W := PullWE;
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   Inc(ICPU.Registers.PCw.PC.W);
   SetPCBase(ICPU.Registers.PCw.xPBPC);
end;

procedure Op60E0; // RTS
begin
   CPU.Cycles := CPU.Cycles + Settings.TwoCycles;
   ICPU.Registers.PCw.PC.W := PullW;
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   Inc(ICPU.Registers.PCw.PC.W);
   SetPCBase(ICPU.Registers.PCw.xPBPC);
end;

procedure Op60Slow; // RTS
begin
   CPU.Cycles := CPU.Cycles + Settings.TwoCycles;
   if CheckEmulation then
      ICPU.Registers.PCw.PC.W := PullWE
   else
      ICPU.Registers.PCw.PC.W := PullW;
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   Inc(ICPU.Registers.PCw.PC.W);
   SetPCBase(ICPU.Registers.PCw.xPBPC);
end;

procedure Op61E1;
begin
   ICPU.OpenBus := GetByte(DirectIndexedIndirectE1(ACC_READ));
   ADC8(ICPU.OpenBus);
end;

procedure Op61E0M1;
begin
   ICPU.OpenBus := GetByte(DirectIndexedIndirectE0(ACC_READ));
   ADC8(ICPU.OpenBus);
end;

procedure Op61E0M0;
begin
   var W := GetWord(DirectIndexedIndirectE0(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(W shr 8);
   ADC16(W);
end;

procedure Op61Slow;
begin
   var addr := DirectIndexedIndirectSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      ADC8(ICPU.OpenBus);
   end
   else
   begin
      var W := GetWord(addr, WRAP_NONE);
      ICPU.OpenBus := Byte(W shr 8);
      ADC16(W);
   end;
end;

procedure Op62E1; // PER
var
   val: Word;
begin
   val := RelativeLong(ACC_NONE);
   PushW(val);
   ICPU.OpenBus := val and $FF;
   ICPU.Registers.S.H := 1;
end;

procedure Op62E0; // PER
var
   val: Word;
begin
   val := RelativeLong(ACC_NONE);
   PushW(val);
   ICPU.OpenBus := val and $FF;
end;

procedure Op62Slow; // PER
var
   val: Word;
begin
   val := RelativeLongSlow(ACC_NONE);
   PushW(val);
   ICPU.OpenBus := val and $FF;
   if CheckEmulation then
      ICPU.Registers.S.H := 1;
end;

procedure Op63M1;
begin
   ICPU.OpenBus := GetByte(StackRelative(ACC_READ));
   ADC8(ICPU.OpenBus);
end;

procedure Op63M0;
begin
   var W := GetWord(StackRelative(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(W shr 8);
   ADC16(W);
end;

procedure Op63Slow;
begin
   var addr := StackRelativeSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      ADC8(ICPU.OpenBus);
   end
   else
   begin
      var W := GetWord(addr, WRAP_NONE);
      ICPU.OpenBus := Byte(W shr 8);
      ADC16(W);
   end;
end;

procedure Op64M1;
begin
   STZ8(Direct(ACC_WRITE));
end;

procedure Op64M0;
begin
   STZ16(Direct(ACC_WRITE), WRAP_BANK);
end;

procedure Op64Slow;
begin
   if CheckMem then
      STZ8(DirectSlow(ACC_WRITE))
   else
      STZ16(DirectSlow(ACC_WRITE), WRAP_BANK);
end;

procedure Op65M1;
begin
   ICPU.OpenBus := GetByte(Direct(ACC_READ));
   ADC8(ICPU.OpenBus);
end;

procedure Op65M0;
begin
   var W := GetWord(Direct(ACC_READ), WRAP_BANK);
   ICPU.OpenBus := Byte(W shr 8);
   ADC16(W);
end;

procedure Op65Slow;
begin
   var addr := DirectSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      ADC8(ICPU.OpenBus);
   end
   else
   begin
      var W := GetWord(addr, WRAP_BANK);
      ICPU.OpenBus := Byte(W shr 8);
      ADC16(W);
   end;
end;

procedure Op66M1;
begin
   ROR8(Direct(ACC_MODIFY));
end;

procedure Op66M0;
begin
   ROR16(Direct(ACC_MODIFY), WRAP_BANK);
end;

procedure Op66Slow;
begin
   if CheckMem then
      ROR8(DirectSlow(ACC_MODIFY))
   else
      ROR16(DirectSlow(ACC_MODIFY), WRAP_BANK);
end;

procedure Op67M1;
begin
   ICPU.OpenBus := GetByte(DirectIndirectLong(ACC_READ));
   ADC8(ICPU.OpenBus);
end;

procedure Op67M0;
begin
   var W := GetWord(DirectIndirectLong(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(W shr 8);
   ADC16(W);
end;

procedure Op67Slow;
begin
   var addr := DirectIndirectLongSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      ADC8(ICPU.OpenBus);
   end
   else
   begin
      var W := GetWord(addr, WRAP_NONE);
      ICPU.OpenBus := Byte(W shr 8);
      ADC16(W);
   end;
end;

procedure Op68E1;
begin
   CPU.Cycles := CPU.Cycles + Settings.TwoCycles;
   ICPU.Registers.A.L := PullBE;
   SetZN8(ICPU.Registers.A.L);
   ICPU.OpenBus := ICPU.Registers.A.L;
end;

procedure Op68E0M1;
begin
   CPU.Cycles := CPU.Cycles + Settings.TwoCycles;
   ICPU.Registers.A.L := PullB;
   SetZN8(ICPU.Registers.A.L);
   ICPU.OpenBus := ICPU.Registers.A.L;
end;

procedure Op68E0M0;
begin
   CPU.Cycles := CPU.Cycles + Settings.TwoCycles;
   ICPU.Registers.A.W := PullW;
   SetZN16(ICPU.Registers.A.W);
   ICPU.OpenBus := ICPU.Registers.A.H;
end;

procedure Op68Slow;
begin
   CPU.Cycles := CPU.Cycles + Settings.TwoCycles;
   if CheckEmulation then
   begin
      ICPU.Registers.A.L := PullBE;
      SetZN8(ICPU.Registers.A.L);
      ICPU.OpenBus := ICPU.Registers.A.L;
   end
   else
      if CheckMem then
      begin
         ICPU.Registers.A.L := PullB;
         SetZN8(ICPU.Registers.A.L);
         ICPU.OpenBus := ICPU.Registers.A.L;
      end
      else
      begin
         ICPU.Registers.A.W := PullW;
         SetZN16(ICPU.Registers.A.W);
         ICPU.OpenBus := ICPU.Registers.A.H;
      end;
end;

procedure Op69M1;
begin
   ADC8(Immediate8(ACC_READ));
end;

procedure Op69M0;
begin
   ADC16(Immediate16(ACC_READ));
end;

procedure Op69Slow;
begin
   if CheckMem then
      ADC8(Immediate8Slow(ACC_READ))
   else
      ADC16(Immediate16Slow(ACC_READ));
end;

procedure Op6AM1;
begin
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   var W: Word := Word(ICPU.Registers.A.L) or (Word(Ord(ICPU.Carry)) shl 8);
   ICPU.Carry := (W and 1) <> 0;
   W := W shr 1;
   ICPU.Registers.A.L := Byte(W);
   SetZN8(ICPU.Registers.A.L);
end;

procedure Op6AM0;
begin
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   var W: Cardinal := Cardinal(ICPU.Registers.A.W) or (Cardinal(Ord(ICPU.Carry)) shl 16);
   ICPU.Carry := (W and 1) <> 0;
   W := W shr 1;
   ICPU.Registers.A.W := Word(W);
   SetZN16(ICPU.Registers.A.W);
end;

procedure Op6ASlow;
begin
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   if CheckMem then
   begin
      var W: Word := Word(ICPU.Registers.A.L) or (Word(Ord(ICPU.Carry)) shl 8);
      ICPU.Carry := (W and 1) <> 0;
      W := W shr 1;
      ICPU.Registers.A.L := Byte(W);
      SetZN8(ICPU.Registers.A.L);
   end
   else
   begin
      var W: Cardinal := Cardinal(ICPU.Registers.A.W) or (Cardinal(Ord(ICPU.Carry)) shl 16);
      ICPU.Carry := (W and 1) <> 0;
      W := W shr 1;
      ICPU.Registers.A.W := Word(W);
      SetZN16(ICPU.Registers.A.W);
   end;
end;

procedure Op6BE1;
begin
   CPU.Cycles := CPU.Cycles + Settings.TwoCycles;
   ICPU.Registers.PCw.PC.W := PullW;
   ICPU.Registers.PCw.PB := PullB;
   ICPU.Registers.S.H := 1;
   Inc(ICPU.Registers.PCw.PC.W);
   SetPCBase(ICPU.Registers.PCw.xPBPC);
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
end;

procedure Op6BE0;
begin
   CPU.Cycles := CPU.Cycles + Settings.TwoCycles;
   ICPU.Registers.PCw.PC.W := PullW;
   ICPU.Registers.PCw.PB := PullB;
   Inc(ICPU.Registers.PCw.PC.W);
   SetPCBase(ICPU.Registers.PCw.xPBPC);
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
end;

procedure Op6BSlow;
begin
   CPU.Cycles := CPU.Cycles + Settings.TwoCycles;
   ICPU.Registers.PCw.PC.W := PullW;
   ICPU.Registers.PCw.PB := PullB;
   if CheckEmulation then
      ICPU.Registers.S.H := 1;
   Inc(ICPU.Registers.PCw.PC.W);
   SetPCBase(ICPU.Registers.PCw.xPBPC);
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
end;

procedure Op6C;
begin
   SetPCBase(ICPU.ShiftedPB or AbsoluteIndirect(ACC_JUMP));
end;

procedure Op6CSlow;
begin
   SetPCBase(ICPU.ShiftedPB or AbsoluteIndirectSlow(ACC_JUMP));
end;

procedure Op6DM1;
begin
   ICPU.OpenBus := GetByte(Absolute(ACC_READ));
   ADC8(ICPU.OpenBus);
end;

procedure Op6DM0;
begin
   var W := GetWord(Absolute(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(W shr 8);
   ADC16(W);
end;

procedure Op6DSlow;
begin
   var addr := AbsoluteSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      ADC8(ICPU.OpenBus);
   end
   else
   begin
      var W := GetWord(addr, WRAP_NONE);
      ICPU.OpenBus := Byte(W shr 8);
      ADC16(W);
   end;
end;

procedure Op6EM1;
begin
   ROR8(Absolute(ACC_MODIFY));
end;

procedure Op6EM0;
begin
   ROR16(Absolute(ACC_MODIFY), WRAP_NONE);
end;

procedure Op6ESlow;
begin
   if CheckMem then
      ROR8(AbsoluteSlow(ACC_MODIFY))
   else
      ROR16(AbsoluteSlow(ACC_MODIFY), WRAP_NONE);
end;

procedure Op6FM1;
begin
   ICPU.OpenBus := GetByte(AbsoluteLong(ACC_READ));
   ADC8(ICPU.OpenBus);
end;

procedure Op6FM0;
begin
   var W := GetWord(AbsoluteLong(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(W shr 8);
   ADC16(W);
end;

procedure Op6FSlow;
begin
   var addr := AbsoluteLongSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      ADC8(ICPU.OpenBus);
   end
   else
   begin
      var W := GetWord(addr, WRAP_NONE);
      ICPU.OpenBus := Byte(W shr 8);
      ADC16(W);
   end;
end;

procedure Op70E1;
var
   newPC: TPair;
begin
   newPC.W := Relative(ACC_JUMP);
   if CheckOverflow then
   begin
      CPU.Cycles := CPU.Cycles + Settings.OneCycle;
      if ICPU.Registers.PCw.PB <> newPC.H then
         CPU.Cycles := CPU.Cycles + Settings.OneCycle;
      if (ICPU.Registers.PCw.PC.W and not MEMMAP_MASK) <> (newPC.W and not MEMMAP_MASK) then
         SetPCBase(ICPU.ShiftedPB or newPC.W)
      else
         ICPU.Registers.PCw.PC.W := newPC.W;
      CPUShutdown;
   end;
end;

procedure Op70E0;
var
   newPC: TPair;
begin
   newPC.W := Relative(ACC_JUMP);
   if CheckOverflow then
   begin
      CPU.Cycles := CPU.Cycles + Settings.OneCycle;
      if (ICPU.Registers.PCw.PC.W and not MEMMAP_MASK) <> (newPC.W and not MEMMAP_MASK) then
         SetPCBase(ICPU.ShiftedPB or newPC.W)
      else
         ICPU.Registers.PCw.PC.W := newPC.W;
      CPUShutdown;
   end;
end;

procedure Op70Slow;
var
   newPC: TPair;
begin
   newPC.W := RelativeSlow(ACC_JUMP);
   if CheckOverflow then
   begin
      CPU.Cycles := CPU.Cycles + Settings.OneCycle;
      if CheckEmulation and (ICPU.Registers.PCw.PB <> newPC.H) then
         CPU.Cycles := CPU.Cycles + Settings.OneCycle;
      if (ICPU.Registers.PCw.PC.W and not MEMMAP_MASK) <> (newPC.W and not MEMMAP_MASK) then
         SetPCBase(ICPU.ShiftedPB or newPC.W)
      else
         ICPU.Registers.PCw.PC.W := newPC.W;
      CPUShutdown;
   end;
end;

procedure Op71E1;
begin
   ICPU.OpenBus := GetByte(DirectIndirectIndexedE1(ACC_READ));
   ADC8(ICPU.OpenBus);
end;

procedure Op71E0M1X1;
begin
   ICPU.OpenBus := GetByte(DirectIndirectIndexedE0X1(ACC_READ));
   ADC8(ICPU.OpenBus);
end;

procedure Op71E0M0X1;
begin
   var W := GetWord(DirectIndirectIndexedE0X1(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(W shr 8);
   ADC16(W);
end;

procedure Op71E0M1X0;
begin
   ICPU.OpenBus := GetByte(DirectIndirectIndexedE0X0(ACC_READ));
   ADC8(ICPU.OpenBus);
end;

procedure Op71E0M0X0;
begin
   var W := GetWord(DirectIndirectIndexedE0X0(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(W shr 8);
   ADC16(W);
end;

procedure Op71Slow;
begin
   var addr := DirectIndirectIndexedSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      ADC8(ICPU.OpenBus);
   end
   else
   begin
      var W := GetWord(addr, WRAP_NONE);
      ICPU.OpenBus := Byte(W shr 8);
      ADC16(W);
   end;
end;

procedure Op72E1;
begin
   ICPU.OpenBus := GetByte(DirectIndirectE1(ACC_READ));
   ADC8(ICPU.OpenBus);
end;

procedure Op72E0M1;
begin
   ICPU.OpenBus := GetByte(DirectIndirectE0(ACC_READ));
   ADC8(ICPU.OpenBus);
end;

procedure Op72E0M0;
begin
   var W := GetWord(DirectIndirectE0(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(W shr 8);
   ADC16(W);
end;

procedure Op72Slow;
begin
   var addr := DirectIndirectSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      ADC8(ICPU.OpenBus);
   end
   else
   begin
      var W := GetWord(addr, WRAP_NONE);
      ICPU.OpenBus := Byte(W shr 8);
      ADC16(W);
   end;
end;

procedure Op73M1;
begin
   ICPU.OpenBus := GetByte(StackRelativeIndirectIndexed(ACC_READ));
   ADC8(ICPU.OpenBus);
end;

procedure Op73M0;
begin
   var W := GetWord(StackRelativeIndirectIndexed(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(W shr 8);
   ADC16(W);
end;

procedure Op73Slow;
begin
   var addr := StackRelativeIndirectIndexedSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      ADC8(ICPU.OpenBus);
   end
   else
   begin
      var W := GetWord(addr, WRAP_NONE);
      ICPU.OpenBus := Byte(W shr 8);
      ADC16(W);
   end;
end;

procedure Op74E1;
begin
   ICPU.OpenBus := GetByte(DirectIndexedXE1(ACC_READ));
   ADC8(ICPU.OpenBus);
end;

procedure Op74E0M1;
begin
   ICPU.OpenBus := GetByte(DirectIndexedXE0(ACC_READ));
   ADC8(ICPU.OpenBus);
end;

procedure Op74E0M0;
begin
   var W := GetWord(DirectIndexedXE0(ACC_READ), WRAP_BANK);
   ICPU.OpenBus := Byte(W shr 8);
   ADC16(W);
end;

procedure Op74Slow;
begin
   var addr := DirectIndexedXSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      ADC8(ICPU.OpenBus);
   end
   else
   begin
      var W := GetWord(addr, WRAP_BANK);
      ICPU.OpenBus := Byte(W shr 8);
      ADC16(W);
   end;
end;

procedure Op75E1;
begin
   ICPU.OpenBus := GetByte(DirectIndexedXE1(ACC_READ));
   ADC8(ICPU.OpenBus);
end;

procedure Op75E0M1;
begin
   ICPU.OpenBus := GetByte(DirectIndexedXE0(ACC_READ));
   ADC8(ICPU.OpenBus);
end;

procedure Op75E0M0;
begin
   var W := GetWord(DirectIndexedXE0(ACC_READ), WRAP_BANK);
   ICPU.OpenBus := Byte(W shr 8);
   ADC16(W);
end;

procedure Op75Slow;
begin
   var addr := DirectIndexedXSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      ADC8(ICPU.OpenBus);
   end
   else
   begin
      var W := GetWord(addr, WRAP_BANK);
      ICPU.OpenBus := Byte(W shr 8);
      ADC16(W);
   end;
end;

procedure Op76E1;
begin
   ROR8(DirectIndexedXE1(ACC_MODIFY));
end;

procedure Op76E0M1;
begin
   ROR8(DirectIndexedXE0(ACC_MODIFY));
end;

procedure Op76E0M0;
begin
   ROR16(DirectIndexedXE0(ACC_MODIFY), WRAP_BANK);
end;

procedure Op76Slow;
begin
   if CheckMem then
      ROR8(DirectIndexedXSlow(ACC_MODIFY))
   else
      ROR16(DirectIndexedXSlow(ACC_MODIFY), WRAP_BANK);
end;

procedure Op77M1;
begin
   ICPU.OpenBus := GetByte(DirectIndirectIndexedLong(ACC_READ));
   ADC8(ICPU.OpenBus);
end;

procedure Op77M0;
begin
   var W := GetWord(DirectIndirectIndexedLong(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(W shr 8);
   ADC16(W);
end;

procedure Op77Slow;
begin
   var addr := DirectIndirectIndexedLongSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      ADC8(ICPU.OpenBus);
   end
   else
   begin
      var W := GetWord(addr, WRAP_NONE);
      ICPU.OpenBus := Byte(W shr 8);
      ADC16(W);
   end;
end;

procedure Op78; // SEI
begin
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   SetFlags(FLAG_IRQ);
end;

procedure Op79M1X1;
begin
   ICPU.OpenBus := GetByte(AbsoluteIndexedYX1(ACC_READ));
   ADC8(ICPU.OpenBus);
end;

procedure Op79M0X1;
begin
   var W := GetWord(AbsoluteIndexedYX1(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(W shr 8);
   ADC16(W);
end;

procedure Op79M1X0;
begin
   ICPU.OpenBus := GetByte(AbsoluteIndexedYX0(ACC_READ));
   ADC8(ICPU.OpenBus);
end;

procedure Op79M0X0;
begin
   var W := GetWord(AbsoluteIndexedYX0(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(W shr 8);
   ADC16(W);
end;

procedure Op79Slow;
begin
   var addr := AbsoluteIndexedYSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      ADC8(ICPU.OpenBus);
   end
   else
   begin
      var W := GetWord(addr, WRAP_NONE);
      ICPU.OpenBus := Byte(W shr 8);
      ADC16(W);
   end;
end;

procedure Op7AE1;
begin
   CPU.Cycles := CPU.Cycles + Settings.TwoCycles;
   ICPU.Registers.Y.L := PullBE;
   SetZN8(ICPU.Registers.Y.L);
   ICPU.OpenBus := ICPU.Registers.Y.L;
end;

procedure Op7AE0X1;
begin
   CPU.Cycles := CPU.Cycles + Settings.TwoCycles;
   ICPU.Registers.Y.L := PullB;
   SetZN8(ICPU.Registers.Y.L);
   ICPU.OpenBus := ICPU.Registers.Y.L;
end;

procedure Op7AE0X0;
begin
   CPU.Cycles := CPU.Cycles + Settings.TwoCycles;
   ICPU.Registers.Y.W := PullW;
   SetZN16(ICPU.Registers.Y.W);
   ICPU.OpenBus := ICPU.Registers.Y.H;
end;

procedure Op7ASlow;
begin
   CPU.Cycles := CPU.Cycles + Settings.TwoCycles;
   if CheckEmulation then
   begin
      ICPU.Registers.Y.L := PullBE;
      SetZN8(ICPU.Registers.Y.L);
      ICPU.OpenBus := ICPU.Registers.Y.L;
   end
   else
   begin
      if CheckIndex then
      begin
         ICPU.Registers.Y.L := PullB;
         SetZN8(ICPU.Registers.Y.L);
         ICPU.OpenBus := ICPU.Registers.Y.L;
      end
      else
      begin
         ICPU.Registers.Y.W := PullW;
         SetZN16(ICPU.Registers.Y.W);
         ICPU.OpenBus := ICPU.Registers.Y.H;
      end;
   end;
end;

procedure Op7B; // TDC
begin
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   ICPU.Registers.A.W := ICPU.Registers.D.W;
   SetZN16(ICPU.Registers.A.W);
end;

procedure Op7C;
begin
   SetPCBase(ICPU.ShiftedPB or AbsoluteIndexedIndirect(ACC_JUMP));
end;

procedure Op7CSlow;
begin
   SetPCBase(ICPU.ShiftedPB or AbsoluteIndexedIndirectSlow(ACC_JUMP));
end;

procedure Op7DM1X1;
begin
   ICPU.OpenBus := GetByte(AbsoluteIndexedXX1(ACC_READ));
   ADC8(ICPU.OpenBus);
end;

procedure Op7DM0X1;
begin
   var W := GetWord(AbsoluteIndexedXX1(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(W shr 8);
   ADC16(W);
end;

procedure Op7DM1X0;
begin
   ICPU.OpenBus := GetByte(AbsoluteIndexedXX0(ACC_READ));
   ADC8(ICPU.OpenBus);
end;

procedure Op7DM0X0;
begin
   var W := GetWord(AbsoluteIndexedXX0(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(W shr 8);
   ADC16(W);
end;

procedure Op7DSlow;
begin
   var addr := AbsoluteIndexedXSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      ADC8(ICPU.OpenBus);
   end
   else
   begin
      var W := GetWord(addr, WRAP_NONE);
      ICPU.OpenBus := Byte(W shr 8);
      ADC16(W);
   end;
end;

procedure Op7EM1X1;
begin
   ROR8(AbsoluteIndexedXX1(ACC_MODIFY));
end;

procedure Op7EM0X1;
begin
   ROR16(AbsoluteIndexedXX1(ACC_MODIFY), WRAP_NONE);
end;

procedure Op7EM1X0;
begin
   ROR8(AbsoluteIndexedXX0(ACC_MODIFY));
end;

procedure Op7EM0X0;
begin
   ROR16(AbsoluteIndexedXX0(ACC_MODIFY), WRAP_NONE);
end;

procedure Op7ESlow;
begin
   if CheckMem then
      ROR8(AbsoluteIndexedXSlow(ACC_MODIFY))
   else
      ROR16(AbsoluteIndexedXSlow(ACC_MODIFY), WRAP_NONE);
end;

procedure Op7FM1;
begin
   ICPU.OpenBus := GetByte(AbsoluteLongIndexedX(ACC_READ));
   ADC8(ICPU.OpenBus);
end;

procedure Op7FM0;
begin
   var W := GetWord(AbsoluteLongIndexedX(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(W shr 8);
   ADC16(W);
end;

procedure Op7FSlow;
begin
   var addr := AbsoluteLongIndexedXSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      ADC8(ICPU.OpenBus);
   end
   else
   begin
      var W := GetWord(addr, WRAP_NONE);
      ICPU.OpenBus := Byte(W shr 8);
      ADC16(W);
   end;
end;

procedure Op80E1;
var
   newPC: TPair;
begin
   newPC.W := Relative(ACC_JUMP);
   begin
      CPU.Cycles := CPU.Cycles + Settings.OneCycle;
      if ICPU.Registers.PCw.PB <> newPC.H then
         CPU.Cycles := CPU.Cycles + Settings.OneCycle;
      if (ICPU.Registers.PCw.PC.W and not MEMMAP_MASK) <> (newPC.W and not MEMMAP_MASK) then
         SetPCBase(ICPU.ShiftedPB or newPC.W)
      else
         ICPU.Registers.PCw.PC.W := newPC.W;
      CPUShutdown;
   end;
end;

procedure Op80E0;
var
   newPC: TPair;
begin
   newPC.W := Relative(ACC_JUMP);
   begin
      CPU.Cycles := CPU.Cycles + Settings.OneCycle;
      if (ICPU.Registers.PCw.PC.W and not MEMMAP_MASK) <> (newPC.W and not MEMMAP_MASK) then
         SetPCBase(ICPU.ShiftedPB or newPC.W)
      else
         ICPU.Registers.PCw.PC.W := newPC.W;
      CPUShutdown;
   end;
end;

procedure Op80Slow;
var
   newPC: TPair;
begin
   newPC.W := RelativeSlow(ACC_JUMP);
   begin
      CPU.Cycles := CPU.Cycles + Settings.OneCycle;
      if CheckEmulation and (ICPU.Registers.PCw.PB <> newPC.H) then
         CPU.Cycles := CPU.Cycles + Settings.OneCycle;
      if (ICPU.Registers.PCw.PC.W and not MEMMAP_MASK) <> (newPC.W and not MEMMAP_MASK) then
         SetPCBase(ICPU.ShiftedPB or newPC.W)
      else
         ICPU.Registers.PCw.PC.W := newPC.W;
      CPUShutdown;
   end;
end;

procedure Op81E1;
begin
   STA8(DirectIndexedIndirectE1(ACC_WRITE));
end;

procedure Op81E0M1;
begin
   STA8(DirectIndexedIndirectE0(ACC_WRITE));
end;

procedure Op81E0M0;
begin
   STA16(DirectIndexedIndirectE0(ACC_WRITE), WRAP_NONE);
end;

procedure Op81Slow;
begin
   if CheckMem then
      STA8(DirectIndexedIndirectSlow(ACC_WRITE))
   else
      STA16(DirectIndexedIndirectSlow(ACC_WRITE), WRAP_NONE);
end;

procedure Op82;
begin
   SetPCBase(ICPU.ShiftedPB or RelativeLong(ACC_JUMP));
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
end;

procedure Op82Slow;
begin
   SetPCBase(ICPU.ShiftedPB or RelativeLongSlow(ACC_JUMP));
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
end;

procedure Op83M1;
begin
   STA8(StackRelative(ACC_WRITE));
end;

procedure Op83M0;
begin
   STA16(StackRelative(ACC_WRITE), WRAP_NONE);
end;

procedure Op83Slow;
begin
   if CheckMem then
      STA8(StackRelativeSlow(ACC_WRITE))
   else
      STA16(StackRelativeSlow(ACC_WRITE), WRAP_NONE);
end;

procedure Op84X1;
begin
   STY8(Direct(ACC_WRITE));
end;

procedure Op84X0;
begin
   STY16(Direct(ACC_WRITE), WRAP_BANK);
end;

procedure Op84Slow;
begin
   if CheckIndex then
      STY8(DirectSlow(ACC_WRITE))
   else
      STY16(DirectSlow(ACC_WRITE), WRAP_BANK);
end;

procedure Op85M1;
begin
   STA8(Direct(ACC_WRITE));
end;

procedure Op85M0;
begin
   STA16(Direct(ACC_WRITE), WRAP_BANK);
end;

procedure Op85Slow;
begin
   if CheckMem then
      STA8(DirectSlow(ACC_WRITE))
   else
      STA16(DirectSlow(ACC_WRITE), WRAP_BANK);
end;

procedure Op86X1;
begin
   STX8(Direct(ACC_WRITE));
end;

procedure Op86X0;
begin
   STX16(Direct(ACC_WRITE), WRAP_BANK);
end;

procedure Op86Slow;
begin
   if CheckIndex then
      STX8(DirectSlow(ACC_WRITE))
   else
      STX16(DirectSlow(ACC_WRITE), WRAP_BANK);
end;

procedure Op87M1;
begin
   STA8(DirectIndirectLong(ACC_WRITE));
end;

procedure Op87M0;
begin
   STA16(DirectIndirectLong(ACC_WRITE), WRAP_NONE);
end;

procedure Op87Slow;
begin
   if CheckMem then
      STA8(DirectIndirectLongSlow(ACC_WRITE))
   else
      STA16(DirectIndirectLongSlow(ACC_WRITE), WRAP_NONE);
end;

procedure Op88X1;
begin
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   CPU.WaitPC := 0;
   Dec(ICPU.Registers.Y.L);
   SetZN8(ICPU.Registers.Y.L);
end;

procedure Op88X0;
begin
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   CPU.WaitPC := 0;
   Dec(ICPU.Registers.Y.W);
   SetZN16(ICPU.Registers.Y.W);
end;

procedure Op88Slow;
begin
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   CPU.WaitPC := 0;
   if CheckIndex then
   begin
      Dec(ICPU.Registers.Y.L);
      SetZN8(ICPU.Registers.Y.L);
   end
   else
   begin
      Dec(ICPU.Registers.Y.W);
      SetZN16(ICPU.Registers.Y.W);
   end;
end;

procedure Op89M1;
begin
   ICPU.Zero := (ICPU.Registers.A.L and Immediate8(ACC_READ)) = 0;
end;

procedure Op89M0;
begin
   ICPU.Zero := (ICPU.Registers.A.W and Immediate16(ACC_READ)) = 0;
end;

procedure Op89Slow;
begin
   if CheckMem then
      ICPU.Zero := (ICPU.Registers.A.L and Immediate8Slow(ACC_READ)) = 0
   else
      ICPU.Zero := (ICPU.Registers.A.W and Immediate16Slow(ACC_READ)) = 0;
end;

procedure Op8AM1;
begin
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   ICPU.Registers.A.L := ICPU.Registers.X.L;
   SetZN8(ICPU.Registers.A.L);
end;

procedure Op8AM0;
begin
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   ICPU.Registers.A.W := ICPU.Registers.X.W;
   SetZN16(ICPU.Registers.A.W);
end;

procedure Op8ASlow;
begin
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   if CheckMem then
   begin
      ICPU.Registers.A.L := ICPU.Registers.X.L;
      SetZN8(ICPU.Registers.A.L);
   end
   else
   begin
      ICPU.Registers.A.W := ICPU.Registers.X.W;
      SetZN16(ICPU.Registers.A.W);
   end;
end;

procedure Op8BE1;
begin
   CPU.Cycles := CPU.Cycles + Settings.TwoCycles;
   ICPU.Registers.DB := PullBE;
   SetZN8(ICPU.Registers.DB);
   ICPU.ShiftedDB := Cardinal(ICPU.Registers.DB) shl 16;
   ICPU.OpenBus := ICPU.Registers.DB;
end;

procedure Op8BE0;
begin
   CPU.Cycles := CPU.Cycles + Settings.TwoCycles;
   ICPU.Registers.DB := PullB;
   SetZN8(ICPU.Registers.DB);
   ICPU.ShiftedDB := Cardinal(ICPU.Registers.DB) shl 16;
   ICPU.OpenBus := ICPU.Registers.DB;
end;

procedure Op8BSlow;
begin
   CPU.Cycles := CPU.Cycles + Settings.TwoCycles;
   if CheckEmulation then
      ICPU.Registers.DB := PullBE
   else
      ICPU.Registers.DB := PullB;
   SetZN8(ICPU.Registers.DB);
   ICPU.ShiftedDB := Cardinal(ICPU.Registers.DB) shl 16;
   ICPU.OpenBus := ICPU.Registers.DB;
end;

procedure Op8CX1;
begin
   STY8(Absolute(ACC_WRITE));
end;

procedure Op8CX0;
begin
   STY16(Absolute(ACC_WRITE), WRAP_NONE);
end;

procedure Op8CSlow;
begin
   if CheckIndex then
      STY8(AbsoluteSlow(ACC_WRITE))
   else
      STY16(AbsoluteSlow(ACC_WRITE), WRAP_NONE);
end;

procedure Op8DM1;
begin
   STA8(Absolute(ACC_WRITE));
end;

procedure Op8DM0;
begin
   STA16(Absolute(ACC_WRITE), WRAP_NONE);
end;

procedure Op8DSlow;
begin
   if CheckMem then
      STA8(AbsoluteSlow(ACC_WRITE))
   else
      STA16(AbsoluteSlow(ACC_WRITE), WRAP_NONE);
end;

procedure Op8EX1;
begin
   STX8(Absolute(ACC_WRITE));
end;

procedure Op8EX0;
begin
   STX16(Absolute(ACC_WRITE), WRAP_NONE);
end;

procedure Op8ESlow;
begin
   if CheckIndex then
      STX8(AbsoluteSlow(ACC_WRITE))
   else
      STX16(AbsoluteSlow(ACC_WRITE), WRAP_NONE);
end;

procedure Op8FM1;
begin
   STA8(AbsoluteLong(ACC_WRITE));
end;

procedure Op8FM0;
begin
   STA16(AbsoluteLong(ACC_WRITE), WRAP_NONE);
end;

procedure Op8FSlow;
begin
   if CheckMem then
      STA8(AbsoluteLongSlow(ACC_WRITE))
   else
      STA16(AbsoluteLongSlow(ACC_WRITE), WRAP_NONE);
end;

procedure Op90E1;
var
   newPC: TPair;
begin
   newPC.W := Relative(ACC_JUMP);
   if not ICPU.Carry then
   begin
      CPU.Cycles := CPU.Cycles + Settings.OneCycle;
      if ICPU.Registers.PCw.PB <> newPC.H then
         CPU.Cycles := CPU.Cycles + Settings.OneCycle;
      if (ICPU.Registers.PCw.PC.W and not MEMMAP_MASK) <> (newPC.W and not MEMMAP_MASK) then
         SetPCBase(ICPU.ShiftedPB or newPC.W)
      else
         ICPU.Registers.PCw.PC.W := newPC.W;
      CPUShutdown;
   end;
end;

procedure Op90E0;
var
   newPC: TPair;
begin
   newPC.W := Relative(ACC_JUMP);
   if not ICPU.Carry then
   begin
      CPU.Cycles := CPU.Cycles + Settings.OneCycle;
      if (ICPU.Registers.PCw.PC.W and not MEMMAP_MASK) <> (newPC.W and not MEMMAP_MASK) then
         SetPCBase(ICPU.ShiftedPB or newPC.W)
      else
         ICPU.Registers.PCw.PC.W := newPC.W;
      CPUShutdown;
   end;
end;

procedure Op90Slow;
var
   newPC: TPair;
begin
   newPC.W := RelativeSlow(ACC_JUMP);
   if not ICPU.Carry then
   begin
      CPU.Cycles := CPU.Cycles + Settings.OneCycle;
      if CheckEmulation and (ICPU.Registers.PCw.PB <> newPC.H) then
         CPU.Cycles := CPU.Cycles + Settings.OneCycle;
      if (ICPU.Registers.PCw.PC.W and not MEMMAP_MASK) <> (newPC.W and not MEMMAP_MASK) then
         SetPCBase(ICPU.ShiftedPB or newPC.W)
      else
         ICPU.Registers.PCw.PC.W := newPC.W;
      CPUShutdown;
   end;
end;

procedure Op91E1;
begin
   STA8(DirectIndirectIndexedE1(ACC_WRITE));
end;

procedure Op91E0M1X1;
begin
   STA8(DirectIndirectIndexedE0X1(ACC_WRITE));
end;

procedure Op91E0M0X1;
begin
   STA16(DirectIndirectIndexedE0X1(ACC_WRITE), WRAP_NONE);
end;

procedure Op91E0M1X0;
begin
   STA8(DirectIndirectIndexedE0X0(ACC_WRITE));
end;

procedure Op91E0M0X0;
begin
   STA16(DirectIndirectIndexedE0X0(ACC_WRITE), WRAP_NONE);
end;

procedure Op91Slow;
begin
   if CheckMem then
      STA8(DirectIndirectIndexedSlow(ACC_WRITE))
   else
      STA16(DirectIndirectIndexedSlow(ACC_WRITE), WRAP_NONE);
end;

procedure Op92E1;
begin
   STA8(DirectIndirectE1(ACC_WRITE));
end;

procedure Op92E0M1;
begin
   STA8(DirectIndirectE0(ACC_WRITE));
end;

procedure Op92E0M0;
begin
   STA16(DirectIndirectE0(ACC_WRITE), WRAP_NONE);
end;

procedure Op92Slow;
begin
   if CheckMem then
      STA8(DirectIndirectSlow(ACC_WRITE))
   else
      STA16(DirectIndirectSlow(ACC_WRITE), WRAP_NONE);
end;

procedure Op93M1;
begin
   STA8(StackRelativeIndirectIndexed(ACC_WRITE));
end;

procedure Op93M0;
begin
   STA16(StackRelativeIndirectIndexed(ACC_WRITE), WRAP_NONE);
end;

procedure Op93Slow;
begin
   if CheckMem then
      STA8(StackRelativeIndirectIndexedSlow(ACC_WRITE))
   else
      STA16(StackRelativeIndirectIndexedSlow(ACC_WRITE), WRAP_NONE);
end;

procedure Op94E1;
begin
   STY8(DirectIndexedXE1(ACC_WRITE));
end;

procedure Op94E0X1;
begin
   STY8(DirectIndexedXE0(ACC_WRITE));
end;

procedure Op94E0X0;
begin
   STY16(DirectIndexedXE0(ACC_WRITE), WRAP_BANK);
end;

procedure Op94Slow;
begin
   if CheckIndex then
      STY8(DirectIndexedXSlow(ACC_WRITE))
   else
      STY16(DirectIndexedXSlow(ACC_WRITE), WRAP_BANK);
end;

procedure Op95E1;
begin
   STA8(DirectIndexedXE1(ACC_WRITE));
end;

procedure Op95E0M1;
begin
   STA8(DirectIndexedXE0(ACC_WRITE));
end;

procedure Op95E0M0;
begin
   STA16(DirectIndexedXE0(ACC_WRITE), WRAP_BANK);
end;

procedure Op95Slow;
begin
   if CheckMem then
      STA8(DirectIndexedXSlow(ACC_WRITE))
   else
      STA16(DirectIndexedXSlow(ACC_WRITE), WRAP_BANK);
end;

procedure Op96E1;
begin
   STX8(DirectIndexedYE1(ACC_WRITE));
end;

procedure Op96E0X1;
begin
   STX8(DirectIndexedYE0(ACC_WRITE));
end;

procedure Op96E0X0;
begin
   STX16(DirectIndexedYE0(ACC_WRITE), WRAP_BANK);
end;

procedure Op96Slow;
begin
   if CheckIndex then
      STX8(DirectIndexedYSlow(ACC_WRITE))
   else
      STX16(DirectIndexedYSlow(ACC_WRITE), WRAP_BANK);
end;

procedure Op97M1;
begin
   STA8(DirectIndirectIndexedLong(ACC_WRITE));
end;

procedure Op97M0;
begin
   STA16(DirectIndirectIndexedLong(ACC_WRITE), WRAP_NONE);
end;

procedure Op97Slow;
begin
   if CheckMem then
      STA8(DirectIndirectIndexedLongSlow(ACC_WRITE))
   else
      STA16(DirectIndirectIndexedLongSlow(ACC_WRITE), WRAP_NONE);
end;

procedure Op98M1;
begin
   ICPU.Registers.A.L := ICPU.Registers.Y.L;
   SetZN8(ICPU.Registers.A.L);
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
end;

procedure Op98M0;
begin
   ICPU.Registers.A.W := ICPU.Registers.Y.W;
   SetZN16(ICPU.Registers.A.W);
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
end;

procedure Op98Slow;
begin
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   if CheckMem then
   begin
      ICPU.Registers.A.L := ICPU.Registers.Y.L;
      SetZN8(ICPU.Registers.A.L);
   end
   else
   begin
      ICPU.Registers.A.W := ICPU.Registers.Y.W;
      SetZN16(ICPU.Registers.A.W);
   end;
end;

procedure Op99M1X1;
begin
   STA8(AbsoluteIndexedYX1(ACC_WRITE));
end;

procedure Op99M0X1;
begin
   STA16(AbsoluteIndexedYX1(ACC_WRITE), WRAP_NONE);
end;

procedure Op99M1X0;
begin
   STA8(AbsoluteIndexedYX0(ACC_WRITE));
end;

procedure Op99M0X0;
begin
   STA16(AbsoluteIndexedYX0(ACC_WRITE), WRAP_NONE);
end;

procedure Op99Slow;
begin
   if CheckMem then
      STA8(AbsoluteIndexedYSlow(ACC_WRITE))
   else
      STA16(AbsoluteIndexedYSlow(ACC_WRITE), WRAP_NONE);
end;

procedure Op9A; // TXS
begin
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   ICPU.Registers.S.W := ICPU.Registers.X.W;
   if CheckEmulation then
      ICPU.Registers.S.H := 1;
end;

procedure Op9BX1;
begin
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   ICPU.Registers.Y.L := ICPU.Registers.X.L;
   SetZN8(ICPU.Registers.Y.L);
end;

procedure Op9BX0;
begin
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   ICPU.Registers.Y.W := ICPU.Registers.X.W;
   SetZN16(ICPU.Registers.Y.W);
end;

procedure Op9BSlow;
begin
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   if CheckIndex then
   begin
      ICPU.Registers.Y.L := ICPU.Registers.X.L;
      SetZN8(ICPU.Registers.Y.L);
   end
   else
   begin
      ICPU.Registers.Y.W := ICPU.Registers.X.W;
      SetZN16(ICPU.Registers.Y.W);
   end;
end;

procedure Op9CM1;
begin
   STZ8(Absolute(ACC_WRITE));
end;

procedure Op9CM0;
begin
   STZ16(Absolute(ACC_WRITE), WRAP_NONE);
end;

procedure Op9CSlow;
begin
   if CheckMem then
      STZ8(AbsoluteSlow(ACC_WRITE))
   else
      STZ16(AbsoluteSlow(ACC_WRITE), WRAP_NONE);
end;

procedure Op9DM1X1;
begin
   STA8(AbsoluteIndexedXX1(ACC_WRITE));
end;

procedure Op9DM0X1;
begin
   STA16(AbsoluteIndexedXX1(ACC_WRITE), WRAP_NONE);
end;

procedure Op9DM1X0;
begin
   STA8(AbsoluteIndexedXX0(ACC_WRITE));
end;

procedure Op9DM0X0;
begin
   STA16(AbsoluteIndexedXX0(ACC_WRITE), WRAP_NONE);
end;

procedure Op9DSlow;
begin
   if CheckMem then
      STA8(AbsoluteIndexedXSlow(ACC_WRITE))
   else
      STA16(AbsoluteIndexedXSlow(ACC_WRITE), WRAP_NONE);
end;

procedure Op9EM1X1;
begin
   STZ8(AbsoluteIndexedXX1(ACC_WRITE));
end;

procedure Op9EM0X1;
begin
   STZ16(AbsoluteIndexedXX1(ACC_WRITE), WRAP_NONE);
end;

procedure Op9EM1X0;
begin
   STZ8(AbsoluteIndexedXX0(ACC_WRITE));
end;

procedure Op9EM0X0;
begin
   STZ16(AbsoluteIndexedXX0(ACC_WRITE), WRAP_NONE);
end;

procedure Op9ESlow;
begin
   if CheckMem then
      STZ8(AbsoluteIndexedXSlow(ACC_WRITE))
   else
      STZ16(AbsoluteIndexedXSlow(ACC_WRITE), WRAP_NONE);
end;

procedure Op9FM1;
begin
   STA8(AbsoluteLongIndexedX(ACC_WRITE));
end;

procedure Op9FM0;
begin
   STA16(AbsoluteLongIndexedX(ACC_WRITE), WRAP_NONE);
end;

procedure Op9FSlow;
begin
   if CheckMem then
      STA8(AbsoluteLongIndexedXSlow(ACC_WRITE))
   else
      STA16(AbsoluteLongIndexedXSlow(ACC_WRITE), WRAP_NONE);
end;

procedure OpA0X1;
begin
   LDY8(Immediate8(ACC_READ));
end;

procedure OpA0X0;
begin
   LDY16(Immediate16(ACC_READ));
end;

procedure OpA0Slow;
begin
   if CheckIndex then
      LDY8(Immediate8Slow(ACC_READ))
   else
      LDY16(Immediate16Slow(ACC_READ));
end;

procedure OpA1E1;
begin
   ICPU.OpenBus := GetByte(DirectIndexedIndirectE1(ACC_READ));
   LDA8(ICPU.OpenBus);
end;

procedure OpA1E0M1;
begin
   ICPU.OpenBus := GetByte(DirectIndexedIndirectE0(ACC_READ));
   LDA8(ICPU.OpenBus);
end;

procedure OpA1E0M0;
begin
   var w := GetWord(DirectIndexedIndirectE0(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(w shr 8);
   LDA16(w);
end;

procedure OpA1Slow;
begin
   var addr := DirectIndexedIndirectSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      LDA8(ICPU.OpenBus);
   end
   else
   begin
      var w := GetWord(addr, WRAP_NONE);
      ICPU.OpenBus := Byte(w shr 8);
      LDA16(w);
   end;
end;

procedure OpA2X1;
begin
   LDX8(Immediate8(ACC_READ));
end;

procedure OpA2X0;
begin
   LDX16(Immediate16(ACC_READ));
end;

procedure OpA2Slow;
begin
   if CheckIndex then
      LDX8(Immediate8Slow(ACC_READ))
   else
      LDX16(Immediate16Slow(ACC_READ));
end;

procedure OpA3M1;
begin
   ICPU.OpenBus := GetByte(StackRelative(ACC_READ));
   LDA8(ICPU.OpenBus);
end;

procedure OpA3M0;
begin
   var w := GetWord(StackRelative(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(w shr 8);
   LDA16(w);
end;

procedure OpA3Slow;
begin
   var addr := StackRelativeSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      LDA8(ICPU.OpenBus);
   end
   else
   begin
      var w := GetWord(addr, WRAP_NONE);
      ICPU.OpenBus := Byte(w shr 8);
      LDA16(w);
   end;
end;

procedure OpA4X1;
begin
   ICPU.OpenBus := GetByte(Direct(ACC_READ));
   LDY8(ICPU.OpenBus);
end;

procedure OpA4X0;
begin
   var w := GetWord(Direct(ACC_READ), WRAP_BANK);
   ICPU.OpenBus := Byte(w shr 8);
   LDY16(w);
end;

procedure OpA4Slow;
begin
   var addr := DirectSlow(ACC_READ);
   if CheckIndex then
   begin
      ICPU.OpenBus := GetByte(addr);
      LDY8(ICPU.OpenBus);
   end
   else
   begin
      var w := GetWord(addr, WRAP_BANK);
      ICPU.OpenBus := Byte(w shr 8);
      LDY16(w);
   end;
end;

procedure OpA5M1;
begin
   ICPU.OpenBus := GetByte(Direct(ACC_READ));
   LDA8(ICPU.OpenBus);
end;

procedure OpA5M0;
begin
   var w := GetWord(Direct(ACC_READ), WRAP_BANK);
   ICPU.OpenBus := Byte(w shr 8);
   LDA16(w);
end;

procedure OpA5Slow;
begin
   var addr := DirectSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      LDA8(ICPU.OpenBus);
   end
   else
   begin
      var w := GetWord(addr, WRAP_BANK);
      ICPU.OpenBus := Byte(w shr 8);
      LDA16(w);
   end;
end;

procedure OpA6X1;
begin
   ICPU.OpenBus := GetByte(Direct(ACC_READ));
   LDX8(ICPU.OpenBus);
end;

procedure OpA6X0;
begin
   var w := GetWord(Direct(ACC_READ), WRAP_BANK);
   ICPU.OpenBus := Byte(w shr 8);
   LDX16(w);
end;

procedure OpA6Slow;
begin
   var addr := DirectSlow(ACC_READ);
   if CheckIndex then
   begin
      ICPU.OpenBus := GetByte(addr);
      LDX8(ICPU.OpenBus);
   end
   else
   begin
      var w := GetWord(addr, WRAP_BANK);
      ICPU.OpenBus := Byte(w shr 8);
      LDX16(w);
   end;
end;

procedure OpA7M1;
begin
   ICPU.OpenBus := GetByte(DirectIndirectLong(ACC_READ));
   LDA8(ICPU.OpenBus);
end;

procedure OpA7M0;
begin
   var w := GetWord(DirectIndirectLong(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(w shr 8);
   LDA16(w);
end;

procedure OpA7Slow;
begin
   var addr := DirectIndirectLongSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      LDA8(ICPU.OpenBus);
   end
   else
   begin
      var w := GetWord(addr, WRAP_NONE);
      ICPU.OpenBus := Byte(w shr 8);
      LDA16(w);
   end;
end;

procedure OpA8X1;
begin
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   ICPU.Registers.Y.L := ICPU.Registers.A.L;
   SetZN8(ICPU.Registers.Y.L);
end;

procedure OpA8X0;
begin
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   ICPU.Registers.Y.w := ICPU.Registers.A.w;
   SetZN16(ICPU.Registers.Y.w);
end;

procedure OpA8Slow;
begin
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   if CheckIndex then
   begin
      ICPU.Registers.Y.L := ICPU.Registers.A.L;
      SetZN8(ICPU.Registers.Y.L);
   end
   else
   begin
      ICPU.Registers.Y.w := ICPU.Registers.A.w;
      SetZN16(ICPU.Registers.Y.w);
   end;
end;

procedure OpA9M1;
begin
   LDA8(Immediate8(ACC_READ));
end;

procedure OpA9M0;
begin
   LDA16(Immediate16(ACC_READ));
end;

procedure OpA9Slow;
begin
   if CheckMem then
      LDA8(Immediate8Slow(ACC_READ))
   else
      LDA16(Immediate16Slow(ACC_READ));
end;

procedure OpAAX1;
begin
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   ICPU.Registers.X.L := ICPU.Registers.A.L;
   SetZN8(ICPU.Registers.X.L);
end;

procedure OpAAX0;
begin
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   ICPU.Registers.X.w := ICPU.Registers.A.w;
   SetZN16(ICPU.Registers.X.w);
end;

procedure OpAASlow;
begin
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   if CheckIndex then
   begin
      ICPU.Registers.X.L := ICPU.Registers.A.L;
      SetZN8(ICPU.Registers.X.L);
   end
   else
   begin
      ICPU.Registers.X.w := ICPU.Registers.A.w;
      SetZN16(ICPU.Registers.X.w);
   end;
end;

procedure OpABE1;
begin
   CPU.Cycles := CPU.Cycles + Settings.TwoCycles;
   ICPU.Registers.DB := PullBE;
   SetZN8(ICPU.Registers.DB);
   ICPU.ShiftedDB := Cardinal(ICPU.Registers.DB) shl 16;
   ICPU.OpenBus := ICPU.Registers.DB;
end;

procedure OpABE0;
begin
   CPU.Cycles := CPU.Cycles + Settings.TwoCycles;
   ICPU.Registers.DB := PullB;
   SetZN8(ICPU.Registers.DB);
   ICPU.ShiftedDB := Cardinal(ICPU.Registers.DB) shl 16;
   ICPU.OpenBus := ICPU.Registers.DB;
end;

procedure OpABSlow;
begin
   CPU.Cycles := CPU.Cycles + Settings.TwoCycles;
   if CheckEmulation then
      ICPU.Registers.DB := PullBE
   else
      ICPU.Registers.DB := PullB;
   SetZN8(ICPU.Registers.DB);
   ICPU.ShiftedDB := Cardinal(ICPU.Registers.DB) shl 16;
   ICPU.OpenBus := ICPU.Registers.DB;
end;

procedure OpACX1;
begin
   ICPU.OpenBus := GetByte(Absolute(ACC_READ));
   LDY8(ICPU.OpenBus);
end;

procedure OpACX0;
begin
   var w := GetWord(Absolute(ACC_READ), WRAP_BANK);
   ICPU.OpenBus := Byte(w shr 8);
   LDY16(w);
end;

procedure OpACSlow;
begin
   var addr := AbsoluteSlow(ACC_READ);
   if CheckIndex then
   begin
      ICPU.OpenBus := GetByte(addr);
      LDY8(ICPU.OpenBus);
   end
   else
   begin
      var w := GetWord(addr, WRAP_BANK);
      ICPU.OpenBus := Byte(w shr 8);
      LDY16(w);
   end;
end;

procedure OpADM1;
begin
   ICPU.OpenBus := GetByte(Absolute(ACC_READ));
   LDA8(ICPU.OpenBus);
end;

procedure OpADM0;
begin
   var w := GetWord(Absolute(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(w shr 8);
   LDA16(w);
end;

procedure OpADSlow;
begin
   var addr := AbsoluteSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      LDA8(ICPU.OpenBus);
   end
   else
   begin
      var w := GetWord(addr, WRAP_NONE);
      ICPU.OpenBus := Byte(w shr 8);
      LDA16(w);
   end;
end;

procedure OpAEX1;
begin
   ICPU.OpenBus := GetByte(Absolute(ACC_READ));
   LDX8(ICPU.OpenBus);
end;

procedure OpAEX0;
begin
   var w := GetWord(Absolute(ACC_READ), WRAP_BANK);
   ICPU.OpenBus := Byte(w shr 8);
   LDX16(w);
end;

procedure OpAESlow;
begin
   var addr := AbsoluteSlow(ACC_READ);
   if CheckIndex then
   begin
      ICPU.OpenBus := GetByte(addr);
      LDX8(ICPU.OpenBus);
   end
   else
   begin
      var w := GetWord(addr, WRAP_BANK);
      ICPU.OpenBus := Byte(w shr 8);
      LDX16(w);
   end;
end;

procedure OpAFM1;
begin
   ICPU.OpenBus := GetByte(AbsoluteLong(ACC_READ));
   LDA8(ICPU.OpenBus);
end;

procedure OpAFM0;
begin
   var w := GetWord(AbsoluteLong(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(w shr 8);
   LDA16(w);
end;

procedure OpAFSlow;
begin
   var addr := AbsoluteLongSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      LDA8(ICPU.OpenBus);
   end
   else
   begin
      var w := GetWord(addr, WRAP_NONE);
      ICPU.OpenBus := Byte(w shr 8);
      LDA16(w);
   end;
end;

procedure OpB0E1;
var
   newPC: TPair;
begin
   newPC.w := Relative(ACC_JUMP);
   if ICPU.Carry then
   begin
      CPU.Cycles := CPU.Cycles + Settings.OneCycle;
      if ICPU.Registers.PCw.PB <> newPC.H then
         CPU.Cycles := CPU.Cycles + Settings.OneCycle;
      if (ICPU.Registers.PCw.PC.w and not MEMMAP_MASK) <> (newPC.w and not MEMMAP_MASK) then
         SetPCBase(ICPU.ShiftedPB or newPC.w)
      else
         ICPU.Registers.PCw.PC.w := newPC.w;
      CPUShutdown;
   end;
end;

procedure OpB0E0;
var
   newPC: TPair;
begin
   newPC.w := Relative(ACC_JUMP);
   if ICPU.Carry then
   begin
      CPU.Cycles := CPU.Cycles + Settings.OneCycle;
      if (ICPU.Registers.PCw.PC.w and not MEMMAP_MASK) <> (newPC.w and not MEMMAP_MASK) then
         SetPCBase(ICPU.ShiftedPB or newPC.w)
      else
         ICPU.Registers.PCw.PC.w := newPC.w;
      CPUShutdown;
   end;
end;

procedure OpB0Slow;
var
   newPC: TPair;
begin
   newPC.w := RelativeSlow(ACC_JUMP);
   if ICPU.Carry then
   begin
      CPU.Cycles := CPU.Cycles + Settings.OneCycle;
      if CheckEmulation and (ICPU.Registers.PCw.PB <> newPC.H) then
         CPU.Cycles := CPU.Cycles + Settings.OneCycle;
      if (ICPU.Registers.PCw.PC.w and not MEMMAP_MASK) <> (newPC.w and not MEMMAP_MASK) then
         SetPCBase(ICPU.ShiftedPB or newPC.w)
      else
         ICPU.Registers.PCw.PC.w := newPC.w;
      CPUShutdown;
   end;
end;

procedure OpB1E1;
begin
   ICPU.OpenBus := GetByte(DirectIndirectIndexedE1(ACC_READ));
   LDA8(ICPU.OpenBus);
end;

procedure OpB1E0M1X1;
begin
   ICPU.OpenBus := GetByte(DirectIndirectIndexedE0X1(ACC_READ));
   LDA8(ICPU.OpenBus);
end;

procedure OpB1E0M0X1;
begin
   var w := GetWord(DirectIndirectIndexedE0X1(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(w shr 8);
   LDA16(w);
end;

procedure OpB1E0M1X0;
begin
   ICPU.OpenBus := GetByte(DirectIndirectIndexedE0X0(ACC_READ));
   LDA8(ICPU.OpenBus);
end;

procedure OpB1E0M0X0;
begin
   var w := GetWord(DirectIndirectIndexedE0X0(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(w shr 8);
   LDA16(w);
end;

procedure OpB1Slow;
begin
   var addr := DirectIndirectIndexedSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      LDA8(ICPU.OpenBus);
   end
   else
   begin
      var w := GetWord(addr, WRAP_NONE);
      ICPU.OpenBus := Byte(w shr 8);
      LDA16(w);
   end;
end;

procedure OpB2E1;
begin
   ICPU.OpenBus := GetByte(DirectIndirectE1(ACC_READ));
   LDA8(ICPU.OpenBus);
end;

procedure OpB2E0M1;
begin
   ICPU.OpenBus := GetByte(DirectIndirectE0(ACC_READ));
   LDA8(ICPU.OpenBus);
end;

procedure OpB2E0M0;
begin
   var w := GetWord(DirectIndirectE0(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(w shr 8);
   LDA16(w);
end;

procedure OpB2Slow;
begin
   var addr := DirectIndirectSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      LDA8(ICPU.OpenBus);
   end
   else
   begin
      var w := GetWord(addr, WRAP_NONE);
      ICPU.OpenBus := Byte(w shr 8);
      LDA16(w);
   end;
end;

procedure OpB3M1;
begin
   ICPU.OpenBus := GetByte(StackRelativeIndirectIndexed(ACC_READ));
   LDA8(ICPU.OpenBus);
end;

procedure OpB3M0;
begin
   var w := GetWord(StackRelativeIndirectIndexed(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(w shr 8);
   LDA16(w);
end;

procedure OpB3Slow;
begin
   var addr := StackRelativeIndirectIndexedSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      LDA8(ICPU.OpenBus);
   end
   else
   begin
      var w := GetWord(addr, WRAP_NONE);
      ICPU.OpenBus := Byte(w shr 8);
      LDA16(w);
   end;
end;

procedure OpB4E1;
begin
   ICPU.OpenBus := GetByte(DirectIndexedXE1(ACC_READ));
   LDY8(ICPU.OpenBus);
end;

procedure OpB4E0X1;
begin
   ICPU.OpenBus := GetByte(DirectIndexedXE0(ACC_READ));
   LDY8(ICPU.OpenBus);
end;

procedure OpB4E0X0;
begin
   var w := GetWord(DirectIndexedXE0(ACC_READ), WRAP_BANK);
   ICPU.OpenBus := Byte(w shr 8);
   LDY16(w);
end;

procedure OpB4Slow;
begin
   var addr := DirectIndexedXSlow(ACC_READ);
   if CheckIndex then
   begin
      ICPU.OpenBus := GetByte(addr);
      LDY8(ICPU.OpenBus);
   end
   else
   begin
      var w := GetWord(addr, WRAP_BANK);
      ICPU.OpenBus := Byte(w shr 8);
      LDY16(w);
   end;
end;

procedure OpB5E1;
begin
   ICPU.OpenBus := GetByte(DirectIndexedXE1(ACC_READ));
   LDA8(ICPU.OpenBus);
end;

procedure OpB5E0M1;
begin
   ICPU.OpenBus := GetByte(DirectIndexedXE0(ACC_READ));
   LDA8(ICPU.OpenBus);
end;

procedure OpB5E0M0;
begin
   var w := GetWord(DirectIndexedXE0(ACC_READ), WRAP_BANK);
   ICPU.OpenBus := Byte(w shr 8);
   LDA16(w);
end;

procedure OpB5Slow;
begin
   var addr := DirectIndexedXSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      LDA8(ICPU.OpenBus);
   end
   else
   begin
      var w := GetWord(addr, WRAP_BANK);
      ICPU.OpenBus := Byte(w shr 8);
      LDA16(w);
   end;
end;

procedure OpB6E1;
begin
   ICPU.OpenBus := GetByte(DirectIndexedYE1(ACC_READ));
   LDX8(ICPU.OpenBus);
end;

procedure OpB6E0X1;
begin
   ICPU.OpenBus := GetByte(DirectIndexedYE0(ACC_READ));
   LDX8(ICPU.OpenBus);
end;

procedure OpB6E0X0;
begin
   var w := GetWord(DirectIndexedYE0(ACC_READ), WRAP_BANK);
   ICPU.OpenBus := Byte(w shr 8);
   LDX16(w);
end;

procedure OpB6Slow;
begin
   var addr := DirectIndexedYSlow(ACC_READ);
   if CheckIndex then
   begin
      ICPU.OpenBus := GetByte(addr);
      LDX8(ICPU.OpenBus);
   end
   else
   begin
      var w := GetWord(addr, WRAP_BANK);
      ICPU.OpenBus := Byte(w shr 8);
      LDX16(w);
   end;
end;

procedure OpB7M1;
begin
   ICPU.OpenBus := GetByte(DirectIndirectIndexedLong(ACC_READ));
   LDA8(ICPU.OpenBus);
end;

procedure OpB7M0;
begin
   var w := GetWord(DirectIndirectIndexedLong(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(w shr 8);
   LDA16(w);
end;

procedure OpB7Slow;
begin
   var addr := DirectIndirectIndexedLongSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      LDA8(ICPU.OpenBus);
   end
   else
   begin
      var w := GetWord(addr, WRAP_NONE);
      ICPU.OpenBus := Byte(w shr 8);
      LDA16(w);
   end;
end;

procedure OpB8; // CLV
begin
   ICPU.Overflow := False;
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
end;

procedure OpB9M1X1;
begin
   ICPU.OpenBus := GetByte(AbsoluteIndexedYX1(ACC_READ));
   LDA8(ICPU.OpenBus);
end;

procedure OpB9M0X1;
begin
   var w := GetWord(AbsoluteIndexedYX1(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(w shr 8);
   LDA16(w);
end;

procedure OpB9M1X0;
begin
   ICPU.OpenBus := GetByte(AbsoluteIndexedYX0(ACC_READ));
   LDA8(ICPU.OpenBus);
end;

procedure OpB9M0X0;
begin
   var w := GetWord(AbsoluteIndexedYX0(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(w shr 8);
   LDA16(w);
end;

procedure OpB9Slow;
begin
   var addr := AbsoluteIndexedYSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      LDA8(ICPU.OpenBus);
   end
   else
   begin
      var w := GetWord(addr, WRAP_NONE);
      ICPU.OpenBus := Byte(w shr 8);
      LDA16(w);
   end;
end;

procedure OpBAX1;
begin
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   ICPU.Registers.X.L := ICPU.Registers.S.L;
   SetZN8(ICPU.Registers.X.L);
end;

procedure OpBAX0;
begin
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   ICPU.Registers.X.w := ICPU.Registers.S.w;
   SetZN16(ICPU.Registers.X.w);
end;

procedure OpBASlow;
begin
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   if CheckIndex then
   begin
      ICPU.Registers.X.L := ICPU.Registers.S.L;
      SetZN8(ICPU.Registers.X.L);
   end
   else
   begin
      ICPU.Registers.X.w := ICPU.Registers.S.w;
      SetZN16(ICPU.Registers.X.w);
   end;
end;

procedure OpBBX1;
begin
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   ICPU.Registers.X.L := ICPU.Registers.Y.L;
   SetZN8(ICPU.Registers.X.L);
end;

procedure OpBBX0;
begin
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   ICPU.Registers.X.w := ICPU.Registers.Y.w;
   SetZN16(ICPU.Registers.X.w);
end;

procedure OpBBSlow;
begin
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   if CheckIndex then
   begin
      ICPU.Registers.X.L := ICPU.Registers.Y.L;
      SetZN8(ICPU.Registers.X.L);
   end
   else
   begin
      ICPU.Registers.X.w := ICPU.Registers.Y.w;
      SetZN16(ICPU.Registers.X.w);
   end;
end;

procedure OpBCX1;
begin
   ICPU.OpenBus := GetByte(AbsoluteIndexedXX1(ACC_READ));
   LDY8(ICPU.OpenBus);
end;

procedure OpBCX0;
begin
   var w := GetWord(AbsoluteIndexedXX0(ACC_READ), WRAP_BANK);
   ICPU.OpenBus := Byte(w shr 8);
   LDY16(w);
end;

procedure OpBCSlow;
begin
   var addr := AbsoluteIndexedXSlow(ACC_READ);
   if CheckIndex then
   begin
      ICPU.OpenBus := GetByte(addr);
      LDY8(ICPU.OpenBus);
   end
   else
   begin
      var w := GetWord(addr, WRAP_BANK);
      ICPU.OpenBus := Byte(w shr 8);
      LDY16(w);
   end;
end;

procedure OpBDM1X1;
begin
   ICPU.OpenBus := GetByte(AbsoluteIndexedXX1(ACC_READ));
   LDA8(ICPU.OpenBus);
end;

procedure OpBDM0X1;
begin
   var w := GetWord(AbsoluteIndexedXX1(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(w shr 8);
   LDA16(w);
end;

procedure OpBDM1X0;
begin
   ICPU.OpenBus := GetByte(AbsoluteIndexedXX0(ACC_READ));
   LDA8(ICPU.OpenBus);
end;

procedure OpBDM0X0;
begin
   var w := GetWord(AbsoluteIndexedXX0(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(w shr 8);
   LDA16(w);
end;

procedure OpBDSlow;
begin
   var addr := AbsoluteIndexedXSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      LDA8(ICPU.OpenBus);
   end
   else
   begin
      var w := GetWord(addr, WRAP_NONE);
      ICPU.OpenBus := Byte(w shr 8);
      LDA16(w);
   end;
end;

procedure OpBEX1;
begin
   ICPU.OpenBus := GetByte(AbsoluteIndexedYX1(ACC_READ));
   LDX8(ICPU.OpenBus);
end;

procedure OpBEX0;
begin
   var w := GetWord(AbsoluteIndexedYX0(ACC_READ), WRAP_BANK);
   ICPU.OpenBus := Byte(w shr 8);
   LDX16(w);
end;

procedure OpBESlow;
begin
   var addr := AbsoluteIndexedYSlow(ACC_READ);
   if CheckIndex then
   begin
      ICPU.OpenBus := GetByte(addr);
      LDX8(ICPU.OpenBus);
   end
   else
   begin
      var w := GetWord(addr, WRAP_BANK);
      ICPU.OpenBus := Byte(w shr 8);
      LDX16(w);
   end;
end;

procedure OpBFM1;
begin
   ICPU.OpenBus := GetByte(AbsoluteLongIndexedX(ACC_READ));
   LDA8(ICPU.OpenBus);
end;

procedure OpBFM0;
begin
   var w := GetWord(AbsoluteLongIndexedX(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(w shr 8);
   LDA16(w);
end;

procedure OpBFSlow;
begin
   var addr := AbsoluteLongIndexedXSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      LDA8(ICPU.OpenBus);
   end
   else
   begin
      var w := GetWord(addr, WRAP_NONE);
      ICPU.OpenBus := Byte(w shr 8);
      LDA16(w);
   end;
end;

procedure OpC0X1;
begin
   CPY8(Immediate8(ACC_READ));
end;

procedure OpC0X0;
begin
   CPY16(Immediate16(ACC_READ));
end;

procedure OpC0Slow;
begin
   if CheckIndex then
      CPY8(Immediate8Slow(ACC_READ))
   else
      CPY16(Immediate16Slow(ACC_READ));
end;

procedure OpC1E1;
begin
   ICPU.OpenBus := GetByte(DirectIndexedIndirectE1(ACC_READ));
   CMP8(ICPU.OpenBus);
end;

procedure OpC1E0M1;
begin
   ICPU.OpenBus := GetByte(DirectIndexedIndirectE0(ACC_READ));
   CMP8(ICPU.OpenBus);
end;

procedure OpC1E0M0;
begin
   var w := GetWord(DirectIndexedIndirectE0(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(w shr 8);
   CMP16(w);
end;

procedure OpC1Slow;
begin
   var addr := DirectIndexedIndirectSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      CMP8(ICPU.OpenBus);
   end
   else
   begin
      var w := GetWord(addr, WRAP_NONE);
      ICPU.OpenBus := Byte(w shr 8);
      CMP16(w);
   end;
end;

procedure OpC2; // REP
var
   Work8: Byte;
begin
   Work8 := not Immediate8(ACC_READ);
   ICPU.Registers.P.L := ICPU.Registers.P.L and Work8;
   ICPU.Carry := ICPU.Carry and (Work8 <> 0);
   ICPU.Overflow := ICPU.Overflow and ((Work8 shr 6) <> 0);
   ICPU.Negative := ICPU.Negative and Work8;
   if (not Work8 and FLAG_ZERO) <> 0 then
      ICPU.Zero := True;

   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   if CheckEmulation then
      SetFlags(FLAG_MEMORY or FLAG_INDEX);
   if CheckIndex then
   begin
      ICPU.Registers.X.H := 0;
      ICPU.Registers.Y.H := 0;
   end;
   FixCycles;
   CheckForIRQ;
end;

procedure OpC2Slow; // REP
var
   Work8: Byte;
begin
   Work8 := not Immediate8Slow(ACC_READ);
   ICPU.Registers.P.L := ICPU.Registers.P.L and Work8;
   ICPU.Carry := ICPU.Carry and (Work8 <> 0);
   ICPU.Overflow := ICPU.Overflow and ((Work8 shr 6) <> 0);
   ICPU.Negative := ICPU.Negative and Work8;
   if (not Work8 and FLAG_ZERO) <> 0 then
      ICPU.Zero := True;

   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   if CheckEmulation then
      SetFlags(FLAG_MEMORY or FLAG_INDEX);
   if CheckIndex then
   begin
      ICPU.Registers.X.H := 0;
      ICPU.Registers.Y.H := 0;
   end;
   FixCycles;
   CheckForIRQ;
end;

procedure OpC3M1;
begin
   ICPU.OpenBus := GetByte(StackRelative(ACC_READ));
   CMP8(ICPU.OpenBus);
end;

procedure OpC3M0;
begin
   var w := GetWord(StackRelative(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(w shr 8);
   CMP16(w);
end;

procedure OpC3Slow;
begin
   var addr := StackRelativeSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      CMP8(ICPU.OpenBus);
   end
   else
   begin
      var w := GetWord(addr, WRAP_NONE);
      ICPU.OpenBus := Byte(w shr 8);
      CMP16(w);
   end;
end;

procedure OpC4X1;
begin
   ICPU.OpenBus := GetByte(Direct(ACC_READ));
   CPY8(ICPU.OpenBus);
end;

procedure OpC4X0;
begin
   var w := GetWord(Direct(ACC_READ), WRAP_BANK);
   ICPU.OpenBus := Byte(w shr 8);
   CPY16(w);
end;

procedure OpC4Slow;
begin
   var addr := DirectSlow(ACC_READ);
   if CheckIndex then
   begin
      ICPU.OpenBus := GetByte(addr);
      CPY8(ICPU.OpenBus);
   end
   else
   begin
      var w := GetWord(addr, WRAP_BANK);
      ICPU.OpenBus := Byte(w shr 8);
      CPY16(w);
   end;
end;

procedure OpC5M1;
begin
   ICPU.OpenBus := GetByte(Direct(ACC_READ));
   CMP8(ICPU.OpenBus);
end;

procedure OpC5M0;
begin
   var w := GetWord(Direct(ACC_READ), WRAP_BANK);
   ICPU.OpenBus := Byte(w shr 8);
   CMP16(w);
end;

procedure OpC5Slow;
begin
   var addr := DirectSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      CMP8(ICPU.OpenBus);
   end
   else
   begin
      var w := GetWord(addr, WRAP_BANK);
      ICPU.OpenBus := Byte(w shr 8);
      CMP16(w);
   end;
end;

procedure OpC6M1;
begin
   DEC8(Direct(ACC_MODIFY));
end;

procedure OpC6M0;
begin
   DEC16(Direct(ACC_MODIFY), WRAP_BANK);
end;

procedure OpC6Slow;
begin
   if CheckMem then
      DEC8(DirectSlow(ACC_MODIFY))
   else
      DEC16(DirectSlow(ACC_MODIFY), WRAP_BANK);
end;

procedure OpC7M1;
begin
   ICPU.OpenBus := GetByte(DirectIndirectLong(ACC_READ));
   CMP8(ICPU.OpenBus);
end;

procedure OpC7M0;
begin
   var w := GetWord(DirectIndirectLong(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(w shr 8);
   CMP16(w);
end;

procedure OpC7Slow;
begin
   var addr := DirectIndirectLongSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      CMP8(ICPU.OpenBus);
   end
   else
   begin
      var w := GetWord(addr, WRAP_NONE);
      ICPU.OpenBus := Byte(w shr 8);
      CMP16(w);
   end;
end;

procedure OpC8X1;
begin
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   CPU.WaitPC := 0;
   Inc(ICPU.Registers.Y.L);
   SetZN8(ICPU.Registers.Y.L);
end;

procedure OpC8X0;
begin
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   CPU.WaitPC := 0;
   Inc(ICPU.Registers.Y.w);
   SetZN16(ICPU.Registers.Y.w);
end;

procedure OpC8Slow;
begin
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   CPU.WaitPC := 0;
   if CheckIndex then
   begin
      Inc(ICPU.Registers.Y.L);
      SetZN8(ICPU.Registers.Y.L);
   end
   else
   begin
      Inc(ICPU.Registers.Y.w);
      SetZN16(ICPU.Registers.Y.w);
   end;
end;

procedure OpC9M1;
begin
   var Int16: SmallInt := SmallInt(ICPU.Registers.A.L) - SmallInt(Immediate8(ACC_READ));
   ICPU.Carry := Int16 >= 0;
   SetZN8(Byte(Int16));
end;

procedure OpC9M0;
begin
   var Int32: Integer := SmallInt(ICPU.Registers.A.w) - SmallInt(Immediate16(ACC_READ));
   ICPU.Carry := Int32 >= 0;
   SetZN16(Word(Int32));
end;

procedure OpC9Slow;
begin
   if CheckMem then
   begin
      var Int16: SmallInt := SmallInt(ICPU.Registers.A.L) - SmallInt(Immediate8Slow(ACC_READ));
      ICPU.Carry := Int16 >= 0;
      SetZN8(Byte(Int16));
   end
   else
   begin
      var Int32: Integer := SmallInt(ICPU.Registers.A.w) - SmallInt(Immediate16Slow(ACC_READ));
      ICPU.Carry := Int32 >= 0;
      SetZN16(Word(Int32));
   end;
end;

procedure OpCAX1;
begin
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   CPU.WaitPC := 0;
   Dec(ICPU.Registers.X.L);
   SetZN8(ICPU.Registers.X.L);
end;

procedure OpCAX0;
begin
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   CPU.WaitPC := 0;
   Dec(ICPU.Registers.X.w);
   SetZN16(ICPU.Registers.X.w);
end;

procedure OpCASlow;
begin
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   CPU.WaitPC := 0;
   if CheckIndex then
   begin
      Dec(ICPU.Registers.X.L);
      SetZN8(ICPU.Registers.X.L);
   end
   else
   begin
      Dec(ICPU.Registers.X.w);
      SetZN16(ICPU.Registers.X.w);
   end;
end;

procedure OpCB; // WAI
begin
   CPU.WaitingForInterrupt := True;
   Dec(ICPU.Registers.PCw.PC.w);
   if Settings.Shutdown then
      CPU.Cycles := CPU.NextEvent
   else
      CPU.Cycles := CPU.Cycles + Settings.OneCycle;
end;

procedure OpCCX1;
begin
   ICPU.OpenBus := GetByte(Absolute(ACC_READ));
   CPY8(ICPU.OpenBus);
end;

procedure OpCCX0;
begin
   var w := GetWord(Absolute(ACC_READ), WRAP_BANK);
   ICPU.OpenBus := Byte(w shr 8);
   CPY16(w);
end;

procedure OpCCSlow;
begin
   var addr := AbsoluteSlow(ACC_READ);
   if CheckIndex then
   begin
      ICPU.OpenBus := GetByte(addr);
      CPY8(ICPU.OpenBus);
   end
   else
   begin
      var w := GetWord(addr, WRAP_BANK);
      ICPU.OpenBus := Byte(w shr 8);
      CPY16(w);
   end;
end;

procedure OpCDM1;
begin
   ICPU.OpenBus := GetByte(Absolute(ACC_READ));
   CMP8(ICPU.OpenBus);
end;

procedure OpCDM0;
begin
   var w := GetWord(Absolute(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(w shr 8);
   CMP16(w);
end;

procedure OpCDSlow;
begin
   var addr := AbsoluteSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      CMP8(ICPU.OpenBus);
   end
   else
   begin
      var w := GetWord(addr, WRAP_NONE);
      ICPU.OpenBus := Byte(w shr 8);
      CMP16(w);
   end;
end;

procedure OpCEM1;
begin
   DEC8(Absolute(ACC_MODIFY));
end;

procedure OpCEM0;
begin
   DEC16(Absolute(ACC_MODIFY), WRAP_NONE);
end;

procedure OpCESlow;
begin
   if CheckMem then
      DEC8(AbsoluteSlow(ACC_MODIFY))
   else
      DEC16(AbsoluteSlow(ACC_MODIFY), WRAP_NONE);
end;

procedure OpCFM1;
begin
   ICPU.OpenBus := GetByte(AbsoluteLong(ACC_READ));
   CMP8(ICPU.OpenBus);
end;

procedure OpCFM0;
begin
   var w := GetWord(AbsoluteLong(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(w shr 8);
   CMP16(w);
end;

procedure OpCFSlow;
begin
   var addr := AbsoluteLongSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      CMP8(ICPU.OpenBus);
   end
   else
   begin
      var w := GetWord(addr, WRAP_NONE);
      ICPU.OpenBus := Byte(w shr 8);
      CMP16(w);
   end;
end;

procedure OpD0E1;
var
   newPC: TPair;
begin
   newPC.w := Relative(ACC_JUMP);
   if not CheckZero then
   begin
      CPU.Cycles := CPU.Cycles + Settings.OneCycle;
      if ICPU.Registers.PCw.PB <> newPC.H then
         CPU.Cycles := CPU.Cycles + Settings.OneCycle;
      if (ICPU.Registers.PCw.PC.w and not MEMMAP_MASK) <> (newPC.w and not MEMMAP_MASK) then
         SetPCBase(ICPU.ShiftedPB or newPC.w)
      else
         ICPU.Registers.PCw.PC.w := newPC.w;
      CPUShutdown;
   end;
end;

procedure OpD0E0;
var
   newPC: TPair;
begin
   newPC.w := Relative(ACC_JUMP);
   if not CheckZero then
   begin
      CPU.Cycles := CPU.Cycles + Settings.OneCycle;
      if (ICPU.Registers.PCw.PC.w and not MEMMAP_MASK) <> (newPC.w and not MEMMAP_MASK) then
         SetPCBase(ICPU.ShiftedPB or newPC.w)
      else
         ICPU.Registers.PCw.PC.w := newPC.w;
      CPUShutdown;
   end;
end;

procedure OpD0Slow;
var
   newPC: TPair;
begin
   newPC.w := RelativeSlow(ACC_JUMP);
   if not CheckZero then
   begin
      CPU.Cycles := CPU.Cycles + Settings.OneCycle;
      if CheckEmulation and (ICPU.Registers.PCw.PB <> newPC.H) then
         CPU.Cycles := CPU.Cycles + Settings.OneCycle;
      if (ICPU.Registers.PCw.PC.w and not MEMMAP_MASK) <> (newPC.w and not MEMMAP_MASK) then
         SetPCBase(ICPU.ShiftedPB or newPC.w)
      else
         ICPU.Registers.PCw.PC.w := newPC.w;
      CPUShutdown;
   end;
end;

procedure OpD1E1;
begin
   ICPU.OpenBus := GetByte(DirectIndirectIndexedE1(ACC_READ));
   CMP8(ICPU.OpenBus);
end;

procedure OpD1E0M1X1;
begin
   ICPU.OpenBus := GetByte(DirectIndirectIndexedE0X1(ACC_READ));
   CMP8(ICPU.OpenBus);
end;

procedure OpD1E0M0X1;
begin
   var w := GetWord(DirectIndirectIndexedE0X1(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(w shr 8);
   CMP16(w);
end;

procedure OpD1E0M1X0;
begin
   ICPU.OpenBus := GetByte(DirectIndirectIndexedE0X0(ACC_READ));
   CMP8(ICPU.OpenBus);
end;

procedure OpD1E0M0X0;
begin
   var w := GetWord(DirectIndirectIndexedE0X0(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(w shr 8);
   CMP16(w);
end;

procedure OpD1Slow;
begin
   var addr := DirectIndirectIndexedSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      CMP8(ICPU.OpenBus);
   end
   else
   begin
      var w := GetWord(addr, WRAP_NONE);
      ICPU.OpenBus := Byte(w shr 8);
      CMP16(w);
   end;
end;

procedure OpD2E1;
begin
   ICPU.OpenBus := GetByte(DirectIndirectE1(ACC_READ));
   CMP8(ICPU.OpenBus);
end;

procedure OpD2E0M1;
begin
   ICPU.OpenBus := GetByte(DirectIndirectE0(ACC_READ));
   CMP8(ICPU.OpenBus);
end;

procedure OpD2E0M0;
begin
   var w := GetWord(DirectIndirectE0(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(w shr 8);
   CMP16(w);
end;

procedure OpD2Slow;
begin
   var addr := DirectIndirectSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      CMP8(ICPU.OpenBus);
   end
   else
   begin
      var w := GetWord(addr, WRAP_NONE);
      ICPU.OpenBus := Byte(w shr 8);
      CMP16(w);
   end;
end;

procedure OpD3M1;
begin
   ICPU.OpenBus := GetByte(StackRelativeIndirectIndexed(ACC_READ));
   CMP8(ICPU.OpenBus);
end;

procedure OpD3M0;
begin
   var w := GetWord(StackRelativeIndirectIndexed(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(w shr 8);
   CMP16(w);
end;

procedure OpD3Slow;
begin
   var addr := StackRelativeIndirectIndexedSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      CMP8(ICPU.OpenBus);
   end
   else
   begin
      var w := GetWord(addr, WRAP_NONE);
      ICPU.OpenBus := Byte(w shr 8);
      CMP16(w);
   end;
end;

procedure OpD4E1;
begin
   PushWE(ICPU.Registers.PCw.PC.w + 1);
   SetPCBase(ICPU.ShiftedPB or DirectIndirectE1(ACC_JUMP));
end;

procedure OpD4E0;
begin
   PushW(ICPU.Registers.PCw.PC.w + 1);
   SetPCBase(ICPU.ShiftedPB or DirectIndirectE0(ACC_JUMP));
end;

procedure OpD4Slow;
begin
   if CheckEmulation then
      PushWE(ICPU.Registers.PCw.PC.w + 1)
   else
      PushW(ICPU.Registers.PCw.PC.w + 1);
   SetPCBase(ICPU.ShiftedPB or DirectIndirectSlow(ACC_JUMP));
end;

procedure OpD5E1;
begin
   ICPU.OpenBus := GetByte(DirectIndexedXE1(ACC_READ));
   CMP8(ICPU.OpenBus);
end;

procedure OpD5E0M1;
begin
   ICPU.OpenBus := GetByte(DirectIndexedXE0(ACC_READ));
   CMP8(ICPU.OpenBus);
end;

procedure OpD5E0M0;
begin
   var w := GetWord(DirectIndexedXE0(ACC_READ), WRAP_BANK);
   ICPU.OpenBus := Byte(w shr 8);
   CMP16(w);
end;

procedure OpD5Slow;
begin
   var addr := DirectIndexedXSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      CMP8(ICPU.OpenBus);
   end
   else
   begin
      var w := GetWord(addr, WRAP_BANK);
      ICPU.OpenBus := Byte(w shr 8);
      CMP16(w);
   end;
end;

procedure OpD6E1;
begin
   DEC8(DirectIndexedXE1(ACC_MODIFY));
end;

procedure OpD6E0M1;
begin
   DEC8(DirectIndexedXE0(ACC_MODIFY));
end;

procedure OpD6E0M0;
begin
   DEC16(DirectIndexedXE0(ACC_MODIFY), WRAP_BANK);
end;

procedure OpD6Slow;
begin
   if CheckMem then
      DEC8(DirectIndexedXSlow(ACC_MODIFY))
   else
      DEC16(DirectIndexedXSlow(ACC_MODIFY), WRAP_BANK);
end;

procedure OpD7M1;
begin
   ICPU.OpenBus := GetByte(DirectIndirectIndexedLong(ACC_READ));
   CMP8(ICPU.OpenBus);
end;

procedure OpD7M0;
begin
   var w := GetWord(DirectIndirectIndexedLong(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(w shr 8);
   CMP16(w);
end;

procedure OpD7Slow;
begin
   var addr := DirectIndirectIndexedLongSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      CMP8(ICPU.OpenBus);
   end
   else
   begin
      var w := GetWord(addr, WRAP_NONE);
      ICPU.OpenBus := Byte(w shr 8);
      CMP16(w);
   end;
end;

procedure OpD8; // CLD
begin
   ClearFlags(FLAG_DECIMAL);
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
end;

procedure OpD9M1X1;
begin
   ICPU.OpenBus := GetByte(AbsoluteIndexedYX1(ACC_READ));
   CMP8(ICPU.OpenBus);
end;

procedure OpD9M0X1;
begin
   var w := GetWord(AbsoluteIndexedYX1(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(w shr 8);
   CMP16(w);
end;

procedure OpD9M1X0;
begin
   ICPU.OpenBus := GetByte(AbsoluteIndexedYX0(ACC_READ));
   CMP8(ICPU.OpenBus);
end;

procedure OpD9M0X0;
begin
   var w := GetWord(AbsoluteIndexedYX0(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(w shr 8);
   CMP16(w);
end;

procedure OpD9Slow;
begin
   var addr := AbsoluteIndexedYSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      CMP8(ICPU.OpenBus);
   end
   else
   begin
      var w := GetWord(addr, WRAP_NONE);
      ICPU.OpenBus := Byte(w shr 8);
      CMP16(w);
   end;
end;

procedure OpDAE1;
begin
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   PushBE(ICPU.Registers.X.L);
   ICPU.OpenBus := ICPU.Registers.X.L;
end;

procedure OpDAE0X1;
begin
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   PushB(ICPU.Registers.X.L);
   ICPU.OpenBus := ICPU.Registers.X.L;
end;

procedure OpDAE0X0;
begin
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   PushW(ICPU.Registers.X.w);
   ICPU.OpenBus := ICPU.Registers.X.L;
end;

procedure OpDASlow;
begin
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   if CheckEmulation then
      PushBE(ICPU.Registers.X.L)
   else
      if CheckIndex then
         PushB(ICPU.Registers.X.L)
      else
         PushW(ICPU.Registers.X.w);
   ICPU.OpenBus := ICPU.Registers.X.L;
end;

procedure OpDB; // STP Usually an STP opcode; SNESAdvance speed hack, not implemented in Snes9xTYL | Snes9x-Euphoria (from the speed-hacks branch of CatSFC)
var
   BranchOffset: Int8;
   OpAddress: UInt32;
begin
//	var NextByte := CPU.PCBase[ICPU.Registers.PCw++];

//	ForceShutdown();
//	BranchOffset = (NextByte & 0x7F) | ((NextByte & 0x40) << 1);
//	OpAddress = ((int32_t) ICPU.Registers.PCw + BranchOffset) & 0xffff;
//
//	switch (NextByte & 0x80)
//	{
//		case 0x00: /* BNE */
//			bOpBody(OpAddress, BranchCheck, !CheckZero(), CheckEmulation())
//			return;
//		case 0x80: /* BEQ */
//			bOpBody(OpAddress, BranchCheck,  CheckZero(), CheckEmulation())
//			return;
//	}
end;

procedure OpDC;
begin
   SetPCBase(AbsoluteIndirectLong(ACC_JUMP));
end;

procedure OpDCSlow;
begin
   SetPCBase(AbsoluteIndirectLongSlow(ACC_JUMP));
end;

procedure OpDDM1X1;
begin
   ICPU.OpenBus := GetByte(AbsoluteIndexedXX1(ACC_READ));
   CMP8(ICPU.OpenBus);
end;

procedure OpDDM0X1;
begin
   var w := GetWord(AbsoluteIndexedXX1(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(w shr 8);
   CMP16(w);
end;

procedure OpDDM1X0;
begin
   ICPU.OpenBus := GetByte(AbsoluteIndexedXX0(ACC_READ));
   CMP8(ICPU.OpenBus);
end;

procedure OpDDM0X0;
begin
   var w := GetWord(AbsoluteIndexedXX0(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(w shr 8);
   CMP16(w);
end;

procedure OpDDSlow;
begin
   var addr := AbsoluteIndexedXSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      CMP8(ICPU.OpenBus);
   end
   else
   begin
      var w := GetWord(addr, WRAP_NONE);
      ICPU.OpenBus := Byte(w shr 8);
      CMP16(w);
   end;
end;

procedure OpDEM1X1;
begin
   DEC8(AbsoluteIndexedXX1(ACC_MODIFY));
end;

procedure OpDEM0X1;
begin
   DEC16(AbsoluteIndexedXX1(ACC_MODIFY), WRAP_NONE);
end;

procedure OpDEM1X0;
begin
   DEC8(AbsoluteIndexedXX0(ACC_MODIFY));
end;

procedure OpDEM0X0;
begin
   DEC16(AbsoluteIndexedXX0(ACC_MODIFY), WRAP_NONE);
end;

procedure OpDESlow;
begin
   if CheckMem then
      DEC8(AbsoluteIndexedXSlow(ACC_MODIFY))
   else
      DEC16(AbsoluteIndexedXSlow(ACC_MODIFY), WRAP_NONE);
end;

procedure OpDFM1;
begin
   ICPU.OpenBus := GetByte(AbsoluteLongIndexedX(ACC_READ));
   CMP8(ICPU.OpenBus);
end;

procedure OpDFM0;
begin
   var w := GetWord(AbsoluteLongIndexedX(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(w shr 8);
   CMP16(w);
end;

procedure OpDFSlow;
begin
   var addr := AbsoluteLongIndexedXSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      CMP8(ICPU.OpenBus);
   end
   else
   begin
      var w := GetWord(addr, WRAP_NONE);
      ICPU.OpenBus := Byte(w shr 8);
      CMP16(w);
   end;
end;

procedure OpE0X1;
begin
   CPX8(Immediate8(ACC_READ));
end;

procedure OpE0X0;
begin
   CPX16(Immediate16(ACC_READ));
end;

procedure OpE0Slow;
begin
   if CheckIndex then
      CPX8(Immediate8Slow(ACC_READ))
   else
      CPX16(Immediate16Slow(ACC_READ));
end;

procedure OpE1E1;
begin
   ICPU.OpenBus := GetByte(DirectIndexedIndirectE1(ACC_READ));
   SBC8(ICPU.OpenBus);
end;

procedure OpE1E0M1;
begin
   ICPU.OpenBus := GetByte(DirectIndexedIndirectE0(ACC_READ));
   SBC8(ICPU.OpenBus);
end;

procedure OpE1E0M0;
begin
   var w := GetWord(DirectIndexedIndirectE0(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(w shr 8);
   SBC16(w);
end;

procedure OpE1Slow;
begin
   var addr := DirectIndexedIndirectSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      SBC8(ICPU.OpenBus);
   end
   else
   begin
      var w := GetWord(addr, WRAP_NONE);
      ICPU.OpenBus := Byte(w shr 8);
      SBC16(w);
   end;
end;

procedure OpE2; // SEP
var
   Work8: Byte;
begin
   Work8 := Immediate8(ACC_READ);
   ICPU.Registers.P.L := ICPU.Registers.P.L or Work8;
   ICPU.Carry := ICPU.Carry or ((Work8 and 1) <> 0);
   ICPU.Overflow := ICPU.Overflow or (((Work8 shr 6) and 1) <> 0);
   ICPU.Negative := ICPU.Negative or Work8;
   if (Work8 and FLAG_ZERO) <> 0 then
      ICPU.Zero := False;
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   if CheckEmulation then
      SetFlags(FLAG_MEMORY or FLAG_INDEX);
   if CheckIndex then
   begin
      ICPU.Registers.X.H := 0;
      ICPU.Registers.Y.H := 0;
   end;
   FixCycles;
end;

procedure OpE2Slow; // SEP
var
   Work8: Byte;
begin
   Work8 := Immediate8Slow(ACC_READ);
   ICPU.Registers.P.L := ICPU.Registers.P.L or Work8;
   ICPU.Carry := ICPU.Carry or ((Work8 and 1) <> 0);
   ICPU.Overflow := ICPU.Overflow or (((Work8 shr 6) and 1) <> 0);
   ICPU.Negative := ICPU.Negative or Work8;
   if (Work8 and FLAG_ZERO) <> 0 then
      ICPU.Zero := False;
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   if CheckEmulation then
      SetFlags(FLAG_MEMORY or FLAG_INDEX);
   if CheckIndex then
   begin
      ICPU.Registers.X.H := 0;
      ICPU.Registers.Y.H := 0;
   end;
   FixCycles;
end;

procedure OpE3M1;
begin
   ICPU.OpenBus := GetByte(StackRelative(ACC_READ));
   SBC8(ICPU.OpenBus);
end;

procedure OpE3M0;
begin
   var w := GetWord(StackRelative(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(w shr 8);
   SBC16(w);
end;

procedure OpE3Slow;
begin
   var addr := StackRelativeSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      SBC8(ICPU.OpenBus);
   end
   else
   begin
      var w := GetWord(addr, WRAP_NONE);
      ICPU.OpenBus := Byte(w shr 8);
      SBC16(w);
   end;
end;

procedure OpE4X1;
begin
   ICPU.OpenBus := GetByte(Direct(ACC_READ));
   CPX8(ICPU.OpenBus);
end;

procedure OpE4X0;
begin
   var w := GetWord(Direct(ACC_READ), WRAP_BANK);
   ICPU.OpenBus := Byte(w shr 8);
   CPX16(w);
end;

procedure OpE4Slow;
begin
   var addr := DirectSlow(ACC_READ);
   if CheckIndex then
   begin
      ICPU.OpenBus := GetByte(addr);
      CPX8(ICPU.OpenBus);
   end
   else
   begin
      var w := GetWord(addr, WRAP_BANK);
      ICPU.OpenBus := Byte(w shr 8);
      CPX16(w);
   end;
end;

procedure OpE5M1;
begin
   ICPU.OpenBus := GetByte(Direct(ACC_READ));
   SBC8(ICPU.OpenBus);
end;

procedure OpE5M0;
begin
   var w := GetWord(Direct(ACC_READ), WRAP_BANK);
   ICPU.OpenBus := Byte(w shr 8);
   SBC16(w);
end;

procedure OpE5Slow;
begin
   var addr := DirectSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      SBC8(ICPU.OpenBus);
   end
   else
   begin
      var w := GetWord(addr, WRAP_BANK);
      ICPU.OpenBus := Byte(w shr 8);
      SBC16(w);
   end;
end;

procedure OpE6M1;
begin
   INC8(Direct(ACC_MODIFY));
end;

procedure OpE6M0;
begin
   INC16(Direct(ACC_MODIFY), WRAP_BANK);
end;

procedure OpE6Slow;
begin
   if CheckMem then
      INC8(DirectSlow(ACC_MODIFY))
   else
      INC16(DirectSlow(ACC_MODIFY), WRAP_BANK);
end;

procedure OpE7M1;
begin
   ICPU.OpenBus := GetByte(DirectIndirectLong(ACC_READ));
   SBC8(ICPU.OpenBus);
end;

procedure OpE7M0;
begin
   var w := GetWord(DirectIndirectLong(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(w shr 8);
   SBC16(w);
end;

procedure OpE7Slow;
begin
   var addr := DirectIndirectLongSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      SBC8(ICPU.OpenBus);
   end
   else
   begin
      var w := GetWord(addr, WRAP_NONE);
      ICPU.OpenBus := Byte(w shr 8);
      SBC16(w);
   end;
end;

procedure OpE8X1;
begin
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   CPU.WaitPC := 0;
   Inc(ICPU.Registers.X.L);
   SetZN8(ICPU.Registers.X.L);
end;

procedure OpE8X0;
begin
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   CPU.WaitPC := 0;
   Inc(ICPU.Registers.X.w);
   SetZN16(ICPU.Registers.X.w);
end;

procedure OpE8Slow;
begin
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   CPU.WaitPC := 0;
   if CheckIndex then
   begin
      Inc(ICPU.Registers.X.L);
      SetZN8(ICPU.Registers.X.L);
   end
   else
   begin
      Inc(ICPU.Registers.X.w);
      SetZN16(ICPU.Registers.X.w);
   end;
end;

procedure OpE9M1;
begin
   SBC8(Immediate8(ACC_READ));
end;

procedure OpE9M0;
begin
   SBC16(Immediate16(ACC_READ));
end;

procedure OpE9Slow;
begin
   if CheckMem then
      SBC8(Immediate8Slow(ACC_READ))
   else
      SBC16(Immediate16Slow(ACC_READ));
end;

procedure OpEA;
begin
	CPU.Cycles := CPU.Cycles + Settings.OneCycle;
end;

procedure OpEB; // XBA
var
   Work8: Byte;
begin
   Work8 := ICPU.Registers.A.L;
   ICPU.Registers.A.L := ICPU.Registers.A.H;
   ICPU.Registers.A.H := Work8;
   SetZN8(ICPU.Registers.A.L);
   CPU.Cycles := CPU.Cycles + Settings.TwoCycles;
end;

procedure OpECX1;
begin
   ICPU.OpenBus := GetByte(Absolute(ACC_READ));
   CPX8(ICPU.OpenBus);
end;

procedure OpECX0;
begin
   var w := GetWord(Absolute(ACC_READ), WRAP_BANK);
   ICPU.OpenBus := Byte(w shr 8);
   CPX16(w);
end;

procedure OpECSlow;
begin
   var addr := AbsoluteSlow(ACC_READ);
   if CheckIndex then
   begin
      ICPU.OpenBus := GetByte(addr);
      CPX8(ICPU.OpenBus);
   end
   else
   begin
      var w := GetWord(addr, WRAP_BANK);
      ICPU.OpenBus := Byte(w shr 8);
      CPX16(w);
   end;
end;

procedure OpEDM1;
begin
   ICPU.OpenBus := GetByte(Absolute(ACC_READ));
   SBC8(ICPU.OpenBus);
end;

procedure OpEDM0;
begin
   var w := GetWord(Absolute(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(w shr 8);
   SBC16(w);
end;

procedure OpEDSlow;
begin
   var addr := AbsoluteSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      SBC8(ICPU.OpenBus);
   end
   else
   begin
      var w := GetWord(addr, WRAP_NONE);
      ICPU.OpenBus := Byte(w shr 8);
      SBC16(w);
   end;
end;

procedure OpEEM1;
begin
   INC8(Absolute(ACC_MODIFY));
end;

procedure OpEEM0;
begin
   INC16(Absolute(ACC_MODIFY), WRAP_NONE);
end;

procedure OpEESlow;
begin
   if CheckMem then
      INC8(AbsoluteSlow(ACC_MODIFY))
   else
      INC16(AbsoluteSlow(ACC_MODIFY), WRAP_NONE);
end;

procedure OpEFM1;
begin
   ICPU.OpenBus := GetByte(AbsoluteLong(ACC_READ));
   SBC8(ICPU.OpenBus);
end;

procedure OpEFM0;
begin
   var w := GetWord(AbsoluteLong(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(w shr 8);
   SBC16(w);
end;

procedure OpEFSlow;
begin
   var addr := AbsoluteLongSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      SBC8(ICPU.OpenBus);
   end
   else
   begin
      var w := GetWord(addr, WRAP_NONE);
      ICPU.OpenBus := Byte(w shr 8);
      SBC16(w);
   end;
end;

procedure OpF0E1;
var
   newPC: TPair;
begin
   newPC.w := Relative(ACC_JUMP);
   if CheckZero then
   begin
      CPU.Cycles := CPU.Cycles + Settings.OneCycle;
      if ICPU.Registers.PCw.PB <> newPC.H then
         CPU.Cycles := CPU.Cycles + Settings.OneCycle;
      if (ICPU.Registers.PCw.PC.w and not MEMMAP_MASK) <> (newPC.w and not MEMMAP_MASK) then
         SetPCBase(ICPU.ShiftedPB or newPC.w)
      else
         ICPU.Registers.PCw.PC.w := newPC.w;
      CPUShutdown;
   end;
end;

procedure OpF0E0;
var
   newPC: TPair;
begin
   newPC.w := Relative(ACC_JUMP);
   if CheckZero then
   begin
      CPU.Cycles := CPU.Cycles + Settings.OneCycle;
      if (ICPU.Registers.PCw.PC.w and not MEMMAP_MASK) <> (newPC.w and not MEMMAP_MASK) then
         SetPCBase(ICPU.ShiftedPB or newPC.w)
      else
         ICPU.Registers.PCw.PC.w := newPC.w;
      CPUShutdown;
   end;
end;

procedure OpF0Slow;
var
   newPC: TPair;
begin
   newPC.w := RelativeSlow(ACC_JUMP);
   if CheckZero then
   begin
      CPU.Cycles := CPU.Cycles + Settings.OneCycle;
      if CheckEmulation and (ICPU.Registers.PCw.PB <> newPC.H) then
         CPU.Cycles := CPU.Cycles + Settings.OneCycle;
      if (ICPU.Registers.PCw.PC.w and not MEMMAP_MASK) <> (newPC.w and not MEMMAP_MASK) then
         SetPCBase(ICPU.ShiftedPB or newPC.w)
      else
         ICPU.Registers.PCw.PC.w := newPC.w;
      CPUShutdown;
   end;
end;

procedure OpF1E1;
begin
   ICPU.OpenBus := GetByte(DirectIndirectIndexedE1(ACC_READ));
   SBC8(ICPU.OpenBus);
end;

procedure OpF1E0M1X1;
begin
   ICPU.OpenBus := GetByte(DirectIndirectIndexedE0X1(ACC_READ));
   SBC8(ICPU.OpenBus);
end;

procedure OpF1E0M0X1;
begin
   var w := GetWord(DirectIndirectIndexedE0X1(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(w shr 8);
   SBC16(w);
end;

procedure OpF1E0M1X0;
begin
   ICPU.OpenBus := GetByte(DirectIndirectIndexedE0X0(ACC_READ));
   SBC8(ICPU.OpenBus);
end;

procedure OpF1E0M0X0;
begin
   var w := GetWord(DirectIndirectIndexedE0X0(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(w shr 8);
   SBC16(w);
end;

procedure OpF1Slow;
begin
   var addr := DirectIndirectIndexedSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      SBC8(ICPU.OpenBus);
   end
   else
   begin
      var w := GetWord(addr, WRAP_NONE);
      ICPU.OpenBus := Byte(w shr 8);
      SBC16(w);
   end;
end;

procedure OpF2E1;
begin
   ICPU.OpenBus := GetByte(DirectIndirectE1(ACC_READ));
   SBC8(ICPU.OpenBus);
end;

procedure OpF2E0M1;
begin
   ICPU.OpenBus := GetByte(DirectIndirectE0(ACC_READ));
   SBC8(ICPU.OpenBus);
end;

procedure OpF2E0M0;
begin
   var w := GetWord(DirectIndirectE0(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(w shr 8);
   SBC16(w);
end;

procedure OpF2Slow;
begin
   var addr := DirectIndirectSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      SBC8(ICPU.OpenBus);
   end
   else
   begin
      var w := GetWord(addr, WRAP_NONE);
      ICPU.OpenBus := Byte(w shr 8);
      SBC16(w);
   end;
end;

procedure OpF3M1;
begin
   ICPU.OpenBus := GetByte(StackRelativeIndirectIndexed(ACC_READ));
   SBC8(ICPU.OpenBus);
end;

procedure OpF3M0;
begin
   var w := GetWord(StackRelativeIndirectIndexed(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(w shr 8);
   SBC16(w);
end;

procedure OpF3Slow;
begin
   var addr := StackRelativeIndirectIndexedSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      SBC8(ICPU.OpenBus);
   end
   else
   begin
      var w := GetWord(addr, WRAP_NONE);
      ICPU.OpenBus := Byte(w shr 8);
      SBC16(w);
   end;
end;

procedure OpF4E1;
var
   val: Word;
begin
   val := Absolute(ACC_NONE);
   PushWE(val);
   ICPU.OpenBus := val and $FF;
   ICPU.Registers.S.H := 1;
end;

procedure OpF4E0;
var
   val: Word;
begin
   val := Absolute(ACC_NONE);
   PushW(val);
   ICPU.OpenBus := val and $FF;
end;

procedure OpF4Slow;
var
   val: Word;
begin
   val := AbsoluteSlow(ACC_NONE);
   PushW(val);
   ICPU.OpenBus := val and $FF;
   if CheckEmulation then
      ICPU.Registers.S.H := 1;
end;

procedure OpF5E1;
begin
   ICPU.OpenBus := GetByte(DirectIndexedXE1(ACC_READ));
   SBC8(ICPU.OpenBus);
end;

procedure OpF5E0M1;
begin
   ICPU.OpenBus := GetByte(DirectIndexedXE0(ACC_READ));
   SBC8(ICPU.OpenBus);
end;

procedure OpF5E0M0;
begin
   var w := GetWord(DirectIndexedXE0(ACC_READ), WRAP_BANK);
   ICPU.OpenBus := Byte(w shr 8);
   SBC16(w);
end;

procedure OpF5Slow;
begin
   var addr := DirectIndexedXSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      SBC8(ICPU.OpenBus);
   end
   else
   begin
      var w := GetWord(addr, WRAP_BANK);
      ICPU.OpenBus := Byte(w shr 8);
      SBC16(w);
   end;
end;

procedure OpF6E1;
begin
   INC8(DirectIndexedXE1(ACC_MODIFY));
end;

procedure OpF6E0M1;
begin
   INC8(DirectIndexedXE0(ACC_MODIFY));
end;

procedure OpF6E0M0;
begin
   INC16(DirectIndexedXE0(ACC_MODIFY), WRAP_BANK);
end;

procedure OpF6Slow;
begin
   if CheckMem then
      INC8(DirectIndexedXSlow(ACC_MODIFY))
   else
      INC16(DirectIndexedXSlow(ACC_MODIFY), WRAP_BANK);
end;

procedure OpF7M1;
begin
   ICPU.OpenBus := GetByte(DirectIndirectIndexedLong(ACC_READ));
   SBC8(ICPU.OpenBus);
end;

procedure OpF7M0;
begin
   var w := GetWord(DirectIndirectIndexedLong(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(w shr 8);
   SBC16(w);
end;

procedure OpF7Slow;
begin
   var addr := DirectIndirectIndexedLongSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      SBC8(ICPU.OpenBus);
   end
   else
   begin
      var w := GetWord(addr, WRAP_NONE);
      ICPU.OpenBus := Byte(w shr 8);
      SBC16(w);
   end;
end;

procedure OpF8; // SED
begin
   SetFlags(FLAG_DECIMAL);
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
end;

procedure OpF9M1X1;
begin
   ICPU.OpenBus := GetByte(AbsoluteIndexedYX1(ACC_READ));
   SBC8(ICPU.OpenBus);
end;

procedure OpF9M0X1;
begin
   var w := GetWord(AbsoluteIndexedYX1(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(w shr 8);
   SBC16(w);
end;

procedure OpF9M1X0;
begin
   ICPU.OpenBus := GetByte(AbsoluteIndexedYX0(ACC_READ));
   SBC8(ICPU.OpenBus);
end;

procedure OpF9M0X0;
begin
   var w := GetWord(AbsoluteIndexedYX0(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(w shr 8);
   SBC16(w);
end;

procedure OpF9Slow;
begin
   var addr := AbsoluteIndexedYSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      SBC8(ICPU.OpenBus);
   end
   else
   begin
      var w := GetWord(addr, WRAP_NONE);
      ICPU.OpenBus := Byte(w shr 8);
      SBC16(w);
   end;
end;

procedure OpFAE1;
begin
   CPU.Cycles := CPU.Cycles + Settings.TwoCycles;
   ICPU.Registers.X.L := PullBE;
   SetZN8(ICPU.Registers.X.L);
   ICPU.OpenBus := ICPU.Registers.X.L;
end;

procedure OpFAE0X1;
begin
   CPU.Cycles := CPU.Cycles + Settings.TwoCycles;
   ICPU.Registers.X.L := PullB;
   SetZN8(ICPU.Registers.X.L);
   ICPU.OpenBus := ICPU.Registers.X.L;
end;

procedure OpFAE0X0;
begin
   CPU.Cycles := CPU.Cycles + Settings.TwoCycles;
   ICPU.Registers.X.w := PullW;
   SetZN16(ICPU.Registers.X.w);
   ICPU.OpenBus := ICPU.Registers.X.H;
end;

procedure OpFASlow;
begin
   CPU.Cycles := CPU.Cycles + Settings.TwoCycles;
   if CheckEmulation then
   begin
      ICPU.Registers.X.L := PullBE;
      SetZN8(ICPU.Registers.X.L);
      ICPU.OpenBus := ICPU.Registers.X.L;
   end
   else
   begin
      if CheckIndex then
      begin
         ICPU.Registers.X.L := PullB;
         SetZN8(ICPU.Registers.X.L);
         ICPU.OpenBus := ICPU.Registers.X.L;
      end
      else
      begin
         ICPU.Registers.X.w := PullW;
         SetZN16(ICPU.Registers.X.w);
         ICPU.OpenBus := ICPU.Registers.X.H;
      end;
   end;
end;

procedure OpFB; // XCE
begin
   CPU.Cycles := CPU.Cycles + Settings.OneCycle;
   var A1 := ICPU.Carry;
   var A2 := ICPU.Registers.P.H;
   ICPU.Carry := (A2 and 1) <> 0;
   ICPU.Registers.P.H := Ord(A1);

   if CheckEmulation then
   begin
      SetFlags(FLAG_MEMORY or FLAG_INDEX);
      ICPU.Registers.S.H := 1;
   end;

   if CheckIndex then
   begin
      ICPU.Registers.X.H := 0;
      ICPU.Registers.Y.H := 0;
   end;
   FixCycles;
end;

procedure OpFCE1;
var
   addr: Word;
begin
   addr := AbsoluteIndexedIndirect(ACC_JSR);
   PushW(ICPU.Registers.PCw.PC.w - 1);
   ICPU.Registers.S.H := 1;
   SetPCBase(ICPU.ShiftedPB or addr);
end;

procedure OpFCE0;
var
   addr: Word;
begin
   addr := AbsoluteIndexedIndirect(ACC_JSR);
   PushW(ICPU.Registers.PCw.PC.w - 1);
   SetPCBase(ICPU.ShiftedPB or addr);
end;

procedure OpFCSlow;
var
   addr: Word;
begin
   addr := AbsoluteIndexedIndirectSlow(ACC_JSR);
   PushW(ICPU.Registers.PCw.PC.w - 1);
   if CheckEmulation then
      ICPU.Registers.S.H := 1;
   SetPCBase(ICPU.ShiftedPB or addr);
end;

procedure OpFDM1X1;
begin
   ICPU.OpenBus := GetByte(AbsoluteIndexedXX1(ACC_READ));
   SBC8(ICPU.OpenBus);
end;

procedure OpFDM0X1;
begin
   var w := GetWord(AbsoluteIndexedXX1(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(w shr 8);
   SBC16(w);
end;

procedure OpFDM1X0;
begin
   ICPU.OpenBus := GetByte(AbsoluteIndexedXX0(ACC_READ));
   SBC8(ICPU.OpenBus);
end;

procedure OpFDM0X0;
begin
   var w := GetWord(AbsoluteIndexedXX0(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(w shr 8);
   SBC16(w);
end;

procedure OpFDSlow;
begin
   var addr := AbsoluteIndexedXSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      SBC8(ICPU.OpenBus);
   end
   else
   begin
      var w := GetWord(addr, WRAP_NONE);
      ICPU.OpenBus := Byte(w shr 8);
      SBC16(w);
   end;
end;

procedure OpFEM1X1;
begin
   INC8(AbsoluteIndexedXX1(ACC_MODIFY));
end;

procedure OpFEM0X1;
begin
   INC16(AbsoluteIndexedXX1(ACC_MODIFY), WRAP_NONE);
end;

procedure OpFEM1X0;
begin
   INC8(AbsoluteIndexedXX0(ACC_MODIFY));
end;

procedure OpFEM0X0;
begin
   INC16(AbsoluteIndexedXX0(ACC_MODIFY), WRAP_NONE);
end;

procedure OpFESlow;
begin
   if CheckMem then
      INC8(AbsoluteIndexedXSlow(ACC_MODIFY))
   else
      INC16(AbsoluteIndexedXSlow(ACC_MODIFY), WRAP_NONE);
end;

procedure OpFFM1;
begin
   ICPU.OpenBus := GetByte(AbsoluteLongIndexedX(ACC_READ));
   SBC8(ICPU.OpenBus);
end;

procedure OpFFM0;
begin
   var w := GetWord(AbsoluteLongIndexedX(ACC_READ), WRAP_NONE);
   ICPU.OpenBus := Byte(w shr 8);
   SBC16(w);
end;

procedure OpFFSlow;
begin
   var addr := AbsoluteLongIndexedXSlow(ACC_READ);
   if CheckMem then
   begin
      ICPU.OpenBus := GetByte(addr);
      SBC8(ICPU.OpenBus);
   end
   else
   begin
      var
      w := GetWord(addr, WRAP_NONE);
      ICPU.OpenBus := Byte(w shr 8);
      SBC16(w);
   end;
end;

// --- Implementações de Interrupção ---
procedure OpcodeNMI;
var
  emulation: Boolean;
  addr: Word;
begin
   CPU.Cycles := CPU.Cycles + CPU.MemSpeed + Settings.OneCycle;
   emulation := CheckEmulation;

   if emulation then
   begin
      PushWE(ICPU.Registers.PCw.PC.W);
      PackStatus;
      PushBE(ICPU.Registers.P.L);
   end
   else
   begin
      PushB(ICPU.Registers.PCw.PB);
      PushW(ICPU.Registers.PCw.PC.W);
      PackStatus;
      PushB(ICPU.Registers.P.L);
   end;

   ICPU.OpenBus := ICPU.Registers.P.L;
   ClearFlags(FLAG_DECIMAL);
   SetFlags(FLAG_IRQ);

   // Lógica para verificar se o chip SA-1 está presente e ativo para redirecionar o NMI
   if (Settings.Chip = CHIP_SA_1) and ((Memory.FillRAM[$2209] and $10) <> 0) then
   begin
      ICPU.OpenBus := Memory.FillRAM[$220d];
      CPU.Cycles := CPU.Cycles + (2 * Settings.OneCycle);
      SetPCBase(Memory.FillRAM[$220c] or (Word(Memory.FillRAM[$220d]) shl 8));
   end
   else
   begin
      // Caminho padrão para NMI
      if emulation then
         addr := GetWord($FFFA, WRAP_NONE)
      else
         addr := GetWord($FFEA, WRAP_NONE);

      ICPU.OpenBus := addr shr 8;
      SetPCBase(addr);
   end;
end;

procedure OpcodeIRQ;
var
   emulation: Boolean;
   addr: Word;
begin
   CPU.Cycles := CPU.Cycles + CPU.MemSpeed + Settings.OneCycle;
   emulation := CheckEmulation;

   if emulation then
   begin
      PushWE(ICPU.Registers.PCw.PC.W);
      PackStatus;
      PushBE(ICPU.Registers.P.L);
   end
   else
   begin
      PushB(ICPU.Registers.PCw.PB);
      PushW(ICPU.Registers.PCw.PC.W);
      PackStatus;
      PushB(ICPU.Registers.P.L);
   end;

   ICPU.OpenBus := ICPU.Registers.P.L;
   ClearFlags(FLAG_DECIMAL);
   SetFlags(FLAG_IRQ);

   // Lógica para verificar se o chip SA-1 está presente e ativo para redirecionar o IRQ
   if (Settings.Chip = CHIP_SA_1) and ((Memory.FillRAM[$2209] and $40) <> 0) then
   begin
      ICPU.OpenBus := Memory.FillRAM[$220f];
      CPU.Cycles := CPU.Cycles + (2 * Settings.OneCycle);
      SetPCBase(Memory.FillRAM[$220e] or (Word(Memory.FillRAM[$220f]) shl 8));
   end
   else
   begin
      // Caminho padrão para IRQ
      if emulation then
         addr := GetWord($FFFE, WRAP_NONE)
      else
         addr := GetWord($FFEE, WRAP_NONE);

      ICPU.OpenBus := addr shr 8;
      SetPCBase(addr);
   end;
end;

procedure InitializeOpcodeTables;
var
  i: integer;
begin
   for i := 0 to 255 do
   begin
      // Inicializa todas as tabelas com um opcode "inválido" ou "lento" para segurança, caso alguma entrada seja esquecida.
      OpcodesE1[i].Opcode   := @Op40Slow;
      OpcodesM1X1[i].Opcode := @Op40Slow;
      OpcodesM1X0[i].Opcode := @Op40Slow;
      OpcodesM0X0[i].Opcode := @Op40Slow;
      OpcodesM0X1[i].Opcode := @Op40Slow;
      OpcodesSlow[i].Opcode := @Op40Slow;
   end;

   // --- Tabela para o modo de Emulação (E=1) ---
   // A tabela E1 é um caso especial, já que M e X estão travados em 1.
   // Muitas de suas entradas apontam para opcodes `M1` ou `X1`.
   OpcodesE1[$00].Opcode := @Op00;
   OpcodesE1[$01].Opcode := @Op01E1;
   OpcodesE1[$02].Opcode := @Op02;
   OpcodesE1[$03].Opcode := @Op03M1;
   OpcodesE1[$04].Opcode := @Op04M1;
   OpcodesE1[$05].Opcode := @Op05M1;
   OpcodesE1[$06].Opcode := @Op06M1;
   OpcodesE1[$07].Opcode := @Op07M1;
   OpcodesE1[$08].Opcode := @Op08E1;
   OpcodesE1[$09].Opcode := @Op09M1;
   OpcodesE1[$0A].Opcode := @Op0AM1;
   OpcodesE1[$0B].Opcode := @Op0BE1;
   OpcodesE1[$0C].Opcode := @Op0CM1;
   OpcodesE1[$0D].Opcode := @Op0DM1;
   OpcodesE1[$0E].Opcode := @Op0EM1;
   OpcodesE1[$0F].Opcode := @Op0FM1;
   OpcodesE1[$10].Opcode := @Op10E1;
   OpcodesE1[$11].Opcode := @Op11E1;
   OpcodesE1[$12].Opcode := @Op12E1;
   OpcodesE1[$13].Opcode := @Op13M1;
   OpcodesE1[$14].Opcode := @Op14M1;
   OpcodesE1[$15].Opcode := @Op15E1;
   OpcodesE1[$16].Opcode := @Op16E1;
   OpcodesE1[$17].Opcode := @Op17M1;
   OpcodesE1[$18].Opcode := @Op18;
   OpcodesE1[$19].Opcode := @Op19M1X1;
   OpcodesE1[$1A].Opcode := @Op1AM1;
   OpcodesE1[$1B].Opcode := @Op1B;
   OpcodesE1[$1C].Opcode := @Op1CM1;
   OpcodesE1[$1D].Opcode := @Op1DM1X1;
   OpcodesE1[$1E].Opcode := @Op1EM1X1;
   OpcodesE1[$1F].Opcode := @Op1FM1;
   OpcodesE1[$20].Opcode := @Op20E1;
   OpcodesE1[$21].Opcode := @Op21E1;
   OpcodesE1[$22].Opcode := @Op22E1;
   OpcodesE1[$23].Opcode := @Op23M1;
   OpcodesE1[$24].Opcode := @Op24M1;
   OpcodesE1[$25].Opcode := @Op25M1;
   OpcodesE1[$26].Opcode := @Op26M1;
   OpcodesE1[$27].Opcode := @Op27M1;
   OpcodesE1[$28].Opcode := @Op28E1;
   OpcodesE1[$29].Opcode := @Op29M1;
   OpcodesE1[$2A].Opcode := @Op2AM1;
   OpcodesE1[$2B].Opcode := @Op2BE1;
   OpcodesE1[$2C].Opcode := @Op2CM1;
   OpcodesE1[$2D].Opcode := @Op2DM1;
   OpcodesE1[$2E].Opcode := @Op2EM1;
   OpcodesE1[$2F].Opcode := @Op2FM1;
   OpcodesE1[$30].Opcode := @Op30E1;
   OpcodesE1[$31].Opcode := @Op31E1;
   OpcodesE1[$32].Opcode := @Op32E1;
   OpcodesE1[$33].Opcode := @Op33M1;
   OpcodesE1[$34].Opcode := @Op34E1;
   OpcodesE1[$35].Opcode := @Op35E1;
   OpcodesE1[$36].Opcode := @Op36E1;
   OpcodesE1[$37].Opcode := @Op37M1;
   OpcodesE1[$38].Opcode := @Op38;
   OpcodesE1[$39].Opcode := @Op39M1X1;
   OpcodesE1[$3A].Opcode := @Op3AM1;
   OpcodesE1[$3B].Opcode := @Op3B;
   OpcodesE1[$3C].Opcode := @Op3CM1X1;
   OpcodesE1[$3D].Opcode := @Op3DM1X1;
   OpcodesE1[$3E].Opcode := @Op3EM1X1;
   OpcodesE1[$3F].Opcode := @Op3FM1;
   OpcodesE1[$40].Opcode := @Op40Slow;
   OpcodesE1[$41].Opcode := @Op41E1;
   OpcodesE1[$42].Opcode := @Op42;
   OpcodesE1[$43].Opcode := @Op43M1;
   OpcodesE1[$44].Opcode := @Op44X1;
   OpcodesE1[$45].Opcode := @Op45M1;
   OpcodesE1[$46].Opcode := @Op46M1;
   OpcodesE1[$47].Opcode := @Op47M1;
   OpcodesE1[$48].Opcode := @Op48E1;
   OpcodesE1[$49].Opcode := @Op49M1;
   OpcodesE1[$4A].Opcode := @Op4AM1;
   OpcodesE1[$4B].Opcode := @Op4BE1;
   OpcodesE1[$4C].Opcode := @Op4C;
   OpcodesE1[$4D].Opcode := @Op4DM1;
   OpcodesE1[$4E].Opcode := @Op4EM1;
   OpcodesE1[$4F].Opcode := @Op4FM1;
   OpcodesE1[$50].Opcode := @Op50E1;
   OpcodesE1[$51].Opcode := @Op51E1;
   OpcodesE1[$52].Opcode := @Op52E1;
   OpcodesE1[$53].Opcode := @Op53M1;
   OpcodesE1[$54].Opcode := @Op54X1;
   OpcodesE1[$55].Opcode := @Op55E1;
   OpcodesE1[$56].Opcode := @Op56E1;
   OpcodesE1[$57].Opcode := @Op57M1;
   OpcodesE1[$58].Opcode := @Op58;
   OpcodesE1[$59].Opcode := @Op59M1X1;
   OpcodesE1[$5A].Opcode := @Op5AE1;
   OpcodesE1[$5B].Opcode := @Op5B;
   OpcodesE1[$5C].Opcode := @Op5C;
   OpcodesE1[$5D].Opcode := @Op5DM1X1;
   OpcodesE1[$5E].Opcode := @Op5EM1X1;
   OpcodesE1[$5F].Opcode := @Op5FM1;
   OpcodesE1[$60].Opcode := @Op60E1;
   OpcodesE1[$61].Opcode := @Op61E1;
   OpcodesE1[$62].Opcode := @Op62E1;
   OpcodesE1[$63].Opcode := @Op63M1;
   OpcodesE1[$64].Opcode := @Op64M1;
   OpcodesE1[$65].Opcode := @Op65M1;
   OpcodesE1[$66].Opcode := @Op66M1;
   OpcodesE1[$67].Opcode := @Op67M1;
   OpcodesE1[$68].Opcode := @Op68E1;
   OpcodesE1[$69].Opcode := @Op69M1;
   OpcodesE1[$6A].Opcode := @Op6AM1;
   OpcodesE1[$6B].Opcode := @Op6BE1;
   OpcodesE1[$6C].Opcode := @Op6C;
   OpcodesE1[$6D].Opcode := @Op6DM1;
   OpcodesE1[$6E].Opcode := @Op6EM1;
   OpcodesE1[$6F].Opcode := @Op6FM1;
   OpcodesE1[$70].Opcode := @Op70E1;
   OpcodesE1[$71].Opcode := @Op71E1;
   OpcodesE1[$72].Opcode := @Op72E1;
   OpcodesE1[$73].Opcode := @Op73M1;
   OpcodesE1[$74].Opcode := @Op74E1;
   OpcodesE1[$75].Opcode := @Op75E1;
   OpcodesE1[$76].Opcode := @Op76E1;
   OpcodesE1[$77].Opcode := @Op77M1;
   OpcodesE1[$78].Opcode := @Op78;
   OpcodesE1[$79].Opcode := @Op79M1X1;
   OpcodesE1[$7A].Opcode := @Op7AE1;
   OpcodesE1[$7B].Opcode := @Op7B;
   OpcodesE1[$7C].Opcode := @Op7C;
   OpcodesE1[$7D].Opcode := @Op7DM1X1;
   OpcodesE1[$7E].Opcode := @Op7EM1X1;
   OpcodesE1[$7F].Opcode := @Op7FM1;
   OpcodesE1[$80].Opcode := @Op80E1;
   OpcodesE1[$81].Opcode := @Op81E1;
   OpcodesE1[$82].Opcode := @Op82;
   OpcodesE1[$83].Opcode := @Op83M1;
   OpcodesE1[$84].Opcode := @Op84X1;
   OpcodesE1[$85].Opcode := @Op85M1;
   OpcodesE1[$86].Opcode := @Op86X1;
   OpcodesE1[$87].Opcode := @Op87M1;
   OpcodesE1[$88].Opcode := @Op88X1;
   OpcodesE1[$89].Opcode := @Op89M1;
   OpcodesE1[$8A].Opcode := @Op8AM1;
   OpcodesE1[$8B].Opcode := @Op8BE1;
   OpcodesE1[$8C].Opcode := @Op8CX1;
   OpcodesE1[$8D].Opcode := @Op8DM1;
   OpcodesE1[$8E].Opcode := @Op8EX1;
   OpcodesE1[$8F].Opcode := @Op8FM1;
   OpcodesE1[$90].Opcode := @Op90E1;
   OpcodesE1[$91].Opcode := @Op91E1;
   OpcodesE1[$92].Opcode := @Op92E1;
   OpcodesE1[$93].Opcode := @Op93M1;
   OpcodesE1[$94].Opcode := @Op94E1;
   OpcodesE1[$95].Opcode := @Op95E1;
   OpcodesE1[$96].Opcode := @Op96E1;
   OpcodesE1[$97].Opcode := @Op97M1;
   OpcodesE1[$98].Opcode := @Op98M1;
   OpcodesE1[$99].Opcode := @Op99M1X1;
   OpcodesE1[$9A].Opcode := @Op9A;
   OpcodesE1[$9B].Opcode := @Op9BX1;
   OpcodesE1[$9C].Opcode := @Op9CM1;
   OpcodesE1[$9D].Opcode := @Op9DM1X1;
   OpcodesE1[$9E].Opcode := @Op9EM1X1;
   OpcodesE1[$9F].Opcode := @Op9FM1;
   OpcodesE1[$A0].Opcode := @OpA0X1;
   OpcodesE1[$A1].Opcode := @OpA1E1;
   OpcodesE1[$A2].Opcode := @OpA2X1;
   OpcodesE1[$A3].Opcode := @OpA3M1;
   OpcodesE1[$A4].Opcode := @OpA4X1;
   OpcodesE1[$A5].Opcode := @OpA5M1;
   OpcodesE1[$A6].Opcode := @OpA6X1;
   OpcodesE1[$A7].Opcode := @OpA7M1;
   OpcodesE1[$A8].Opcode := @OpA8X1;
   OpcodesE1[$A9].Opcode := @OpA9M1;
   OpcodesE1[$AA].Opcode := @OpAAX1;
   OpcodesE1[$AB].Opcode := @OpABE1;
   OpcodesE1[$AC].Opcode := @OpACX1;
   OpcodesE1[$AD].Opcode := @OpADM1;
   OpcodesE1[$AE].Opcode := @OpAEX1;
   OpcodesE1[$AF].Opcode := @OpAFM1;
   OpcodesE1[$B0].Opcode := @OpB0E1;
   OpcodesE1[$B1].Opcode := @OpB1E1;
   OpcodesE1[$B2].Opcode := @OpB2E1;
   OpcodesE1[$B3].Opcode := @OpB3M1;
   OpcodesE1[$B4].Opcode := @OpB4E1;
   OpcodesE1[$B5].Opcode := @OpB5E1;
   OpcodesE1[$B6].Opcode := @OpB6E1;
   OpcodesE1[$B7].Opcode := @OpB7M1;
   OpcodesE1[$B8].Opcode := @OpB8;
   OpcodesE1[$B9].Opcode := @OpB9M1X1;
   OpcodesE1[$BA].Opcode := @OpBAX1;
   OpcodesE1[$BB].Opcode := @OpBBX1;
   OpcodesE1[$BC].Opcode := @OpBCX1;
   OpcodesE1[$BD].Opcode := @OpBDM1X1;
   OpcodesE1[$BE].Opcode := @OpBEX1;
   OpcodesE1[$BF].Opcode := @OpBFM1;
   OpcodesE1[$C0].Opcode := @OpC0X1;
   OpcodesE1[$C1].Opcode := @OpC1E1;
   OpcodesE1[$C2].Opcode := @OpC2;
   OpcodesE1[$C3].Opcode := @OpC3M1;
   OpcodesE1[$C4].Opcode := @OpC4X1;
   OpcodesE1[$C5].Opcode := @OpC5M1;
   OpcodesE1[$C6].Opcode := @OpC6M1;
   OpcodesE1[$C7].Opcode := @OpC7M1;
   OpcodesE1[$C8].Opcode := @OpC8X1;
   OpcodesE1[$C9].Opcode := @OpC9M1;
   OpcodesE1[$CA].Opcode := @OpCAX1;
   OpcodesE1[$CB].Opcode := @OpCB;
   OpcodesE1[$CC].Opcode := @OpCCX1;
   OpcodesE1[$CD].Opcode := @OpCDM1;
   OpcodesE1[$CE].Opcode := @OpCEM1;
   OpcodesE1[$CF].Opcode := @OpCFM1;
   OpcodesE1[$D0].Opcode := @OpD0E1;
   OpcodesE1[$D1].Opcode := @OpD1E1;
   OpcodesE1[$D2].Opcode := @OpD2E1;
   OpcodesE1[$D3].Opcode := @OpD3M1;
   OpcodesE1[$D4].Opcode := @OpD4E1;
   OpcodesE1[$D5].Opcode := @OpD5E1;
   OpcodesE1[$D6].Opcode := @OpD6E1;
   OpcodesE1[$D7].Opcode := @OpD7M1;
   OpcodesE1[$D8].Opcode := @OpD8;
   OpcodesE1[$D9].Opcode := @OpD9M1X1;
   OpcodesE1[$DA].Opcode := @OpDAE1;
   OpcodesE1[$DB].Opcode := @OpDB;
   OpcodesE1[$DC].Opcode := @OpDC;
   OpcodesE1[$DD].Opcode := @OpDDM1X1;
   OpcodesE1[$DE].Opcode := @OpDEM1X1;
   OpcodesE1[$DF].Opcode := @OpDFM1;
   OpcodesE1[$E0].Opcode := @OpE0X1;
   OpcodesE1[$E1].Opcode := @OpE1E1;
   OpcodesE1[$E2].Opcode := @OpE2;
   OpcodesE1[$E3].Opcode := @OpE3M1;
   OpcodesE1[$E4].Opcode := @OpE4X1;
   OpcodesE1[$E5].Opcode := @OpE5M1;
   OpcodesE1[$E6].Opcode := @OpE6M1;
   OpcodesE1[$E7].Opcode := @OpE7M1;
   OpcodesE1[$E8].Opcode := @OpE8X1;
   OpcodesE1[$E9].Opcode := @OpE9M1;
   OpcodesE1[$EA].Opcode := @OpEA;
   OpcodesE1[$EB].Opcode := @OpEB;
   OpcodesE1[$EC].Opcode := @OpECX1;
   OpcodesE1[$ED].Opcode := @OpEDM1;
   OpcodesE1[$EE].Opcode := @OpEEM1;
   OpcodesE1[$EF].Opcode := @OpEFM1;
   OpcodesE1[$F0].Opcode := @OpF0E1;
   OpcodesE1[$F1].Opcode := @OpF1E1;
   OpcodesE1[$F2].Opcode := @OpF2E1;
   OpcodesE1[$F3].Opcode := @OpF3M1;
   OpcodesE1[$F4].Opcode := @OpF4E1;
   OpcodesE1[$F5].Opcode := @OpF5E1;
   OpcodesE1[$F6].Opcode := @OpF6E1;
   OpcodesE1[$F7].Opcode := @OpF7M1;
   OpcodesE1[$F8].Opcode := @OpF8;
   OpcodesE1[$F9].Opcode := @OpF9M1X1;
   OpcodesE1[$FA].Opcode := @OpFAE1;
   OpcodesE1[$FB].Opcode := @OpFB;
   OpcodesE1[$FC].Opcode := @OpFCE1;
   OpcodesE1[$FD].Opcode := @OpFDM1X1;
   OpcodesE1[$FE].Opcode := @OpFEM1X1;
   OpcodesE1[$FF].Opcode := @OpFFM1;

   // --- Tabela para M=1, X=1 ---
   OpcodesM1X1 := OpcodesE1;
   OpcodesM1X1[$48].Opcode := @Op48E0M1;
   OpcodesM1X1[$68].Opcode := @Op68E0M1;
   OpcodesM1X1[$88].Opcode := @Op88X1;
   OpcodesM1X1[$A8].Opcode := @OpA8X1;
   OpcodesM1X1[$C8].Opcode := @OpC8X1;
   OpcodesM1X1[$E8].Opcode := @OpE8X1;
   OpcodesM1X1[$5A].Opcode := @Op5AE0X1;
   OpcodesM1X1[$DA].Opcode := @OpDAE0X1;
   OpcodesM1X1[$FA].Opcode := @OpFAE0X1;

   // --- Tabela para M=1, X=0 ---
   OpcodesM1X0 := OpcodesM1X1;
   OpcodesM1X0[$19].Opcode := @Op19M1X0;
   OpcodesM1X0[$1D].Opcode := @Op1DM1X0;
   OpcodesM1X0[$1E].Opcode := @Op1EM1X0;
   OpcodesM1X0[$39].Opcode := @Op39M1X0;
   OpcodesM1X0[$3D].Opcode := @Op3DM1X0;
   OpcodesM1X0[$3E].Opcode := @Op3EM1X0;
   OpcodesM1X0[$44].Opcode := @Op44X0;
   OpcodesM1X0[$54].Opcode := @Op54X0;
   OpcodesM1X0[$59].Opcode := @Op59M1X0;
   OpcodesM1X0[$5A].Opcode := @Op5AE0X0;
   OpcodesM1X0[$5D].Opcode := @Op5DM1X0;
   OpcodesM1X0[$5E].Opcode := @Op5EM1X0;
   OpcodesM1X0[$79].Opcode := @Op79M1X0;
   OpcodesM1X0[$7A].Opcode := @Op7AE0X0;
   OpcodesM1X0[$7D].Opcode := @Op7DM1X0;
   OpcodesM1X0[$7E].Opcode := @Op7EM1X0;
   OpcodesM1X0[$84].Opcode := @Op84X0;
   OpcodesM1X0[$86].Opcode := @Op86X0;
   OpcodesM1X0[$88].Opcode := @Op88X0;
   OpcodesM1X0[$8C].Opcode := @Op8CX0;
   OpcodesM1X0[$8E].Opcode := @Op8EX0;
   OpcodesM1X0[$94].Opcode := @Op94E0X0;
   OpcodesM1X0[$96].Opcode := @Op96E0X0;
   OpcodesM1X0[$99].Opcode := @Op99M1X0;
   OpcodesM1X0[$9B].Opcode := @Op9BX0;
   OpcodesM1X0[$9D].Opcode := @Op9DM1X0;
   OpcodesM1X0[$9E].Opcode := @Op9EM1X0;
   OpcodesM1X0[$A0].Opcode := @OpA0X0;
   OpcodesM1X0[$A2].Opcode := @OpA2X0;
   OpcodesM1X0[$A4].Opcode := @OpA4X0;
   OpcodesM1X0[$A6].Opcode := @OpA6X0;
   OpcodesM1X0[$A8].Opcode := @OpA8X0;
   OpcodesM1X0[$AA].Opcode := @OpAAX0;
   OpcodesM1X0[$AC].Opcode := @OpACX0;
   OpcodesM1X0[$AE].Opcode := @OpAEX0;
   OpcodesM1X0[$B4].Opcode := @OpB4E0X0;
   OpcodesM1X0[$B6].Opcode := @OpB6E0X0;
   OpcodesM1X0[$B9].Opcode := @OpB9M1X0;
   OpcodesM1X0[$BA].Opcode := @OpBAX0;
   OpcodesM1X0[$BB].Opcode := @OpBBX0;
   OpcodesM1X0[$BC].Opcode := @OpBCX0;
   OpcodesM1X0[$BD].Opcode := @OpBDM1X0;
   OpcodesM1X0[$BE].Opcode := @OpBEX0;
   OpcodesM1X0[$C0].Opcode := @OpC0X0;
   OpcodesM1X0[$C4].Opcode := @OpC4X0;
   OpcodesM1X0[$C8].Opcode := @OpC8X0;
   OpcodesM1X0[$CA].Opcode := @OpCAX0;
   OpcodesM1X0[$CC].Opcode := @OpCCX0;
   OpcodesM1X0[$D9].Opcode := @OpD9M1X0;
   OpcodesM1X0[$DA].Opcode := @OpDAE0X0;
   OpcodesM1X0[$DD].Opcode := @OpDDM1X0;
   OpcodesM1X0[$DE].Opcode := @OpDEM1X0;
   OpcodesM1X0[$E0].Opcode := @OpE0X0;
   OpcodesM1X0[$E4].Opcode := @OpE4X0;
   OpcodesM1X0[$E8].Opcode := @OpE8X0;
   OpcodesM1X0[$EC].Opcode := @OpECX0;
   OpcodesM1X0[$F9].Opcode := @OpF9M1X0;
   OpcodesM1X0[$FA].Opcode := @OpFAE0X0;
   OpcodesM1X0[$FD].Opcode := @OpFDM1X0;
   OpcodesM1X0[$FE].Opcode := @OpFEM1X0;

   // --- Tabela para M=0, X=0 ---
   OpcodesM0X0 := OpcodesM1X0;
   OpcodesM0X0[$01].Opcode := @Op01E0M0;
   OpcodesM0X0[$03].Opcode := @Op03M0;
   OpcodesM0X0[$04].Opcode := @Op04M0;
   OpcodesM0X0[$05].Opcode := @Op05M0;
   OpcodesM0X0[$06].Opcode := @Op06M0;
   OpcodesM0X0[$07].Opcode := @Op07M0;
   OpcodesM0X0[$09].Opcode := @Op09M0;
   OpcodesM0X0[$0A].Opcode := @Op0AM0;
   OpcodesM0X0[$0C].Opcode := @Op0CM0;
   OpcodesM0X0[$0D].Opcode := @Op0DM0;
   OpcodesM0X0[$0E].Opcode := @Op0EM0;
   OpcodesM0X0[$0F].Opcode := @Op0FM0;
   OpcodesM0X0[$11].Opcode := @Op11E0M0X0;
   OpcodesM0X0[$12].Opcode := @Op12E0M0;
   OpcodesM0X0[$13].Opcode := @Op13M0;
   OpcodesM0X0[$14].Opcode := @Op14M0;
   OpcodesM0X0[$15].Opcode := @Op15E0M0;
   OpcodesM0X0[$16].Opcode := @Op16E0M0;
   OpcodesM0X0[$17].Opcode := @Op17M0;
   OpcodesM0X0[$19].Opcode := @Op19M0X0;
   OpcodesM0X0[$1A].Opcode := @Op1AM0;
   OpcodesM0X0[$1C].Opcode := @Op1CM0;
   OpcodesM0X0[$1D].Opcode := @Op1DM0X0;
   OpcodesM0X0[$1E].Opcode := @Op1EM0X0;
   OpcodesM0X0[$1F].Opcode := @Op1FM0;
   OpcodesM0X0[$21].Opcode := @Op21E0M0;
   OpcodesM0X0[$23].Opcode := @Op23M0;
   OpcodesM0X0[$24].Opcode := @Op24M0;
   OpcodesM0X0[$25].Opcode := @Op25M0;
   OpcodesM0X0[$26].Opcode := @Op26M0;
   OpcodesM0X0[$27].Opcode := @Op27M0;
   OpcodesM0X0[$29].Opcode := @Op29M0;
   OpcodesM0X0[$2A].Opcode := @Op2AM0;
   OpcodesM0X0[$2C].Opcode := @Op2CM0;
   OpcodesM0X0[$2D].Opcode := @Op2DM0;
   OpcodesM0X0[$2E].Opcode := @Op2EM0;
   OpcodesM0X0[$2F].Opcode := @Op2FM0;
   OpcodesM0X0[$31].Opcode := @Op31E0M0X0;
   OpcodesM0X0[$32].Opcode := @Op32E0M0;
   OpcodesM0X0[$33].Opcode := @Op33M0;
   OpcodesM0X0[$34].Opcode := @Op34E0M0;
   OpcodesM0X0[$35].Opcode := @Op35E0M0;
   OpcodesM0X0[$36].Opcode := @Op36E0M0;
   OpcodesM0X0[$37].Opcode := @Op37M0;
   OpcodesM0X0[$39].Opcode := @Op39M0X0;
   OpcodesM0X0[$3A].Opcode := @Op3AM0;
   OpcodesM0X0[$3C].Opcode := @Op3CM0X0;
   OpcodesM0X0[$3D].Opcode := @Op3DM0X0;
   OpcodesM0X0[$3E].Opcode := @Op3EM0X0;
   OpcodesM0X0[$3F].Opcode := @Op3FM0;
   OpcodesM0X0[$41].Opcode := @Op41E0M0;
   OpcodesM0X0[$43].Opcode := @Op43M0;
   OpcodesM0X0[$45].Opcode := @Op45M0;
   OpcodesM0X0[$46].Opcode := @Op46M0;
   OpcodesM0X0[$47].Opcode := @Op47M0;
   OpcodesM0X0[$48].Opcode := @Op48E0M0;
   OpcodesM0X0[$49].Opcode := @Op49M0;
   OpcodesM0X0[$4A].Opcode := @Op4AM0;
   OpcodesM0X0[$4D].Opcode := @Op4DM0;
   OpcodesM0X0[$4E].Opcode := @Op4EM0;
   OpcodesM0X0[$4F].Opcode := @Op4FM0;
   OpcodesM0X0[$51].Opcode := @Op51E0M0X0;
   OpcodesM0X0[$52].Opcode := @Op52E0M0;
   OpcodesM0X0[$53].Opcode := @Op53M0;
   OpcodesM0X0[$55].Opcode := @Op55E0M0;
   OpcodesM0X0[$56].Opcode := @Op56E0M0;
   OpcodesM0X0[$57].Opcode := @Op57M0;
   OpcodesM0X0[$59].Opcode := @Op59M0X0;
   OpcodesM0X0[$5D].Opcode := @Op5DM0X0;
   OpcodesM0X0[$5E].Opcode := @Op5EM0X0;
   OpcodesM0X0[$5F].Opcode := @Op5FM0;
   OpcodesM0X0[$61].Opcode := @Op61E0M0;
   OpcodesM0X0[$63].Opcode := @Op63M0;
   OpcodesM0X0[$64].Opcode := @Op64M0;
   OpcodesM0X0[$65].Opcode := @Op65M0;
   OpcodesM0X0[$66].Opcode := @Op66M0;
   OpcodesM0X0[$67].Opcode := @Op67M0;
   OpcodesM0X0[$68].Opcode := @Op68E0M0;
   OpcodesM0X0[$69].Opcode := @Op69M0;
   OpcodesM0X0[$6A].Opcode := @Op6AM0;
   OpcodesM0X0[$6D].Opcode := @Op6DM0;
   OpcodesM0X0[$6E].Opcode := @Op6EM0;
   OpcodesM0X0[$6F].Opcode := @Op6FM0;
   OpcodesM0X0[$71].Opcode := @Op71E0M0X0;
   OpcodesM0X0[$72].Opcode := @Op72E0M0;
   OpcodesM0X0[$73].Opcode := @Op73M0;
   OpcodesM0X0[$74].Opcode := @Op74E0M0;
   OpcodesM0X0[$75].Opcode := @Op75E0M0;
   OpcodesM0X0[$76].Opcode := @Op76E0M0;
   OpcodesM0X0[$77].Opcode := @Op77M0;
   OpcodesM0X0[$79].Opcode := @Op79M0X0;
   OpcodesM0X0[$7D].Opcode := @Op7DM0X0;
   OpcodesM0X0[$7E].Opcode := @Op7EM0X0;
   OpcodesM0X0[$7F].Opcode := @Op7FM0;
   OpcodesM0X0[$81].Opcode := @Op81E0M0;
   OpcodesM0X0[$83].Opcode := @Op83M0;
   OpcodesM0X0[$85].Opcode := @Op85M0;
   OpcodesM0X0[$87].Opcode := @Op87M0;
   OpcodesM0X0[$89].Opcode := @Op89M0;
   OpcodesM0X0[$8A].Opcode := @Op8AM0;
   OpcodesM0X0[$8D].Opcode := @Op8DM0;
   OpcodesM0X0[$8F].Opcode := @Op8FM0;
   OpcodesM0X0[$91].Opcode := @Op91E0M0X0;
   OpcodesM0X0[$92].Opcode := @Op92E0M0;
   OpcodesM0X0[$93].Opcode := @Op93M0;
   OpcodesM0X0[$95].Opcode := @Op95E0M0;
   OpcodesM0X0[$97].Opcode := @Op97M0;
   OpcodesM0X0[$98].Opcode := @Op98M0;
   OpcodesM0X0[$99].Opcode := @Op99M0X0;
   OpcodesM0X0[$9C].Opcode := @Op9CM0;
   OpcodesM0X0[$9D].Opcode := @Op9DM0X0;
   OpcodesM0X0[$9E].Opcode := @Op9EM0X0;
   OpcodesM0X0[$9F].Opcode := @Op9FM0;
   OpcodesM0X0[$A1].Opcode := @OpA1E0M0;
   OpcodesM0X0[$A3].Opcode := @OpA3M0;
   OpcodesM0X0[$A5].Opcode := @OpA5M0;
   OpcodesM0X0[$A7].Opcode := @OpA7M0;
   OpcodesM0X0[$A9].Opcode := @OpA9M0;
   OpcodesM0X0[$AD].Opcode := @OpADM0;
   OpcodesM0X0[$AF].Opcode := @OpAFM0;
   OpcodesM0X0[$B1].Opcode := @OpB1E0M0X0;
   OpcodesM0X0[$B2].Opcode := @OpB2E0M0;
   OpcodesM0X0[$B3].Opcode := @OpB3M0;
   OpcodesM0X0[$B5].Opcode := @OpB5E0M0;
   OpcodesM0X0[$B7].Opcode := @OpB7M0;
   OpcodesM0X0[$B9].Opcode := @OpB9M0X0;
   OpcodesM0X0[$BD].Opcode := @OpBDM0X0;
   OpcodesM0X0[$BF].Opcode := @OpBFM0;
   OpcodesM0X0[$C1].Opcode := @OpC1E0M0;
   OpcodesM0X0[$C3].Opcode := @OpC3M0;
   OpcodesM0X0[$C5].Opcode := @OpC5M0;
   OpcodesM0X0[$C6].Opcode := @OpC6M0;
   OpcodesM0X0[$C7].Opcode := @OpC7M0;
   OpcodesM0X0[$C9].Opcode := @OpC9M0;
   OpcodesM0X0[$CD].Opcode := @OpCDM0;
   OpcodesM0X0[$CE].Opcode := @OpCEM0;
   OpcodesM0X0[$CF].Opcode := @OpCFM0;
   OpcodesM0X0[$D1].Opcode := @OpD1E0M0X0;
   OpcodesM0X0[$D2].Opcode := @OpD2E0M0;
   OpcodesM0X0[$D3].Opcode := @OpD3M0;
   OpcodesM0X0[$D5].Opcode := @OpD5E0M0;
   OpcodesM0X0[$D6].Opcode := @OpD6E0M0;
   OpcodesM0X0[$D7].Opcode := @OpD7M0;
   OpcodesM0X0[$D9].Opcode := @OpD9M0X0;
   OpcodesM0X0[$DD].Opcode := @OpDDM0X0;
   OpcodesM0X0[$DE].Opcode := @OpDEM0X0;
   OpcodesM0X0[$DF].Opcode := @OpDFM0;
   OpcodesM0X0[$E1].Opcode := @OpE1E0M0;
   OpcodesM0X0[$E3].Opcode := @OpE3M0;
   OpcodesM0X0[$E5].Opcode := @OpE5M0;
   OpcodesM0X0[$E6].Opcode := @OpE6M0;
   OpcodesM0X0[$E7].Opcode := @OpE7M0;
   OpcodesM0X0[$E9].Opcode := @OpE9M0;
   OpcodesM0X0[$ED].Opcode := @OpEDM0;
   OpcodesM0X0[$EE].Opcode := @OpEEM0;
   OpcodesM0X0[$EF].Opcode := @OpEFM0;
   OpcodesM0X0[$F1].Opcode := @OpF1E0M0X0;
   OpcodesM0X0[$F2].Opcode := @OpF2E0M0;
   OpcodesM0X0[$F3].Opcode := @OpF3M0;
   OpcodesM0X0[$F5].Opcode := @OpF5E0M0;
   OpcodesM0X0[$F6].Opcode := @OpF6E0M0;
   OpcodesM0X0[$F7].Opcode := @OpF7M0;
   OpcodesM0X0[$F9].Opcode := @OpF9M0X0;
   OpcodesM0X0[$FD].Opcode := @OpFDM0X0;
   OpcodesM0X0[$FE].Opcode := @OpFEM0X0;
   OpcodesM0X0[$FF].Opcode := @OpFFM0;

   // --- Tabela para M=0, X=1 ---
   OpcodesM0X1 := OpcodesM0X0;
   OpcodesM0X1[$11].Opcode := @Op11E0M0X1;
   OpcodesM0X1[$19].Opcode := @Op19M0X1;
   OpcodesM0X1[$1D].Opcode := @Op1DM0X1;
   OpcodesM0X1[$1E].Opcode := @Op1EM0X1;
   OpcodesM0X1[$31].Opcode := @Op31E0M0X1;
   OpcodesM0X1[$39].Opcode := @Op39M0X1;
   OpcodesM0X1[$3C].Opcode := @Op3CM0X1;
   OpcodesM0X1[$3D].Opcode := @Op3DM0X1;
   OpcodesM0X1[$3E].Opcode := @Op3EM0X1;
   OpcodesM0X1[$51].Opcode := @Op51E0M0X1;
   OpcodesM0X1[$59].Opcode := @Op59M0X1;
   OpcodesM0X1[$5D].Opcode := @Op5DM0X1;
   OpcodesM0X1[$5E].Opcode := @Op5EM0X1;
   OpcodesM0X1[$71].Opcode := @Op71E0M0X1;
   OpcodesM0X1[$79].Opcode := @Op79M0X1;
   OpcodesM0X1[$7D].Opcode := @Op7DM0X1;
   OpcodesM0X1[$7E].Opcode := @Op7EM0X1;
   OpcodesM0X1[$91].Opcode := @Op91E0M0X1;
   OpcodesM0X1[$99].Opcode := @Op99M0X1;
   OpcodesM0X1[$9D].Opcode := @Op9DM0X1;
   OpcodesM0X1[$9E].Opcode := @Op9EM0X1;
   OpcodesM0X1[$B1].Opcode := @OpB1E0M0X1;
   OpcodesM0X1[$B9].Opcode := @OpB9M0X1;
   OpcodesM0X1[$BD].Opcode := @OpBDM0X1;
   OpcodesM0X1[$D1].Opcode := @OpD1E0M0X1;
   OpcodesM0X1[$D9].Opcode := @OpD9M0X1;
   OpcodesM0X1[$DD].Opcode := @OpDDM0X1;
   OpcodesM0X1[$DE].Opcode := @OpDEM0X1;
   OpcodesM0X1[$F1].Opcode := @OpF1E0M0X1;
   OpcodesM0X1[$F9].Opcode := @OpF9M0X1;
   OpcodesM0X1[$FD].Opcode := @OpFDM0X1;
   OpcodesM0X1[$FE].Opcode := @OpFEM0X1;

   // --- Tabela para Acesso Lento ---
   OpcodesSlow := OpcodesM0X0;
   for i := 0 to 255 do
      OpcodesSlow[i].Opcode := @Op40Slow;
   OpcodesSlow[$01].Opcode := @Op01Slow;
   OpcodesSlow[$03].Opcode := @Op03Slow;
   OpcodesSlow[$04].Opcode := @Op04Slow;
   OpcodesSlow[$05].Opcode := @Op05Slow;
   OpcodesSlow[$06].Opcode := @Op06Slow;
   OpcodesSlow[$07].Opcode := @Op07Slow;
   OpcodesSlow[$08].Opcode := @Op08Slow;
   OpcodesSlow[$09].Opcode := @Op09Slow;
   OpcodesSlow[$0A].Opcode := @Op0ASlow;
   OpcodesSlow[$0B].Opcode := @Op0BSlow;
   OpcodesSlow[$0C].Opcode := @Op0CSlow;
   OpcodesSlow[$0D].Opcode := @Op0DSlow;
   OpcodesSlow[$0E].Opcode := @Op0ESlow;
   OpcodesSlow[$0F].Opcode := @Op0FSlow;
   OpcodesSlow[$10].Opcode := @Op10Slow;
   OpcodesSlow[$11].Opcode := @Op11Slow;
   OpcodesSlow[$12].Opcode := @Op12Slow;
   OpcodesSlow[$13].Opcode := @Op13Slow;
   OpcodesSlow[$14].Opcode := @Op14Slow;
   OpcodesSlow[$15].Opcode := @Op15Slow;
   OpcodesSlow[$16].Opcode := @Op16Slow;
   OpcodesSlow[$17].Opcode := @Op17Slow;
   OpcodesSlow[$18].Opcode := @Op18;
   OpcodesSlow[$19].Opcode := @Op19Slow;
   OpcodesSlow[$1A].Opcode := @Op1ASlow;
   OpcodesSlow[$1B].Opcode := @Op1B;
   OpcodesSlow[$1C].Opcode := @Op1CSlow;
   OpcodesSlow[$1D].Opcode := @Op1DSlow;
   OpcodesSlow[$1E].Opcode := @Op1ESlow;
   OpcodesSlow[$1F].Opcode := @Op1FSlow;
   OpcodesSlow[$20].Opcode := @Op20Slow;
   OpcodesSlow[$21].Opcode := @Op21Slow;
   OpcodesSlow[$22].Opcode := @Op22Slow;
   OpcodesSlow[$23].Opcode := @Op23Slow;
   OpcodesSlow[$24].Opcode := @Op24Slow;
   OpcodesSlow[$25].Opcode := @Op25Slow;
   OpcodesSlow[$26].Opcode := @Op26Slow;
   OpcodesSlow[$27].Opcode := @Op27Slow;
   OpcodesSlow[$28].Opcode := @Op28Slow;
   OpcodesSlow[$29].Opcode := @Op29Slow;
   OpcodesSlow[$2A].Opcode := @Op2ASlow;
   OpcodesSlow[$2B].Opcode := @Op2BSlow;
   OpcodesSlow[$2C].Opcode := @Op2CSlow;
   OpcodesSlow[$2D].Opcode := @Op2DSlow;
   OpcodesSlow[$2E].Opcode := @Op2ESlow;
   OpcodesSlow[$2F].Opcode := @Op2FSlow;
   OpcodesSlow[$30].Opcode := @Op30Slow;
   OpcodesSlow[$31].Opcode := @Op31Slow;
   OpcodesSlow[$32].Opcode := @Op32Slow;
   OpcodesSlow[$33].Opcode := @Op33Slow;
   OpcodesSlow[$34].Opcode := @Op34Slow;
   OpcodesSlow[$35].Opcode := @Op35Slow;
   OpcodesSlow[$36].Opcode := @Op36Slow;
   OpcodesSlow[$37].Opcode := @Op37Slow;
   OpcodesSlow[$38].Opcode := @Op38;
   OpcodesSlow[$39].Opcode := @Op39Slow;
   OpcodesSlow[$3A].Opcode := @Op3ASlow;
   OpcodesSlow[$3B].Opcode := @Op3B;
   OpcodesSlow[$3C].Opcode := @Op3CSlow;
   OpcodesSlow[$3D].Opcode := @Op3DSlow;
   OpcodesSlow[$3E].Opcode := @Op3ESlow;
   OpcodesSlow[$3F].Opcode := @Op3FSlow;
   OpcodesSlow[$41].Opcode := @Op41Slow;
   OpcodesSlow[$42].Opcode := @Op42;
   OpcodesSlow[$43].Opcode := @Op43Slow;
   OpcodesSlow[$44].Opcode := @Op44Slow;
   OpcodesSlow[$45].Opcode := @Op45Slow;
   OpcodesSlow[$46].Opcode := @Op46Slow;
   OpcodesSlow[$47].Opcode := @Op47Slow;
   OpcodesSlow[$48].Opcode := @Op48Slow;
   OpcodesSlow[$49].Opcode := @Op49Slow;
   OpcodesSlow[$4A].Opcode := @Op4ASlow;
   OpcodesSlow[$4B].Opcode := @Op4BSlow;
   OpcodesSlow[$4C].Opcode := @Op4CSlow;
   OpcodesSlow[$4D].Opcode := @Op4DSlow;
   OpcodesSlow[$4E].Opcode := @Op4ESlow;
   OpcodesSlow[$4F].Opcode := @Op4FSlow;
   OpcodesSlow[$50].Opcode := @Op50Slow;
   OpcodesSlow[$51].Opcode := @Op51Slow;
   OpcodesSlow[$52].Opcode := @Op52Slow;
   OpcodesSlow[$53].Opcode := @Op53Slow;
   OpcodesSlow[$54].Opcode := @Op54Slow;
   OpcodesSlow[$55].Opcode := @Op55Slow;
   OpcodesSlow[$56].Opcode := @Op56Slow;
   OpcodesSlow[$57].Opcode := @Op57Slow;
   OpcodesSlow[$58].Opcode := @Op58;
   OpcodesSlow[$59].Opcode := @Op59Slow;
   OpcodesSlow[$5A].Opcode := @Op5ASlow;
   OpcodesSlow[$5B].Opcode := @Op5B;
   OpcodesSlow[$5C].Opcode := @Op5CSlow;
   OpcodesSlow[$5D].Opcode := @Op5DSlow;
   OpcodesSlow[$5E].Opcode := @Op5ESlow;
   OpcodesSlow[$5F].Opcode := @Op5FSlow;
   OpcodesSlow[$60].Opcode := @Op60Slow;
   OpcodesSlow[$61].Opcode := @Op61Slow;
   OpcodesSlow[$62].Opcode := @Op62Slow;
   OpcodesSlow[$63].Opcode := @Op63Slow;
   OpcodesSlow[$64].Opcode := @Op64Slow;
   OpcodesSlow[$65].Opcode := @Op65Slow;
   OpcodesSlow[$66].Opcode := @Op66Slow;
   OpcodesSlow[$67].Opcode := @Op67Slow;
   OpcodesSlow[$68].Opcode := @Op68Slow;
   OpcodesSlow[$69].Opcode := @Op69Slow;
   OpcodesSlow[$6A].Opcode := @Op6ASlow;
   OpcodesSlow[$6B].Opcode := @Op6BSlow;
   OpcodesSlow[$6C].Opcode := @Op6CSlow;
   OpcodesSlow[$6D].Opcode := @Op6DSlow;
   OpcodesSlow[$6E].Opcode := @Op6ESlow;
   OpcodesSlow[$6F].Opcode := @Op6FSlow;
   OpcodesSlow[$70].Opcode := @Op70Slow;
   OpcodesSlow[$71].Opcode := @Op71Slow;
   OpcodesSlow[$72].Opcode := @Op72Slow;
   OpcodesSlow[$73].Opcode := @Op73Slow;
   OpcodesSlow[$74].Opcode := @Op74Slow;
   OpcodesSlow[$75].Opcode := @Op75Slow;
   OpcodesSlow[$76].Opcode := @Op76Slow;
   OpcodesSlow[$77].Opcode := @Op77Slow;
   OpcodesSlow[$78].Opcode := @Op78;
   OpcodesSlow[$79].Opcode := @Op79Slow;
   OpcodesSlow[$7A].Opcode := @Op7ASlow;
   OpcodesSlow[$7B].Opcode := @Op7B;
   OpcodesSlow[$7C].Opcode := @Op7CSlow;
   OpcodesSlow[$7D].Opcode := @Op7DSlow;
   OpcodesSlow[$7E].Opcode := @Op7ESlow;
   OpcodesSlow[$7F].Opcode := @Op7FSlow;
   OpcodesSlow[$80].Opcode := @Op80Slow;
   OpcodesSlow[$81].Opcode := @Op81Slow;
   OpcodesSlow[$82].Opcode := @Op82Slow;
   OpcodesSlow[$83].Opcode := @Op83Slow;
   OpcodesSlow[$84].Opcode := @Op84Slow;
   OpcodesSlow[$85].Opcode := @Op85Slow;
   OpcodesSlow[$86].Opcode := @Op86Slow;
   OpcodesSlow[$87].Opcode := @Op87Slow;
   OpcodesSlow[$88].Opcode := @Op88Slow;
   OpcodesSlow[$89].Opcode := @Op89Slow;
   OpcodesSlow[$8A].Opcode := @Op8ASlow;
   OpcodesSlow[$8B].Opcode := @Op8BSlow;
   OpcodesSlow[$8C].Opcode := @Op8CSlow;
   OpcodesSlow[$8D].Opcode := @Op8DSlow;
   OpcodesSlow[$8E].Opcode := @Op8ESlow;
   OpcodesSlow[$8F].Opcode := @Op8FSlow;
   OpcodesSlow[$90].Opcode := @Op90Slow;
   OpcodesSlow[$91].Opcode := @Op91Slow;
   OpcodesSlow[$92].Opcode := @Op92Slow;
   OpcodesSlow[$93].Opcode := @Op93Slow;
   OpcodesSlow[$94].Opcode := @Op94Slow;
   OpcodesSlow[$95].Opcode := @Op95Slow;
   OpcodesSlow[$96].Opcode := @Op96Slow;
   OpcodesSlow[$97].Opcode := @Op97Slow;
   OpcodesSlow[$98].Opcode := @Op98Slow;
   OpcodesSlow[$99].Opcode := @Op99Slow;
   OpcodesSlow[$9A].Opcode := @Op9A;
   OpcodesSlow[$9B].Opcode := @Op9BSlow;
   OpcodesSlow[$9C].Opcode := @Op9CSlow;
   OpcodesSlow[$9D].Opcode := @Op9DSlow;
   OpcodesSlow[$9E].Opcode := @Op9ESlow;
   OpcodesSlow[$9F].Opcode := @Op9FSlow;
   OpcodesSlow[$A0].Opcode := @OpA0Slow;
   OpcodesSlow[$A1].Opcode := @OpA1Slow;
   OpcodesSlow[$A2].Opcode := @OpA2Slow;
   OpcodesSlow[$A3].Opcode := @OpA3Slow;
   OpcodesSlow[$A4].Opcode := @OpA4Slow;
   OpcodesSlow[$A5].Opcode := @OpA5Slow;
   OpcodesSlow[$A6].Opcode := @OpA6Slow;
   OpcodesSlow[$A7].Opcode := @OpA7Slow;
   OpcodesSlow[$A8].Opcode := @OpA8Slow;
   OpcodesSlow[$A9].Opcode := @OpA9Slow;
   OpcodesSlow[$AA].Opcode := @OpAASlow;
   OpcodesSlow[$AB].Opcode := @OpABSlow;
   OpcodesSlow[$AC].Opcode := @OpACSlow;
   OpcodesSlow[$AD].Opcode := @OpADSlow;
   OpcodesSlow[$AE].Opcode := @OpAESlow;
   OpcodesSlow[$AF].Opcode := @OpAFSlow;
   OpcodesSlow[$B0].Opcode := @OpB0Slow;
   OpcodesSlow[$B1].Opcode := @OpB1Slow;
   OpcodesSlow[$B2].Opcode := @OpB2Slow;
   OpcodesSlow[$B3].Opcode := @OpB3Slow;
   OpcodesSlow[$B4].Opcode := @OpB4Slow;
   OpcodesSlow[$B5].Opcode := @OpB5Slow;
   OpcodesSlow[$B6].Opcode := @OpB6Slow;
   OpcodesSlow[$B7].Opcode := @OpB7Slow;
   OpcodesSlow[$B8].Opcode := @OpB8;
   OpcodesSlow[$B9].Opcode := @OpB9Slow;
   OpcodesSlow[$BA].Opcode := @OpBASlow;
   OpcodesSlow[$BB].Opcode := @OpBBSlow;
   OpcodesSlow[$BC].Opcode := @OpBCSlow;
   OpcodesSlow[$BD].Opcode := @OpBDSlow;
   OpcodesSlow[$BE].Opcode := @OpBESlow;
   OpcodesSlow[$BF].Opcode := @OpBFSlow;
   OpcodesSlow[$C0].Opcode := @OpC0Slow;
   OpcodesSlow[$C1].Opcode := @OpC1Slow;
   OpcodesSlow[$C2].Opcode := @OpC2Slow;
   OpcodesSlow[$C3].Opcode := @OpC3Slow;
   OpcodesSlow[$C4].Opcode := @OpC4Slow;
   OpcodesSlow[$C5].Opcode := @OpC5Slow;
   OpcodesSlow[$C6].Opcode := @OpC6Slow;
   OpcodesSlow[$C7].Opcode := @OpC7Slow;
   OpcodesSlow[$C8].Opcode := @OpC8Slow;
   OpcodesSlow[$C9].Opcode := @OpC9Slow;
   OpcodesSlow[$CA].Opcode := @OpCASlow;
   OpcodesSlow[$CB].Opcode := @OpCB;
   OpcodesSlow[$CC].Opcode := @OpCCSlow;
   OpcodesSlow[$CD].Opcode := @OpCDSlow;
   OpcodesSlow[$CE].Opcode := @OpCESlow;
   OpcodesSlow[$CF].Opcode := @OpCFSlow;
   OpcodesSlow[$D0].Opcode := @OpD0Slow;
   OpcodesSlow[$D1].Opcode := @OpD1Slow;
   OpcodesSlow[$D2].Opcode := @OpD2Slow;
   OpcodesSlow[$D3].Opcode := @OpD3Slow;
   OpcodesSlow[$D4].Opcode := @OpD4Slow;
   OpcodesSlow[$D5].Opcode := @OpD5Slow;
   OpcodesSlow[$D6].Opcode := @OpD6Slow;
   OpcodesSlow[$D7].Opcode := @OpD7Slow;
   OpcodesSlow[$D8].Opcode := @OpD8;
   OpcodesSlow[$D9].Opcode := @OpD9Slow;
   OpcodesSlow[$DA].Opcode := @OpDASlow;
   OpcodesSlow[$DB].Opcode := @OpDB;
   OpcodesSlow[$DC].Opcode := @OpDCSlow;
   OpcodesSlow[$DD].Opcode := @OpDDSlow;
   OpcodesSlow[$DE].Opcode := @OpDESlow;
   OpcodesSlow[$DF].Opcode := @OpDFSlow;
   OpcodesSlow[$E0].Opcode := @OpE0Slow;
   OpcodesSlow[$E1].Opcode := @OpE1Slow;
   OpcodesSlow[$E2].Opcode := @OpE2Slow;
   OpcodesSlow[$E3].Opcode := @OpE3Slow;
   OpcodesSlow[$E4].Opcode := @OpE4Slow;
   OpcodesSlow[$E5].Opcode := @OpE5Slow;
   OpcodesSlow[$E6].Opcode := @OpE6Slow;
   OpcodesSlow[$E7].Opcode := @OpE7Slow;
   OpcodesSlow[$E8].Opcode := @OpE8Slow;
   OpcodesSlow[$E9].Opcode := @OpE9Slow;
   OpcodesSlow[$EA].Opcode := @OpEA;
   OpcodesSlow[$EB].Opcode := @OpEB;
   OpcodesSlow[$EC].Opcode := @OpECSlow;
   OpcodesSlow[$ED].Opcode := @OpEDSlow;
   OpcodesSlow[$EE].Opcode := @OpEESlow;
   OpcodesSlow[$EF].Opcode := @OpEFSlow;
   OpcodesSlow[$F0].Opcode := @OpF0Slow;
   OpcodesSlow[$F1].Opcode := @OpF1Slow;
   OpcodesSlow[$F2].Opcode := @OpF2Slow;
   OpcodesSlow[$F3].Opcode := @OpF3Slow;
   OpcodesSlow[$F4].Opcode := @OpF4Slow;
   OpcodesSlow[$F5].Opcode := @OpF5Slow;
   OpcodesSlow[$F6].Opcode := @OpF6Slow;
   OpcodesSlow[$F7].Opcode := @OpF7Slow;
   OpcodesSlow[$F8].Opcode := @OpF8;
   OpcodesSlow[$F9].Opcode := @OpF9Slow;
   OpcodesSlow[$FA].Opcode := @OpFASlow;
   OpcodesSlow[$FB].Opcode := @OpFB;
   OpcodesSlow[$FC].Opcode := @OpFCSlow;
   OpcodesSlow[$FD].Opcode := @OpFDSlow;
   OpcodesSlow[$FE].Opcode := @OpFESlow;
   OpcodesSlow[$FF].Opcode := @OpFFSlow;
end;

// Declaração de todos os procedures para que o compilador os conheça
// Esta seção é necessária para que os ponteiros de procedimento possam ser atribuídos.


const
   // Porte das tabelas de `globals.c`
   OpLengthsM1X1_Data: array[0..255] of Byte = (
      2, 2, 2, 2, 2, 2, 2, 2, 1, 2, 1, 1, 3, 3, 3, 4,
      2, 2, 2, 2, 2, 2, 2, 2, 1, 3, 1, 1, 3, 3, 3, 4,
      3, 2, 4, 2, 2, 2, 2, 2, 1, 2, 1, 1, 3, 3, 3, 4,
      2, 2, 2, 2, 2, 2, 2, 2, 1, 3, 1, 1, 3, 3, 3, 4,
      1, 2, 2, 2, 3, 2, 2, 2, 1, 2, 1, 1, 3, 3, 3, 4,
      2, 2, 2, 2, 3, 2, 2, 2, 1, 3, 1, 1, 4, 3, 3, 4,
      1, 2, 3, 2, 2, 2, 2, 2, 1, 2, 1, 1, 3, 3, 3, 4,
      2, 2, 2, 2, 2, 2, 2, 2, 1, 3, 1, 1, 3, 3, 3, 4,
      2, 2, 3, 2, 2, 2, 2, 2, 1, 2, 1, 1, 3, 3, 3, 4,
      2, 2, 2, 2, 2, 2, 2, 2, 1, 3, 1, 1, 3, 3, 3, 4,
      2, 2, 2, 2, 2, 2, 2, 2, 1, 2, 1, 1, 3, 3, 3, 4,
      2, 2, 2, 2, 2, 2, 2, 2, 1, 3, 1, 1, 3, 3, 3, 4,
      2, 2, 2, 2, 2, 2, 2, 2, 1, 2, 1, 1, 3, 3, 3, 4,
      2, 2, 2, 2, 2, 2, 2, 2, 1, 3, 1, 1, 3, 3, 3, 4,
      2, 2, 2, 2, 2, 2, 2, 2, 1, 2, 1, 1, 3, 3, 3, 4,
      2, 2, 2, 2, 3, 2, 2, 2, 1, 3, 1, 1, 3, 3, 3, 4);

   OpLengthsM0X0_Data: array[0..255] of Byte = (
      {      0, 1, 2, 3, 4, 5, 6, 7, 8, 9, a, b, c, d, e, f }
      { 00 } 2, 2, 2, 2, 2, 2, 2, 2, 1, 3, 1, 1, 3, 3, 3, 4,
      { 10 } 2, 2, 2, 2, 2, 2, 2, 2, 1, 3, 1, 1, 3, 3, 3, 4,
      { 20 } 3, 2, 4, 2, 2, 2, 2, 2, 1, 3, 1, 1, 3, 3, 3, 4,
      { 30 } 2, 2, 2, 2, 2, 2, 2, 2, 1, 3, 1, 1, 3, 3, 3, 4,
      { 40 } 1, 2, 2, 2, 3, 2, 2, 2, 1, 3, 1, 1, 3, 3, 3, 4,
      { 50 } 2, 2, 2, 2, 3, 2, 2, 2, 1, 3, 1, 1, 4, 3, 3, 4,
      { 60 } 1, 2, 3, 2, 2, 2, 2, 2, 1, 3, 1, 1, 3, 3, 3, 4,
      { 70 } 2, 2, 2, 2, 2, 2, 2, 2, 1, 3, 1, 1, 3, 3, 3, 4,
      { 80 } 2, 2, 3, 2, 2, 2, 2, 2, 1, 3, 1, 1, 3, 3, 3, 4,
      { 90 } 2, 2, 2, 2, 2, 2, 2, 2, 1, 3, 1, 1, 3, 3, 3, 4,
      { a0 } 3, 2, 3, 2, 2, 2, 2, 2, 1, 3, 1, 1, 3, 3, 3, 4,
      { b0 } 2, 2, 2, 2, 2, 2, 2, 2, 1, 3, 1, 1, 3, 3, 3, 4,
      { c0 } 3, 2, 2, 2, 2, 2, 2, 2, 1, 3, 1, 1, 3, 3, 3, 4,
      { d0 } 2, 2, 2, 2, 2, 2, 2, 2, 1, 3, 1, 1, 3, 3, 3, 4,
      { e0 } 3, 2, 2, 2, 2, 2, 2, 2, 1, 3, 1, 1, 3, 3, 3, 4,
      { f0 } 2, 2, 2, 2, 3, 2, 2, 2, 1, 3, 1, 1, 3, 3, 3, 4);

   OpLengthsM0X1_Data: array[0..255] of Byte = (
      {      0, 1, 2, 3, 4, 5, 6, 7, 8, 9, a, b, c, d, e, f }
      { 00 } 2, 2, 2, 2, 2, 2, 2, 2, 1, 3, 1, 1, 3, 3, 3, 4,
      { 10 } 2, 2, 2, 2, 2, 2, 2, 2, 1, 3, 1, 1, 3, 3, 3, 4,
      { 20 } 3, 2, 4, 2, 2, 2, 2, 2, 1, 3, 1, 1, 3, 3, 3, 4,
      { 30 } 2, 2, 2, 2, 2, 2, 2, 2, 1, 3, 1, 1, 3, 3, 3, 4,
      { 40 } 1, 2, 2, 2, 3, 2, 2, 2, 1, 3, 1, 1, 3, 3, 3, 4,
      { 50 } 2, 2, 2, 2, 3, 2, 2, 2, 1, 3, 1, 1, 4, 3, 3, 4,
      { 60 } 1, 2, 3, 2, 2, 2, 2, 2, 1, 3, 1, 1, 3, 3, 3, 4,
      { 70 } 2, 2, 2, 2, 2, 2, 2, 2, 1, 3, 1, 1, 3, 3, 3, 4,
      { 80 } 2, 2, 3, 2, 2, 2, 2, 2, 1, 3, 1, 1, 3, 3, 3, 4,
      { 90 } 2, 2, 2, 2, 2, 2, 2, 2, 1, 3, 1, 1, 3, 3, 3, 4,
      { a0 } 2, 2, 2, 2, 2, 2, 2, 2, 1, 3, 1, 1, 3, 3, 3, 4,
      { b0 } 2, 2, 2, 2, 2, 2, 2, 2, 1, 3, 1, 1, 3, 3, 3, 4,
      { c0 } 2, 2, 2, 2, 2, 2, 2, 2, 1, 3, 1, 1, 3, 3, 3, 4,
      { d0 } 2, 2, 2, 2, 2, 2, 2, 2, 1, 3, 1, 1, 3, 3, 3, 4,
      { e0 } 2, 2, 2, 2, 2, 2, 2, 2, 1, 3, 1, 1, 3, 3, 3, 4,
      { f0 } 2, 2, 2, 2, 3, 2, 2, 2, 1, 3, 1, 1, 3, 3, 3, 4);

   OpLengthsM1X0_Data: array[0..255] of Byte = (
      {      0, 1, 2, 3, 4, 5, 6, 7, 8, 9, a, b, c, d, e, f }
      { 00 } 2, 2, 2, 2, 2, 2, 2, 2, 1, 2, 1, 1, 3, 3, 3, 4,
      { 10 } 2, 2, 2, 2, 2, 2, 2, 2, 1, 3, 1, 1, 3, 3, 3, 4,
      { 20 } 3, 2, 4, 2, 2, 2, 2, 2, 1, 2, 1, 1, 3, 3, 3, 4,
      { 30 } 2, 2, 2, 2, 2, 2, 2, 2, 1, 3, 1, 1, 3, 3, 3, 4,
      { 40 } 1, 2, 2, 2, 3, 2, 2, 2, 1, 2, 1, 1, 3, 3, 3, 4,
      { 50 } 2, 2, 2, 2, 3, 2, 2, 2, 1, 3, 1, 1, 4, 3, 3, 4,
      { 60 } 1, 2, 3, 2, 2, 2, 2, 2, 1, 2, 1, 1, 3, 3, 3, 4,
      { 70 } 2, 2, 2, 2, 2, 2, 2, 2, 1, 3, 1, 1, 3, 3, 3, 4,
      { 80 } 2, 2, 3, 2, 2, 2, 2, 2, 1, 2, 1, 1, 3, 3, 3, 4,
      { 90 } 2, 2, 2, 2, 2, 2, 2, 2, 1, 3, 1, 1, 3, 3, 3, 4,
      { a0 } 3, 2, 3, 2, 2, 2, 2, 2, 1, 2, 1, 1, 3, 3, 3, 4,
      { b0 } 2, 2, 2, 2, 2, 2, 2, 2, 1, 3, 1, 1, 3, 3, 3, 4,
      { c0 } 3, 2, 2, 2, 2, 2, 2, 2, 1, 2, 1, 1, 3, 3, 3, 4,
      { d0 } 2, 2, 2, 2, 2, 2, 2, 2, 1, 3, 1, 1, 3, 3, 3, 4,
      { e0 } 3, 2, 2, 2, 2, 2, 2, 2, 1, 2, 1, 1, 3, 3, 3, 4,
      { f0 } 2, 2, 2, 2, 3, 2, 2, 2, 1, 3, 1, 1, 3, 3, 3, 4);


   APUCycleLengths_Data: array[0..255] of Byte = (
      {      0, 1, 2, 3, 4, 5, 6, 7, 8, 9, a, b, c, d, e,  f }
      { 00 } 2, 8, 4, 5, 3, 4, 3, 6, 2, 6, 5, 4, 5, 4, 6,  8,
      { 10 } 2, 8, 4, 5, 4, 5, 5, 6, 5, 5, 6, 5, 2, 2, 4,  6,
      { 20 } 2, 8, 4, 5, 3, 4, 3, 6, 2, 6, 5, 4, 5, 4, 5,  4,
      { 30 } 2, 8, 4, 5, 4, 5, 5, 6, 5, 5, 6, 5, 2, 2, 3,  8,
      { 40 } 2, 8, 4, 5, 3, 4, 3, 6, 2, 6, 4, 4, 5, 4, 6,  6,
      { 50 } 2, 8, 4, 5, 4, 5, 5, 6, 5, 5, 4, 5, 2, 2, 4,  3,
      { 60 } 2, 8, 4, 5, 3, 4, 3, 6, 2, 6, 4, 4, 5, 4, 5,  5,
      { 70 } 2, 8, 4, 5, 4, 5, 5, 6, 5, 5, 5, 5, 2, 2, 3,  6,
      { 80 } 2, 8, 4, 5, 3, 4, 3, 6, 2, 6, 5, 4, 5, 2, 4,  5,
      { 90 } 2, 8, 4, 5, 4, 5, 5, 6, 5, 5, 5, 5, 2, 2, 12, 5,
      { a0 } 3, 8, 4, 5, 3, 4, 3, 6, 2, 6, 4, 4, 5, 2, 4,  4,
      { b0 } 2, 8, 4, 5, 4, 5, 5, 6, 5, 5, 5, 5, 2, 2, 3,  4,
      { c0 } 3, 8, 4, 5, 4, 5, 4, 7, 2, 5, 6, 4, 5, 2, 4,  9,
      { d0 } 2, 8, 4, 5, 5, 6, 6, 7, 4, 5, 4, 5, 2, 2, 6,  3,
      { e0 } 2, 8, 4, 5, 3, 4, 3, 6, 2, 4, 5, 3, 4, 3, 4,  3,
      { f0 } 2, 8, 4, 5, 4, 5, 5, 6, 3, 4, 5, 4, 2, 2, 4,  3);

   APUCycles_Data: array[0..255] of Byte = (
      {      0, 1, 2, 3, 4, 5, 6, 7, 8, 9, a, b, c, d, e,  f }
      { 00 } 2, 8, 4, 5, 3, 4, 3, 6, 2, 6, 5, 4, 5, 4, 6,  8,
      { 10 } 2, 8, 4, 5, 4, 5, 5, 6, 5, 5, 6, 5, 2, 2, 4,  6,
      { 20 } 2, 8, 4, 5, 3, 4, 3, 6, 2, 6, 5, 4, 5, 4, 5,  4,
      { 30 } 2, 8, 4, 5, 4, 5, 5, 6, 5, 5, 6, 5, 2, 2, 3,  8,
      { 40 } 2, 8, 4, 5, 3, 4, 3, 6, 2, 6, 4, 4, 5, 4, 6,  6,
      { 50 } 2, 8, 4, 5, 4, 5, 5, 6, 5, 5, 4, 5, 2, 2, 4,  3,
      { 60 } 2, 8, 4, 5, 3, 4, 3, 6, 2, 6, 4, 4, 5, 4, 5,  5,
      { 70 } 2, 8, 4, 5, 4, 5, 5, 6, 5, 5, 5, 5, 2, 2, 3,  6,
      { 80 } 2, 8, 4, 5, 3, 4, 3, 6, 2, 6, 5, 4, 5, 2, 4,  5,
      { 90 } 2, 8, 4, 5, 4, 5, 5, 6, 5, 5, 5, 5, 2, 2, 12, 5,
      { a0 } 3, 8, 4, 5, 3, 4, 3, 6, 2, 6, 4, 4, 5, 2, 4,  4,
      { b0 } 2, 8, 4, 5, 4, 5, 5, 6, 5, 5, 5, 5, 2, 2, 3,  4,
      { c0 } 3, 8, 4, 5, 4, 5, 4, 7, 2, 5, 6, 4, 5, 2, 4,  9,
      { d0 } 2, 8, 4, 5, 5, 6, 6, 7, 4, 5, 4, 5, 2, 2, 6,  3,
      { e0 } 2, 8, 4, 5, 3, 4, 3, 6, 2, 4, 5, 3, 4, 3, 4,  3,
      { f0 } 2, 8, 4, 5, 4, 5, 5, 6, 3, 4, 5, 4, 2, 2, 4,  3);

initialization
   // Inicializa as variáveis da unit ao ser carregada
   Move(OpLengthsM1X1_Data, OpLengthsM1X1, SizeOf(OpLengthsM1X1_Data));
   Move(OpLengthsM1X0_Data, OpLengthsM1X0, SizeOf(OpLengthsM1X0_Data));
   Move(OpLengthsM0X1_Data, OpLengthsM0X1, SizeOf(OpLengthsM0X1_Data));
   Move(OpLengthsM0X0_Data, OpLengthsM0X0, SizeOf(OpLengthsM0X0_Data));

   InitializeOpcodeTables;

end.
