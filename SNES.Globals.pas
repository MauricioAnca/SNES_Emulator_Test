unit SNES.Globals;

interface

uses
   SNES.DataTypes;

var
   // Variáveis de estado principais (equivalente a globals.c)
   Settings: TSettings;
   CPU: TSCPUState;
   ICPU: TSICPU;
   PPU: TSPPU;
   IPPU: TInternalPPU;
   APU: TSAPU;
   IAPU: TSIAPU;
   Memory: TMemory;
   GFX: TSGFX;
   BG: TSBG;
   EXT: TSEXTState;
   DMA: array[0..7] of TSDMA;
   // Adicione outras variáveis globais aqui conforme necessário (SA1, SuperFX, etc.)

   finishedFrame: Boolean;

   APUCycles: array[0..255] of Byte;

function SNES_CYCLES_PER_SECOND: Cardinal;

implementation

function SNES_CYCLES_PER_SECOND: Cardinal;
begin
   if Settings.PAL then
      Result := 21281370 // Clock do SNES PAL
   else
      Result := 21477272; // Clock do SNES NTSC
end;

end.
