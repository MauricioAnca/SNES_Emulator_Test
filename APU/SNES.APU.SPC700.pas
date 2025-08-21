unit SNES.APU.SPC700;

interface

uses
   SNES.DataTypes;

// --- Funções Públicas da Unit ---
procedure APUExecute;
procedure InitializeAPUOpcodes;

// --- Opcodes ---
procedure Apu00; // NOP
procedure Apu01;
procedure Apu02; // SET1 dp.0
procedure Apu03;
procedure Apu04;
procedure Apu05;
procedure Apu06;
procedure Apu07;
procedure Apu08;
procedure Apu09; // OR dp(dest),dp(src)
procedure Apu0A; // OR1 C,membit
procedure Apu0B; // ASL dp
procedure Apu0C; // ASL abs
procedure Apu0D; // PUSH PSW
procedure Apu0E; // TSET1 abs
procedure Apu0F; // BRK
procedure Apu10; // BPL
procedure Apu11;
procedure Apu12; // CLR1 dp.0
procedure Apu13;
procedure Apu14;
procedure Apu15;
procedure Apu16;
procedure Apu17;
procedure Apu18; // OR dp,#00
procedure Apu19; // OR (X),(Y)
procedure Apu1A; // DECW dp
procedure Apu1B; // ASL dp+X
procedure Apu1C; // ASL A
procedure Apu1D; // DEC X
procedure Apu1E; // CMP X,abs
procedure Apu1F; // JMP (abs+X)
procedure Apu20; // CLRP
procedure Apu21;
procedure Apu22; // SET1 dp.1
procedure Apu23;
procedure Apu24;
procedure Apu25;
procedure Apu26;
procedure Apu27;
procedure Apu28;
procedure Apu29; // AND dp(dest),dp(src)
procedure Apu2B; // ROL dp
procedure Apu2C; // ROL abs
procedure Apu2D; // PUSH A
procedure Apu2E; // CBNE dp,rel
procedure Apu2F; // BRA rel
procedure Apu31;
procedure Apu32; // CLR1 dp.1
procedure Apu33;
procedure Apu34;
procedure Apu35;
procedure Apu36;
procedure Apu37;
procedure Apu38; // AND dp,#00
procedure Apu39; // AND (X),(Y)
procedure Apu3A; // INCW dp
procedure Apu3B; // ROL dp+X
procedure Apu3C; // ROL A
procedure Apu3D; // INC X
procedure Apu3E; // CMP X,dp
procedure Apu3F; // CALL absolute
procedure Apu40; // SETP
procedure Apu41;
procedure Apu42; // SET1 dp.2
procedure Apu43;
procedure Apu44;
procedure Apu45;
procedure Apu46;
procedure Apu47;
procedure Apu48;
procedure Apu49; // EOR dp(dest),dp(src)
procedure Apu4A; // AND1 C,membit
procedure Apu4B; // LSR dp
procedure Apu4C; // LSR abs
procedure Apu4D; // PUSH X
procedure Apu4E; // TCLR1 abs
procedure Apu4F; // PCALL $XX
procedure Apu50; // BVC
procedure Apu51;
procedure Apu52; // CLR1 dp.2
procedure Apu53;
procedure Apu54;
procedure Apu55;
procedure Apu56;
procedure Apu57;
procedure Apu58; // EOR dp,#00
procedure Apu59; // EOR (X),(Y)
procedure Apu5A; // CMPW YA,dp
procedure Apu5B; // LSR dp+X
procedure Apu5C; // LSR A
procedure Apu5D; // MOV X,A
procedure Apu5E; // CMP Y,abs
procedure Apu5F; // JMP abs
procedure Apu60; // CLRC
procedure Apu61;
procedure Apu62; // SET1 dp.3
procedure Apu63;
procedure Apu64;
procedure Apu65;
procedure Apu66;
procedure Apu67;
procedure Apu68;
procedure Apu69; // CMP dp(dest),dp(src)
procedure Apu6A; // AND1 C,membit
procedure Apu6B; // ROR dp
procedure Apu6C; // ROR abs
procedure Apu6D; // PUSH Y
procedure Apu6E; // DBNZ dp,rel
procedure Apu6F; // RET
procedure Apu70; // BVS
procedure Apu71;
procedure Apu72; // CLR1 dp.3
procedure Apu73;
procedure Apu74;
procedure Apu75;
procedure Apu76;
procedure Apu77;
procedure Apu78; // CMP dp,#00
procedure Apu79; // CMP (X),(Y)
procedure Apu7A; // ADDW YA,dp
procedure Apu7B; // ROR dp+X
procedure Apu7C; // ROR A
procedure Apu7D; // MOV A,X
procedure Apu7E; // CMP Y,dp
procedure Apu7F; // RETI

procedure Apu81;
procedure Apu82; // SET1 dp.4
procedure Apu83;













procedure Apu91;
procedure Apu92; // CLR1 dp.4
procedure Apu93;












procedure ApuA0; // EI
procedure ApuA1;
procedure ApuA2; // SET1 dp.5
procedure ApuA3;
procedure ApuA4; // SBC A,dp
procedure ApuA5; // SBC A,abs
procedure ApuA6; // SBC A,(X)
procedure ApuA7; // SBC A,(dp+X)
procedure ApuA8; // SBC A,#00
procedure ApuA9; // SBC dp(dest),dp(src)
procedure ApuAA; // MOV1 C,membit
procedure ApuAB; // INC dp
procedure ApuAC; // INC abs
procedure ApuAD; // CMP Y,#00
procedure ApuAE; // POP A
procedure ApuAF; // MOV (X)+, A
procedure ApuB0; // BCS
procedure ApuB1;
procedure ApuB2; // CLR1 dp.5
procedure ApuB3;
procedure ApuB4; // SBC A,dp+X
procedure ApuB5; // SBC A,abs+X
procedure ApuB6; // SBC A,abs+Y
procedure ApuB7; // SBC A,(dp)+Y
procedure ApuB8; // SBC dp,#00
procedure ApuB9; // SBC (X),(Y)
procedure ApuBA; // MOVW YA,dp
procedure ApuBB; // INC dp+X
procedure ApuBC; // INC A
procedure ApuBD; // MOV SP,X
procedure ApuBE; // DAS
procedure ApuBF; // MOV A,(X)+
procedure ApuC0; // DI
procedure ApuC1;
procedure ApuC2; // SET1 dp.6
procedure ApuC3;
procedure ApuC4; // MOV dp,A
procedure ApuC5; // MOV abs,A
procedure ApuC6; // MOV (X), A
procedure ApuC7; // MOV (dp+X),A
procedure ApuC8; // CMP X,#00
procedure ApuC9; // MOV abs,X
procedure ApuCA; // MOV1 membit,C
procedure ApuCB; // MOV dp,Y
procedure ApuCC; // MOV abs,Y
procedure ApuCD; // MOV X,#00
procedure ApuCE; // POP X
procedure ApuCF; // MUL YA
procedure ApuD0; // BNE
procedure ApuD1;
procedure ApuD2; // CLR1 dp.6
procedure ApuD3;
procedure ApuD4;
procedure ApuD5;
procedure ApuD6;
procedure ApuD7;
procedure ApuD8; // MOV dp,X
procedure ApuD9; // MOV dp+Y,X
procedure ApuDA; // MOVW dp,YA
procedure ApuDB; // MOV dp+X,Y
procedure ApuDC; // DEC Y
procedure ApuDD; // MOV A,Y
procedure ApuDE; // CBNE dp+X,rel
procedure ApuDF; // DAA
procedure ApuE0; // CLRV
procedure ApuE1;
procedure ApuE2; // SET1 dp.7
procedure ApuE3;
procedure ApuE4; // MOV A,dp
procedure ApuE5; // MOV A,abs
procedure ApuE6; // MOV A,(X)
procedure ApuE7; // MOV A,(dp+X)
procedure ApuE8; // MOV A,#00
procedure ApuE9; // MOV X,abs
procedure ApuEA; // NOT1 membit
procedure ApuEB; // MOV Y,dp
procedure ApuEC; // MOV Y,abs
procedure ApuED; // NOTC
procedure ApuEE; // POP Y
procedure ApuEF_FF; // SLEEP / STOP
procedure ApuF0; // BEQ
procedure ApuF1;
procedure ApuF2; // CLR1 dp.7
procedure ApuF3;
procedure ApuF4; // MOV A,dp+X
procedure ApuF5; // MOV A,abs+X
procedure ApuF6; // MOV A,abs+Y
procedure ApuF7; // MOV A,(dp)+Y
procedure ApuF8; // MOV X,dp
procedure ApuF9; // MOV X,dp+Y
procedure ApuFA; // MOV dp(dest),dp(src)
procedure ApuFB; // MOV Y,dp+X
procedure ApuFC; // INC Y
procedure ApuFD; // MOV Y,A
procedure ApuFE; // DBNZ Y,rel

implementation

uses
   System.SysUtils,
   SNES.Globals,
   SNES.Memory,
   SNES.CPU,
   SNES.APU,
   SNES.APU.DSP;

var
   // Variáveis de trabalho para os opcodes
   Int8: ShortInt;
   Int16: SmallInt;
   Int32: Integer;
   W1, W2, Work8: Byte;
   Work16: Word;
   Work32: Cardinal;

   // Tabela de ponteiros de função para os opcodes do SPC700
   ApuOpcodes: array [0 .. 255] of TOpcodeFunc;

procedure APUExecute;
var
   Op: Byte;
begin
   // Se a APU não estiver em execução, apenas sincroniza os contadores de ciclo e sai.
   if not IAPU.Executing then
   begin
      APU.Cycles := APUGetCPUCycles;
      Exit;
   end;

   // Loop principal do SPC700. Ele continuará executando instruções até que o contador de ciclos da APU alcance (ou ultrapasse) o contador de ciclos da CPU principal.
   while APU.Cycles < APUGetCPUCycles do
   begin
      // Lê o opcode (byte) para o qual o ponteiro do Program Counter (IAPU.PC) aponta.
      Op := IAPU.PC^;

      // Adiciona o número de ciclos que esta instrução consumirá.
      // O array APUCycles foi preenchido com os tempos corretos durante a inicialização.
      APU.Cycles := APU.Cycles + APUCycles[Op];

      // Usa o opcode como índice para a tabela de opcodes e chama o procedimento correspondente.
      ApuOpcodes[Op]();
   end;
end;

// ROTINAS AUXILIARES INLINE (Tradução de spc700.c e spc700.h)
function OP1: Byte; inline;
begin
   Result := IAPU.PC[1];
end;

function OP2: Byte; inline;
begin
   Result := IAPU.PC[2];
end;

procedure APUShutdown; inline;
begin
   if Settings.Shutdown and ((IAPU.PC = IAPU.WaitAddress1) or (IAPU.PC = IAPU.WaitAddress2)) then
   begin
      if IAPU.WaitCounter = 0 then
      begin
         if (APU.Cycles < EXT.NextAPUTimerPos) and (EXT.NextAPUTimerPos < CPU.Cycles) then
            APU.Cycles := EXT.NextAPUTimerPos
         else
            if APU.Cycles < CPU.Cycles then
               APU.Cycles := CPU.Cycles;
         IAPU.Executing := False;
      end
      else
         if IAPU.WaitCounter >= 2 then
            IAPU.WaitCounter := 1
         else
            Dec(IAPU.WaitCounter);
   end;
end;

procedure APUSetZN8(b: Byte); inline;
begin
   IAPU.Zero := b = 0;
end;

procedure APUSetZN16(w: Word); inline;
begin
   IAPU.Zero := w = 0;
end;

procedure SBC(var a: Byte; b: Byte); inline;
begin
   Int16 := SmallInt(a) - SmallInt(b) + Ord(IAPU.Carry) - 1;
   IAPU.Carry := Int16 >= 0;
   if (((a xor b) and $80) <> 0) and (((a xor Byte(Int16)) and $80) <> 0) then
      IAPU.Overflow := True
   else
      IAPU.Overflow := False;
   if ((a xor b xor Byte(Int16)) and $10) <> 0 then
      IAPU.Registers.P := IAPU.Registers.P and not APU_HALF_CARRY
   else
      IAPU.Registers.P := IAPU.Registers.P or APU_HALF_CARRY;
   a := Byte(Int16);
   APUSetZN8(a);
end;

procedure ADC(var a: Byte; b: Byte); inline;
begin
   Work16 := a + b + Ord(IAPU.Carry);
   IAPU.Carry := Work16 >= $100;
   if ((not(a xor b)) and ((b xor Byte(Work16)))) and $80 <> 0 then
      IAPU.Overflow := True
   else
      IAPU.Overflow := False;
   if ((a xor b xor Byte(Work16)) and $10) <> 0 then
      IAPU.Registers.P := IAPU.Registers.P or APU_HALF_CARRY
   else
      IAPU.Registers.P := IAPU.Registers.P and not APU_HALF_CARRY;
   a := Byte(Work16);
   APUSetZN8(a);
end;

procedure CMP(a, b: Byte); inline;
begin
   Int16 := SmallInt(a) - SmallInt(b);
   IAPU.Carry := Int16 >= 0;
   APUSetZN8(Byte(Int16));
end;

procedure ASL(var b: Byte); inline;
begin
   IAPU.Carry := (b and $80) <> 0;
   b := b shl 1;
   APUSetZN8(b);
end;

procedure LSR(var b: Byte); inline;
begin
   IAPU.Carry := (b and 1) <> 0;
   b := b shr 1;
   APUSetZN8(b);
end;

procedure ROL(var b: Byte); inline;
begin
   Work16 := (Word(b) shl 1) or Ord(IAPU.Carry);
   IAPU.Carry := Work16 >= $100;
   b := Byte(Work16);
   APUSetZN8(b);
end;

procedure ROR(var b: Byte); inline;
begin
   Work16 := b or (Word(Ord(IAPU.Carry)) shl 8);
   IAPU.Carry := (Work16 and 1) <> 0;
   Work16 := Work16 shr 1;
   b := Byte(Work16);
   APUSetZN8(b);
end;

procedure Push(b: Byte); inline;
begin
   IAPU.RAM[$100 + IAPU.Registers.S] := b;
   Dec(IAPU.Registers.S);
end;

function Pop: Byte; inline;
begin
   Inc(IAPU.Registers.S);
   Result := IAPU.RAM[$100 + IAPU.Registers.S];
end;

procedure PushW(w: Word); inline;
begin
   IAPU.RAM[$FF + IAPU.Registers.S] := Byte(w);
   IAPU.RAM[$100 + IAPU.Registers.S] := Byte(w shr 8);
   Dec(IAPU.Registers.S, 2);
end;

function PopW: Word; inline;
begin
   Inc(IAPU.Registers.S, 2);
   if IAPU.Registers.S = 0 then
      Result := IAPU.RAM[$1FF] or (IAPU.RAM[$100] shl 8)
   else
      Result := IAPU.RAM[$FF + IAPU.Registers.S] + (IAPU.RAM[$100 + IAPU.Registers.S] shl 8);
end;

procedure TCALL(n: Integer); inline;
begin
   PushW(Word(NativeUInt(IAPU.PC) - NativeUInt(IAPU.RAM)) + 1);
   IAPU.PC := IAPU.RAM + APUGetByte($FFC0 + ((15 - n) shl 1)) + (APUGetByte($FFC1 + ((15 - n) shl 1)) shl 8);
end;

procedure Relative; inline;
begin
   Int8 := ShortInt(OP1);
   Int16 := SmallInt(NativeUInt(IAPU.PC) - NativeUInt(IAPU.RAM)) + 2 + Int8;
end;

procedure Relative2; inline;
begin
   Int8 := ShortInt(OP2);
   Int16 := SmallInt(NativeUInt(IAPU.PC) - NativeUInt(IAPU.RAM)) + 3 + Int8;
end;

procedure IndexedXIndirect; inline;
begin
   IAPU.Address := PWord(@IAPU.DirectPage[(OP1 + IAPU.Registers.X) and $FF])^;
end;

procedure Absolute; inline;
begin
   IAPU.Address := PWord(@IAPU.PC[1])^;
end;

procedure AbsoluteX; inline;
begin
   IAPU.Address := PWord(@IAPU.PC[1])^ + IAPU.Registers.X;
end;

procedure AbsoluteY; inline;
begin
   IAPU.Address := PWord(@IAPU.PC[1])^ + IAPU.Registers.YA.Y;
end;

procedure MemBit; inline;
begin
   IAPU.Address := PWord(@IAPU.PC[1])^;
   IAPU.Bit := IAPU.Address shr 13;
   IAPU.Address := IAPU.Address and $1FFF;
end;

procedure IndirectIndexedY; inline;
begin
   IAPU.Address := PWord(@IAPU.DirectPage[OP1])^ + IAPU.Registers.YA.Y;
end;

procedure Set_Bit(b: Byte);
begin
   APUSetByteDP(APUGetByteDP(OP1) or (1 shl b), OP1);
   Inc(IAPU.PC, 2);
end;

procedure Clr_Bit(b: Byte);
begin
   APUSetByteDP(APUGetByteDP(OP1) and not(1 shl b), OP1);
   Inc(IAPU.PC, 2);
end;

procedure BBS_Bit(b: Byte);
begin
   Work8 := OP1;
   Relative2;
   if (APUGetByteDP(Work8) and (1 shl b)) <> 0 then
   begin
      IAPU.PC := IAPU.RAM + Word(Int16);
      APU.Cycles := APU.Cycles + (IAPU.OneCycle shl 1);
   end
   else
      Inc(IAPU.PC, 3);
end;

procedure BBC_Bit(b: Byte);
begin
   Work8 := OP1;
   Relative2;
   if (APUGetByteDP(Work8) and (1 shl b)) = 0 then
   begin
      IAPU.PC := IAPU.RAM + Word(Int16);
      APU.Cycles := APU.Cycles + (IAPU.OneCycle shl 1);
   end
   else
      Inc(IAPU.PC, 3);
end;

// SPC700 Opcodes
procedure Apu00; // NOP
begin
   Inc(IAPU.PC);
end;

procedure Apu01;
begin
   TCALL(0);
end;

procedure Apu02; // SET1 dp.0
begin
   APUSetByteDP(APUGetByteDP(OP1) or (1 shl 0), OP1);
   Inc(IAPU.PC, 2);
end;

procedure Apu03;
begin
   BBS_Bit(0);
end;

procedure Apu04;
begin
   IAPU.Registers.YA.a := IAPU.Registers.YA.a or APUGetByteDP(OP1);
   APUSetZN8(IAPU.Registers.YA.a);
   Inc(IAPU.PC, 2);
end;

procedure Apu05;
begin
   Absolute;
   IAPU.Registers.YA.a := IAPU.Registers.YA.a or APUGetByte(IAPU.Address);
   APUSetZN8(IAPU.Registers.YA.a);
   Inc(IAPU.PC, 3);
end;

procedure Apu06;
begin
   IAPU.Registers.YA.a := IAPU.Registers.YA.a or APUGetByteDP(IAPU.Registers.X);
   APUSetZN8(IAPU.Registers.YA.a);
   Inc(IAPU.PC);
end;

procedure Apu07;
begin
   IndexedXIndirect;
   IAPU.Registers.YA.a := IAPU.Registers.YA.a or APUGetByte(IAPU.Address);
   APUSetZN8(IAPU.Registers.YA.a);
   Inc(IAPU.PC, 2);
end;

procedure Apu08;
begin
   IAPU.Registers.YA.a := IAPU.Registers.YA.a or OP1;
   APUSetZN8(IAPU.Registers.YA.a);
   Inc(IAPU.PC, 2);
end;

procedure Apu09; // OR dp(dest),dp(src)
begin
   Work8 := APUGetByteDP(OP1);
   Work8 := Work8 or APUGetByteDP(OP2);
   APUSetByteDP(Work8, OP2);
   APUSetZN8(Work8);
   Inc(IAPU.PC, 3);
end;

procedure Apu0A; // OR1 C,membit
begin
   MemBit;
   if not IAPU.Carry then
      if (APUGetByte(IAPU.Address) and (1 shl IAPU.Bit)) <> 0 then
         IAPU.Carry := True;
   Inc(IAPU.PC, 3);
end;

procedure Apu0B; // ASL dp
begin
   Work8 := APUGetByteDP(OP1);
   ASL(Work8);
   APUSetByteDP(Work8, OP1);
   Inc(IAPU.PC, 2);
end;

procedure Apu0C; // ASL abs
begin
   Absolute;
   Work8 := APUGetByte(IAPU.Address);
   ASL(Work8);
   APUSetByte(Work8, IAPU.Address);
   Inc(IAPU.PC, 3);
end;

procedure Apu0D; // PUSH PSW
begin
   APUPackStatus;
   Push(ICPU.Registers.P);
   Inc(IAPU.PC);
end;

procedure Apu0E; // TSET1 abs
begin
   Absolute;
   Work8 := APUGetByte(IAPU.Address);
   APUSetByte(Work8 or IAPU.Registers.YA.a, IAPU.Address);
   Work8 := IAPU.Registers.YA.a - Work8;
   APUSetZN8(Work8);
   Inc(IAPU.PC, 3);
end;

procedure Apu0F; // BRK
begin
   PushW(Word(NativeUInt(IAPU.PC) - NativeUInt(IAPU.RAM)) + 1);
   APUPackStatus;
   Push(ICPU.Registers.P);
   IAPU.Registers.P := IAPU.Registers.P or APU_BREAK;
   IAPU.Registers.P := IAPU.Registers.P and not APU_INTERRUPT;
   IAPU.PC := IAPU.RAM + APUGetByte($FFDE) + (APUGetByte($FFDF) shl 8);
end;

procedure Apu10; // BPL
begin
   Relative;
   if not APUCheckNegative then
   begin
      IAPU.PC := IAPU.RAM + Word(Int16);
      APU.Cycles := APU.Cycles + (IAPU.OneCycle shl 1);
      APUShutdown;
   end
   else
      Inc(IAPU.PC, 2);
end;

procedure Apu11;
begin
   TCALL(1);
end;

procedure Apu12; // CLR1 dp.0
begin
   APUSetByteDP(APUGetByteDP(OP1) and not(1 shl 0), OP1);
   Inc(IAPU.PC, 2);
end;

procedure Apu13;
begin
   BBC_Bit(0);
end;

procedure Apu14;
begin
   IAPU.Registers.YA.a := IAPU.Registers.YA.a or APUGetByteDP(OP1 + IAPU.Registers.X);
   APUSetZN8(IAPU.Registers.YA.a);
   Inc(IAPU.PC, 2);
end;

procedure Apu15;
begin
   AbsoluteX;
   IAPU.Registers.YA.a := IAPU.Registers.YA.a or APUGetByte(IAPU.Address);
   APUSetZN8(IAPU.Registers.YA.a);
   Inc(IAPU.PC, 3);
end;

procedure Apu16;
begin
   AbsoluteY;
   IAPU.Registers.YA.a := IAPU.Registers.YA.a or APUGetByte(IAPU.Address);
   APUSetZN8(IAPU.Registers.YA.a);
   Inc(IAPU.PC, 3);
end;

procedure Apu17;
begin
   IndirectIndexedY;
   IAPU.Registers.YA.a := IAPU.Registers.YA.a or APUGetByte(IAPU.Address);
   APUSetZN8(IAPU.Registers.YA.a);
   Inc(IAPU.PC, 2);
end;

procedure Apu18; // OR dp,#00
begin
   Work8 := OP1;
   Work8 := Work8 or APUGetByteDP(OP2);
   APUSetByteDP(Work8, OP2);
   APUSetZN8(Work8);
   Inc(IAPU.PC, 3);
end;

procedure Apu19; // OR (X),(Y)
begin
   Work8 := APUGetByteDP(IAPU.Registers.X) or APUGetByteDP(IAPU.Registers.YA.Y);
   APUSetZN8(Work8);
   APUSetByteDP(Work8, IAPU.Registers.X);
   Inc(IAPU.PC);
end;

procedure Apu1A; // DECW dp
begin
   Work16 := APUGetByteDP(OP1) + (APUGetByteDP(OP1 + 1) shl 8) - 1;
   APUSetByteDP(Byte(Work16), OP1);
   APUSetByteDP(Byte(Work16 shr 8), OP1 + 1);
   APUSetZN16(Work16);
   Inc(IAPU.PC, 2);
end;

procedure Apu1B; // ASL dp+X
begin
   Work8 := APUGetByteDP(OP1 + IAPU.Registers.X);
   ASL(Work8);
   APUSetByteDP(Work8, OP1 + IAPU.Registers.X);
   Inc(IAPU.PC, 2);
end;

procedure Apu1C; // ASL A
begin
   ASL(IAPU.Registers.YA.a);
   Inc(IAPU.PC);
end;

procedure Apu1D; // DEC X
begin
   Dec(IAPU.Registers.X);
   APUSetZN8(IAPU.Registers.X);
   Inc(IAPU.WaitCounter);
   Inc(IAPU.PC);
end;

procedure Apu1E; // CMP X,abs
begin
   Absolute;
   Work8 := APUGetByte(IAPU.Address);
   CMP(IAPU.Registers.X, Work8);
   Inc(IAPU.PC, 3);
end;

procedure Apu1F; // JMP (abs+X)
begin
   Absolute;
   IAPU.PC := IAPU.RAM + APUGetByte(IAPU.Address + IAPU.Registers.X) + (APUGetByte(IAPU.Address + IAPU.Registers.X + 1) shl 8);
end;

procedure Apu20; // CLRP
begin
   ICPU.Registers.P := ICPU.Registers.P and not APU_DIRECT_PAGE;
   IAPU.DirectPage := IAPU.RAM;
   Inc(IAPU.PC);
end;

procedure Apu21;
begin
   TCALL(2);
end;

procedure Apu22; // SET1 dp.1
begin
   APUSetByteDP(APUGetByteDP(OP1) or (1 shl 1), OP1);
   Inc(IAPU.PC, 2);
end;

procedure Apu23;
begin
   BBS_Bit(1);
end;

procedure Apu24;
begin
   IAPU.Registers.YA.a := IAPU.Registers.YA.a and APUGetByteDP(OP1);
   APUSetZN8(IAPU.Registers.YA.a);
   Inc(IAPU.PC, 2);
end;

procedure Apu25;
begin
   Absolute;
   IAPU.Registers.YA.a := IAPU.Registers.YA.a and APUGetByte(IAPU.Address);
   APUSetZN8(IAPU.Registers.YA.a);
   Inc(IAPU.PC, 3);
end;

procedure Apu26;
begin
   IAPU.Registers.YA.a := IAPU.Registers.YA.a and APUGetByteDP(IAPU.Registers.X);
   APUSetZN8(IAPU.Registers.YA.a);
   Inc(IAPU.PC);
end;

procedure Apu27;
begin
   IndexedXIndirect;
   IAPU.Registers.YA.a := IAPU.Registers.YA.a and APUGetByte(IAPU.Address);
   APUSetZN8(IAPU.Registers.YA.a);
   Inc(IAPU.PC, 2);
end;

procedure Apu28;
begin
   IAPU.Registers.YA.a := IAPU.Registers.YA.a and OP1;
   APUSetZN8(IAPU.Registers.YA.a);
   Inc(IAPU.PC, 2);
end;

procedure Apu29; // AND dp(dest),dp(src)
begin
   Work8 := APUGetByteDP(OP1);
   Work8 := Work8 and APUGetByteDP(OP2);
   APUSetByteDP(Work8, OP2);
   APUSetZN8(Work8);
   Inc(IAPU.PC, 3);
end;

procedure Apu2B; // ROL dp
begin
   Work8 := APUGetByteDP(OP1);
   ROL(Work8);
   APUSetByteDP(Work8, OP1);
   Inc(IAPU.PC, 2);
end;

procedure Apu2C; // ROL abs
begin
   Absolute;
   Work8 := APUGetByte(IAPU.Address);
   ROL(Work8);
   APUSetByte(Work8, IAPU.Address);
   Inc(IAPU.PC, 3);
end;

procedure Apu2D; // PUSH A
begin
   Push(IAPU.Registers.YA.a);
   Inc(IAPU.PC);
end;

procedure Apu2E; // CBNE dp,rel
begin
   Work8 := OP1;
   Relative2;
   if APUGetByteDP(Work8) <> IAPU.Registers.YA.a then
   begin
      IAPU.PC := IAPU.RAM + Word(Int16);
      APU.Cycles := APU.Cycles + (IAPU.OneCycle shl 1);
      APUShutdown;
   end
   else
      Inc(IAPU.PC, 3);
end;

procedure Apu2F; // BRA rel
begin
   Relative;
   IAPU.PC := IAPU.RAM + Word(Int16);
end;

procedure Apu31;
begin
   TCALL(3);
end;

procedure Apu32; // CLR1 dp.1
begin
   APUSetByteDP(APUGetByteDP(OP1) and not(1 shl 1), OP1);
   Inc(IAPU.PC, 2);
end;

procedure Apu33;
begin
   BBC_Bit(1);
end;

procedure Apu34;
begin
   IAPU.Registers.YA.a := IAPU.Registers.YA.a and APUGetByteDP(OP1 + IAPU.Registers.X);
   APUSetZN8(IAPU.Registers.YA.a);
   Inc(IAPU.PC, 2);
end;

procedure Apu35;
begin
   AbsoluteX;
   IAPU.Registers.YA.a := IAPU.Registers.YA.a and APUGetByte(IAPU.Address);
   APUSetZN8(IAPU.Registers.YA.a);
   Inc(IAPU.PC, 3);
end;

procedure Apu36;
begin
   AbsoluteY;
   IAPU.Registers.YA.a := IAPU.Registers.YA.a and APUGetByte(IAPU.Address);
   APUSetZN8(IAPU.Registers.YA.a);
   Inc(IAPU.PC, 3);
end;

procedure Apu37;
begin
   IndirectIndexedY;
   IAPU.Registers.YA.a := IAPU.Registers.YA.a and APUGetByte(IAPU.Address);
   APUSetZN8(IAPU.Registers.YA.a);
   Inc(IAPU.PC, 2);
end;

procedure Apu38; // AND dp,#00
begin
   Work8 := OP1;
   Work8 := Work8 and APUGetByteDP(OP2);
   APUSetByteDP(Work8, OP2);
   APUSetZN8(Work8);
   Inc(IAPU.PC, 3);
end;

procedure Apu39; // AND (X),(Y)
begin
   Work8 := APUGetByteDP(IAPU.Registers.X) and APUGetByteDP(IAPU.Registers.YA.Y);
   APUSetZN8(Work8);
   APUSetByteDP(Work8, IAPU.Registers.X);
   Inc(IAPU.PC);
end;

procedure Apu3A; // INCW dp
begin
   Work16 := APUGetByteDP(OP1) + (APUGetByteDP(OP1 + 1) shl 8) + 1;
   APUSetByteDP(Byte(Work16), OP1);
   APUSetByteDP(Byte(Work16 shr 8), OP1 + 1);
   APUSetZN16(Work16);
   Inc(IAPU.PC, 2);
end;

procedure Apu3B; // ROL dp+X
begin
   Work8 := APUGetByteDP(OP1 + IAPU.Registers.X);
   ROL(Work8);
   APUSetByteDP(Work8, OP1 + IAPU.Registers.X);
   Inc(IAPU.PC, 2);
end;

procedure Apu3C; // ROL A
begin
   ROL(IAPU.Registers.YA.a);
   Inc(IAPU.PC);
end;

procedure Apu3D; // INC X
begin
   Inc(IAPU.Registers.X);
   APUSetZN8(IAPU.Registers.X);
   Inc(IAPU.WaitCounter);
   Inc(IAPU.PC);
end;

procedure Apu3E; // CMP X,dp
begin
   Work8 := APUGetByteDP(OP1);
   CMP(IAPU.Registers.X, Work8);
   Inc(IAPU.PC, 2);
end;

procedure Apu3F; // CALL absolute
begin
   Absolute;
   PushW(Word(NativeUInt(IAPU.PC) - NativeUInt(IAPU.RAM)) + 3);
   IAPU.PC := IAPU.RAM + IAPU.Address;
end;

procedure Apu40; // SETP
begin
   IAPU.Registers.P := IAPU.Registers.P or APU_DIRECT_PAGE;
   IAPU.DirectPage := IAPU.RAM + $100;
   Inc(IAPU.PC);
end;

procedure Apu41;
begin
   TCALL(4);
end;

procedure Apu42; // SET1 dp.2
begin
   APUSetByteDP(APUGetByteDP(OP1) or (1 shl 2), OP1);
   Inc(IAPU.PC, 2);
end;

procedure Apu43;
begin
   BBS_Bit(2);
end;

procedure Apu44;
begin
   IAPU.Registers.YA.a := IAPU.Registers.YA.a xor APUGetByteDP(OP1);
   APUSetZN8(IAPU.Registers.YA.a);
   Inc(IAPU.PC, 2);
end;

procedure Apu45;
begin
   Absolute;
   IAPU.Registers.YA.a := IAPU.Registers.YA.a xor APUGetByte(IAPU.Address);
   APUSetZN8(IAPU.Registers.YA.a);
   Inc(IAPU.PC, 3);
end;

procedure Apu46;
begin
   IAPU.Registers.YA.a := IAPU.Registers.YA.a xor APUGetByteDP(IAPU.Registers.X);
   APUSetZN8(IAPU.Registers.YA.a);
   Inc(IAPU.PC);
end;

procedure Apu47;
begin
   IndexedXIndirect;
   IAPU.Registers.YA.a := IAPU.Registers.YA.a xor APUGetByte(IAPU.Address);
   APUSetZN8(IAPU.Registers.YA.a);
   Inc(IAPU.PC, 2);
end;

procedure Apu48;
begin
   IAPU.Registers.YA.a := IAPU.Registers.YA.a xor OP1;
   APUSetZN8(IAPU.Registers.YA.a);
   Inc(IAPU.PC, 2);
end;

procedure Apu49; // EOR dp(dest),dp(src)
begin
   Work8 := APUGetByteDP(OP1);
   Work8 := Work8 xor APUGetByteDP(OP2);
   APUSetByteDP(Work8, OP2);
   APUSetZN8(Work8);
   Inc(IAPU.PC, 3);
end;

procedure Apu4A; // AND1 C,membit
begin
   MemBit;
   if IAPU.Carry then
      if (APUGetByte(IAPU.Address) and (1 shl IAPU.Bit)) = 0 then
         IAPU.Carry := False;
   Inc(IAPU.PC, 3);
end;

procedure Apu4B; // LSR dp
begin
   Work8 := APUGetByteDP(OP1);
   LSR(Work8);
   APUSetByteDP(Work8, OP1);
   Inc(IAPU.PC, 2);
end;

procedure Apu4C; // LSR abs
begin
   Absolute;
   Work8 := APUGetByte(IAPU.Address);
   LSR(Work8);
   APUSetByte(Work8, IAPU.Address);
   Inc(IAPU.PC, 3);
end;

procedure Apu4D; // PUSH X
begin
   Push(IAPU.Registers.X);
   Inc(IAPU.PC);
end;

procedure Apu4E; // TCLR1 abs
begin
   Absolute;
   Work8 := APUGetByte(IAPU.Address);
   APUSetByte(Work8 and not IAPU.Registers.YA.a, IAPU.Address);
   Work8 := IAPU.Registers.YA.a - Work8;
   APUSetZN8(Work8);
   Inc(IAPU.PC, 3);
end;

procedure Apu4F; // PCALL $XX
begin
   Work8 := OP1;
   PushW(Word(NativeUInt(IAPU.PC) - NativeUInt(IAPU.RAM)) + 2);
   IAPU.PC := IAPU.RAM + $FF00 + Work8;
end;

procedure Apu50; // BVC
begin
   Relative;
   if not IAPU.Overflow then
   begin
      IAPU.PC := IAPU.RAM + Word(Int16);
      APU.Cycles := APU.Cycles + (IAPU.OneCycle shl 1);
   end
   else
      Inc(IAPU.PC, 2);
end;

procedure Apu51;
begin
   TCALL(5);
end;

procedure Apu52; // CLR1 dp.2
begin
   APUSetByteDP(APUGetByteDP(OP1) and not(1 shl 2), OP1);
   Inc(IAPU.PC, 2);
end;

procedure Apu53;
begin
   BBC_Bit(2);
end;

procedure Apu54;
begin
   IAPU.Registers.YA.a := IAPU.Registers.YA.a xor APUGetByteDP(OP1 + IAPU.Registers.X);
   APUSetZN8(IAPU.Registers.YA.a);
   Inc(IAPU.PC, 2);
end;

procedure Apu55;
begin
   AbsoluteX;
   IAPU.Registers.YA.a := IAPU.Registers.YA.a xor APUGetByte(IAPU.Address);
   APUSetZN8(IAPU.Registers.YA.a);
   Inc(IAPU.PC, 3);
end;

procedure Apu56;
begin
   AbsoluteY;
   IAPU.Registers.YA.a := IAPU.Registers.YA.a xor APUGetByte(IAPU.Address);
   APUSetZN8(IAPU.Registers.YA.a);
   Inc(IAPU.PC, 3);
end;

procedure Apu57;
begin
   IndirectIndexedY;
   IAPU.Registers.YA.a := IAPU.Registers.YA.a xor APUGetByte(IAPU.Address);
   APUSetZN8(IAPU.Registers.YA.a);
   Inc(IAPU.PC, 2);
end;

procedure Apu58; // EOR dp,#00
begin
   Work8 := OP1;
   Work8 := Work8 xor APUGetByteDP(OP2);
   APUSetByteDP(Work8, OP2);
   APUSetZN8(Work8);
   Inc(IAPU.PC, 3);
end;

procedure Apu59; // EOR (X),(Y)
begin
   Work8 := APUGetByteDP(IAPU.Registers.X) xor APUGetByteDP(IAPU.Registers.YA.Y);
   APUSetZN8(Work8);
   APUSetByteDP(Work8, IAPU.Registers.X);
   Inc(IAPU.PC);
end;

procedure Apu5A; // CMPW YA,dp
begin
   Work16 := APUGetByteDP(OP1) + (APUGetByteDP(OP1 + 1) shl 8);
   Int32 := SmallInt(IAPU.Registers.YA.w) - SmallInt(Work16);
   IAPU.Carry := Int32 >= 0;
   APUSetZN16(Word(Int32));
   Inc(IAPU.PC, 2);
end;

procedure Apu5B; // LSR dp+X
begin
   Work8 := APUGetByteDP(OP1 + IAPU.Registers.X);
   LSR(Work8);
   APUSetByteDP(Work8, OP1 + IAPU.Registers.X);
   Inc(IAPU.PC, 2);
end;

procedure Apu5C; // LSR A
begin
   LSR(IAPU.Registers.YA.a);
   Inc(IAPU.PC);
end;

procedure Apu5D; // MOV X,A
begin
   IAPU.Registers.X := IAPU.Registers.YA.a;
   APUSetZN8(IAPU.Registers.X);
   Inc(IAPU.PC);
end;

procedure Apu5E; // CMP Y,abs
begin
   Absolute;
   Work8 := APUGetByte(IAPU.Address);
   CMP(IAPU.Registers.YA.Y, Work8);
   Inc(IAPU.PC, 3);
end;

procedure Apu5F; // JMP abs
begin
   Absolute;
   IAPU.PC := IAPU.RAM + IAPU.Address;
end;

procedure Apu60; // CLRC
begin
   IAPU.Carry := False;
   Inc(IAPU.PC);
end;

procedure Apu61;
begin
   TCALL(6);
end;

procedure Apu62; // SET1 dp.3
begin
   APUSetByteDP(APUGetByteDP(OP1) or (1 shl 3), OP1);
   Inc(IAPU.PC, 2);
end;

procedure Apu63;
begin
   BBS_Bit(3);
end;

procedure Apu64;
begin
   IAPU.Registers.YA.a := IAPU.Registers.YA.a - APUGetByteDP(OP1);
   APUSetZN8(IAPU.Registers.YA.a);
   Inc(IAPU.PC, 2);
end;

procedure Apu65;
begin
   Absolute;
   Work8 := APUGetByte(IAPU.Address);
   CMP(IAPU.Registers.YA.a, Work8);
   Inc(IAPU.PC, 3);
end;

procedure Apu66;
begin
   Work8 := APUGetByteDP(IAPU.Registers.X);
   CMP(IAPU.Registers.YA.a, Work8);
   Inc(IAPU.PC);
end;

procedure Apu67;
begin
   IndexedXIndirect;
   Work8 := APUGetByte(IAPU.Address);
   CMP(IAPU.Registers.YA.a, Work8);
   Inc(IAPU.PC, 2);
end;

procedure Apu68;
begin
   Work8 := OP1;
   CMP(IAPU.Registers.YA.a, Work8);
   Inc(IAPU.PC, 2);
end;

procedure Apu69; // CMP dp(dest),dp(src)
begin
   W1 := APUGetByteDP(OP1);
   Work8 := APUGetByteDP(OP2);
   CMP(Work8, W1);
   Inc(IAPU.PC, 3);
end;

procedure Apu6A; // AND1 C,membit
begin
   MemBit;
   if IAPU.Carry then
      if (APUGetByte(IAPU.Address) and (1 shl IAPU.Bit)) = 0 then
         IAPU.Carry := False;
   Inc(IAPU.PC, 3);
end;

procedure Apu6B; // ROR dp
begin
   Work8 := APUGetByteDP(OP1);
   ROR(Work8);
   APUSetByteDP(Work8, OP1);
   Inc(IAPU.PC, 2);
end;

procedure Apu6C; // ROR abs
begin
   Absolute;
   Work8 := APUGetByte(IAPU.Address);
   ROR(Work8);
   APUSetByte(Work8, IAPU.Address);
   Inc(IAPU.PC, 3);
end;

procedure Apu6D; // PUSH Y
begin
   Push(IAPU.Registers.YA.Y);
   Inc(IAPU.PC);
end;

procedure Apu6E; // DBNZ dp,rel
begin
   Work8 := OP1;
   Relative2;
   W1 := APUGetByteDP(Work8) - 1;
   APUSetByteDP(W1, Work8);
   if W1 <> 0 then
   begin
      IAPU.PC := IAPU.RAM + Word(Int16);
      APU.Cycles := APU.Cycles + (IAPU.OneCycle shl 1);
   end
   else
      Inc(IAPU.PC, 3);
end;

procedure Apu6F; // RET
begin
   IAPU.Registers.PC := PopW;
   IAPU.PC := IAPU.RAM + IAPU.Registers.PC;
end;

procedure Apu70; // BVS
begin
   Relative;
   if IAPU.Overflow then
   begin
      IAPU.PC := IAPU.RAM + Word(Int16);
      APU.Cycles := APU.Cycles + (IAPU.OneCycle shl 1);
   end
   else
      Inc(IAPU.PC, 2);
end;

procedure Apu71;
begin
   TCALL(7);
end;

procedure Apu72; // CLR1 dp.3
begin
   APUSetByteDP(APUGetByteDP(OP1) and not(1 shl 3), OP1);
   Inc(IAPU.PC, 2);
end;

procedure Apu73;
begin
   BBC_Bit(3);
end;

procedure Apu74;
begin
   IAPU.OpenBus := GetByte(DirectIndexedXE1(ACC_READ));
   ADC8(ICPU.OpenBus);
end;

procedure Apu75;
begin
   AbsoluteX;
   Work8 := APUGetByte(IAPU.Address);
   CMP(IAPU.Registers.YA.a, Work8);
   Inc(IAPU.PC, 3);
end;

procedure Apu76;
begin
   AbsoluteY;
   Work8 := APUGetByte(IAPU.Address);
   CMP(IAPU.Registers.YA.a, Work8);
   Inc(IAPU.PC, 3);
end;

procedure Apu77;
begin
   IndirectIndexedY;
   Work8 := APUGetByte(IAPU.Address);
   CMP(IAPU.Registers.YA.a, Work8);
   Inc(IAPU.PC, 2);
end;

procedure Apu78; // CMP dp,#00
begin
   Work8 := OP1;
   W1 := APUGetByteDP(OP2);
   CMP(W1, Work8);
   Inc(IAPU.PC, 3);
end;

procedure Apu79; // CMP (X),(Y)
begin
   W1 := APUGetByteDP(IAPU.Registers.X);
   Work8 := APUGetByteDP(IAPU.Registers.YA.Y);
   CMP(W1, Work8);
   Inc(IAPU.PC);
end;

procedure Apu7A; // ADDW YA,dp
begin
   Work16 := APUGetByteDP(OP1) + (APUGetByteDP(OP1 + 1) shl 8);
   Work32 := Cardinal(IAPU.Registers.YA.w) + Work16;
   IAPU.Carry := Work32 >= $10000;
   if ((not(IAPU.Registers.YA.w xor Work16)) and (Work16 xor Word(Work32))) and $8000 <> 0 then
      IAPU.Overflow := True
   else
      IAPU.Overflow := False;

   if ((IAPU.Registers.YA.w xor Work16 xor Word(Work32)) and $1000) <> 0 then
      IAPU.Registers.P := IAPU.Registers.P or APU_HALF_CARRY
   else
      IAPU.Registers.P := IAPU.Registers.P and not APU_HALF_CARRY;

   IAPU.Registers.YA.w := Word(Work32);
   APUSetZN16(IAPU.Registers.YA.w);
   Inc(IAPU.PC, 2);
end;

procedure Apu7B; // ROR dp+X
begin
   Work8 := APUGetByteDP(OP1 + IAPU.Registers.X);
   ROR(Work8);
   APUSetByteDP(Work8, OP1 + IAPU.Registers.X);
   Inc(IAPU.PC, 2);
end;

procedure Apu7C; // ROR A
begin
   ROR(IAPU.Registers.YA.a);
   Inc(IAPU.PC);
end;

procedure Apu7D; // MOV A,X
begin
   IAPU.Registers.YA.a := IAPU.Registers.X;
   APUSetZN8(IAPU.Registers.YA.a);
   Inc(IAPU.PC);
end;

procedure Apu7E; // CMP Y,dp
begin
   Work8 := APUGetByteDP(OP1);
   CMP(IAPU.Registers.YA.Y, Work8);
   Inc(IAPU.PC, 2);
end;

procedure Apu7F; // RETI
begin
   IAPU.Registers.P := Pop;
   APUUnpackStatus;
   IAPU.Registers.PC := PopW;
   IAPU.PC := IAPU.RAM + IAPU.Registers.PC;
end;

procedure Apu81;
begin
   TCALL(8);
end;

procedure Apu82; // SET1 dp.4
begin
   APUSetByteDP(APUGetByteDP(OP1) or (1 shl 4), OP1);
   Inc(IAPU.PC, 2);
end;

procedure Apu83;
begin
   BBS_Bit(4);
end;

procedure Apu91;
begin
   TCALL(9);
end;

procedure Apu92; // CLR1 dp.4
begin
   APUSetByteDP(APUGetByteDP(OP1) and not(1 shl 4), OP1);
   Inc(IAPU.PC, 2);
end;

procedure Apu93;
begin
   BBC_Bit(4);
end;

procedure ApuA0; // EI
begin
   IAPU.Registers.P := IAPU.Registers.P or APU_INTERRUPT;
   Inc(IAPU.PC);
end;

procedure ApuA1;
begin
   TCALL(10);
end;

procedure ApuA2; // SET1 dp.5
begin
   APUSetByteDP(APUGetByteDP(OP1) or (1 shl 5), OP1);
   Inc(IAPU.PC, 2);
end;

procedure ApuA3;
begin
   BBS_Bit(5);
end;

procedure ApuA4; // SBC A,dp
begin
   Work8 := APUGetByteDP(OP1);
   SBC(IAPU.Registers.YA.a, Work8);
   Inc(IAPU.PC, 2);
end;

procedure ApuA5; // SBC A,abs
begin
   Absolute;
   Work8 := APUGetByte(IAPU.Address);
   SBC(IAPU.Registers.YA.a, Work8);
   Inc(IAPU.PC, 3);
end;

procedure ApuA6; // SBC A,(X)
begin
   Work8 := APUGetByteDP(IAPU.Registers.X);
   SBC(IAPU.Registers.YA.a, Work8);
   Inc(IAPU.PC);
end;

procedure ApuA7; // SBC A,(dp+X)
begin
   IndexedXIndirect;
   Work8 := APUGetByte(IAPU.Address);
   SBC(IAPU.Registers.YA.a, Work8);
   Inc(IAPU.PC, 2);
end;

procedure ApuA8; // SBC A,#00
begin
   Work8 := OP1;
   SBC(IAPU.Registers.YA.a, Work8);
   Inc(IAPU.PC, 2);
end;

procedure ApuA9; // SBC dp(dest),dp(src)
begin
   Work8 := APUGetByteDP(OP1);
   W1 := APUGetByteDP(OP2);
   SBC(W1, Work8);
   APUSetByteDP(W1, OP2);
   Inc(IAPU.PC, 3);
end;

procedure ApuAA; // MOV1 C,membit
begin
   MemBit;
   if (APUGetByte(IAPU.Address) and (1 shl IAPU.Bit)) <> 0 then
      IAPU.Carry := True
   else
      IAPU.Carry := False;
   Inc(IAPU.PC, 3);
end;

procedure ApuAB; // INC dp
begin
   Work8 := APUGetByteDP(OP1) + 1;
   APUSetByteDP(Work8, OP1);
   APUSetZN8(Work8);
   Inc(IAPU.WaitCounter);
   Inc(IAPU.PC, 2);
end;

procedure ApuAC; // INC abs
begin
   Absolute;
   Work8 := APUGetByte(IAPU.Address) + 1;
   APUSetByte(Work8, IAPU.Address);
   APUSetZN8(Work8);
   Inc(IAPU.WaitCounter);
   Inc(IAPU.PC, 3);
end;

procedure ApuAD; // CMP Y,#00
begin
   Work8 := OP1;
   CMP(IAPU.Registers.YA.Y, Work8);
   Inc(IAPU.PC, 2);
end;

procedure ApuAE; // POP A
begin
   IAPU.Registers.YA.a := Pop;
   Inc(IAPU.PC);
end;

procedure ApuAF; // MOV (X)+, A
begin
   APUSetByteDP(IAPU.Registers.YA.a, IAPU.Registers.X);
   Inc(IAPU.Registers.X);
   Inc(IAPU.PC);
end;

procedure ApuB0; // BCS
begin
   Relative;
   if IAPU.Carry then
   begin
      IAPU.PC := IAPU.RAM + Word(Int16);
      APU.Cycles := APU.Cycles + (IAPU.OneCycle shl 1);
      APUShutdown;
   end
   else
      Inc(IAPU.PC, 2);
end;

procedure ApuB1;
begin
   TCALL(11);
end;

procedure ApuB2; // CLR1 dp.5
begin
   APUSetByteDP(APUGetByteDP(OP1) and not(1 shl 5), OP1);
   Inc(IAPU.PC, 2);
end;

procedure ApuB3;
begin
   BBC_Bit(5);
end;

procedure ApuB4; // SBC A,dp+X
begin
   Work8 := APUGetByteDP(OP1 + IAPU.Registers.X);
   SBC(IAPU.Registers.YA.a, Work8);
   Inc(IAPU.PC, 2);
end;

procedure ApuB5; // SBC A,abs+X
begin
   AbsoluteX;
   Work8 := APUGetByte(IAPU.Address);
   SBC(IAPU.Registers.YA.a, Work8);
   Inc(IAPU.PC, 3);
end;

procedure ApuB6; // SBC A,abs+Y
begin
   AbsoluteY;
   Work8 := APUGetByte(IAPU.Address);
   SBC(IAPU.Registers.YA.a, Work8);
   Inc(IAPU.PC, 3);
end;

procedure ApuB7; // SBC A,(dp)+Y
begin
   IndirectIndexedY;
   Work8 := APUGetByte(IAPU.Address);
   SBC(IAPU.Registers.YA.a, Work8);
   Inc(IAPU.PC, 2);
end;

procedure ApuB8; // SBC dp,#00
begin
   Work8 := OP1;
   W1 := APUGetByteDP(OP2);
   SBC(W1, Work8);
   APUSetByteDP(W1, OP2);
   Inc(IAPU.PC, 3);
end;

procedure ApuB9; // SBC (X),(Y)
begin
   W1 := APUGetByteDP(IAPU.Registers.X);
   Work8 := APUGetByteDP(IAPU.Registers.YA.Y);
   SBC(W1, Work8);
   APUSetByteDP(W1, IAPU.Registers.X);
   Inc(IAPU.PC);
end;

procedure ApuBA; // MOVW YA,dp
begin
   IAPU.Registers.YA.a := APUGetByteDP(OP1);
   IAPU.Registers.YA.Y := APUGetByteDP(OP1 + 1);
   APUSetZN16(IAPU.Registers.YA.w);
   Inc(IAPU.PC, 2);
end;

procedure ApuBB; // INC dp+X
begin
   Work8 := APUGetByteDP(OP1 + IAPU.Registers.X) + 1;
   APUSetByteDP(Work8, OP1 + IAPU.Registers.X);
   APUSetZN8(Work8);
   Inc(IAPU.WaitCounter);
   Inc(IAPU.PC, 2);
end;

procedure ApuBC; // INC A
begin
   Inc(IAPU.Registers.YA.a);
   APUSetZN8(IAPU.Registers.YA.a);
   Inc(IAPU.WaitCounter);
   Inc(IAPU.PC);
end;

procedure ApuBD; // MOV SP,X
begin
   IAPU.Registers.S := IAPU.Registers.X;
   Inc(IAPU.PC);
end;

procedure ApuBE; // DAS
begin
   if (IAPU.Registers.YA.a > $99) or (not IAPU.Carry) then
   begin
      IAPU.Registers.YA.a := IAPU.Registers.YA.a - $60;
      IAPU.Carry := False;
   end
   else
   begin
      IAPU.Carry := True;
   end;

   if ((IAPU.Registers.YA.a and $0F) > 9) or not((IAPU.Registers.P and APU_HALF_CARRY) <> 0) then
   begin
      IAPU.Registers.YA.a := IAPU.Registers.YA.a - 6;
   end;
   APUSetZN8(IAPU.Registers.YA.a);
   Inc(IAPU.PC);
end;

procedure ApuBF; // MOV A,(X)+
begin
   IAPU.Registers.YA.a := APUGetByteDP(IAPU.Registers.X);
   Inc(IAPU.Registers.X);
   APUSetZN8(IAPU.Registers.YA.a);
   Inc(IAPU.PC);
end;

procedure ApuC0; // DI
begin
   IAPU.Registers.P := IAPU.Registers.P and not APU_INTERRUPT;
   Inc(IAPU.PC);
end;

procedure ApuC1;
begin
   TCALL(12);
end;

procedure ApuC2; // SET1 dp.6
begin
   APUSetByteDP(APUGetByteDP(OP1) or (1 shl 6), OP1);
   Inc(IAPU.PC, 2);
end;

procedure ApuC3;
begin
   BBS_Bit(6);
end;

procedure ApuC4; // MOV dp,A
begin
   APUSetByteDP(IAPU.Registers.YA.a, OP1);
   Inc(IAPU.PC, 2);
end;

procedure ApuC5; // MOV abs,A
begin
   Absolute;
   APUSetByte(IAPU.Registers.YA.a, IAPU.Address);
   Inc(IAPU.PC, 3);
end;

procedure ApuC6; // MOV (X), A
begin
   APUSetByteDP(IAPU.Registers.YA.a, IAPU.Registers.X);
   Inc(IAPU.PC);
end;

procedure ApuC7; // MOV (dp+X),A
begin
   IndexedXIndirect;
   APUSetByte(IAPU.Registers.YA.a, IAPU.Address);
   Inc(IAPU.PC, 2);
end;

procedure ApuC8; // CMP X,#00
begin
   CMP(IAPU.Registers.X, OP1);
   Inc(IAPU.PC, 2);
end;

procedure ApuC9; // MOV abs,X
begin
   Absolute;
   APUSetByte(IAPU.Registers.X, IAPU.Address);
   Inc(IAPU.PC, 3);
end;

procedure ApuCA; // MOV1 membit,C
begin
   MemBit;
   if IAPU.Carry then
      APUSetByte(APUGetByte(IAPU.Address) or (1 shl IAPU.Bit), IAPU.Address)
   else
      APUSetByte(APUGetByte(IAPU.Address) and not(1 shl IAPU.Bit), IAPU.Address);
   Inc(IAPU.PC, 3);
end;

procedure ApuCB; // MOV dp,Y
begin
   APUSetByteDP(IAPU.Registers.YA.Y, OP1);
   Inc(IAPU.PC, 2);
end;

procedure ApuCC; // MOV abs,Y
begin
   Absolute;
   APUSetByte(IAPU.Registers.YA.Y, IAPU.Address);
   Inc(IAPU.PC, 3);
end;

procedure ApuCD; // MOV X,#00
begin
   IAPU.Registers.X := OP1;
   APUSetZN8(IAPU.Registers.X);
   Inc(IAPU.PC, 2);
end;

procedure ApuCE; // POP X
begin
   IAPU.Registers.X := Pop;
   Inc(IAPU.PC);
end;

procedure ApuCF; // MUL YA
begin
   IAPU.Registers.YA.w := Word(IAPU.Registers.YA.a) * IAPU.Registers.YA.Y;
   APUSetZN8(IAPU.Registers.YA.Y);
   Inc(IAPU.PC);
end;

procedure ApuD0; // BNE
begin
   Relative;
   if not IAPU.Zero then
   begin
      IAPU.PC := IAPU.RAM + Word(Int16);
      APU.Cycles := APU.Cycles + (IAPU.OneCycle shl 1);
      APUShutdown;
   end
   else
      Inc(IAPU.PC, 2);
end;

procedure ApuD1;
begin
   TCALL(13);
end;

procedure ApuD2; // CLR1 dp.6
begin
   APUSetByteDP(APUGetByteDP(OP1) and not(1 shl 6), OP1);
   Inc(IAPU.PC, 2);
end;

procedure ApuD3;
begin
   BBC_Bit(6);
end;

procedure ApuD4;
begin
   APUSetByteDP(IAPU.Registers.YA.a, OP1 + IAPU.Registers.X);
   Inc(IAPU.PC, 2);
end;

procedure ApuD5;
begin
   AbsoluteX;
   APUSetByte(IAPU.Registers.YA.a, IAPU.Address);
   Inc(IAPU.PC, 3);
end;

procedure ApuD6;
begin
   AbsoluteY;
   APUSetByte(IAPU.Registers.YA.a, IAPU.Address);
   Inc(IAPU.PC, 3);
end;

procedure ApuD7;
begin
   IndirectIndexedY;
   APUSetByte(IAPU.Registers.YA.a, IAPU.Address);
   Inc(IAPU.PC, 2);
end;

procedure ApuD8; // MOV dp,X
begin
   APUSetByteDP(IAPU.Registers.X, OP1);
   Inc(IAPU.PC, 2);
end;

procedure ApuD9; // MOV dp+Y,X
begin
   APUSetByteDP(IAPU.Registers.X, OP1 + IAPU.Registers.YA.Y);
   Inc(IAPU.PC, 2);
end;

procedure ApuDA; // MOVW dp,YA
begin
   APUSetByteDP(IAPU.Registers.YA.a, OP1);
   APUSetByteDP(IAPU.Registers.YA.Y, OP1 + 1);
   Inc(IAPU.PC, 2);
end;

procedure ApuDB; // MOV dp+X,Y
begin
   APUSetByteDP(IAPU.Registers.YA.Y, OP1 + IAPU.Registers.X);
   Inc(IAPU.PC, 2);
end;

procedure ApuDC; // DEC Y
begin
   Dec(IAPU.Registers.YA.Y);
   APUSetZN8(IAPU.Registers.YA.Y);
   Inc(IAPU.WaitCounter);
   Inc(IAPU.PC);
end;

procedure ApuDD; // MOV A,Y
begin
   IAPU.Registers.YA.a := IAPU.Registers.YA.Y;
   APUSetZN8(IAPU.Registers.YA.a);
   Inc(IAPU.PC);
end;

procedure ApuDE; // CBNE dp+X,rel
begin
   Work8 := OP1 + IAPU.Registers.X;
   Relative2;
   if APUGetByteDP(Work8) <> IAPU.Registers.YA.a then
   begin
      IAPU.PC := IAPU.RAM + Word(Int16);
      APU.Cycles := APU.Cycles + (IAPU.OneCycle shl 1);
      APUShutdown;
   end
   else
      Inc(IAPU.PC, 3);
end;

procedure ApuDF; // DAA
begin
   if (IAPU.Registers.YA.a > $99) or IAPU.Carry then
   begin
      IAPU.Registers.YA.a := IAPU.Registers.YA.a + $60;
      IAPU.Carry := True;
   end
   else
   begin
      IAPU.Carry := False;
   end;

   if ((IAPU.Registers.YA.a and $0F) > 9) or ((IAPU.Registers.P and APU_HALF_CARRY) <> 0) then
   begin
      IAPU.Registers.YA.a := IAPU.Registers.YA.a + 6;
   end;
   APUSetZN8(IAPU.Registers.YA.a);
   Inc(IAPU.PC);
end;

procedure ApuE0; // CLRV
begin
   IAPU.Registers.P := IAPU.Registers.P and not APU_HALF_CARRY;
   IAPU.Overflow := False;
   Inc(IAPU.PC);
end;

procedure ApuE1;
begin
   TCALL(14);
end;

procedure ApuE2; // SET1 dp.7
begin
   APUSetByteDP(APUGetByteDP(OP1) or (1 shl 7), OP1);
   Inc(IAPU.PC, 2);
end;

procedure ApuE3;
begin
   BBS_Bit(7);
end;

procedure ApuE4; // MOV A,dp
begin
   IAPU.Registers.YA.a := APUGetByteDP(OP1);
   APUSetZN8(IAPU.Registers.YA.a);
   Inc(IAPU.PC, 2);
end;

procedure ApuE5; // MOV A,abs
begin
   Absolute;
   IAPU.Registers.YA.a := APUGetByte(IAPU.Address);
   APUSetZN8(IAPU.Registers.YA.a);
   Inc(IAPU.PC, 3);
end;

procedure ApuE6; // MOV A,(X)
begin
   IAPU.Registers.YA.a := APUGetByteDP(IAPU.Registers.X);
   APUSetZN8(IAPU.Registers.YA.a);
   Inc(IAPU.PC);
end;

procedure ApuE7; // MOV A,(dp+X)
begin
   IndexedXIndirect;
   IAPU.Registers.YA.a := APUGetByte(IAPU.Address);
   APUSetZN8(IAPU.Registers.YA.a);
   Inc(IAPU.PC, 2);
end;

procedure ApuE8; // MOV A,#00
begin
   IAPU.Registers.YA.a := OP1;
   APUSetZN8(IAPU.Registers.YA.a);
   Inc(IAPU.PC, 2);
end;

procedure ApuE9; // MOV X,abs
begin
   Absolute;
   IAPU.Registers.X := APUGetByte(IAPU.Address);
   APUSetZN8(IAPU.Registers.X);
   Inc(IAPU.PC, 3);
end;

procedure ApuEA; // NOT1 membit
begin
   MemBit;
   APUSetByte(APUGetByte(IAPU.Address) xor (1 shl IAPU.Bit), IAPU.Address);
   Inc(IAPU.PC, 3);
end;

procedure ApuEB; // MOV Y,dp
begin
   IAPU.Registers.YA.Y := APUGetByteDP(OP1);
   APUSetZN8(IAPU.Registers.YA.Y);
   Inc(IAPU.PC, 2);
end;

procedure ApuEC; // MOV Y,abs
begin
   Absolute;
   IAPU.Registers.YA.Y := APUGetByte(IAPU.Address);
   APUSetZN8(IAPU.Registers.YA.Y);
   Inc(IAPU.PC, 3);
end;

procedure ApuED; // NOTC
begin
   IAPU.Carry := not IAPU.Carry;
   Inc(IAPU.PC);
end;

procedure ApuEE; // POP Y
begin
   IAPU.Registers.YA.Y := Pop;
   Inc(IAPU.PC);
end;

procedure ApuEF_FF; // SLEEP / STOP
begin
   APU.TimerEnabled[0] := False;
   APU.TimerEnabled[1] := False;
   APU.TimerEnabled[2] := False;
   IAPU.Executing := False;
end;

procedure ApuF0; // BEQ
begin
   Relative;
   if IAPU.Zero then
   begin
      IAPU.PC := IAPU.RAM + Word(Int16);
      APU.Cycles := APU.Cycles + (IAPU.OneCycle shl 1);
      APUShutdown;
   end
   else
      Inc(IAPU.PC, 2);
end;

procedure ApuF1;
begin
   TCALL(15);
end;

procedure ApuF2; // CLR1 dp.7
begin
   APUSetByteDP(APUGetByteDP(OP1) and not(1 shl 7), OP1);
   Inc(IAPU.PC, 2);
end;

procedure ApuF3;
begin
   BBC_Bit(7);
end;

procedure ApuF4; // MOV A,dp+X
begin
   IAPU.Registers.YA.a := APUGetByteDP(OP1 + IAPU.Registers.X);
   APUSetZN8(IAPU.Registers.YA.a);
   Inc(IAPU.PC, 2);
end;

procedure ApuF5; // MOV A,abs+X
begin
   AbsoluteX;
   IAPU.Registers.YA.a := APUGetByte(IAPU.Address);
   APUSetZN8(IAPU.Registers.YA.a);
   Inc(IAPU.PC, 3);
end;

procedure ApuF6; // MOV A,abs+Y
begin
   AbsoluteY;
   IAPU.Registers.YA.a := APUGetByte(IAPU.Address);
   APUSetZN8(IAPU.Registers.YA.a);
   Inc(IAPU.PC, 3);
end;

procedure ApuF7; // MOV A,(dp)+Y
begin
   IndirectIndexedY;
   IAPU.Registers.YA.a := APUGetByte(IAPU.Address);
   APUSetZN8(IAPU.Registers.YA.a);
   Inc(IAPU.PC, 2);
end;

procedure ApuF8; // MOV X,dp
begin
   IAPU.Registers.X := APUGetByteDP(OP1);
   APUSetZN8(IAPU.Registers.X);
   Inc(IAPU.PC, 2);
end;

procedure ApuF9; // MOV X,dp+Y
begin
   IAPU.Registers.X := APUGetByteDP(OP1 + IAPU.Registers.YA.Y);
   APUSetZN8(IAPU.Registers.X);
   Inc(IAPU.PC, 2);
end;

procedure ApuFA; // MOV dp(dest),dp(src)
begin
   APUSetByteDP(APUGetByteDP(OP1), OP2);
   Inc(IAPU.PC, 3);
end;

procedure ApuFB; // MOV Y,dp+X
begin
   IAPU.Registers.YA.Y := APUGetByteDP(OP1 + IAPU.Registers.X);
   APUSetZN8(IAPU.Registers.YA.Y);
   Inc(IAPU.PC, 2);
end;

procedure ApuFC; // INC Y
begin
   Inc(IAPU.Registers.YA.Y);
   APUSetZN8(IAPU.Registers.YA.Y);
   Inc(IAPU.WaitCounter);
   Inc(IAPU.PC);
end;

procedure ApuFD; // MOV Y,A
begin
   IAPU.Registers.YA.Y := IAPU.Registers.YA.a;
   APUSetZN8(IAPU.Registers.YA.Y);
   Inc(IAPU.PC);
end;

procedure ApuFE; // DBNZ Y,rel
begin
   Relative;
   Dec(IAPU.Registers.YA.Y);
   if IAPU.Registers.YA.Y <> 0 then
   begin
      IAPU.PC := IAPU.RAM + Word(Int16);
      APU.Cycles := APU.Cycles + (IAPU.OneCycle shl 1);
   end
   else
      Inc(IAPU.PC, 2);
end;

procedure InitializeAPUOpcodes;
begin
   ApuOpcodes[  0] := @Apu00; ApuOpcodes[  1] := @Apu01; ApuOpcodes[  2] := @Apu02; ApuOpcodes[  3] := @Apu03; ApuOpcodes[  4] := @Apu04; ApuOpcodes[  5] := @Apu05; ApuOpcodes[  6] := @Apu06; ApuOpcodes[  7] := @Apu07;
   ApuOpcodes[  8] := @Apu08; ApuOpcodes[  9] := @Apu09; ApuOpcodes[ 10] := @Apu0A; ApuOpcodes[ 11] := @Apu0B; ApuOpcodes[ 12] := @Apu0C; ApuOpcodes[ 13] := @Apu0D; ApuOpcodes[ 14] := @Apu0E; ApuOpcodes[ 15] := @Apu0F;
   ApuOpcodes[ 16] := @Apu10; ApuOpcodes[ 17] := @Apu11; ApuOpcodes[ 18] := @Apu12; ApuOpcodes[ 19] := @Apu13; ApuOpcodes[ 20] := @Apu14; ApuOpcodes[ 21] := @Apu15; ApuOpcodes[ 22] := @Apu16; ApuOpcodes[ 23] := @Apu17;
   ApuOpcodes[ 24] := @Apu18; ApuOpcodes[ 25] := @Apu19; ApuOpcodes[ 26] := @Apu1A; ApuOpcodes[ 27] := @Apu1B; ApuOpcodes[ 28] := @Apu1C; ApuOpcodes[ 29] := @Apu1D; ApuOpcodes[ 30] := @Apu1E; ApuOpcodes[ 31] := @Apu1F;
   ApuOpcodes[ 32] := @Apu20; ApuOpcodes[ 33] := @Apu21; ApuOpcodes[ 34] := @Apu22; ApuOpcodes[ 35] := @Apu23; ApuOpcodes[ 36] := @Apu24; ApuOpcodes[ 37] := @Apu25; ApuOpcodes[ 38] := @Apu26; ApuOpcodes[ 39] := @Apu27;
   ApuOpcodes[ 40] := @Apu28; ApuOpcodes[ 41] := @Apu29; ApuOpcodes[ 42] := @Apu2A; ApuOpcodes[ 43] := @Apu2B; ApuOpcodes[ 44] := @Apu2C; ApuOpcodes[ 45] := @Apu2D; ApuOpcodes[ 46] := @Apu2E; ApuOpcodes[ 47] := @Apu2F;
   ApuOpcodes[ 48] := @Apu30; ApuOpcodes[ 49] := @Apu31; ApuOpcodes[ 50] := @Apu32; ApuOpcodes[ 51] := @Apu33; ApuOpcodes[ 52] := @Apu34; ApuOpcodes[ 53] := @Apu35; ApuOpcodes[ 54] := @Apu36; ApuOpcodes[ 55] := @Apu37;
   ApuOpcodes[ 56] := @Apu38; ApuOpcodes[ 57] := @Apu39; ApuOpcodes[ 58] := @Apu3A; ApuOpcodes[ 59] := @Apu3B; ApuOpcodes[ 60] := @Apu3C; ApuOpcodes[ 61] := @Apu3D; ApuOpcodes[ 62] := @Apu3E; ApuOpcodes[ 63] := @Apu3F;
   ApuOpcodes[ 64] := @Apu40; ApuOpcodes[ 65] := @Apu41; ApuOpcodes[ 66] := @Apu42; ApuOpcodes[ 67] := @Apu43; ApuOpcodes[ 68] := @Apu44; ApuOpcodes[ 69] := @Apu45; ApuOpcodes[ 70] := @Apu46; ApuOpcodes[ 71] := @Apu47;
   ApuOpcodes[ 72] := @Apu48; ApuOpcodes[ 73] := @Apu49; ApuOpcodes[ 74] := @Apu4A; ApuOpcodes[ 75] := @Apu4B; ApuOpcodes[ 76] := @Apu4C; ApuOpcodes[ 77] := @Apu4D; ApuOpcodes[ 78] := @Apu4E; ApuOpcodes[ 79] := @Apu4F;
   ApuOpcodes[ 80] := @Apu50; ApuOpcodes[ 81] := @Apu51; ApuOpcodes[ 82] := @Apu52; ApuOpcodes[ 83] := @Apu53; ApuOpcodes[ 84] := @Apu54; ApuOpcodes[ 85] := @Apu55; ApuOpcodes[ 86] := @Apu56; ApuOpcodes[ 87] := @Apu57;
   ApuOpcodes[ 88] := @Apu58; ApuOpcodes[ 89] := @Apu59; ApuOpcodes[ 90] := @Apu5A; ApuOpcodes[ 91] := @Apu5B; ApuOpcodes[ 92] := @Apu5C; ApuOpcodes[ 93] := @Apu5D; ApuOpcodes[ 94] := @Apu5E; ApuOpcodes[ 95] := @Apu5F;
   ApuOpcodes[ 96] := @Apu60; ApuOpcodes[ 97] := @Apu61; ApuOpcodes[ 98] := @Apu62; ApuOpcodes[ 99] := @Apu63; ApuOpcodes[100] := @Apu64; ApuOpcodes[101] := @Apu65; ApuOpcodes[102] := @Apu66; ApuOpcodes[103] := @Apu67;
   ApuOpcodes[104] := @Apu68; ApuOpcodes[105] := @Apu69; ApuOpcodes[106] := @Apu6A; ApuOpcodes[107] := @Apu6B; ApuOpcodes[108] := @Apu6C; ApuOpcodes[109] := @Apu6D; ApuOpcodes[110] := @Apu6E; ApuOpcodes[111] := @Apu6F;
   ApuOpcodes[112] := @Apu70; ApuOpcodes[113] := @Apu71; ApuOpcodes[114] := @Apu72; ApuOpcodes[115] := @Apu73; ApuOpcodes[116] := @Apu74; ApuOpcodes[117] := @Apu75; ApuOpcodes[118] := @Apu76; ApuOpcodes[119] := @Apu77;
   ApuOpcodes[120] := @Apu78; ApuOpcodes[121] := @Apu79; ApuOpcodes[122] := @Apu7A; ApuOpcodes[123] := @Apu7B; ApuOpcodes[124] := @Apu7C; ApuOpcodes[125] := @Apu7D; ApuOpcodes[126] := @Apu7E; ApuOpcodes[127] := @Apu7F;
   ApuOpcodes[128] := @Apu80; ApuOpcodes[129] := @Apu81; ApuOpcodes[130] := @Apu82; ApuOpcodes[131] := @Apu83; ApuOpcodes[132] := @Apu84; ApuOpcodes[133] := @Apu85; ApuOpcodes[134] := @Apu86; ApuOpcodes[135] := @Apu87;
   ApuOpcodes[136] := @Apu88; ApuOpcodes[137] := @Apu89; ApuOpcodes[138] := @Apu8A; ApuOpcodes[139] := @Apu8B; ApuOpcodes[140] := @Apu8C; ApuOpcodes[141] := @Apu8D; ApuOpcodes[142] := @Apu8E; ApuOpcodes[143] := @Apu8F;
   ApuOpcodes[144] := @Apu90; ApuOpcodes[145] := @Apu91; ApuOpcodes[146] := @Apu92; ApuOpcodes[147] := @Apu93; ApuOpcodes[148] := @Apu94; ApuOpcodes[149] := @Apu95; ApuOpcodes[150] := @Apu96; ApuOpcodes[151] := @Apu97;
   ApuOpcodes[152] := @Apu98; ApuOpcodes[153] := @Apu99; ApuOpcodes[154] := @Apu9A; ApuOpcodes[155] := @Apu9B; ApuOpcodes[156] := @Apu9C; ApuOpcodes[157] := @Apu9D; ApuOpcodes[158] := @Apu9E; ApuOpcodes[159] := @Apu9F;
   ApuOpcodes[160] := @ApuA0; ApuOpcodes[161] := @ApuA1; ApuOpcodes[162] := @ApuA2; ApuOpcodes[163] := @ApuA3; ApuOpcodes[164] := @ApuA4; ApuOpcodes[165] := @ApuA5; ApuOpcodes[166] := @ApuA6; ApuOpcodes[167] := @ApuA7;
   ApuOpcodes[168] := @ApuA8; ApuOpcodes[169] := @ApuA9; ApuOpcodes[170] := @ApuAA; ApuOpcodes[171] := @ApuAB; ApuOpcodes[172] := @ApuAC; ApuOpcodes[173] := @ApuAD; ApuOpcodes[174] := @ApuAE; ApuOpcodes[175] := @ApuAF;
   ApuOpcodes[176] := @ApuB0; ApuOpcodes[177] := @ApuB1; ApuOpcodes[178] := @ApuB2; ApuOpcodes[179] := @ApuB3; ApuOpcodes[180] := @ApuB4; ApuOpcodes[181] := @ApuB5; ApuOpcodes[182] := @ApuB6; ApuOpcodes[183] := @ApuB7;
   ApuOpcodes[184] := @ApuB8; ApuOpcodes[185] := @ApuB9; ApuOpcodes[186] := @ApuBA; ApuOpcodes[187] := @ApuBB; ApuOpcodes[188] := @ApuBC; ApuOpcodes[189] := @ApuBD; ApuOpcodes[190] := @ApuBE; ApuOpcodes[191] := @ApuBF;
   ApuOpcodes[192] := @ApuC0; ApuOpcodes[193] := @ApuC1; ApuOpcodes[194] := @ApuC2; ApuOpcodes[195] := @ApuC3; ApuOpcodes[196] := @ApuC4; ApuOpcodes[197] := @ApuC5; ApuOpcodes[198] := @ApuC6; ApuOpcodes[199] := @ApuC7;
   ApuOpcodes[200] := @ApuC8; ApuOpcodes[201] := @ApuC9; ApuOpcodes[202] := @ApuCA; ApuOpcodes[203] := @ApuCB; ApuOpcodes[204] := @ApuCC; ApuOpcodes[205] := @ApuCD; ApuOpcodes[206] := @ApuCE; ApuOpcodes[207] := @ApuCF;
   ApuOpcodes[208] := @ApuD0; ApuOpcodes[209] := @ApuD1; ApuOpcodes[210] := @ApuD2; ApuOpcodes[211] := @ApuD3; ApuOpcodes[212] := @ApuD4; ApuOpcodes[213] := @ApuD5; ApuOpcodes[214] := @ApuD6; ApuOpcodes[215] := @ApuD7;
   ApuOpcodes[216] := @ApuD8; ApuOpcodes[217] := @ApuD9; ApuOpcodes[218] := @ApuDA; ApuOpcodes[219] := @ApuDB; ApuOpcodes[220] := @ApuDC; ApuOpcodes[221] := @ApuDD; ApuOpcodes[222] := @ApuDE; ApuOpcodes[223] := @ApuDF;
   ApuOpcodes[224] := @ApuE0; ApuOpcodes[225] := @ApuE1; ApuOpcodes[226] := @ApuE2; ApuOpcodes[227] := @ApuE3; ApuOpcodes[228] := @ApuE4; ApuOpcodes[229] := @ApuE5; ApuOpcodes[230] := @ApuE6; ApuOpcodes[231] := @ApuE7;
   ApuOpcodes[232] := @ApuE8; ApuOpcodes[233] := @ApuE9; ApuOpcodes[234] := @ApuEA; ApuOpcodes[235] := @ApuEB; ApuOpcodes[236] := @ApuEC; ApuOpcodes[237] := @ApuED; ApuOpcodes[238] := @ApuEE; ApuOpcodes[239] := @OpEF_FF;
   ApuOpcodes[240] := @ApuF0; ApuOpcodes[241] := @ApuF1; ApuOpcodes[242] := @ApuF2; ApuOpcodes[243] := @ApuF3; ApuOpcodes[244] := @ApuF4; ApuOpcodes[245] := @ApuF5; ApuOpcodes[246] := @ApuF6; ApuOpcodes[247] := @ApuF7;
   ApuOpcodes[248] := @ApuF8; ApuOpcodes[249] := @ApuF9; ApuOpcodes[250] := @ApuFA; ApuOpcodes[251] := @ApuFB; ApuOpcodes[252] := @ApuFC; ApuOpcodes[253] := @ApuFD; ApuOpcodes[254] := @ApuFE; ApuOpcodes[255] := @OpEF_FF;
end;

end.
