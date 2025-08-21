unit SNES.Platform.Interfaces;

interface

uses
  System.Types;

type
  TInputDevice = (idJoypad1, idJoypad2, idJoypad3, idJoypad4, idJoypad5, idMouse1, idMouse2, idSuperScope);
  TSnesButton = (sbB, sbY, sbSelect, sbStart, sbUp, sbDown, sbLeft, sbRight, sbA, sbX, sbL, sbR);
  TSnesButtons = set of TSnesButton;

  IPlatformServices = interface
    ['{BADD2651-729D-4B4D-9B1D-93D2A78F67C8}']
    // -- Gerenciamento de Janela e Vídeo --
    function Initialize(const AWidth, AHeight: Integer; const ATitle: string): Boolean;
    procedure Shutdown;
    function WindowShouldClose: Boolean;
    procedure BeginDrawing;
    procedure EndDrawing;
    procedure UpdateTexture(const ABuffer: Pointer);
    procedure DrawTexture;

    // -- Gerenciamento de Áudio --
    function InitializeAudio(const ASampleRate, ABufSize: Integer): Boolean;
    procedure ShutdownAudio;
    procedure UpdateAudioStream(const ABuffer: Pointer; AFrameCount: Integer);
    function GetAudioFramesProcessed: Integer;

    // -- Input --
    procedure PollInput;
    function GetJoypadState(ADevice: TInputDevice): TSnesButtons;
    // Adicionar aqui métodos para Mouse, SuperScope, etc.

    // -- Timing --
    function GetTime: Double;
    procedure SetTargetFPS(AFPS: Integer);

    // -- Logging --
    procedure Log(const AMessage: string);
  end;

implementation

end.