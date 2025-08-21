program SNESEmulator;

uses
  System.SysUtils,
  System.Classes,
  System.IOUtils,
  {$IFDEF MSWINDOWS}
  Winapi.Windows,
  {$ENDIF }
  SNES.Memory in 'Memory\SNES.Memory.pas',
  SNES.Chips.OBC1 in 'Chips\SNES.Chips.OBC1.pas',
  SNES.CPU.Addressing in 'CPU\SNES.CPU.Addressing.pas',
  SNES.CPU.Opcodes in 'CPU\SNES.CPU.Opcodes.pas',
  SNES.Utils.Math in 'Utils\SNES.Utils.Math.pas',
  SNES.DataTypes in 'SNES.DataTypes.pas',
  SNES.Platform.Interfaces in 'Platform\SNES.Platform.Interfaces.pas',
  SNES.Platform.Raylib in 'Platform\SNES.Platform.Raylib.pas',
  SNES.CPU in 'CPU\SNES.CPU.pas',
  SNES.PPU in 'PPU\SNES.PPU.pas',
  SNES.Tile in 'PPU\SNES.Tile.pas',
  SNES.GFX in 'PPU\SNES.GFX.pas',
  SNES.Clip in 'PPU\SNES.Clip.pas',
  SNES.DMA in 'Memory\SNES.DMA.pas',
  SNES.Globals in 'SNES.Globals.pas',
  SNES.PixelFormats in 'SNES.PixelFormats.pas',
  SNES.Chips.SuperFX in 'Chips\SNES.Chips.SuperFX.pas',
  SNES.Core in 'Core\SNES.Core.pas',
  SNES.APU in 'APU\SNES.APU.pas',
  SNES.APU.SPC700 in 'APU\SNES.APU.SPC700.pas',
  SNES.APU.DSP in 'APU\SNES.APU.DSP.pas';

var
   Platform: IPlatformServices;
   Emulator: TSNESEmulator;
   Info: TStringStream;
   GameData: TBytes;

begin
   ReportMemoryLeaksOnShutdown := True;

   //Writeln('SNES Emulator in Delphi');

   // 1. Inicializar Serviços de Plataforma
   Platform := TRaylibServices.Create;
   if not Platform.Initialize(SNES_WIDTH, SNES_HEIGHT_EXTENDED, 'Delphi SNES Emulator') then
   begin
      Writeln('Falha ao inicializar a plataforma (Raylib).');
      Exit;
   end;

   // 2. Inicializar o Emulador
   Emulator := TSNESEmulator.Create(Platform);

   try
      // 3. Carregar uma ROM (Exemplo: carregar de um arquivo)
      // Para este exemplo, vamos simular, mas aqui você usaria TFileStream.
       GameData := TFile.ReadAllBytes('3_Ninjas_Kick_Back.sfc');
       if not Emulator.LoadROM(GameData) then
       begin
         Platform.Log('Falha ao carregar a ROM.');
         Exit;
       end;

      Platform.Log('ROM carregada com sucesso (simulado).');
      Emulator.Reset;

      // 4. Loop Principal
      while not Platform.WindowShouldClose do
      begin
         Emulator.RunFrame;

         Platform.BeginDrawing;
         Platform.UpdateTexture(Emulator.GetFramebuffer);
         Platform.DrawTexture;
         Platform.EndDrawing;
      end;

   finally
      // 5. Finalizar
      Emulator.Free;
      Platform.Shutdown;
      Platform := nil;
   end;
end.