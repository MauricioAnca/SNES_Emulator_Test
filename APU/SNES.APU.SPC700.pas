unit SNES.APU.SPC700;

interface

uses
   SNES.DataTypes;

// --- Funções Públicas da Unit ---
procedure APUMainLoop;
procedure ResetAPU;
procedure InitSPC700;


implementation

uses
   System.SysUtils,
   SNES.Globals,
   SNES.Memory,
   SNES.CPU,
   SNES.APU,
   SNES.APU.DSP;

const
   ACC_READ = 0;
   ACC_WRITE = 1;
   ACC_READ_WRITE = 2;

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


//**********************************************************************************
//--- Funções Auxiliares (Modos de Endereçamento, Acesso à Memória, Pilha, etc.) ---
//**********************************************************************************


// --- Funções de Acesso à Memória da APU ---

{
  APUGetByte
  ------------------------------------------------------------------------------
  Lê um byte de qualquer endereço na RAM da APU (0-$FFFF).
}
function APUGetByte(Address: Cardinal): Byte;
begin
  case Address of
    $F0..$FF: // Faixa de registradores I/O
      begin
        // A lógica de leitura de registradores é complexa e será tratada
        // em uma função dedicada quando portarmos a unit SNES.APU.pas
        // Por enquanto, lemos diretamente da RAM.
        Result := IAPU.RAM[Address];
      end;
  else
    Result := IAPU.RAM[Address];
  end;
end;

{
  APUSetByte
  ------------------------------------------------------------------------------
  Escreve um byte em qualquer endereço na RAM da APU (0-$FFFF).
}
procedure APUSetByte(val: Byte; Address: Cardinal);
begin
  case Address of
    $F0..$FF: // Faixa de registradores I/O
      begin
        // A lógica de escrita em registradores será tratada em SNES.APU.pas
        // Por enquanto, escrevemos diretamente na RAM.
        IAPU.RAM[Address] := val;
      end;
  else
    IAPU.RAM[Address] := val;
  end;
end;

{
  APUGetByteZ
  ------------------------------------------------------------------------------
  Lê um byte da Página Direta (Zero Page) da APU.
  O endereço é mascarado para 8 bits e usado como um offset a partir do
  ponteiro IAPU.DirectPage.
}
function APUGetByteZ(Address: Cardinal): Byte;
begin
  Result := IAPU.DirectPage[Address and $FF];
end;

{
  APUSetByteZ
  ------------------------------------------------------------------------------
  Escreve um byte na Página Direta (Zero Page) da APU.
}
procedure APUSetByteZ(val: Byte; Address: Cardinal);
begin
  IAPU.DirectPage[Address and $FF] := val;
end;

{
  APUGetWord
  ------------------------------------------------------------------------------
  Lê uma palavra (16 bits) de qualquer endereço na RAM da APU, tratando
  corretamente a ordem dos bytes (Little Endian).
}
function APUGetWord(Address: Cardinal): Word;
var
  l, h: Byte;
begin
  l := APUGetByte(Address);
  h := APUGetByte(Address + 1);
  Result := l or (h shl 8);
end;

{
  APUSetWord
  ------------------------------------------------------------------------------
  Escreve uma palavra (16 bits) em qualquer endereço na RAM da APU.
}
procedure APUSetWord(val: Word; Address: Cardinal);
begin
  APUSetByte(val and $FF, Address);
  APUSetByte(val shr 8, Address + 1);
end;

{
  APUGetWordZ
  ------------------------------------------------------------------------------
  Lê uma palavra (16 bits) da Página Direta da APU, tratando o wrap-around
  se a leitura começar em $FF.
}
function APUGetWordZ(Address: Cardinal): Word;
var
  l, h: Byte;
begin
  l := APUGetByteZ(Address);
  h := APUGetByteZ(Address + 1);
  Result := l or (h shl 8);
end;

{
  APUSetWordZ
  ------------------------------------------------------------------------------
  Escreve uma palavra (16 bits) na Página Direta da APU.
}
procedure APUSetWordZ(val: Word; Address: Cardinal);
begin
  APUSetByteZ(val and $FF, Address);
  APUSetByteZ(val shr 8, Address + 1);
end;

// --- Funções de Leitura de Operandos ---

function Immediate(access: Integer): Byte;
begin
  Result := IAPU.PC^;
  Inc(IAPU.PC);
end;

function ImmediateWord(access: Integer): Word;
var
  w: Word;
begin
  w := IAPU.PC^;
  Inc(IAPU.PC);
  w := w or (IAPU.PC^ shl 8);
  Inc(IAPU.PC);
  Result := w;
end;

// --- Modos de Endereçamento ---

function Direct(access: Integer): Cardinal;
begin
  Result := Immediate(access);
end;

function Absolute(access: Integer): Cardinal;
begin
  Result := ImmediateWord(access);
end;

function DirectIndexedX(access: Integer): Cardinal;
begin
  Result := (IAPU.Registers.X + IAPU.PC^);
  Inc(IAPU.PC);
end;

function DirectIndexedY(access: Integer): Cardinal;
begin
  Result := (IAPU.Registers.YA.Y + IAPU.PC^);
  Inc(IAPU.PC);
end;

function AbsoluteIndexedX(access: Integer): Cardinal;
begin
  Result := IAPU.Registers.X + ImmediateWord(access);
end;

function AbsoluteIndexedY(access: Integer): Cardinal;
begin
  Result := IAPU.Registers.YA.Y + ImmediateWord(access);
end;

function IndirectIndexedY(access: Integer): Cardinal;
var
  dp: Byte;
  addr: Word;
begin
  dp := Immediate(ACC_READ);
  addr := APUGetWordZ(dp);
  Result := addr + IAPU.Registers.YA.Y;
end;


// --- Operações de Pilha (Stack) ---

procedure Push(val: Byte);
begin
  IAPU.RAM[$100 + IAPU.Registers.S] := val;
  IAPU.Registers.S := IAPU.Registers.S - 1;
end;

function Pop: Byte;
begin
  IAPU.Registers.S := IAPU.Registers.S + 1;
  Result := IAPU.RAM[$100 + IAPU.Registers.S];
end;

procedure PushW(val: Word);
begin
  Push(val shr 8); // Empurra o byte alto (MSB) primeiro
  Push(val and $FF);  // Empurra o byte baixo (LSB)
end;

function PopW: Word;
var
  l, h: Byte;
begin
  l := Pop; // Puxa o byte baixo (LSB) primeiro
  h := Pop; // Puxa o byte alto (MSB)
  Result := l or (h shl 8);
end;

// --- Funções de Controle de Fluxo ---

procedure Branch(condition: Boolean);
var
  offset: SmallInt;
begin
  offset := SmallInt(Immediate(ACC_READ)); // Lê o offset com sinal
  if condition then
  begin
    // Adiciona 2 ciclos se o desvio for tomado
    APU.Cycles := APU.Cycles + APUCycles[2];
    IAPU.PC := PByte(NativeUInt(IAPU.PC) + offset);
  end;
end;

procedure TCALL(idx: Integer);
var
  addr: Word;
begin
  addr := $FFC0 + ((15 - idx) * 2);
  addr := APUGetWord(addr);
  PushW(IAPU.Registers.PC);
  IAPU.PC := @IAPU.RAM[addr];
end;

procedure BRK;
var
  addr: Word;
begin
  addr := APUGetWord($FFE0);
  PushW(IAPU.Registers.PC);
  APUPackStatus;
  Push(IAPU.Registers.P or APU_BREAK_FLAG);
  IAPU.Registers.P := IAPU.Registers.P and not APU_INTERRUPT_FLAG;
  IAPU.PC := @IAPU.RAM[addr];
end;

// --- Rotinas de Atualização de Flags ---

procedure APUCheckZero(b: Byte); inline;
begin
  IAPU.Zero := Ord(b = 0);
end;

procedure APUCheckNegative(b: Byte); inline;
begin
   // A flag 'Negative' é 1 se o bit 7 de 'b' for 1, e 0 caso contrário.
   IAPU.Negative := b shr 7;
end;

procedure APUUnpackStatus;
begin
  IAPU.Carry := (IAPU.Registers.P and APU_CARRY_FLAG) <> 0;
  IAPU.Zero := Ord((IAPU.Registers.P and APU_ZERO_FLAG) = 0); // Zero flag is inverted in P
  IAPU.Overflow := (IAPU.Registers.P and APU_OVERFLOW_FLAG) <> 0;
  IAPU.Negative := (IAPU.Registers.P and APU_NEGATIVE_FLAG) shr 7;
  if (IAPU.Registers.P and APU_DIRECT_PAGE_FLAG) <> 0 then
    IAPU.DirectPage := @IAPU.RAM[$100]
  else
    IAPU.DirectPage := IAPU.RAM;
end;

procedure APUPackStatus;
begin
  IAPU.Registers.P :=
    Ord(IAPU.Carry) or
    (Ord(IAPU.Zero = 0) shl 1) or // Inverte a Zero flag ao salvar
    Ord((IAPU.Registers.P and APU_INTERRUPT_FLAG) <> 0) shl 2 or
    (IAPU.Registers.P and APU_HALF_CARRY_FLAG) or
    (IAPU.Registers.P and APU_BREAK_FLAG) or
    Ord((IAPU.DirectPage = @IAPU.RAM[$100])) shl 5 or
    Ord(IAPU.Overflow) shl 6 or
    (IAPU.Negative shl 7);
end;

procedure APUPopStatus;
begin
  IAPU.Registers.P := Pop;
  APUUnpackStatus;
end;

// --- Funções Aritméticas Genéricas ---

function ADC_Generic(a, b: Byte): Byte;
var
   temp: Word;
begin
   temp := a + b + Ord(IAPU.Carry);
   IAPU.Carry := temp >= $100;
   IAPU.Zero := Ord(Byte(temp) = 0);
   APUCheckNegative(Byte(temp));

   if (((a and $F) + (b and $F) + Ord(IAPU.Carry)) > $F) then
      IAPU.Registers.P := IAPU.Registers.P or APU_HALF_CARRY_FLAG
   else
      IAPU.Registers.P := IAPU.Registers.P and not APU_HALF_CARRY_FLAG;

   if (((a xor b) and $80) = 0) and (((a xor Byte(temp)) and $80) <> 0) then
      IAPU.Overflow := True
   else
      IAPU.Overflow := False;

   Result := Byte(temp);
end;

procedure ADC(val: Byte);
begin
  IAPU.Registers.YA.A := ADC_Generic(IAPU.Registers.YA.A, val);
end;

function SBC_Generic(a, b: Byte): Byte;
var
  temp: SmallInt;
begin
  temp := SmallInt(a) - SmallInt(b) - Ord(not IAPU.Carry);
  IAPU.Carry := temp >= 0;
  IAPU.Zero := Ord(Byte(temp) = 0);
  APUCheckNegative(Byte(temp));

  if (((a and $F) - (b and $F) - Ord(not IAPU.Carry)) < 0) then
    IAPU.Registers.P := IAPU.Registers.P or APU_HALF_CARRY_FLAG
  else
    IAPU.Registers.P := IAPU.Registers.P and not APU_HALF_CARRY_FLAG;

  if (((a xor b) and $80) <> 0) and (((a xor Byte(temp)) and $80) <> 0) then
    IAPU.Overflow := True
  else
    IAPU.Overflow := False;

  Result := Byte(temp);
end;

procedure SBC(val: Byte);
begin
  IAPU.Registers.YA.A := SBC_Generic(IAPU.Registers.YA.A, val);
end;

procedure CMP_Generic(a, b: Byte);
var
  temp: SmallInt;
begin
  temp := SmallInt(a) - SmallInt(b);
  IAPU.Carry := temp >= 0;
  IAPU.Zero := Ord(Byte(temp) = 0);
  APUCheckNegative(Byte(temp));
end;

procedure ADDW(val: Word);
var
  YA: Cardinal;
begin
  YA := IAPU.Registers.YA.W + val;
  IAPU.Carry := YA >= $10000;
  IAPU.Zero := Ord(Word(YA) = 0);
  APUCheckNegative(Byte(YA shr 8));

  if (((IAPU.Registers.YA.W and $FFF) + (val and $FFF)) > $FFF) then
     IAPU.Registers.P := IAPU.Registers.P or APU_HALF_CARRY_FLAG
  else
     IAPU.Registers.P := IAPU.Registers.P and not APU_HALF_CARRY_FLAG;

  if (((IAPU.Registers.YA.W xor val) and $8000) = 0) and (((IAPU.Registers.YA.W xor Word(YA)) and $8000) <> 0) then
    IAPU.Overflow := True
  else
    IAPU.Overflow := False;

  IAPU.Registers.YA.W := Word(YA);
end;

procedure SUBW(val: Word);
var
  YA: Integer;
begin
  YA := Integer(IAPU.Registers.YA.W) - Integer(val);
  IAPU.Carry := YA >= 0;
  IAPU.Zero := Ord(Word(YA) = 0);
  APUCheckNegative(Byte(Word(YA) shr 8));

  if (((IAPU.Registers.YA.W and $FFF) - (val and $FFF)) < 0) then
     IAPU.Registers.P := IAPU.Registers.P or APU_HALF_CARRY_FLAG
  else
     IAPU.Registers.P := IAPU.Registers.P and not APU_HALF_CARRY_FLAG;

  if (((IAPU.Registers.YA.W xor val) and $8000) <> 0) and (((IAPU.Registers.YA.W xor Word(YA)) and $8000) <> 0) then
    IAPU.Overflow := True
  else
    IAPU.Overflow := False;

  IAPU.Registers.YA.W := Word(YA);
end;

procedure CMPW_Generic(a, b: Word);
var
  temp: Integer;
begin
  temp := Integer(a) - Integer(b);
  IAPU.Carry := temp >= 0;
  IAPU.Zero := Ord(Word(temp) = 0);
  APUCheckNegative(Byte(Word(temp) shr 8));
end;

// --- Funções de Deslocamento e Rotação de Bits ---

procedure ASL_Byte(addr: Cardinal);
var
  b: Byte;
begin
  b := APUGetByteZ(addr);
  IAPU.Carry := (b and $80) <> 0;
  b := b shl 1;
  APUSetByteZ(b, addr);
  APUCheckZero(b);
  APUCheckNegative(b);
end;

procedure ASL_Word(addr: Cardinal);
var
  w: Word;
begin
  w := APUGetWord(addr);
  IAPU.Carry := (w and $8000) <> 0;
  w := w shl 1;
  APUSetWord(w, addr);
  IAPU.Zero := Ord(w = 0);
  APUCheckNegative(w shr 8);
end;

procedure LSR_Byte(addr: Cardinal);
var
  b: Byte;
begin
  b := APUGetByteZ(addr);
  IAPU.Carry := (b and 1) <> 0;
  b := b shr 1;
  APUSetByteZ(b, addr);
  IAPU.Zero := Ord(b = 0);
  APUCheckNegative(b); // Sempre 0
end;

procedure LSR_Word(addr: Cardinal);
var
  w: Word;
begin
  w := APUGetWord(addr);
  IAPU.Carry := (w and 1) <> 0;
  w := w shr 1;
  APUSetWord(w, addr);
  IAPU.Zero := Ord(w = 0);
  APUCheckNegative(w shr 8); // Sempre 0
end;

procedure ROL_Byte(addr: Cardinal);
var
  b: Byte;
  c: Boolean;
begin
  b := APUGetByteZ(addr);
  c := IAPU.Carry;
  IAPU.Carry := (b and $80) <> 0;
  b := (b shl 1) or Ord(c);
  APUSetByteZ(b, addr);
  APUCheckZero(b);
  APUCheckNegative(b);
end;

procedure ROL_Word(addr: Cardinal);
var
  w: Word;
  c: Boolean;
begin
  w := APUGetWord(addr);
  c := IAPU.Carry;
  IAPU.Carry := (w and $8000) <> 0;
  w := (w shl 1) or Ord(c);
  APUSetWord(w, addr);
  IAPU.Zero := Ord(w = 0);
  APUCheckNegative(w shr 8);
end;

procedure ROR_Byte(addr: Cardinal);
var
  b: Byte;
  c: Boolean;
begin
  b := APUGetByteZ(addr);
  c := IAPU.Carry;
  IAPU.Carry := (b and 1) <> 0;
  b := (b shr 1) or (Ord(c) shl 7);
  APUSetByteZ(b, addr);
  APUCheckZero(b);
  APUCheckNegative(b);
end;

procedure ROR_Word(addr: Cardinal);
var
  w: Word;
  c: Boolean;
begin
  w := APUGetWord(addr);
  c := IAPU.Carry;
  IAPU.Carry := (w and 1) <> 0;
  w := (w shr 1) or (Ord(c) shl 15);
  APUSetWord(w, addr);
  IAPU.Zero := Ord(w = 0);
  APUCheckNegative(w shr 8);
end;

{
  ReadBit
  ------------------------------------------------------------------------------
  Função auxiliar interna que lê um byte da memória, extrai o endereço e o
  número do bit de um operando de 16 bits, e retorna o valor do bit.
}
function ReadBit(addr: Cardinal; out mem_addr: Cardinal; out bit_num: Byte): Boolean;
var
  b: Byte;
begin
  mem_addr := addr and $1FFF;
  bit_num := (addr shr 13) and 7;
  b := APUGetByte(mem_addr);
  Result := (b and (1 shl bit_num)) <> 0;
end;

{
  AND1
  ------------------------------------------------------------------------------
  Executa a operação: Carry = Carry AND BitDeMemoria
}
procedure AND1(addr: Cardinal);
var
  mem_addr: Cardinal;
  bit_num: Byte;
begin
  if not IAPU.Carry then
    Exit;
  IAPU.Carry := ReadBit(addr, mem_addr, bit_num);
end;

{
  AND1N
  ------------------------------------------------------------------------------
  Executa a operação: Carry = Carry AND (NOT BitDeMemoria)
}
procedure AND1N(addr: Cardinal);
var
  mem_addr: Cardinal;
  bit_num: Byte;
begin
  if not IAPU.Carry then
    Exit;
  IAPU.Carry := not ReadBit(addr, mem_addr, bit_num);
end;

{
  OR1
  ------------------------------------------------------------------------------
  Executa a operação: Carry = Carry OR BitDeMemoria
}
procedure OR1(addr: Cardinal);
var
  mem_addr: Cardinal;
  bit_num: Byte;
begin
  if IAPU.Carry then
    Exit;
  IAPU.Carry := ReadBit(addr, mem_addr, bit_num);
end;

{
  OR1N
  ------------------------------------------------------------------------------
  Executa a operação: Carry = Carry OR (NOT BitDeMemoria)
}
procedure OR1N(addr: Cardinal);
var
  mem_addr: Cardinal;
  bit_num: Byte;
begin
  if IAPU.Carry then
    Exit;
  IAPU.Carry := not ReadBit(addr, mem_addr, bit_num);
end;

{
  EOR1
  ------------------------------------------------------------------------------
  Executa a operação: Carry = Carry XOR BitDeMemoria
}
procedure EOR1(addr: Cardinal);
var
  mem_addr: Cardinal;
  bit_num: Byte;
begin
  IAPU.Carry := IAPU.Carry xor ReadBit(addr, mem_addr, bit_num);
end;

{
  NOT1
  ------------------------------------------------------------------------------
  Executa a operação: BitDeMemoria = NOT BitDeMemoria
}
procedure NOT1(addr: Cardinal);
var
  mem_addr: Cardinal;
  bit_num: Byte;
  b: Byte;
begin
  mem_addr := addr and $1FFF;
  bit_num := (addr shr 13) and 7;
  b := APUGetByte(mem_addr);
  b := b xor (1 shl bit_num);
  APUSetByte(b, mem_addr);
end;

{
  MOV1_C
  ------------------------------------------------------------------------------
  Executa a operação: Carry = BitDeMemoria
}
procedure MOV1_C(addr: Cardinal);
var
  mem_addr: Cardinal;
  bit_num: Byte;
begin
  IAPU.Carry := ReadBit(addr, mem_addr, bit_num);
end;

{
  MOV1_M
  ------------------------------------------------------------------------------
  Executa a operação: BitDeMemoria = Carry
}
procedure MOV1_M(addr: Cardinal);
var
  mem_addr: Cardinal;
  bit_num: Byte;
  b: Byte;
begin
  mem_addr := addr and $1FFF;
  bit_num := (addr shr 13) and 7;
  b := APUGetByte(mem_addr);
  if IAPU.Carry then
    b := b or (1 shl bit_num)
  else
    b := b and not (1 shl bit_num);
  APUSetByte(b, mem_addr);
end;

//********************************************
// --- Implementação dos Opcodes do SPC700 ---
//********************************************

// $00 NOP
procedure Apu00;
begin
  // Nenhuma operação
end;

// $01 TCALL 0
procedure Apu01;
begin
  TCALL(0);
end;

// $02 SET P (Direct Page)
procedure Apu02;
begin
  IAPU.Registers.P := IAPU.Registers.P or APU_DIRECT_PAGE_FLAG;
  IAPU.DirectPage := @IAPU.RAM[$100];
end;

// $03 BBS 0, dp, rel (Branch on Bit Set)
procedure Apu03;
var
  addr: Cardinal;
  b: Byte;
begin
  addr := Direct(ACC_READ);
  b := APUGetByteZ(addr);
  Branch((b and (1 shl 0)) <> 0);
end;

// $04 OR A, dp
procedure Apu04;
var
  addr: Cardinal;
begin
  addr := Direct(ACC_READ);
  IAPU.Registers.YA.A := IAPU.Registers.YA.A or APUGetByteZ(addr);
  APUCheckZero(IAPU.Registers.YA.A);
  APUCheckNegative(IAPU.Registers.YA.A);
end;

// $05 OR A, addr
procedure Apu05;
var
  addr: Cardinal;
begin
  addr := Absolute(ACC_READ);
  IAPU.Registers.YA.A := IAPU.Registers.YA.A or APUGetByte(addr);
  APUCheckZero(IAPU.Registers.YA.A);
  APUCheckNegative(IAPU.Registers.YA.A);
end;

// $06 OR A, (X)
procedure Apu06;
begin
  IAPU.Registers.YA.A := IAPU.Registers.YA.A or APUGetByteZ(IAPU.Registers.X);
  APUCheckZero(IAPU.Registers.YA.A);
  APUCheckNegative(IAPU.Registers.YA.A);
end;

// $07 OR A, (dp+X)
procedure Apu07;
var
  addr: Cardinal;
begin
  addr := DirectIndexedX(ACC_READ);
  IAPU.Registers.YA.A := IAPU.Registers.YA.A or APUGetByteZ(addr);
  APUCheckZero(IAPU.Registers.YA.A);
  APUCheckNegative(IAPU.Registers.YA.A);
end;

// $08 OR A, #imm
procedure Apu08;
begin
  IAPU.Registers.YA.A := IAPU.Registers.YA.A or Immediate(ACC_READ);
  APUCheckZero(IAPU.Registers.YA.A);
  APUCheckNegative(IAPU.Registers.YA.A);
end;

// $09 OR dp, dp
procedure Apu09;
var
  addr1, addr2: Cardinal;
  b: Byte;
begin
  addr1 := Direct(ACC_READ_WRITE);
  addr2 := Direct(ACC_READ);
  b := APUGetByteZ(addr1) or APUGetByteZ(addr2);
  APUSetByteZ(b, addr1);
  APUCheckZero(b);
  APUCheckNegative(b);
end;

// $0A OR1 C, addr:bit
procedure Apu0A;
begin
  OR1(Absolute(ACC_READ));
end;

// $0B ASL dp
procedure Apu0B;
var
  addr: Cardinal;
begin
  addr := Direct(ACC_READ_WRITE);
  ASL_Byte(addr);
end;

// $0C ASL addr
procedure Apu0C;
var
  addr: Cardinal;
begin
  addr := Absolute(ACC_READ_WRITE);
  ASL_Word(addr);
end;

// $0D PUSH PSW
procedure Apu0D;
begin
  APUPackStatus;
  Push(IAPU.Registers.P);
end;

// $0E TSET1 addr
procedure Apu0E;
var
  addr: Cardinal;
  b: Byte;
begin
  addr := Absolute(ACC_READ_WRITE);
  b := APUGetByte(addr);
  IAPU.Zero := Ord((IAPU.Registers.YA.A - b) = 0);
  APUCheckNegative(IAPU.Registers.YA.A - b);
  b := b or IAPU.Registers.YA.A;
  APUSetByte(b, addr);
end;

// $0F BRK
procedure Apu0F;
begin
  BRK;
end;

// $10 BPL rel (Branch on Plus)
procedure Apu10;
begin
  Branch(IAPU.Negative = 0);
end;

// $11 TCALL 1
procedure Apu11;
begin
  TCALL(1);
end;

// $12 CLR P
procedure Apu12;
begin
  IAPU.Registers.P := IAPU.Registers.P and not APU_DIRECT_PAGE_FLAG;
  IAPU.DirectPage := IAPU.RAM;
end;

// $13 BBS 1, dp, rel
procedure Apu13;
var
  addr: Cardinal;
  b: Byte;
begin
  addr := Direct(ACC_READ);
  b := APUGetByteZ(addr);
  Branch((b and (1 shl 1)) <> 0);
end;

// $14 OR A, dp+X
procedure Apu14;
var
  addr: Cardinal;
begin
  addr := DirectIndexedX(ACC_READ);
  IAPU.Registers.YA.A := IAPU.Registers.YA.A or APUGetByteZ(addr);
  APUCheckZero(IAPU.Registers.YA.A);
  APUCheckNegative(IAPU.Registers.YA.A);
end;

// $15 OR A, addr+X
procedure Apu15;
var
  addr: Cardinal;
begin
  addr := AbsoluteIndexedX(ACC_READ);
  IAPU.Registers.YA.A := IAPU.Registers.YA.A or APUGetByte(addr);
  APUCheckZero(IAPU.Registers.YA.A);
  APUCheckNegative(IAPU.Registers.YA.A);
end;

// $16 OR A, addr+Y
procedure Apu16;
var
  addr: Cardinal;
begin
  addr := AbsoluteIndexedY(ACC_READ);
  IAPU.Registers.YA.A := IAPU.Registers.YA.A or APUGetByte(addr);
  APUCheckZero(IAPU.Registers.YA.A);
  APUCheckNegative(IAPU.Registers.YA.A);
end;

// $17 OR A, (dp)+Y
procedure Apu17;
var
  addr: Cardinal;
begin
  addr := IndirectIndexedY(ACC_READ);
  IAPU.Registers.YA.A := IAPU.Registers.YA.A or APUGetByteZ(addr);
  APUCheckZero(IAPU.Registers.YA.A);
  APUCheckNegative(IAPU.Registers.YA.A);
end;

// $18 OR dp, #imm
procedure Apu18;
var
  addr: Cardinal;
  b: Byte;
begin
  addr := Direct(ACC_READ_WRITE);
  b := APUGetByteZ(addr) or Immediate(ACC_READ);
  APUSetByteZ(b, addr);
  APUCheckZero(b);
  APUCheckNegative(b);
end;

// $19 OR (X), (Y)
procedure Apu19;
var
  b: Byte;
begin
  b := APUGetByteZ(IAPU.Registers.X) or APUGetByteZ(IAPU.Registers.YA.Y);
  APUSetByteZ(b, IAPU.Registers.X);
  APUCheckZero(b);
  APUCheckNegative(b);
end;

// $1A DECW dp
procedure Apu1A;
var
  addr: Cardinal;
  w: Word;
begin
  addr := Direct(ACC_READ_WRITE);
  w := APUGetWordZ(addr) - 1;
  APUSetWordZ(w, addr);
  IAPU.Zero := Ord(w = 0);
  APUCheckNegative(w shr 8);
end;

// $1B ASL dp+X
procedure Apu1B;
var
  addr: Cardinal;
begin
  addr := DirectIndexedX(ACC_READ_WRITE);
  ASL_Byte(addr);
end;

// $1C ASL A
procedure Apu1C;
var
  b: Byte;
begin
  b := IAPU.Registers.YA.A;
  IAPU.Carry := (b and $80) <> 0;
  b := b shl 1;
  IAPU.Registers.YA.A := b;
  APUCheckZero(b);
  APUCheckNegative(b);
end;

// $1D DEC X
procedure Apu1D;
begin
  IAPU.Registers.X := IAPU.Registers.X - 1;
  IAPU.Zero := Ord(IAPU.Registers.X = 0);
  APUCheckNegative(IAPU.Registers.X);
end;

// $1E CMP X, addr
procedure Apu1E;
var
  addr: Cardinal;
begin
  addr := Absolute(ACC_READ);
  CMP_Generic(IAPU.Registers.X, APUGetByte(addr));
end;

// $1F JMP (addr+X)
procedure Apu1F;
begin
  IAPU.PC := @IAPU.RAM[APUGetWord(AbsoluteIndexedX(ACC_READ))];
end;

// $20 CLR V
procedure Apu20;
begin
  IAPU.Overflow := False;
  IAPU.Registers.P := IAPU.Registers.P and not APU_HALF_CARRY_FLAG;
end;

// $21 TCALL 2
procedure Apu21;
begin
  TCALL(2);
end;

// $22 SET1 dp.1
procedure Apu22;
begin
  // Placeholder - SET1 é um opcode "ilegal" mas referenciado.
  // Pode ser tratado como NOP ou implementar a lógica específica se necessário.
end;

// $23 BBS 2, dp, rel
procedure Apu23;
var
  addr: Cardinal;
  b: Byte;
begin
  addr := Direct(ACC_READ);
  b := APUGetByteZ(addr);
  Branch((b and (1 shl 2)) <> 0);
end;

// $24 AND A, dp
procedure Apu24;
var
  addr: Cardinal;
begin
  addr := Direct(ACC_READ);
  IAPU.Registers.YA.A := IAPU.Registers.YA.A and APUGetByteZ(addr);
  APUCheckZero(IAPU.Registers.YA.A);
  APUCheckNegative(IAPU.Registers.YA.A);
end;

// $25 AND A, addr
procedure Apu25;
var
  addr: Cardinal;
begin
  addr := Absolute(ACC_READ);
  IAPU.Registers.YA.A := IAPU.Registers.YA.A and APUGetByte(addr);
  APUCheckZero(IAPU.Registers.YA.A);
  APUCheckNegative(IAPU.Registers.YA.A);
end;

// $26 AND A, (X)
procedure Apu26;
begin
  IAPU.Registers.YA.A := IAPU.Registers.YA.A and APUGetByteZ(IAPU.Registers.X);
  APUCheckZero(IAPU.Registers.YA.A);
  APUCheckNegative(IAPU.Registers.YA.A);
end;

// $27 AND A, (dp+X)
procedure Apu27;
var
  addr: Cardinal;
begin
  addr := DirectIndexedX(ACC_READ);
  IAPU.Registers.YA.A := IAPU.Registers.YA.A and APUGetByteZ(addr);
  APUCheckZero(IAPU.Registers.YA.A);
  APUCheckNegative(IAPU.Registers.YA.A);
end;

// $28 AND A, #imm
procedure Apu28;
begin
  IAPU.Registers.YA.A := IAPU.Registers.YA.A and Immediate(ACC_READ);
  APUCheckZero(IAPU.Registers.YA.A);
  APUCheckNegative(IAPU.Registers.YA.A);
end;

// $29 AND dp, dp
procedure Apu29;
var
  addr1, addr2: Cardinal;
  b: Byte;
begin
  addr1 := Direct(ACC_READ_WRITE);
  addr2 := Direct(ACC_READ);
  b := APUGetByteZ(addr1) and APUGetByteZ(addr2);
  APUSetByteZ(b, addr1);
  APUCheckZero(b);
  APUCheckNegative(b);
end;

// $2A OR1 C, /addr:bit
procedure Apu2A;
begin
  NOT1(Absolute(ACC_READ));
end;

// $2B ROL dp
procedure Apu2B;
var
  addr: Cardinal;
begin
  addr := Direct(ACC_READ_WRITE);
  ROL_Byte(addr);
end;

// $2C ROL addr
procedure Apu2C;
var
  addr: Cardinal;
begin
  addr := Absolute(ACC_READ_WRITE);
  ROL_Word(addr);
end;

// $2D PUSH A
procedure Apu2D;
begin
  Push(IAPU.Registers.YA.A);
end;

// $2E CBNE dp, rel
procedure Apu2E;
var
  addr: Cardinal;
  b: Byte;
begin
  addr := Direct(ACC_READ);
  b := APUGetByteZ(addr);
  Branch(IAPU.Registers.YA.A <> b);
end;

// $2F BRA rel
procedure Apu2F;
begin
  Branch(True);
end;

// $30 BMI rel (Branch on Minus)
procedure Apu30;
begin
  Branch(IAPU.Negative <> 0);
end;

// $31 TCALL 3
procedure Apu31;
begin
  TCALL(3);
end;

// $32 SET1 dp.1
procedure Apu32;
begin
  // Placeholder - SET1 é um opcode "ilegal"
end;

// $33 BBS 3, dp, rel
procedure Apu33;
var
  addr: Cardinal;
  b: Byte;
begin
  addr := Direct(ACC_READ);
  b := APUGetByteZ(addr);
  Branch((b and (1 shl 3)) <> 0);
end;

// $34 AND A, dp+X
procedure Apu34;
var
  addr: Cardinal;
begin
  addr := DirectIndexedX(ACC_READ);
  IAPU.Registers.YA.A := IAPU.Registers.YA.A and APUGetByteZ(addr);
  APUCheckZero(IAPU.Registers.YA.A);
  APUCheckNegative(IAPU.Registers.YA.A);
end;

// $35 AND A, addr+X
procedure Apu35;
var
  addr: Cardinal;
begin
  addr := AbsoluteIndexedX(ACC_READ);
  IAPU.Registers.YA.A := IAPU.Registers.YA.A and APUGetByte(addr);
  APUCheckZero(IAPU.Registers.YA.A);
  APUCheckNegative(IAPU.Registers.YA.A);
end;

// $36 AND A, addr+Y
procedure Apu36;
var
  addr: Cardinal;
begin
  addr := AbsoluteIndexedY(ACC_READ);
  IAPU.Registers.YA.A := IAPU.Registers.YA.A and APUGetByte(addr);
  APUCheckZero(IAPU.Registers.YA.A);
  APUCheckNegative(IAPU.Registers.YA.A);
end;

// $37 AND A, (dp)+Y
procedure Apu37;
var
  addr: Cardinal;
begin
  addr := IndirectIndexedY(ACC_READ);
  IAPU.Registers.YA.A := IAPU.Registers.YA.A and APUGetByteZ(addr);
  APUCheckZero(IAPU.Registers.YA.A);
  APUCheckNegative(IAPU.Registers.YA.A);
end;

// $38 AND dp, #imm
procedure Apu38;
var
  addr: Cardinal;
  b: Byte;
begin
  addr := Direct(ACC_READ_WRITE);
  b := APUGetByteZ(addr) and Immediate(ACC_READ);
  APUSetByteZ(b, addr);
  APUCheckZero(b);
  APUCheckNegative(b);
end;

// $39 AND (X), (Y)
procedure Apu39;
var
  b: Byte;
begin
  b := APUGetByteZ(IAPU.Registers.X) and APUGetByteZ(IAPU.Registers.YA.Y);
  APUSetByteZ(b, IAPU.Registers.X);
  APUCheckZero(b);
  APUCheckNegative(b);
end;

// $3A INCW dp
procedure Apu3A;
var
  addr: Cardinal;
  w: Word;
begin
  addr := Direct(ACC_READ_WRITE);
  w := APUGetWordZ(addr) + 1;
  APUSetWordZ(w, addr);
  IAPU.Zero := Ord(w = 0);
  APUCheckNegative(w shr 8);
end;

// $3B ROL dp+X
procedure Apu3B;
var
  addr: Cardinal;
begin
  addr := DirectIndexedX(ACC_READ_WRITE);
  ROL_Byte(addr);
end;

// $3C ROL A
procedure Apu3C;
var
  b: Byte;
  c: Boolean;
begin
  b := IAPU.Registers.YA.A;
  c := IAPU.Carry;
  IAPU.Carry := (b and $80) <> 0;
  b := (b shl 1) or Ord(c);
  IAPU.Registers.YA.A := b;
  APUCheckZero(b);
  APUCheckNegative(b);
end;

// $3D INC X
procedure Apu3D;
begin
  IAPU.Registers.X := IAPU.Registers.X + 1;
  IAPU.Zero := Ord(IAPU.Registers.X = 0);
  APUCheckNegative(IAPU.Registers.X);
end;

// $3E CMP X, dp
procedure Apu3E;
var
  addr: Cardinal;
begin
  addr := Direct(ACC_READ);
  CMP_Generic(IAPU.Registers.X, APUGetByteZ(addr));
end;

// $3F CALL addr
procedure Apu3F;
var
  addr: Word;
begin
  addr := Absolute(ACC_READ);
  PushW(IAPU.Registers.PC);
  IAPU.PC := @IAPU.RAM[addr];
end;

// $40 SET C (Carry)
procedure Apu40;
begin
  IAPU.Carry := True;
end;

// $41 TCALL 4
procedure Apu41;
begin
  TCALL(4);
end;

// $42 SET1 dp.2
procedure Apu42;
begin
  // Placeholder - SET1 é um opcode "ilegal"
end;

// $43 BBS 4, dp, rel
procedure Apu43;
var
  addr: Cardinal;
  b: Byte;
begin
  addr := Direct(ACC_READ);
  b := APUGetByteZ(addr);
  Branch((b and (1 shl 4)) <> 0);
end;

// $44 EOR A, dp
procedure Apu44;
var
  addr: Cardinal;
begin
  addr := Direct(ACC_READ);
  IAPU.Registers.YA.A := IAPU.Registers.YA.A xor APUGetByteZ(addr);
  APUCheckZero(IAPU.Registers.YA.A);
  APUCheckNegative(IAPU.Registers.YA.A);
end;

// $45 EOR A, addr
procedure Apu45;
var
  addr: Cardinal;
begin
  addr := Absolute(ACC_READ);
  IAPU.Registers.YA.A := IAPU.Registers.YA.A xor APUGetByte(addr);
  APUCheckZero(IAPU.Registers.YA.A);
  APUCheckNegative(IAPU.Registers.YA.A);
end;

// $46 EOR A, (X)
procedure Apu46;
begin
  IAPU.Registers.YA.A := IAPU.Registers.YA.A xor APUGetByteZ(IAPU.Registers.X);
  APUCheckZero(IAPU.Registers.YA.A);
  APUCheckNegative(IAPU.Registers.YA.A);
end;

// $47 EOR A, (dp+X)
procedure Apu47;
var
  addr: Cardinal;
begin
  addr := DirectIndexedX(ACC_READ);
  IAPU.Registers.YA.A := IAPU.Registers.YA.A xor APUGetByteZ(addr);
  APUCheckZero(IAPU.Registers.YA.A);
  APUCheckNegative(IAPU.Registers.YA.A);
end;

// $48 EOR A, #imm
procedure Apu48;
begin
  IAPU.Registers.YA.A := IAPU.Registers.YA.A xor Immediate(ACC_READ);
  APUCheckZero(IAPU.Registers.YA.A);
  APUCheckNegative(IAPU.Registers.YA.A);
end;

// $49 EOR dp, dp
procedure Apu49;
var
  addr1, addr2: Cardinal;
  b: Byte;
begin
  addr1 := Direct(ACC_READ_WRITE);
  addr2 := Direct(ACC_READ);
  b := APUGetByteZ(addr1) xor APUGetByteZ(addr2);
  APUSetByteZ(b, addr1);
  APUCheckZero(b);
  APUCheckNegative(b);
end;

// $4A AND1 C, addr:bit
procedure Apu4A;
begin
  AND1(Absolute(ACC_READ));
end;

// $4B LSR dp
procedure Apu4B;
var
  addr: Cardinal;
begin
  addr := Direct(ACC_READ_WRITE);
  LSR_Byte(addr);
end;

// $4C LSR addr
procedure Apu4C;
var
  addr: Cardinal;
begin
  addr := Absolute(ACC_READ_WRITE);
  LSR_Word(addr);
end;

// $4D PUSH X
procedure Apu4D;
begin
  Push(IAPU.Registers.X);
end;

// $4E TCLR1 addr
procedure Apu4E;
var
  addr: Cardinal;
  b: Byte;
begin
  addr := Absolute(ACC_READ_WRITE);
  b := APUGetByte(addr);
  IAPU.Zero := Ord((IAPU.Registers.YA.A - b) = 0);
  APUCheckNegative(IAPU.Registers.YA.A - b);
  b := b and not IAPU.Registers.YA.A;
  APUSetByte(b, addr);
end;

// $4F PCALL u
procedure Apu4F;
var
  addr: Word;
begin
  addr := $FF00 + (Immediate(ACC_READ) shl 1);
  addr := APUGetWord(addr);
  PushW(IAPU.Registers.PC);
  IAPU.PC := @IAPU.RAM[addr];
end;

// $50 BVC rel (Branch on Overflow Clear)
procedure Apu50;
begin
  Branch(not IAPU.Overflow);
end;

// $51 TCALL 5
procedure Apu51;
begin
  TCALL(5);
end;

// $52 CLR1 dp.2
procedure Apu52;
begin
  // Placeholder - CLR1 é um opcode "ilegal"
end;

// $53 BBS 5, dp, rel
procedure Apu53;
var
  addr: Cardinal;
  b: Byte;
begin
  addr := Direct(ACC_READ);
  b := APUGetByteZ(addr);
  Branch((b and (1 shl 5)) <> 0);
end;

// $54 EOR A, dp+X
procedure Apu54;
var
  addr: Cardinal;
begin
  addr := DirectIndexedX(ACC_READ);
  IAPU.Registers.YA.A := IAPU.Registers.YA.A xor APUGetByteZ(addr);
  APUCheckZero(IAPU.Registers.YA.A);
  APUCheckNegative(IAPU.Registers.YA.A);
end;

// $55 EOR A, addr+X
procedure Apu55;
var
  addr: Cardinal;
begin
  addr := AbsoluteIndexedX(ACC_READ);
  IAPU.Registers.YA.A := IAPU.Registers.YA.A xor APUGetByte(addr);
  APUCheckZero(IAPU.Registers.YA.A);
  APUCheckNegative(IAPU.Registers.YA.A);
end;

// $56 EOR A, addr+Y
procedure Apu56;
var
  addr: Cardinal;
begin
  addr := AbsoluteIndexedY(ACC_READ);
  IAPU.Registers.YA.A := IAPU.Registers.YA.A xor APUGetByte(addr);
  APUCheckZero(IAPU.Registers.YA.A);
  APUCheckNegative(IAPU.Registers.YA.A);
end;

// $57 EOR A, (dp)+Y
procedure Apu57;
var
  addr: Cardinal;
begin
  addr := IndirectIndexedY(ACC_READ);
  IAPU.Registers.YA.A := IAPU.Registers.YA.A xor APUGetByteZ(addr);
  APUCheckZero(IAPU.Registers.YA.A);
  APUCheckNegative(IAPU.Registers.YA.A);
end;

// $58 EOR dp, #imm
procedure Apu58;
var
  addr: Cardinal;
  b: Byte;
begin
  addr := Direct(ACC_READ_WRITE);
  b := APUGetByteZ(addr) xor Immediate(ACC_READ);
  APUSetByteZ(b, addr);
  APUCheckZero(b);
  APUCheckNegative(b);
end;

// $59 EOR (X), (Y)
procedure Apu59;
var
  b: Byte;
begin
  b := APUGetByteZ(IAPU.Registers.X) xor APUGetByteZ(IAPU.Registers.YA.Y);
  APUSetByteZ(b, IAPU.Registers.X);
  APUCheckZero(b);
  APUCheckNegative(b);
end;

// $5A CMPW YA, dp
procedure Apu5A;
var
  addr: Cardinal;
begin
  addr := Direct(ACC_READ);
  CMPW_Generic(IAPU.Registers.YA.W, APUGetWordZ(addr));
end;

// $5B LSR dp+X
procedure Apu5B;
var
  addr: Cardinal;
begin
  addr := DirectIndexedX(ACC_READ_WRITE);
  LSR_Byte(addr);
end;

// $5C LSR A
procedure Apu5C;
var
  b: Byte;
begin
  b := IAPU.Registers.YA.A;
  IAPU.Carry := (b and 1) <> 0;
  b := b shr 1;
  IAPU.Registers.YA.A := b;
  IAPU.Zero := Ord(b = 0);
  APUCheckNegative(b); // Sempre 0
end;

// $5D MOV X, A
procedure Apu5D;
begin
  IAPU.Registers.X := IAPU.Registers.YA.A;
  IAPU.Zero := Ord(IAPU.Registers.X = 0);
  APUCheckNegative(IAPU.Registers.X);
end;

// $5E CMP Y, addr
procedure Apu5E;
var
  addr: Cardinal;
begin
  addr := Absolute(ACC_READ);
  CMP_Generic(IAPU.Registers.YA.Y, APUGetByte(addr));
end;

// $5F JMP addr
procedure Apu5F;
begin
  IAPU.PC := @IAPU.RAM[Absolute(ACC_READ)];
end;

// $60 CLR C
procedure Apu60;
begin
  IAPU.Carry := False;
end;

// $61 TCALL 6
procedure Apu61;
begin
  TCALL(6);
end;

// $62 SET1 dp.3
procedure Apu62;
begin
  // Placeholder - SET1 é um opcode "ilegal"
end;

// $63 BBS 6, dp, rel
procedure Apu63;
var
  addr: Cardinal;
  b: Byte;
begin
  addr := Direct(ACC_READ);
  b := APUGetByteZ(addr);
  Branch((b and (1 shl 6)) <> 0);
end;

// $64 CMP A, dp
procedure Apu64;
var
  addr: Cardinal;
begin
  addr := Direct(ACC_READ);
  CMP_Generic(IAPU.Registers.YA.A, APUGetByteZ(addr));
end;

// $65 CMP A, addr
procedure Apu65;
var
  addr: Cardinal;
begin
  addr := Absolute(ACC_READ);
  CMP_Generic(IAPU.Registers.YA.A, APUGetByte(addr));
end;

// $66 CMP A, (X)
procedure Apu66;
begin
  CMP_Generic(IAPU.Registers.YA.A, APUGetByteZ(IAPU.Registers.X));
end;

// $67 CMP A, (dp+X)
procedure Apu67;
var
  addr: Cardinal;
begin
  addr := DirectIndexedX(ACC_READ);
  CMP_Generic(IAPU.Registers.YA.A, APUGetByteZ(addr));
end;

// $68 CMP A, #imm
procedure Apu68;
begin
  CMP_Generic(IAPU.Registers.YA.A, Immediate(ACC_READ));
end;

// $69 CMP dp, dp
procedure Apu69;
var
  addr1, addr2: Cardinal;
begin
  addr1 := Direct(ACC_READ);
  addr2 := Direct(ACC_READ);
  CMP_Generic(APUGetByteZ(addr1), APUGetByteZ(addr2));
end;

// $6A AND1 C, /addr:bit
procedure Apu6A;
begin
  AND1N(Absolute(ACC_READ));
end;

// $6B ROR dp
procedure Apu6B;
var
  addr: Cardinal;
begin
  addr := Direct(ACC_READ_WRITE);
  ROR_Byte(addr);
end;

// $6C ROR addr
procedure Apu6C;
var
  addr: Cardinal;
begin
  addr := Absolute(ACC_READ_WRITE);
  ROR_Word(addr);
end;

// $6D PUSH Y
procedure Apu6D;
begin
  Push(IAPU.Registers.YA.Y);
end;

// $6E DBNE dp, rel
procedure Apu6E;
var
  addr: Cardinal;
  b: Byte;
begin
  addr := Direct(ACC_READ_WRITE);
  b := APUGetByteZ(addr) - 1;
  APUSetByteZ(b, addr);
  Branch(b <> 0);
end;

// $6F RET
procedure Apu6F;
begin
  IAPU.Registers.PC := PopW;
  IAPU.PC := @IAPU.RAM[IAPU.Registers.PC];
end;

// $70 BVS rel (Branch on Overflow Set)
procedure Apu70;
begin
  Branch(IAPU.Overflow);
end;

// $71 TCALL 7
procedure Apu71;
begin
  TCALL(7);
end;

// $72 CLR1 dp.3
procedure Apu72;
begin
  // Placeholder - CLR1 é um opcode "ilegal"
end;

// $73 BBS 7, dp, rel
procedure Apu73;
var
  addr: Cardinal;
  b: Byte;
begin
  addr := Direct(ACC_READ);
  b := APUGetByteZ(addr);
  Branch((b and (1 shl 7)) <> 0);
end;

// $74 CMP A, dp+X
procedure Apu74;
var
  addr: Cardinal;
begin
  addr := DirectIndexedX(ACC_READ);
  CMP_Generic(IAPU.Registers.YA.A, APUGetByteZ(addr));
end;

// $75 CMP A, addr+X
procedure Apu75;
var
  addr: Cardinal;
begin
  addr := AbsoluteIndexedX(ACC_READ);
  CMP_Generic(IAPU.Registers.YA.A, APUGetByte(addr));
end;

// $76 CMP A, addr+Y
procedure Apu76;
var
  addr: Cardinal;
begin
  addr := AbsoluteIndexedY(ACC_READ);
  CMP_Generic(IAPU.Registers.YA.A, APUGetByte(addr));
end;

// $77 CMP A, (dp)+Y
procedure Apu77;
var
  addr: Cardinal;
begin
  addr := IndirectIndexedY(ACC_READ);
  CMP_Generic(IAPU.Registers.YA.A, APUGetByteZ(addr));
end;

// $78 CMP dp, #imm
procedure Apu78;
var
  addr: Cardinal;
begin
  addr := Direct(ACC_READ);
  CMP_Generic(APUGetByteZ(addr), Immediate(ACC_READ));
end;

// $79 CMP (X), (Y)
procedure Apu79;
begin
  CMP_Generic(APUGetByteZ(IAPU.Registers.X), APUGetByteZ(IAPU.Registers.YA.Y));
end;

// $7A ADDW YA, dp
procedure Apu7A;
var
  addr: Cardinal;
begin
  addr := Direct(ACC_READ);
  ADDW(APUGetWordZ(addr));
end;

// $7B ROR dp+X
procedure Apu7B;
var
  addr: Cardinal;
begin
  addr := DirectIndexedX(ACC_READ_WRITE);
  ROR_Byte(addr);
end;

// $7C ROR A
procedure Apu7C;
var
  b: Byte;
  c: Boolean;
begin
  b := IAPU.Registers.YA.A;
  c := IAPU.Carry;
  IAPU.Carry := (b and 1) <> 0;
  b := (b shr 1) or (Ord(c) shl 7);
  IAPU.Registers.YA.A := b;
  APUCheckZero(b);
  APUCheckNegative(b);
end;

// $7D MOV A, X
procedure Apu7D;
begin
  IAPU.Registers.YA.A := IAPU.Registers.X;
  IAPU.Zero := Ord(IAPU.Registers.YA.A = 0);
  APUCheckNegative(IAPU.Registers.YA.A);
end;

// $7E CMP Y, dp
procedure Apu7E;
var
  addr: Cardinal;
begin
  addr := Direct(ACC_READ);
  CMP_Generic(IAPU.Registers.YA.Y, APUGetByteZ(addr));
end;

// $7F RETI
procedure Apu7F;
begin
  APUPopStatus;
  IAPU.Registers.PC := PopW;
  IAPU.PC := @IAPU.RAM[IAPU.Registers.PC];
end;

// $80 SET C
procedure Apu80;
begin
  IAPU.Carry := True;
end;

// $81 TCALL 8
procedure Apu81;
begin
  TCALL(8);
end;

// $82 SET1 dp.4
procedure Apu82;
begin
  // Placeholder - SET1 é um opcode "ilegal"
end;

// $83 BBC 0, dp, rel (Branch on Bit Clear)
procedure Apu83;
var
  addr: Cardinal;
  b: Byte;
begin
  addr := Direct(ACC_READ);
  b := APUGetByteZ(addr);
  Branch((b and (1 shl 0)) = 0);
end;

// $84 ADC A, dp
procedure Apu84;
var
  addr: Cardinal;
begin
  addr := Direct(ACC_READ);
  ADC(APUGetByteZ(addr));
end;

// $85 ADC A, addr
procedure Apu85;
var
  addr: Cardinal;
begin
  addr := Absolute(ACC_READ);
  ADC(APUGetByte(addr));
end;

// $86 ADC A, (X)
procedure Apu86;
begin
  ADC(APUGetByteZ(IAPU.Registers.X));
end;

// $87 ADC A, (dp+X)
procedure Apu87;
var
  addr: Cardinal;
begin
  addr := DirectIndexedX(ACC_READ);
  ADC(APUGetByteZ(addr));
end;

// $88 ADC A, #imm
procedure Apu88;
begin
  ADC(Immediate(ACC_READ));
end;

// $89 ADC dp, dp
procedure Apu89;
var
  addr1, addr2: Cardinal;
  b: Byte;
begin
  addr1 := Direct(ACC_READ);
  addr2 := Direct(ACC_READ_WRITE);
  b := ADC_Generic(APUGetByteZ(addr1), APUGetByteZ(addr2));
  APUSetByteZ(b, addr2);
end;

// $8A EOR1 C, addr:bit
procedure Apu8A;
begin
  EOR1(Absolute(ACC_READ));
end;

// $8B DEC dp
procedure Apu8B;
var
  addr: Cardinal;
  b: Byte;
begin
  addr := Direct(ACC_READ_WRITE);
  b := APUGetByteZ(addr) - 1;
  APUSetByteZ(b, addr);
  IAPU.Zero := Ord(b = 0);
  APUCheckNegative(b);
end;

// $8C DEC addr
procedure Apu8C;
var
  addr: Cardinal;
  b: Byte;
begin
  addr := Absolute(ACC_READ_WRITE);
  b := APUGetByte(addr) - 1;
  APUSetByte(b, addr);
  IAPU.Zero := Ord(b = 0);
  APUCheckNegative(b);
end;

// $8D MOV Y, #imm
procedure Apu8D;
begin
  IAPU.Registers.YA.Y := Immediate(ACC_READ);
  IAPU.Zero := Ord(IAPU.Registers.YA.Y = 0);
  APUCheckNegative(IAPU.Registers.YA.Y);
end;

// $8E POP PSW
procedure Apu8E;
begin
  IAPU.Registers.P := Pop;
  APUUnpackStatus;
end;

// $8F MOV dp, #imm
procedure Apu8F;
var
  addr: Cardinal;
  b: Byte;
begin
  b := Immediate(ACC_READ);
  addr := Direct(ACC_WRITE);
  APUSetByteZ(b, addr);
end;

// $90 BCC rel (Branch on Carry Clear)
procedure Apu90;
begin
  Branch(not IAPU.Carry);
end;

// $91 TCALL 9
procedure Apu91;
begin
  TCALL(9);
end;

// $92 CLR1 dp.4
procedure Apu92;
begin
  // Placeholder - CLR1 é um opcode "ilegal"
end;

// $93 BBC 1, dp, rel
procedure Apu93;
var
  addr: Cardinal;
  b: Byte;
begin
  addr := Direct(ACC_READ);
  b := APUGetByteZ(addr);
  Branch((b and (1 shl 1)) = 0);
end;

// $94 ADC A, dp+X
procedure Apu94;
var
  addr: Cardinal;
begin
  addr := DirectIndexedX(ACC_READ);
  ADC(APUGetByteZ(addr));
end;

// $95 ADC A, addr+X
procedure Apu95;
var
  addr: Cardinal;
begin
  addr := AbsoluteIndexedX(ACC_READ);
  ADC(APUGetByte(addr));
end;

// $96 ADC A, addr+Y
procedure Apu96;
var
  addr: Cardinal;
begin
  addr := AbsoluteIndexedY(ACC_READ);
  ADC(APUGetByte(addr));
end;

// $97 ADC A, (dp)+Y
procedure Apu97;
var
  addr: Cardinal;
begin
  addr := IndirectIndexedY(ACC_READ);
  ADC(APUGetByteZ(addr));
end;

// $98 ADC dp, #imm
procedure Apu98;
var
  addr: Cardinal;
  b: Byte;
begin
  addr := Direct(ACC_READ_WRITE);
  b := ADC_Generic(APUGetByteZ(addr), Immediate(ACC_READ));
  APUSetByteZ(b, addr);
end;

// $99 ADC (X), (Y)
procedure Apu99;
var
  b: Byte;
begin
  b := ADC_Generic(APUGetByteZ(IAPU.Registers.X), APUGetByteZ(IAPU.Registers.YA.Y));
  APUSetByteZ(b, IAPU.Registers.X);
end;

// $9A SUBW YA, dp
procedure Apu9A;
var
  addr: Cardinal;
begin
  addr := Direct(ACC_READ);
  SUBW(APUGetWordZ(addr));
end;

// $9B DEC dp+X
procedure Apu9B;
var
  addr: Cardinal;
  b: Byte;
begin
  addr := DirectIndexedX(ACC_READ_WRITE);
  b := APUGetByteZ(addr) - 1;
  APUSetByteZ(b, addr);
  IAPU.Zero := Ord(b = 0);
  APUCheckNegative(b);
end;

// $9C DEC A
procedure Apu9C;
begin
  IAPU.Registers.YA.A := IAPU.Registers.YA.A - 1;
  IAPU.Zero := Ord(IAPU.Registers.YA.A = 0);
  APUCheckNegative(IAPU.Registers.YA.A);
end;

// $9D MOV X, SP
procedure Apu9D;
begin
  IAPU.Registers.X := IAPU.Registers.S;
  IAPU.Zero := Ord(IAPU.Registers.X = 0);
  APUCheckNegative(IAPU.Registers.X);
end;

// $9E DIV YA, X
procedure Apu9E;
var
  YA: Word;
  Y, A, X, _div, Rem: Word;
begin
  YA := IAPU.Registers.YA.W;
  X := IAPU.Registers.X;

  // A divisão no SPC700 é indefinida se X for 0
  if X = 0 then
  begin
    IAPU.Registers.YA.W := $FFFF;
    IAPU.Overflow := True;
    IAPU.Registers.P := IAPU.Registers.P or APU_HALF_CARRY_FLAG;
  end
  else
  begin
    Y := IAPU.Registers.YA.Y;
    A := IAPU.Registers.YA.A;
    _div := YA div X;
    Rem := YA mod X;
    IAPU.Registers.YA.A := _div;
    IAPU.Registers.YA.Y := Rem;
    IAPU.Overflow := False;
    if (Y / 2) >= X then
      IAPU.Registers.P := IAPU.Registers.P or APU_HALF_CARRY_FLAG
    else
      IAPU.Registers.P := IAPU.Registers.P and not APU_HALF_CARRY_FLAG;
  end;
end;

// $9F XCN A (eXchange Nibble)
procedure Apu9F;
begin
  IAPU.Registers.YA.A := (IAPU.Registers.YA.A shr 4) or (IAPU.Registers.YA.A shl 4);
  IAPU.Zero := Ord(IAPU.Registers.YA.A = 0);
  APUCheckNegative(IAPU.Registers.YA.A);
end;

// $A0 EI (Enable Interrupts)
procedure ApuA0;
begin
  IAPU.Registers.P := IAPU.Registers.P or APU_INTERRUPT_FLAG;
end;

// $A1 TCALL 10
procedure ApuA1;
begin
  TCALL(10);
end;

// $A2 SET1 dp.5
procedure ApuA2;
begin
  // Placeholder - SET1 é um opcode "ilegal"
end;

// $A3 BBC 2, dp, rel
procedure ApuA3;
var
  addr: Cardinal;
  b: Byte;
begin
  addr := Direct(ACC_READ);
  b := APUGetByteZ(addr);
  Branch((b and (1 shl 2)) = 0);
end;

// $A4 SBC A, dp
procedure ApuA4;
var
  addr: Cardinal;
begin
  addr := Direct(ACC_READ);
  SBC(APUGetByteZ(addr));
end;

// $A5 SBC A, addr
procedure ApuA5;
var
  addr: Cardinal;
begin
  addr := Absolute(ACC_READ);
  SBC(APUGetByte(addr));
end;

// $A6 SBC A, (X)
procedure ApuA6;
begin
  SBC(APUGetByteZ(IAPU.Registers.X));
end;

// $A7 SBC A, (dp+X)
procedure ApuA7;
var
  addr: Cardinal;
begin
  addr := DirectIndexedX(ACC_READ);
  SBC(APUGetByteZ(addr));
end;

// $A8 SBC A, #imm
procedure ApuA8;
begin
  SBC(Immediate(ACC_READ));
end;

// $A9 SBC dp, dp
procedure ApuA9;
var
  addr1, addr2: Cardinal;
  b: Byte;
begin
  addr1 := Direct(ACC_READ);
  addr2 := Direct(ACC_READ_WRITE);
  b := SBC_Generic(APUGetByteZ(addr1), APUGetByteZ(addr2));
  APUSetByteZ(b, addr2);
end;

// $AA MOV1 C, addr:bit
procedure ApuAA;
begin
  MOV1_C(Absolute(ACC_READ));
end;

// $AB INC dp
procedure ApuAB;
var
  addr: Cardinal;
  b: Byte;
begin
  addr := Direct(ACC_READ_WRITE);
  b := APUGetByteZ(addr) + 1;
  APUSetByteZ(b, addr);
  IAPU.Zero := Ord(b = 0);
  APUCheckNegative(b);
end;

// $AC INC addr
procedure ApuAC;
var
  addr: Cardinal;
  b: Byte;
begin
  addr := Absolute(ACC_READ_WRITE);
  b := APUGetByte(addr) + 1;
  APUSetByte(b, addr);
  IAPU.Zero := Ord(b = 0);
  APUCheckNegative(b);
end;

// $AD CMP Y, #imm
procedure ApuAD;
begin
  CMP_Generic(IAPU.Registers.YA.Y, Immediate(ACC_READ));
end;

// $AE POP A
procedure ApuAE;
begin
  IAPU.Registers.YA.A := Pop;
end;

// $AF MOV (X)+, A
procedure ApuAF;
begin
  APUSetByteZ(IAPU.Registers.YA.A, IAPU.Registers.X);
  IAPU.Registers.X := IAPU.Registers.X + 1;
end;

// $B0 BCS rel (Branch on Carry Set)
procedure ApuB0;
begin
  Branch(IAPU.Carry);
end;

// $B1 TCALL 11
procedure ApuB1;
begin
  TCALL(11);
end;

// $B2 CLR1 dp.5
procedure ApuB2;
begin
  // Placeholder - CLR1 é um opcode "ilegal"
end;

// $B3 BBC 3, dp, rel
procedure ApuB3;
var
  addr: Cardinal;
  b: Byte;
begin
  addr := Direct(ACC_READ);
  b := APUGetByteZ(addr);
  Branch((b and (1 shl 3)) = 0);
end;

// $B4 SBC A, dp+X
procedure ApuB4;
var
  addr: Cardinal;
begin
  addr := DirectIndexedX(ACC_READ);
  SBC(APUGetByteZ(addr));
end;

// $B5 SBC A, addr+X
procedure ApuB5;
var
  addr: Cardinal;
begin
  addr := AbsoluteIndexedX(ACC_READ);
  SBC(APUGetByte(addr));
end;

// $B6 SBC A, addr+Y
procedure ApuB6;
var
  addr: Cardinal;
begin
  addr := AbsoluteIndexedY(ACC_READ);
  SBC(APUGetByte(addr));
end;

// $B7 SBC A, (dp)+Y
procedure ApuB7;
var
  addr: Cardinal;
begin
  addr := IndirectIndexedY(ACC_READ);
  SBC(APUGetByteZ(addr));
end;

// $B8 SBC dp, #imm
procedure ApuB8;
var
  addr: Cardinal;
  b: Byte;
begin
  addr := Direct(ACC_READ_WRITE);
  b := SBC_Generic(APUGetByteZ(addr), Immediate(ACC_READ));
  APUSetByteZ(b, addr);
end;

// $B9 SBC (X), (Y)
procedure ApuB9;
var
  b: Byte;
begin
  b := SBC_Generic(APUGetByteZ(IAPU.Registers.X), APUGetByteZ(IAPU.Registers.YA.Y));
  APUSetByteZ(b, IAPU.Registers.X);
end;

// $BA MOVW YA, dp
procedure ApuBA;
var
  addr: Cardinal;
begin
  addr := Direct(ACC_READ);
  IAPU.Registers.YA.W := APUGetWordZ(addr);
  IAPU.Zero := Ord(IAPU.Registers.YA.W = 0);
  APUCheckNegative(IAPU.Registers.YA.Y);
end;

// $BB INC dp+X
procedure ApuBB;
var
  addr: Cardinal;
  b: Byte;
begin
  addr := DirectIndexedX(ACC_READ_WRITE);
  b := APUGetByteZ(addr) + 1;
  APUSetByteZ(b, addr);
  IAPU.Zero := Ord(b = 0);
  APUCheckNegative(b);
end;

// $BC INC A
procedure ApuBC;
begin
  IAPU.Registers.YA.A := IAPU.Registers.YA.A + 1;
  IAPU.Zero := Ord(IAPU.Registers.YA.A = 0);
  APUCheckNegative(IAPU.Registers.YA.A);
end;

// $BD MOV SP, X
procedure ApuBD;
begin
  IAPU.Registers.S := IAPU.Registers.X;
end;

// $BE DAS (Decimal Adjust for Subtraction)
procedure ApuBE;
var
  A: Byte;
  temp: Word;
begin
  A := IAPU.Registers.YA.A;
  if IAPU.Carry or (A > $99) then
  begin
    A := A - $60;
    IAPU.Carry := True;
  end;
  if ((IAPU.Registers.P and APU_HALF_CARRY_FLAG) <> 0) or ((A and $0F) > 9) then
  begin
    A := A - 6;
  end;
  IAPU.Registers.YA.A := A;
  IAPU.Zero := Ord(A = 0);
  APUCheckNegative(A);
end;

// $BF MOV A, (X)+
procedure ApuBF;
begin
  IAPU.Registers.YA.A := APUGetByteZ(IAPU.Registers.X);
  IAPU.Registers.X := IAPU.Registers.X + 1;
  IAPU.Zero := Ord(IAPU.Registers.YA.A = 0);
  APUCheckNegative(IAPU.Registers.YA.A);
end;

// $C0 DI (Disable Interrupts)
procedure ApuC0;
begin
  IAPU.Registers.P := IAPU.Registers.P and not APU_INTERRUPT_FLAG;
end;

// $C1 TCALL 12
procedure ApuC1;
begin
  TCALL(12);
end;

// $C2 SET1 dp.6
procedure ApuC2;
begin
  // Placeholder - SET1 é um opcode "ilegal"
end;

// $C3 BBC 4, dp, rel
procedure ApuC3;
var
  addr: Cardinal;
  b: Byte;
begin
  addr := Direct(ACC_READ);
  b := APUGetByteZ(addr);
  Branch((b and (1 shl 4)) = 0);
end;

// $C4 MOV dp, A
procedure ApuC4;
var
  addr: Cardinal;
begin
  addr := Direct(ACC_WRITE);
  APUSetByteZ(IAPU.Registers.YA.A, addr);
end;

// $C5 MOV addr, A
procedure ApuC5;
var
  addr: Cardinal;
begin
  addr := Absolute(ACC_WRITE);
  APUSetByte(IAPU.Registers.YA.A, addr);
end;

// $C6 MOV (X), A
procedure ApuC6;
begin
  APUSetByteZ(IAPU.Registers.YA.A, IAPU.Registers.X);
end;

// $C7 MOV (dp+X), A
procedure ApuC7;
var
  addr: Cardinal;
begin
  addr := DirectIndexedX(ACC_WRITE);
  APUSetByteZ(IAPU.Registers.YA.A, addr);
end;

// $C8 CMP X, #imm
procedure ApuC8;
begin
  CMP_Generic(IAPU.Registers.X, Immediate(ACC_READ));
end;

// $C9 MOV addr, X
procedure ApuC9;
var
  addr: Cardinal;
begin
  addr := Absolute(ACC_WRITE);
  APUSetByte(IAPU.Registers.X, addr);
end;

// $CA MOV1 addr:bit, C
procedure ApuCA;
begin
  MOV1_M(Absolute(ACC_READ));
end;

// $CB MOV dp, Y
procedure ApuCB;
var
  addr: Cardinal;
begin
  addr := Direct(ACC_WRITE);
  APUSetByteZ(IAPU.Registers.YA.Y, addr);
end;

// $CC MOV addr, Y
procedure ApuCC;
var
  addr: Cardinal;
begin
  addr := Absolute(ACC_WRITE);
  APUSetByte(IAPU.Registers.YA.Y, addr);
end;

// $CD MOV Y, #imm
procedure ApuCD;
begin
  IAPU.Registers.YA.Y := Immediate(ACC_READ);
  IAPU.Zero := Ord(IAPU.Registers.YA.Y = 0);
  APUCheckNegative(IAPU.Registers.YA.Y);
end;

// $CE POP X
procedure ApuCE;
begin
  IAPU.Registers.X := Pop;
end;

// $CF MUL YA
procedure ApuCF;
var
  res: Word;
begin
  res := IAPU.Registers.YA.Y * IAPU.Registers.YA.A;
  IAPU.Registers.YA.W := res;
  IAPU.Zero := Ord(res = 0);
  APUCheckNegative(IAPU.Registers.YA.Y);
end;

// $D0 BNE rel (Branch on Not Equal)
procedure ApuD0;
begin
  Branch(IAPU.Zero = 0);
end;

// $D1 TCALL 13
procedure ApuD1;
begin
  TCALL(13);
end;

// $D2 CLR1 dp.6
procedure ApuD2;
begin
  // Placeholder - CLR1 é um opcode "ilegal"
end;

// $D3 BBC 5, dp, rel
procedure ApuD3;
var
  addr: Cardinal;
  b: Byte;
begin
  addr := Direct(ACC_READ);
  b := APUGetByteZ(addr);
  Branch((b and (1 shl 5)) = 0);
end;

// $D4 MOV dp+X, A
procedure ApuD4;
var
  addr: Cardinal;
begin
  addr := DirectIndexedX(ACC_WRITE);
  APUSetByteZ(IAPU.Registers.YA.A, addr);
end;

// $D5 MOV addr+X, A
procedure ApuD5;
var
  addr: Cardinal;
begin
  addr := AbsoluteIndexedX(ACC_WRITE);
  APUSetByte(IAPU.Registers.YA.A, addr);
end;

// $D6 MOV addr+Y, A
procedure ApuD6;
var
  addr: Cardinal;
begin
  addr := AbsoluteIndexedY(ACC_WRITE);
  APUSetByte(IAPU.Registers.YA.A, addr);
end;

// $D7 MOV (dp)+Y, A
procedure ApuD7;
var
  addr: Cardinal;
begin
  addr := IndirectIndexedY(ACC_WRITE);
  APUSetByteZ(IAPU.Registers.YA.A, addr);
end;

// $D8 MOV dp, X
procedure ApuD8;
var
  addr: Cardinal;
begin
  addr := Direct(ACC_WRITE);
  APUSetByteZ(IAPU.Registers.X, addr);
end;

// $D9 MOV dp+Y, X
procedure ApuD9;
var
  addr: Cardinal;
begin
  addr := DirectIndexedY(ACC_WRITE);
  APUSetByteZ(IAPU.Registers.X, addr);
end;

// $DA MOVW dp, YA
procedure ApuDA;
var
  addr: Cardinal;
begin
  addr := Direct(ACC_WRITE);
  APUSetWordZ(IAPU.Registers.YA.W, addr);
end;

// $DB MOV X, dp+Y
procedure ApuDB;
var
  addr: Cardinal;
begin
  addr := DirectIndexedY(ACC_READ);
  IAPU.Registers.X := APUGetByteZ(addr);
  IAPU.Zero := Ord(IAPU.Registers.X = 0);
  APUCheckNegative(IAPU.Registers.X);
end;

// $DC DEC Y
procedure ApuDC;
begin
  IAPU.Registers.YA.Y := IAPU.Registers.YA.Y - 1;
  IAPU.Zero := Ord(IAPU.Registers.YA.Y = 0);
  APUCheckNegative(IAPU.Registers.YA.Y);
end;

// $DD MOV A, Y
procedure ApuDD;
begin
  IAPU.Registers.YA.A := IAPU.Registers.YA.Y;
  IAPU.Zero := Ord(IAPU.Registers.YA.A = 0);
  APUCheckNegative(IAPU.Registers.YA.A);
end;

// $DE CBNE addr, rel
procedure ApuDE;
var
  addr: Cardinal;
  b: Byte;
begin
  addr := Absolute(ACC_READ);
  b := APUGetByte(addr);
  Branch(IAPU.Registers.YA.A <> b);
end;

// $DF DAA (Decimal Adjust for Addition)
procedure ApuDF;
var
  A: Byte;
  temp: Word;
begin
  A := IAPU.Registers.YA.A;
  if IAPU.Carry or (A > $99) then
  begin
    A := A + $60;
    IAPU.Carry := True;
  end;
  if ((IAPU.Registers.P and APU_HALF_CARRY_FLAG) <> 0) or ((A and $0F) > 9) then
  begin
    A := A + 6;
  end;
  IAPU.Registers.YA.A := A;
  IAPU.Zero := Ord(A = 0);
  APUCheckNegative(A);
end;

// $E0 CLV (Clear Overflow)
procedure ApuE0;
begin
  IAPU.Overflow := False;
end;

// $E1 TCALL 14
procedure ApuE1;
begin
  TCALL(14);
end;

// $E2 SET1 dp.7
procedure ApuE2;
begin
  // Placeholder - SET1 é um opcode "ilegal"
end;

// $E3 BBC 6, dp, rel
procedure ApuE3;
var
  addr: Cardinal;
  b: Byte;
begin
  addr := Direct(ACC_READ);
  b := APUGetByteZ(addr);
  Branch((b and (1 shl 6)) = 0);
end;

// $E4 MOV A, dp
procedure ApuE4;
var
  addr: Cardinal;
begin
  addr := Direct(ACC_READ);
  IAPU.Registers.YA.A := APUGetByteZ(addr);
  IAPU.Zero := Ord(IAPU.Registers.YA.A = 0);
  APUCheckNegative(IAPU.Registers.YA.A);
end;

// $E5 MOV A, addr
procedure ApuE5;
var
  addr: Cardinal;
begin
  addr := Absolute(ACC_READ);
  IAPU.Registers.YA.A := APUGetByte(addr);
  IAPU.Zero := Ord(IAPU.Registers.YA.A = 0);
  APUCheckNegative(IAPU.Registers.YA.A);
end;

// $E6 MOV A, (X)
procedure ApuE6;
begin
  IAPU.Registers.YA.A := APUGetByteZ(IAPU.Registers.X);
  IAPU.Zero := Ord(IAPU.Registers.YA.A = 0);
  APUCheckNegative(IAPU.Registers.YA.A);
end;

// $E7 MOV A, (dp+X)
procedure ApuE7;
var
  addr: Cardinal;
begin
  addr := DirectIndexedX(ACC_READ);
  IAPU.Registers.YA.A := APUGetByteZ(addr);
  IAPU.Zero := Ord(IAPU.Registers.YA.A = 0);
  APUCheckNegative(IAPU.Registers.YA.A);
end;

// $E8 MOV X, #imm
procedure ApuE8;
begin
  IAPU.Registers.X := Immediate(ACC_READ);
  IAPU.Zero := Ord(IAPU.Registers.X = 0);
  APUCheckNegative(IAPU.Registers.X);
end;

// $E9 MOV X, addr
procedure ApuE9;
var
  addr: Cardinal;
begin
  addr := Absolute(ACC_READ);
  IAPU.Registers.X := APUGetByte(addr);
  IAPU.Zero := Ord(IAPU.Registers.X = 0);
  APUCheckNegative(IAPU.Registers.X);
end;

// $EA NOT1 addr:bit
procedure ApuEA;
begin
  NOT1(Absolute(ACC_READ));
end;

// $EB MOV Y, dp
procedure ApuEB;
var
  addr: Cardinal;
begin
  addr := Direct(ACC_READ);
  IAPU.Registers.YA.Y := APUGetByteZ(addr);
  IAPU.Zero := Ord(IAPU.Registers.YA.Y = 0);
  APUCheckNegative(IAPU.Registers.YA.Y);
end;

// $EC MOV Y, addr
procedure ApuEC;
var
  addr: Cardinal;
begin
  addr := Absolute(ACC_READ);
  IAPU.Registers.YA.Y := APUGetByte(addr);
  IAPU.Zero := Ord(IAPU.Registers.YA.Y = 0);
  APUCheckNegative(IAPU.Registers.YA.Y);
end;

// $ED NOTC
procedure ApuED;
begin
  IAPU.Carry := not IAPU.Carry;
end;

// $EE POP Y
procedure ApuEE;
begin
  IAPU.Registers.YA.Y := Pop;
end;

// $EF SLEEP
procedure ApuEF;
begin
  // Emula SLEEP esperando por uma interrupção
  IAPU.WaitCounter := IAPU.WaitCounter + 1;
  APU.Cycles := CPU.Cycles;
end;

// $F0 BEQ rel (Branch on Equal)
procedure ApuF0;
begin
  Branch(IAPU.Zero <> 0);
end;

// $F1 TCALL 15
procedure ApuF1;
begin
  TCALL(15);
end;

// $F2 CLR1 dp.7
procedure ApuF2;
begin
  // Placeholder - CLR1 é um opcode "ilegal"
end;

// $F3 BBC 7, dp, rel
procedure ApuF3;
var
  addr: Cardinal;
  b: Byte;
begin
  addr := Direct(ACC_READ);
  b := APUGetByteZ(addr);
  Branch((b and (1 shl 7)) = 0);
end;

// $F4 MOV A, dp+X
procedure ApuF4;
var
  addr: Cardinal;
begin
  addr := DirectIndexedX(ACC_READ);
  IAPU.Registers.YA.A := APUGetByteZ(addr);
  IAPU.Zero := Ord(IAPU.Registers.YA.A = 0);
  APUCheckNegative(IAPU.Registers.YA.A);
end;

// $F5 MOV A, addr+X
procedure ApuF5;
var
  addr: Cardinal;
begin
  addr := AbsoluteIndexedX(ACC_READ);
  IAPU.Registers.YA.A := APUGetByte(addr);
  IAPU.Zero := Ord(IAPU.Registers.YA.A = 0);
  APUCheckNegative(IAPU.Registers.YA.A);
end;

// $F6 MOV A, addr+Y
procedure ApuF6;
var
  addr: Cardinal;
begin
  addr := AbsoluteIndexedY(ACC_READ);
  IAPU.Registers.YA.A := APUGetByte(addr);
  IAPU.Zero := Ord(IAPU.Registers.YA.A = 0);
  APUCheckNegative(IAPU.Registers.YA.A);
end;

// $F7 MOV A, (dp)+Y
procedure ApuF7;
var
  addr: Cardinal;
begin
  addr := IndirectIndexedY(ACC_READ);
  IAPU.Registers.YA.A := APUGetByteZ(addr);
  IAPU.Zero := Ord(IAPU.Registers.YA.A = 0);
  APUCheckNegative(IAPU.Registers.YA.A);
end;

// $F8 MOV X, dp
procedure ApuF8;
var
  addr: Cardinal;
begin
  addr := Direct(ACC_READ);
  IAPU.Registers.X := APUGetByteZ(addr);
  IAPU.Zero := Ord(IAPU.Registers.X = 0);
  APUCheckNegative(IAPU.Registers.X);
end;

// $F9 MOV X, dp+Y
procedure ApuF9;
var
  addr: Cardinal;
begin
  addr := DirectIndexedY(ACC_READ);
  IAPU.Registers.X := APUGetByteZ(addr);
  IAPU.Zero := Ord(IAPU.Registers.X = 0);
  APUCheckNegative(IAPU.Registers.X);
end;

// $FA MOV dp, YA
procedure ApuFA;
var
  addr: Cardinal;
begin
  addr := Direct(ACC_WRITE);
  APUSetWordZ(IAPU.Registers.YA.W, addr);
end;

// $FB MOV Y, dp
procedure ApuFB;
var
  addr: Cardinal;
begin
  addr := Direct(ACC_READ);
  IAPU.Registers.YA.Y := APUGetByteZ(addr);
  IAPU.Zero := Ord(IAPU.Registers.YA.Y = 0);
  APUCheckNegative(IAPU.Registers.YA.Y);
end;

// $FC INC Y
procedure ApuFC;
begin
  IAPU.Registers.YA.Y := IAPU.Registers.YA.Y + 1;
  IAPU.Zero := Ord(IAPU.Registers.YA.Y = 0);
  APUCheckNegative(IAPU.Registers.YA.Y);
end;

// $FD MOV Y, A
procedure ApuFD;
begin
  IAPU.Registers.YA.Y := IAPU.Registers.YA.A;
  IAPU.Zero := Ord(IAPU.Registers.YA.Y = 0);
  APUCheckNegative(IAPU.Registers.YA.Y);
end;

// $FE DBNE Y, rel
procedure ApuFE;
var
  b: Byte;
begin
  b := IAPU.Registers.YA.Y - 1;
  IAPU.Registers.YA.Y := b;
  Branch(b <> 0);
end;

// $FF STOP
procedure ApuFF;
begin
  IAPU.WaitCounter := $FFFFFFFF;
  APU.Cycles := CPU.Cycles;
end;

//******************************************************************************
// Loop de Execução Principal e Rotinas de Controle
//******************************************************************************

{
  InitSPC700
  ------------------------------------------------------------------------------
  Inicializa a tabela de opcodes e a tabela de ciclos. Este procedimento
  deve ser chamado uma vez na inicialização do emulador.
}
procedure InitSPC700;
var
   i: Integer;
begin
   // Preenche a tabela de opcodes com os ponteiros para os procedimentos
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
   ApuOpcodes[232] := @ApuE8; ApuOpcodes[233] := @ApuE9; ApuOpcodes[234] := @ApuEA; ApuOpcodes[235] := @ApuEB; ApuOpcodes[236] := @ApuEC; ApuOpcodes[237] := @ApuED; ApuOpcodes[238] := @ApuEE; ApuOpcodes[239] := @ApuEF;
   ApuOpcodes[240] := @ApuF0; ApuOpcodes[241] := @ApuF1; ApuOpcodes[242] := @ApuF2; ApuOpcodes[243] := @ApuF3; ApuOpcodes[244] := @ApuF4; ApuOpcodes[245] := @ApuF5; ApuOpcodes[246] := @ApuF6; ApuOpcodes[247] := @ApuF7;
   ApuOpcodes[248] := @ApuF8; ApuOpcodes[249] := @ApuF9; ApuOpcodes[250] := @ApuFA; ApuOpcodes[251] := @ApuFB; ApuOpcodes[252] := @ApuFC; ApuOpcodes[253] := @ApuFD; ApuOpcodes[254] := @ApuFE; ApuOpcodes[255] := @ApuFF;

   // Preenche a tabela de ciclos com base na tabela de comprimentos
   for i := 0 to 255 do
   begin
      APUCycles[i] := APUCycleLengths[i];
   end;
end;

function APUGetCPUCycles: Integer;
begin
   Result := CPU.Cycles - APU.Cycles;
end;

{
  APUMainLoop
  ------------------------------------------------------------------------------
  O motor de execução do SPC700. Ele executa instruções em um loop,
  sincronizado com a CPU principal.
}
procedure APUMainLoop;
var
   opcode: Byte;
begin
   APU.Cycles := APU.Cycles + APUGetCPUCycles;

   while APU.Cycles > 0 do
   begin
      if IAPU.WaitCounter > 0 then
      begin
         // Simula estado de SLEEP ou STOP
         if APU.Cycles > 256 then
            APU.Cycles := APU.Cycles - 256
         else
            APU.Cycles := 0;
         Continue;
      end;

      // Busca o opcode no endereço apontado pelo Program Counter
      opcode := IAPU.PC^;
      Inc(IAPU.PC);

      // Subtrai os ciclos desta instrução do total
      APU.Cycles := APU.Cycles - APUCycles[opcode];

      // Executa o procedimento do opcode correspondente
      if Assigned(ApuOpcodes[opcode]) then
         ApuOpcodes[opcode]()
      else
         // Trata opcode ilegal, se necessário
         ;
   end;
end;

{
  ResetAPU
  ------------------------------------------------------------------------------
  Reseta o estado do processador SPC700 e da APU para seus valores iniciais.
}
procedure ResetAPU;
const
   APUROM: array[0..63] of Byte = ($CD, $EF, $BD, $E8, $00, $C6, $1D, $D0, $FC, $8F, $AA, $F4, $8F, $BB, $F5, $78,
                                   $CC, $F4, $D0, $FB, $2F, $19, $EB, $F4, $D0, $FC, $7E, $F4, $D0, $0B, $E4, $F5,
                                   $CB, $F4, $D7, $00, $FC, $D0, $F3, $AB, $01, $10, $EF, $7E, $F4, $10, $EB, $BA,
                                   $F6, $DA, $00, $BA, $F4, $C4, $F4, $DD, $5D, $D0, $DB, $1F, $00, $00, $C0, $FF);
var
   i: Integer;
begin
  // Reseta o estado da APU
  FillChar(APU, SizeOf(APU), 0);
  Settings.APUEnabled := True;

  // Copia o IPL ROM da APU para os últimos 64 bytes da RAM
  Move(APUROM[0], IAPU.RAM[$FFC0], 64);
  Move(APUROM[0], APU.ExtraRAM[0], 64);

  // Inicializa os registradores do SPC700
  IAPU.Registers.PC := IAPU.RAM[$FFFE] or (IAPU.RAM[$FFFF] shl 8);
  IAPU.PC := @IAPU.RAM[IAPU.Registers.PC];
  IAPU.Registers.YA.W := 0;
  IAPU.Registers.X := 0;
  IAPU.Registers.P := APU_ZERO_FLAG; // Flag Z setada, as outras limpas
  IAPU.Registers.S := $EF;
  APUUnpackStatus;

  // Reseta o estado de execução e timers
  IAPU.Executing := Settings.APUEnabled;
  IAPU.WaitAddress1 := nil;
  IAPU.WaitAddress2 := nil;
  IAPU.WaitCounter := 0;

  // Configuração dos timers internos da APU
  EXT.t64Cnt := 0;
  IAPU.RAM[$F0] := $0A;
  IAPU.RAM[$F1] := $B0;
  APU.ShowROM := True;

  for i := 0 to 2 do
  begin
    APU.TimerEnabled[i] := False;
    APU.Timer[i] := 0;
    APU.TimerTarget[i] := 0;
  end;

  // Sincronização inicial com a CPU
  APU.Cycles := 0;
end;

initialization
   InitSPC700;

end.
