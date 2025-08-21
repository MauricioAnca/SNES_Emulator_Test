unit SNES.Utils.Math;

interface

uses
  System.SysUtils;

// Equivalente das macros em math.h
function MathAbs(X: Integer): Integer; inline;
function MathMin(A, B: Integer): Integer; inline;
function MathMax(A, B: Integer): Integer; inline;

// Tabelas de constantes de math.c
const
  AtanTable: array[0..255] of SmallInt = (
    0,   1,   1,   2,   3,   3,   4,   4,   5,   6,   6,   7,   8,   8,   9,   10,
    10,  11,  11,  12,  13,  13,  14,  15,  15,  16,  16,  17,  18,  18,  19,  20,
    20,  21,  21,  22,  23,  23,  24,  25,  25,  26,  26,  27,  28,  28,  29,  29,
    30,  31,  31,  32,  33,  33,  34,  34,  35,  36,  36,  37,  37,  38,  39,  39,
    40,  40,  41,  42,  42,  43,  43,  44,  44,  45,  46,  46,  47,  47,  48,  49,
    49,  50,  50,  51,  51,  52,  53,  53,  54,  54,  55,  55,  56,  57,  57,  58,
    58,  59,  59,  60,  60,  61,  62,  62,  63,  63,  64,  64,  65,  65,  66,  66,
    67,  67,  68,  69,  69,  70,  70,  71,  71,  72,  72,  73,  73,  74,  74,  75,
    75,  76,  76,  77,  77,  78,  78,  79,  79,  80,  80,  81,  81,  82,  82,  83,
    83,  84,  84,  85,  85,  86,  86,  86,  87,  87,  88,  88,  89,  89,  90,  90,
    91,  91,  92,  92,  92,  93,  93,  94,  94,  95,  95,  96,  96,  96,  97,  97,
    98,  98,  99,  99,  99,  100, 100, 101, 101, 101, 102, 102, 103, 103, 104, 104,
    104, 105, 105, 106, 106, 106, 107, 107, 108, 108, 108, 109, 109, 109, 110, 110,
    111, 111, 111, 112, 112, 113, 113, 113, 114, 114, 114, 115, 115, 115, 116, 116,
    117, 117, 117, 118, 118, 118, 119, 119, 119, 120, 120, 120, 121, 121, 121, 122,
    122, 122, 123, 123, 123, 124, 124, 124, 125, 125, 125, 126, 126, 126, 127, 127
  );

  MulTable: array[0..255] of SmallInt = (
    $0000, $0003, $0006, $0009, $000c, $000f, $0012, $0015, $0019, $001c, $001f, $0022,
    $0025, $0028, $002b, $002f, $0032, $0035, $0038, $003b, $003e, $0041, $0045, $0048,
    $004b, $004e, $0051, $0054, $0057, $005b, $005e, $0061, $0064, $0067, $006a, $006d,
    $0071, $0074, $0077, $007a, $007d, $0080, $0083, $0087, $008a, $008d, $0090, $0093,
    $0096, $0099, $009d, $00a0, $00a3, $00a6, $00a9, $00ac, $00af, $00b3, $00b6, $00b9,
    $00bc, $00bf, $00c2, $00c5, $00c9, $00cc, $00cf, $00d2, $00d5, $00d8, $00db, $00df,
    $00e2, $00e5, $00e8, $00eb, $00ee, $00f1, $00f5, $00f8, $00fb, $00fe, $0101, $0104,
    $0107, $010b, $010e, $0111, $0114, $0117, $011a, $011d, $0121, $0124, $0127, $012a,
    $012d, $0130, $0133, $0137, $013a, $013d, $0140, $0143, $0146, $0149, $014d, $0150,
    $0153, $0156, $0159, $015c, $015f, $0163, $0166, $0169, $016c, $016f, $0172, $0175,
    $0178, $017c, $017f, $0182, $0185, $0188, $018b, $018e, $0192, $0195, $0198, $019b,
    $019e, $01a1, $01a4, $01a8, $01ab, $01ae, $01b1, $01b4, $01b7, $01ba, $01be, $01c1,
    $01c4, $01c7, $01ca, $01cd, $01d0, $01d4, $01d7, $01da, $01dd, $01e0, $01e3, $01e6,
    $01ea, $01ed, $01f0, $01f3, $01f6, $01f9, $01fc, $0200, $0203, $0206, $0209, $020c,
    $020f, $0212, $0216, $0219, $021c, $021f, $0222, $0225, $0228, $022c, $022f, $0232,
    $0235, $0238, $023b, $023e, $0242, $0245, $0248, $024b, $024e, $0251, $0254, $0258,
    $025b, $025e, $0261, $0264, $0267, $026a, $026e, $0271, $0274, $0277, $027a, $027d,
    $0280, $0284, $0287, $028a, $028d, $0290, $0293, $0296, $029a, $029d, $02a0, $02a3,
    $02a6, $02a9, $02ac, $02b0, $02b3, $02b6, $02b9, $02bc, $02bf, $02c2, $02c6, $02c9,
    $02cc, $02cf, $02d2, $02d5, $02d8, $02db, $02df, $02e2, $02e5, $02e8, $02eb, $02ee,
    $02f1, $02f5, $02f8, $02fb, $02fe, $0301, $0304, $0307, $030b, $030e, $0311, $0314,
    $0317, $031a, $031d, $0321
  );

  SinTable: array[0..255] of SmallInt = (
     $0000,  $0324,  $0647,  $096a,  $0c8b,  $0fab,  $12c8,  $15e2,
     $18f8,  $1c0b,  $1f19,  $2223,  $2528,  $2826,  $2b1f,  $2e11,
     $30fb,  $33de,  $36ba,  $398c,  $3c56,  $3f17,  $41ce,  $447a,
     $471c,  $49b4,  $4c3f,  $4ebf,  $5133,  $539b,  $55f5,  $5842,
     $5a82,  $5cb4,  $5ed7,  $60ec,  $62f2,  $64e8,  $66cf,  $68a6,
     $6a6d,  $6c24,  $6dca,  $6f5f,  $70e2,  $7255,  $73b5,  $7504,
     $7641,  $776c,  $7884,  $798a,  $7a7d,  $7b5d,  $7c29,  $7ce3,
     $7d8a,  $7e1d,  $7e9d,  $7f09,  $7f62,  $7fa7,  $7fd8,  $7ff6,
     $7fff,  $7ff6,  $7fd8,  $7fa7,  $7f62,  $7f09,  $7e9d,  $7e1d,
     $7d8a,  $7ce3,  $7c29,  $7b5d,  $7a7d,  $798a,  $7884,  $776c,
     $7641,  $7504,  $73b5,  $7255,  $70e2,  $6f5f,  $6dca,  $6c24,
     $6a6d,  $68a6,  $66cf,  $64e8,  $62f2,  $60ec,  $5ed7,  $5cb4,
     $5a82,  $5842,  $55f5,  $539b,  $5133,  $4ebf,  $4c3f,  $49b4,
     $471c,  $447a,  $41ce,  $3f17,  $3c56,  $398c,  $36ba,  $33de,
     $30fb,  $2e11,  $2b1f,  $2826,  $2528,  $2223,  $1f19,  $1c0b,
     $18f8,  $15e2,  $12c8,  $0fab,  $0c8b,  $096a,  $0647,  $0324,
    -$0000, -$0324, -$0647, -$096a, -$0c8b, -$0fab, -$12c8, -$15e2,
    -$18f8, -$1c0b, -$1f19, -$2223, -$2528, -$2826, -$2b1f, -$2e11,
    -$30fb, -$33de, -$36ba, -$398c, -$3c56, -$3f17, -$41ce, -$447a,
    -$471c, -$49b4, -$4c3f, -$4ebf, -$5133, -$539b, -$55f5, -$5842,
    -$5a82, -$5cb4, -$5ed7, -$60ec, -$62f2, -$64e8, -$66cf, -$68a6,
    -$6a6d, -$6c24, -$6dca, -$6f5f, -$70e2, -$7255, -$73b5, -$7504,
    -$7641, -$776c, -$7884, -$798a, -$7a7d, -$7b5d, -$7c29, -$7ce3,
    -$7d8a, -$7e1d, -$7e9d, -$7f09, -$7f62, -$7fa7, -$7fd8, -$7ff6,
    -$7fff, -$7ff6, -$7fd8, -$7fa7, -$7f62, -$7f09, -$7e9d, -$7e1d,
    -$7d8a, -$7ce3, -$7c29, -$7b5d, -$7a7d, -$798a, -$7884, -$776c,
    -$7641, -$7504, -$73b5, -$7255, -$70e2, -$6f5f, -$6dca, -$6c24,
    -$6a6d, -$68a6, -$66cf, -$64e8, -$62f2, -$60ec, -$5ed7, -$5cb4,
    -$5a82, -$5842, -$55f5, -$539b, -$5133, -$4ebf, -$4c3f, -$49b4,
    -$471c, -$447a, -$41ce, -$3f17, -$3c56, -$398c, -$36ba, -$33de,
    -$30fb, -$2e11, -$2b1f, -$2826, -$2528, -$2223, -$1f19, -$1c0b,
    -$18f8, -$15e2, -$12c8, -$0fab, -$0c8b, -$096a, -$0647, -$0324
  );

// Funções de math.c
function math_atan2(x, y: SmallInt): SmallInt;
function math_cos(angle: SmallInt): SmallInt;
function math_sin(angle: SmallInt): SmallInt;
function math_sqrt(val: Integer): Integer;

implementation

function MathAbs(X: Integer): Integer;
begin
  if X < 0 then Result := -X else Result := X;
end;

function MathMin(A, B: Integer): Integer;
begin
  if A < B then Result := A else Result := B;
end;

function MathMax(A, B: Integer): Integer;
begin
  if A > B then Result := A else Result := B;
end;

function math_atan2(x, y: SmallInt): SmallInt;
var
  absAtan: Integer;
  x1, y1: Integer;
begin
  if x = 0 then
    Exit(0);

  x1 := MathAbs(x);
  y1 := MathAbs(y);

  if x1 > y1 then
    absAtan := AtanTable[Byte((y1 shl 8) div x1)]
  else
    absAtan := AtanTable[Byte((x1 shl 8) div y1)];

  if (x >= 0) xor (y >= 0) then
    Result := -absAtan
  else
    Result := absAtan;
end;

function math_cos(angle: SmallInt): SmallInt;
var
  S: Integer;
  angleS8: SmallInt;
begin
  if angle < 0 then
  begin
    if angle = -32768 then
      Exit(-32768);
    angle := -angle;
  end;

  angleS8 := angle shr 8;
  S := SinTable[$40 + angleS8] - ((Int64(MulTable[angle and $ff]) * SinTable[angleS8]) shr 15);

  if S < -32768 then
    S := -32767;

  Result := SmallInt(S);
end;

function math_sin(angle: SmallInt): SmallInt;
var
  S: Integer;
  angleS8: SmallInt;
begin
  if angle < 0 then
  begin
    if angle = -32768 then
      Exit(0);
    Exit(-math_sin(-angle));
  end;

  angleS8 := angle shr 8;
  S := SinTable[angleS8] + ((Int64(MulTable[angle and $ff]) * SinTable[$40 + angleS8]) shr 15);

  if S > 32767 then
    S := 32767;

  Result := SmallInt(S);
end;

function math_sqrt(val: Integer): Integer;
var
  root, remainder: Integer;
  squaredbit: Cardinal;
begin
  if val < 1 then
    Exit(0);

  root := 0;
  remainder := val;
  squaredbit := 1 shl 30;

  while squaredbit > 0 do
  begin
    if Cardinal(remainder) >= (squaredbit or Cardinal(root)) then
    begin
      remainder := remainder - (Integer(squaredbit) or root);
      root := root shr 1;
      root := root or Integer(squaredbit);
    end
    else
    begin
      root := root shr 1;
    end;
    squaredbit := squaredbit shr 2;
  end;
  Result := root;
end;

end.