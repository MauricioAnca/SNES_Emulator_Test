unit SNES.Platform.Raylib;

interface

uses
   System.SysUtils, System.Types,
   raylib,
   SNES.Platform.Interfaces;

type
   TRaylibServices = class(TInterfacedObject, IPlatformServices)
   private
      FTexture: TTexture2D;
      FAudioStream: TAudioStream;
      FRomLoaded: Boolean;
   public
      // IPlatformServices
      function Initialize(const AWidth, AHeight: Integer; const ATitle: string): Boolean;
      procedure Shutdown;
      function WindowShouldClose: Boolean;
      procedure BeginDrawing;
      procedure EndDrawing;
      procedure UpdateTexture(const ABuffer: Pointer);
      procedure DrawTexture;

      function InitializeAudio(const ASampleRate, ABufSize: Integer): Boolean;
      procedure ShutdownAudio;
      procedure UpdateAudioStream(const ABuffer: Pointer; AFrameCount: Integer);
      function GetAudioFramesProcessed: Integer;

      procedure PollInput;
      function GetJoypadState(ADevice: TInputDevice): TSnesButtons;

      function GetTime: Double;
      procedure SetTargetFPS(AFPS: Integer);

      procedure Log(const AMessage: string);
   end;

implementation

{ TRaylibServices }

procedure TRaylibServices.BeginDrawing;
begin
   raylib.BeginDrawing;
   raylib.ClearBackground(BLACK);
end;

procedure TRaylibServices.DrawTexture;
begin
   // Desenha a textura na tela, escalonando para o tamanho da janela
   DrawTexturePro(FTexture,
                  RectangleCreate(0, 0, FTexture.width, FTexture.height),
                  RectangleCreate(0, 0, GetScreenWidth, GetScreenHeight),
                  Vector2Create(0, 0), 0, WHITE);
end;

procedure TRaylibServices.EndDrawing;
begin
   raylib.EndDrawing;
end;

function TRaylibServices.GetAudioFramesProcessed: Integer;
begin
   Result := 0; // Raylib não expõe isso diretamente, pode ser necessário gerenciar manualmente
end;

function TRaylibServices.GetJoypadState(ADevice: TInputDevice): TSnesButtons;
var
   JoypadIndex: Integer;
begin
   Result := [];
   JoypadIndex := Ord(ADevice);

   if IsGamepadAvailable(JoypadIndex) then
   begin
      if IsGamepadButtonDown(JoypadIndex, GAMEPAD_BUTTON_RIGHT_FACE_DOWN) then Include(Result, sbB);
      if IsGamepadButtonDown(JoypadIndex, GAMEPAD_BUTTON_RIGHT_FACE_LEFT) then Include(Result, sbY);
      if IsGamepadButtonDown(JoypadIndex, GAMEPAD_BUTTON_MIDDLE_LEFT) then Include(Result, sbSelect);
      if IsGamepadButtonDown(JoypadIndex, GAMEPAD_BUTTON_MIDDLE_RIGHT) then Include(Result, sbStart);
      if IsGamepadButtonDown(JoypadIndex, GAMEPAD_BUTTON_LEFT_FACE_UP) then Include(Result, sbUp);
      if IsGamepadButtonDown(JoypadIndex, GAMEPAD_BUTTON_LEFT_FACE_DOWN) then Include(Result, sbDown);
      if IsGamepadButtonDown(JoypadIndex, GAMEPAD_BUTTON_LEFT_FACE_LEFT) then Include(Result, sbLeft);
      if IsGamepadButtonDown(JoypadIndex, GAMEPAD_BUTTON_LEFT_FACE_RIGHT) then Include(Result, sbRight);
      if IsGamepadButtonDown(JoypadIndex, GAMEPAD_BUTTON_RIGHT_FACE_RIGHT) then Include(Result, sbA);
      if IsGamepadButtonDown(JoypadIndex, GAMEPAD_BUTTON_RIGHT_FACE_UP) then Include(Result, sbX);
      if IsGamepadButtonDown(JoypadIndex, GAMEPAD_BUTTON_LEFT_TRIGGER_1) then Include(Result, sbL);
      if IsGamepadButtonDown(JoypadIndex, GAMEPAD_BUTTON_RIGHT_TRIGGER_1) then Include(Result, sbR);
   end;

   // Mapeamento do teclado para o Joypad 1 como fallback
   if ADevice = idJoypad1 then
   begin
      if IsKeyDown(KEY_Z) then Include(Result, sbB);
      if IsKeyDown(KEY_A) then Include(Result, sbY);
      if IsKeyDown(KEY_BACKSPACE) then Include(Result, sbSelect);
      if IsKeyDown(KEY_ENTER) then Include(Result, sbStart);
      if IsKeyDown(KEY_UP) then Include(Result, sbUp);
      if IsKeyDown(KEY_DOWN) then Include(Result, sbDown);
      if IsKeyDown(KEY_LEFT) then Include(Result, sbLeft);
      if IsKeyDown(KEY_RIGHT) then Include(Result, sbRight);
      if IsKeyDown(KEY_X) then Include(Result, sbA);
      if IsKeyDown(KEY_S) then Include(Result, sbX);
      if IsKeyDown(KEY_Q) then Include(Result, sbL);
      if IsKeyDown(KEY_W) then Include(Result, sbR);
   end;
end;

function TRaylibServices.GetTime: Double;
begin
   Result := raylib.GetTime;
end;

function TRaylibServices.Initialize(const AWidth, AHeight: Integer; const ATitle: string): Boolean;
var
   Image: TImage;
begin
   raylib.InitWindow(AWidth * 2, AHeight * 2, PAnsiChar(ATitle)); // Janela inicial com escala 2x
   raylib.SetTargetFPS(60);

   // Cria uma imagem e textura iniciais
   Image := raylib.GenImageColor(AWidth, AHeight, BLACK);
   FTexture := raylib.LoadTextureFromImage(Image);
   raylib.UnloadImage(Image);

   Result := raylib.IsWindowReady;
end;

function TRaylibServices.InitializeAudio(const ASampleRate, ABufSize: Integer): Boolean;
begin
   raylib.InitAudioDevice;
   FAudioStream := raylib.LoadAudioStream(ASampleRate, 16, 2); // SampleRate, 16-bit, Stereo
   raylib.SetAudioStreamBufferSizeDefault(ABufSize);
   raylib.PlayAudioStream(FAudioStream);
   Result := raylib.IsAudioDeviceReady;
end;

procedure TRaylibServices.Log(const AMessage: string);
begin
   raylib.TraceLog(LOG_INFO, PAnsiChar(AMessage));
end;

procedure TRaylibServices.PollInput;
begin
   // Raylib faz polling implicitamente em suas funções `Is...Down`
end;

procedure TRaylibServices.SetTargetFPS(AFPS: Integer);
begin
   raylib.SetTargetFPS(AFPS);
end;

procedure TRaylibServices.Shutdown;
begin
   raylib.UnloadTexture(FTexture);
   raylib.CloseWindow;
end;

procedure TRaylibServices.ShutdownAudio;
begin
   raylib.StopAudioStream(FAudioStream);
   raylib.UnloadAudioStream(FAudioStream);
   raylib.CloseAudioDevice;
end;

procedure TRaylibServices.UpdateAudioStream(const ABuffer: Pointer; AFrameCount: Integer);
begin
   if raylib.IsAudioStreamProcessed(FAudioStream) then
      raylib.UpdateAudioStream(FAudioStream, ABuffer, AFrameCount);
end;

procedure TRaylibServices.UpdateTexture(const ABuffer: Pointer);
begin
   // Assume que o buffer é 16-bit RGB565, que é o formato padrão do Snes9x e compatível com PIXELFORMAT_UNCOMPRESSED_R5G6B5
   raylib.UpdateTexture(FTexture, ABuffer);
end;

function TRaylibServices.WindowShouldClose: Boolean;
begin
   Result := raylib.WindowShouldClose;
end;

end.