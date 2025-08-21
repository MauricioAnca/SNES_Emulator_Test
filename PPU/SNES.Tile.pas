unit SNES.Tile;

interface

uses
  System.SysUtils,
  SNES.DataTypes,
  SNES.Globals;

const
  BLANK_TILE = 2;

type
  // Tipo procedural para o ponteiro da função de conversão de tile.
  TConvertTileFunc = function(pCache: PByte; TileAddr: Cardinal): Byte;

var
  // Variável global que aponta para a função de conversão de tile apropriada.
  ConvertTile: TConvertTileFunc;

// Seleciona a função de conversão de tile correta com base no modo gráfico atual.
procedure SelectConvertTile;

implementation

uses
  SNES.Memory,
  SNES.PPU,
  SNES.GFX; // Depende das tabelas de consulta (odd_high, etc.) definidas em SNES.GFX

// Converte um tile de 8 bits por pixel (256 cores).
function ConvertTile8bpp(pCache: PByte; TileAddr: Cardinal): Byte;
var
  tp: PByte;
  p: PCardinal;
  line, pix: Byte;
  p1, p2, non_zero: Cardinal;
begin
  tp := @Memory.VRAM[TileAddr];
  p := PCardinal(pCache);
  non_zero := 0;

  for line := 8 downto 1 do
  begin
    p1 := 0;
    p2 := 0;

    pix := tp[0];
    if pix <> 0 then
    begin
      p1 := p1 or odd_high[0, pix shr 4];
      p2 := p2 or odd_low[0, pix and $f];
    end;

    pix := tp[1];
    if pix <> 0 then
    begin
      p1 := p1 or even_high[0, pix shr 4];
      p2 := p2 or even_low[0, pix and $f];
    end;

    pix := tp[16];
    if pix <> 0 then
    begin
      p1 := p1 or odd_high[1, pix shr 4];
      p2 := p2 or odd_low[1, pix and $f];
    end;

    pix := tp[17];
    if pix <> 0 then
    begin
      p1 := p1 or even_high[1, pix shr 4];
      p2 := p2 or even_low[1, pix and $f];
    end;

    pix := tp[32];
    if pix <> 0 then
    begin
      p1 := p1 or odd_high[2, pix shr 4];
      p2 := p2 or odd_low[2, pix and $f];
    end;

    pix := tp[33];
    if pix <> 0 then
    begin
      p1 := p1 or even_high[2, pix shr 4];
      p2 := p2 or even_low[2, pix and $f];
    end;

    pix := tp[48];
    if pix <> 0 then
    begin
      p1 := p1 or odd_high[3, pix shr 4];
      p2 := p2 or odd_low[3, pix and $f];
    end;

    pix := tp[49];
    if pix <> 0 then
    begin
      p1 := p1 or even_high[3, pix shr 4];
      p2 := p2 or even_low[3, pix and $f];
    end;

    p^ := p1;
    Inc(p);
    p^ := p2;
    Inc(p);
    non_zero := non_zero or p1 or p2;
    Inc(tp, 2);
  end;

  if non_zero <> 0 then
    Result := 1
  else
    Result := BLANK_TILE;
end;

// Converte um tile de 4 bits por pixel (16 cores).
function ConvertTile4bpp(pCache: PByte; TileAddr: Cardinal): Byte;
var
  tp: PByte;
  p: PCardinal;
  line, pix: Byte;
  p1, p2, non_zero: Cardinal;
begin
  tp := @Memory.VRAM[TileAddr];
  p := PCardinal(pCache);
  non_zero := 0;

  for line := 8 downto 1 do
  begin
    p1 := 0;
    p2 := 0;

    pix := tp[0];
    if pix <> 0 then
    begin
      p1 := p1 or odd_high[0, pix shr 4];
      p2 := p2 or odd_low[0, pix and $f];
    end;

    pix := tp[1];
    if pix <> 0 then
    begin
      p1 := p1 or even_high[0, pix shr 4];
      p2 := p2 or even_low[0, pix and $f];
    end;

    pix := tp[16];
    if pix <> 0 then
    begin
      p1 := p1 or odd_high[1, pix shr 4];
      p2 := p2 or odd_low[1, pix and $f];
    end;

    pix := tp[17];
    if pix <> 0 then
    begin
      p1 := p1 or even_high[1, pix shr 4];
      p2 := p2 or even_low[1, pix and $f];
    end;

    p^ := p1;
    Inc(p);
    p^ := p2;
    Inc(p);
    non_zero := non_zero or p1 or p2;
    Inc(tp, 2);
  end;

  if non_zero <> 0 then
    Result := 1
  else
    Result := BLANK_TILE;
end;

// Converte um tile de 2 bits por pixel (4 cores).
function ConvertTile2bpp(pCache: PByte; TileAddr: Cardinal): Byte;
var
  tp: PByte;
  p: PCardinal;
  line, pix: Byte;
  p1, p2, non_zero: Cardinal;
begin
  tp := @Memory.VRAM[TileAddr];
  p := PCardinal(pCache);
  non_zero := 0;

  for line := 8 downto 1 do
  begin
    p1 := 0;
    p2 := 0;

    pix := tp[0];
    if pix <> 0 then
    begin
      p1 := p1 or odd_high[0, pix shr 4];
      p2 := p2 or odd_low[0, pix and $f];
    end;

    pix := tp[1];
    if pix <> 0 then
    begin
      p1 := p1 or even_high[0, pix shr 4];
      p2 := p2 or even_low[0, pix and $f];
    end;

    p^ := p1;
    Inc(p);
    p^ := p2;
    Inc(p);
    non_zero := non_zero or p1 or p2;
    Inc(tp, 2);
  end;

  if non_zero <> 0 then
    Result := 1
  else
    Result := BLANK_TILE;
end;

procedure SelectConvertTile;
begin
  case BG.BitShift of
    8: ConvertTile := @ConvertTile8bpp;
    4: ConvertTile := @ConvertTile4bpp;
    2: ConvertTile := @ConvertTile2bpp;
  else
    ConvertTile := nil; // Estado inválido
  end;
end;

end.
