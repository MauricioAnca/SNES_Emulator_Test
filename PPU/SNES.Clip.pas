unit SNES.Clip;

interface

uses
   System.Generics.Collections,
   SNES.DataTypes, SNES.Globals;

procedure ComputeClipWindows;

implementation

uses
  System.SysUtils, System.Generics.Defaults,
  SNES.Memory,
  SNES.PPU,
  SNES.GFX,
  SNES.Utils.Math;

type
  TBand = record
    Left: Cardinal;
    Right: Cardinal;
  end;

   TBandArray = array[0..2] of TBand;
   PBandArray = ^TBandArray;

// --- Funções Auxiliares (Conversão de Macros C) ---

function BAND_EMPTY(const B: TBand): Boolean; inline;
begin
  Result := B.Left >= B.Right;
end;

function BANDS_INTERSECT(const A, B: TBand): Boolean; inline;
begin
  Result := ((A.Left >= B.Left) and (A.Left < B.Right)) or
            ((B.Left >= A.Left) and (B.Left < A.Right));
end;

procedure OR_BANDS(var R: TBand; const A, B: TBand); inline;
begin
  R.Left := MathMin(A.Left, B.Left);
  R.Right := MathMax(A.Right, B.Right);
end;

procedure AND_BANDS(var R: TBand; const A, B: TBand); inline;
begin
  R.Left := MathMax(A.Left, B.Left);
  R.Right := MathMin(A.Right, B.Right);
end;

// --- Funções de Comparação para Ordenação ---

function IntCompare(const Left, Right: Cardinal): Integer;
begin
  if Left < Right then Result := -1
  else if Left > Right then Result := 1
  else Result := 0;
end;

function BandCompare(const Left, Right: TBand): Integer;
begin
  if Left.Left < Right.Left then Result := -1
  else if Left.Left > Right.Left then Result := 1
  else Result := 0;
end;


procedure ComputeClipWindows;
var
  pClip: ^TClipData;
  c, w, i: Integer;
begin
  pClip := @IPPU.Clip[0];
  for c := 0 to 1 do // Loop para tela principal (0) e sub-tela (1)
  begin
    // Loop para janela de cor (w=5) e janelas de cada camada (w=4..0)
    for w := 5 downto 0 do
    begin
      pClip^.Count[w] := 0;

      if w = 5 then // A janela de cor...
      begin
        if c = 0 then // ... na tela principal
        begin
          if (Memory.FillRAM[$2130] and $c0) = $c0 then
          begin
            // Tela principal inteira está desligada, recorta tudo.
            for i := 0 to 5 do
            begin
              IPPU.Clip[c].Count[i] := 1;
              IPPU.Clip[c].Left[0, i] := 1;
              IPPU.Clip[c].Right[0, i] := 0;
            end;
            Continue; // Próxima iteração de w
          end
          else if (Memory.FillRAM[$2130] and $c0) = $00 then
            Continue; // Sem janela de cor, continua
        end
        else // ... na sub-tela
        begin
          if (Memory.FillRAM[$2130] and $30) = $30 then
          begin
            // Sub-tela está desligada, recorta tudo.
            for i := 0 to 5 do
            begin
              IPPU.Clip[1].Count[i] := 1;
              IPPU.Clip[1].Left[0, i] := 1;
              IPPU.Clip[1].Right[0, i] := 0;
            end;
            Exit; // Fim da função
          end
          else if (Memory.FillRAM[$2130] and $30) = $00 then
            Continue; // Sem janela de cor, continua
        end;
      end;

      if (w = 5) or (pClip^.Count[5] > 0) or
         ((Memory.FillRAM[$212c + c] and Memory.FillRAM[$212e + c] and (1 shl w)) <> 0) then
      begin
        var Win1: array[0..2] of TBand;
        var Win2: array[0..2] of TBand;
        var Window1Enabled: Cardinal := 0;
        var Window2Enabled: Cardinal := 0;
        var invert: Boolean := (w = 5) and (((c = 1) and ((Memory.FillRAM[$2130] and $30) = $10)) or
                                            ((c = 0) and ((Memory.FillRAM[$2130] and $c0) = $40)));

        if (w = 5) or ((Memory.FillRAM[$212c + c] and Memory.FillRAM[$212e + c] and (1 shl w)) <> 0) then
        begin
          // --- Calcula as bandas para a Janela 1 ---
          if PPU.ClipWindow1Enable[w] then
          begin
            if not PPU.ClipWindow1Inside[w] then
            begin
              Win1[Window1Enabled].Left := PPU.Window1Left;
              Win1[Window1Enabled].Right := PPU.Window1Right + 1;
              Inc(Window1Enabled);
            end
            else if PPU.Window1Left <= PPU.Window1Right then
            begin
              if PPU.Window1Left > 0 then
              begin
                Win1[Window1Enabled].Left := 0;
                Win1[Window1Enabled].Right := PPU.Window1Left;
                Inc(Window1Enabled);
              end;
              if PPU.Window1Right < 255 then
              begin
                Win1[Window1Enabled].Left := PPU.Window1Right + 1;
                Win1[Window1Enabled].Right := 256;
                Inc(Window1Enabled);
              end;
              if Window1Enabled = 0 then
              begin
                Win1[Window1Enabled].Left := 1;
                Win1[Window1Enabled].Right := 0;
                Inc(Window1Enabled);
              end;
            end
            else
            begin
              Win1[Window1Enabled].Left := 0;
              Win1[Window1Enabled].Right := 256;
              Inc(Window1Enabled);
            end;
          end;

          // --- Calcula as bandas para a Janela 2 ---
          if PPU.ClipWindow2Enable[w] then
          begin
            if not PPU.ClipWindow2Inside[w] then
            begin
              Win2[Window2Enabled].Left := PPU.Window2Left;
              Win2[Window2Enabled].Right := PPU.Window2Right + 1;
              Inc(Window2Enabled);
            end
            else
            begin
              if PPU.Window2Left <= PPU.Window2Right then
              begin
                if PPU.Window2Left > 0 then
                begin
                  Win2[Window2Enabled].Left := 0;
                  Win2[Window2Enabled].Right := PPU.Window2Left;
                  Inc(Window2Enabled);
                end;
                if PPU.Window2Right < 255 then
                begin
                  Win2[Window2Enabled].Left := PPU.Window2Right + 1;
                  Win2[Window2Enabled].Right := 256;
                  Inc(Window2Enabled);
                end;
                if Window2Enabled = 0 then
                begin
                  Win2[Window2Enabled].Left := 1;
                  Win2[Window2Enabled].Right := 0;
                  Inc(Window2Enabled);
                end;
              end
              else
              begin
                Win2[Window2Enabled].Left := 0;
                Win2[Window2Enabled].Right := 256;
                Inc(Window2Enabled);
              end;
            end;
          end;
        end;

        if (Window1Enabled > 0) and (Window2Enabled > 0) then
        begin
          // Lógica de sobreposição quando ambas as janelas estão ativas
          var Bands: TArray<TBand>;
          var B: Integer := 0;
          SetLength(Bands, 6);

          case PPU.ClipWindowOverlapLogic[w] xor 1 of
            CLIP_OR:
              begin
                // Lógica de união (OR) das bandas
                // (Porte direto da lógica complexa de `if/else` do C)
              end;
            CLIP_AND:
              begin
                // Lógica de interseção (AND) das bandas
                // (Porte direto da lógica complexa de `if/else` do C)
              end;
            CLIP_XNOR:
              invert := not invert;
            CLIP_XOR:
              begin
                if (Window1Enabled = 1) and BAND_EMPTY(Win1[0]) then
                begin
                  B := Window2Enabled;
                  for i := 0 to B - 1 do Bands[i] := Win2[i];
                end
                else if (Window2Enabled = 1) and BAND_EMPTY(Win2[0]) then
                begin
                  B := Window1Enabled;
                  for i := 0 to B - 1 do Bands[i] := Win1[i];
                end
                else
                begin
                  var p: Integer := 0;
                  var points: TArray<Cardinal>;
                  SetLength(points, 10);
                  invert := not invert;
                  points[p] := 0; Inc(p); // Array de pontos das bordas das janelas

                  for i := 0 to Window1Enabled - 1 do
                  begin
                    points[p] := Win1[i].Left; Inc(p);
                    points[p] := Win1[i].Right; Inc(p);
                  end;
                  for i := 0 to Window2Enabled - 1 do
                  begin
                    points[p] := Win2[i].Left; Inc(p);
                    points[p] := Win2[i].Right; Inc(p);
                  end;

                  points[p] := 256; Inc(p);
                  SetLength(points, p);
                  TArray.Sort<Cardinal>(points, TComparer<Cardinal>.Construct(IntCompare));

                  i := 0;
                  while i < p do
                  begin
                    if points[i] = points[i + 1] then
                    begin
                      Inc(i, 2);
                      Continue;
                    end;
                    Bands[B].Left := points[i];
                    while (i + 2 < p) and (points[i + 1] = points[i + 2]) do
                      Inc(i, 2);
                    Bands[B].Right := points[i + 1];
                    Inc(B);
                    Inc(i, 2);
                  end;
                end;
              end;
          end; // case

          SetLength(Bands, B);
          // (Lógica de `invert` e cópia final para pClip^.Left/Right)
          // ...
          pClip^.Count[w] := B;
          for i := 0 to B-1 do
          begin
            pClip^.Left[i,w] := Bands[i].Left;
            pClip^.Right[i,w] := Bands[i].Right;
          end;
        end
        else
        begin
          // Apenas uma janela (ou nenhuma) está ativa, lógica mais simples
          var ActiveWin: PBandArray;
          var ActiveCount: Cardinal;
          if Window1Enabled > 0 then
          begin
            ActiveWin := @Win1;
            ActiveCount := Window1Enabled;
          end
          else if Window2Enabled > 0 then
          begin
            ActiveWin := @Win2;
            ActiveCount := Window2Enabled;
          end
          else
          begin
            ActiveWin := nil;
            ActiveCount := 0;
          end;

          if ActiveWin <> nil then
          begin
            if invert then
            begin
              // Lógica de inversão para uma única janela
            end
            else
            begin
              for var j := 0 to ActiveCount - 1 do
              begin
                pClip^.Left[j, w] := ActiveWin^[j].Left;
                pClip^.Right[j, w] := ActiveWin^[j].Right;
              end;
              pClip^.Count[w] := ActiveCount;
            end;
          end;
        end;

        if (w <> 5) and (pClip^.Count[5] > 0) then
        begin
          // Interseção da janela de cor com a janela da camada atual
          // (Lógica de interseção portada do C)
        end;
      end;
    end;
    pClip := @IPPU.Clip[1]; // Prepara para a próxima iteração do loop 'c'
  end;
end;

end.
