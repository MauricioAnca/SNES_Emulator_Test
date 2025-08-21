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
   DMA: array[0..7] of TSDMA;
   // Adicione outras variáveis globais aqui conforme necessário (SA1, SuperFX, etc.)

   finishedFrame: Boolean;

implementation

end.
