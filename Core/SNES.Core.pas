unit SNES.Core;

interface

uses
   System.Classes,
   System.SysUtils,
   SNES.Platform.Interfaces,
   SNES.DataTypes;

type
   TSNESEmulator = class
   private
      FPlatform: IPlatformServices;
      FInfoBuffer: TStringStream;
   public
      constructor Create(const APlatform: IPlatformServices);
      destructor Destroy; override;
      function LoadROM(const AGameData: TBytes): Boolean;
      procedure Reset;
      procedure RunFrame;
      function GetFramebuffer: Pointer;
   end;

implementation

uses
   SNES.Globals,
   SNES.Memory,
   SNES.CPU,
   SNES.CPU.Opcodes,
   SNES.GFX;

{ TSNESEmulator }

constructor TSNESEmulator.Create(const APlatform: IPlatformServices);
begin
   inherited Create;

   FPlatform := APlatform;
   FInfoBuffer := TStringStream.Create('');

   // Inicializa os subsistemas principais do emulador
   if not InitMemory then
   begin
      FPlatform.Log('Falha ao inicializar a memória do emulador.');
      raise Exception.Create('Falha ao inicializar a memória do emulador.');
   end;

   // Inicializa as tabelas de ponteiros de função para os opcodes
   InitializeOpcodeTables;

   FPlatform.Log('Núcleo do emulador inicializado com sucesso.');
end;

destructor TSNESEmulator.Destroy;
begin
   DeinitMemory;
   FInfoBuffer.Free;

   inherited Destroy;
end;

function TSNESEmulator.GetFramebuffer: Pointer;
begin
   // Retorna um ponteiro para o buffer de tela que a PPU/GFX renderizou
   Result := GFX.Screen;
end;

function TSNESEmulator.LoadROM(const AGameData: TBytes): Boolean;
var
   InfoStr: String;
begin
   // Chama a rotina de carregamento de ROM da unit de memória
   Result := SNES.Memory.LoadROM(AGameData, InfoStr);
   if Result then
      { FPlatform.Log('Carregada ROM: ' + InfoStr); }
   else
      { FPlatform.Log('Falha ao carregar ROM.'); }
end;

procedure TSNESEmulator.Reset;
begin
   // Chama a rotina global de Reset
   SNES.CPU.Reset;
end;

procedure TSNESEmulator.RunFrame;
begin
   // Esta é a função que roda um quadro completo da emulação
   finishedFrame := False;
   G_MainLoop; // G_MainLoop é o ponteiro para o loop principal (Fast, SA1, etc)
end;

end.
