unit SNES.PixelFormats;

interface

// Defina este símbolo no seu projeto (Project > Options > Delphi Compiler > Conditional defines)
// se você precisar do formato BGR555. Caso contrário, o padrão será RGB565.
// {$DEFINE USE_BGR555}

function BUILD_PIXEL2(R, G, B: Cardinal): Word; inline;
procedure DECOMPOSE_PIXEL(Pixel: Word; var R, G, B: Cardinal); inline;
function BUILD_PIXEL(R, G, B: Cardinal): Word; inline;

{$IFDEF USE_BGR555}
// --- Formato BGR555 (1 bit de alfa/não usado, 5 bits por cor) ---
const
  MAX_RED = 31;
  MAX_GREEN = 31;
  MAX_BLUE = 31;
  RED_SHIFT_BITS = 0;
  GREEN_SHIFT_BITS = 5;
  BLUE_SHIFT_BITS = 10;
  ALPHA_BITS_MASK = $8000;

function BUILD_PIXEL(R, G, B: Cardinal): Word; inline;
begin
  Result := ((B and 31) shl 10) or ((G and 31) shl 5) or (R and 31);
end;

procedure DECOMPOSE_PIXEL(Pixel: Word; var R, G, B: Cardinal); inline;
begin
  R := (Pixel shr 0) and 31;
  G := (Pixel shr 5) and 31;
  B := (Pixel shr 10) and 31;
end;

{$ELSE}
// --- Formato RGB565 (5 bits para R, 6 para G, 5 para B) ---
const
  MAX_RED = 31;
  MAX_GREEN = 63;
  MAX_BLUE = 31;
  RED_SHIFT_BITS = 11;
  GREEN_SHIFT_BITS = 5;
  BLUE_SHIFT_BITS = 0;
  ALPHA_BITS_MASK = $0000;

implementation

function BUILD_PIXEL(R, G, B: Cardinal): Word; inline;
begin
  // No SNES, os valores de cor vão de 0 a 31. O G do RGB565 vai de 0 a 63.
  // Portanto, dobramos o valor do verde para mapear corretamente a faixa.
  Result := ((R and 31) shl 11) or ((G and 31) shl 6) or (B and 31);
end;

procedure DECOMPOSE_PIXEL(Pixel: Word; var R, G, B: Cardinal); inline;
begin
  R := (Pixel shr 11) and 31;
  G := (Pixel shr 5) and 63;
  B := (Pixel shr 0) and 31;
end;

{$ENDIF}

// BUILD_PIXEL2 é usado para a tabela de cores direta, que já tem o range correto.
function BUILD_PIXEL2(R, G, B: Cardinal): Word; inline;
begin
{$IFDEF USE_BGR555}
  Result := ((B and 31) shl 10) or ((G and 31) shl 5) or (R and 31);
{$ELSE}
  Result := ((R and 31) shl 11) or ((G and 63) shl 5) or (B and 31);
{$ENDIF}
end;


end.
