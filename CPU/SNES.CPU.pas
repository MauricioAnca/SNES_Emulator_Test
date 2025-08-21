unit SNES.CPU;

interface

uses
  SNES.DataTypes, SNES.Globals;

var
  G_MainLoop: procedure;

// --- Funções de Gerenciamento da CPU ---
procedure ResetCPU;
procedure SoftReset;
procedure Reset;

// Funções de Acesso aos Registradores de I/O da CPU
procedure SetCPU(ByteValue: Byte; Address: Word);
function GetCPU(Address: Word): Byte;

// --- Funções Auxiliares do Loop de Execução ---
procedure CPUShutdown; inline;

procedure SetMainLoop;
procedure SetIRQSource(source: Cardinal);
procedure ClearIRQSource(source: Cardinal);

implementation

uses
  System.SysUtils,
  SNES.Memory,
  SNES.CPU.Opcodes,
  SNES.PPU,
  SNES.GFX,
//  SNES.APU,
  SNES.DMA;
//  SNES.Chips.SuperFX,
//  SNES.Chips.SA1;


procedure ForceShutdown; inline;
begin
  CPU.WaitPC := 0;
  CPU.Cycles := CPU.NextEvent;
end;

procedure CPUShutdown;
begin
   if (not Settings.Shutdown) or (ICPU.Registers.PCw.PC.W <> CPU.WaitPC) then
      Exit;

   // Não pular ciclos com uma NMI ou IRQ pendente - poderia causar interrupções atrasadas.
   if (CPU.WaitCounter = 0) and ((CPU.Flags and (IRQ_FLAG or NMI_FLAG)) = 0) then
      ForceShutdown
   else if CPU.WaitCounter >= 2 then
      CPU.WaitCounter := 1
   else
      Dec(CPU.WaitCounter);
end;

// --- Rotinas Auxiliares de Timing e Eventos (de cpuexec.h) ---
procedure Reschedule; inline;
var
  which: Byte;
  max: Integer;
begin
  if (CPU.WhichEvent = HBLANK_START_EVENT) or (CPU.WhichEvent = HTIMER_AFTER_EVENT) then
  begin
    which := HBLANK_END_EVENT;
    max := Settings.H_Max;
  end
  else
  begin
    which := HBLANK_START_EVENT;
    max := Settings.HBlankStart;
  end;

  if PPU.HTimerEnabled and (PPU.HTimerPosition < max) and (PPU.HTimerPosition > CPU.NextEvent) and
     (not PPU.VTimerEnabled or (PPU.VTimerEnabled and (CPU.V_Counter = PPU.IRQVBeamPos))) then
  begin
    if PPU.HTimerPosition < Settings.HBlankStart then
      which := HTIMER_BEFORE_EVENT
    else
      which := HTIMER_AFTER_EVENT;
    max := PPU.HTimerPosition;
  end;

  CPU.NextEvent := max;
  CPU.WhichEvent := which;
end;

// --- Rotinas de Processamento de H-Blank (de cpuexec.c) ---
procedure DoHBlankProcessing_NoSFX;
var
  i: Integer;
begin
  CPU.WaitCounter := CPU.WaitCounter + 1;

  case CPU.WhichEvent of
    HBLANK_START_EVENT:
      begin
        if (IPPU.HDMA <> 0) and (CPU.V_Counter <= PPU.ScreenHeight) then
          IPPU.HDMA := DoHDMA(IPPU.HDMA);
      end;
    HBLANK_END_EVENT:
      begin
        CPU.Cycles := CPU.Cycles - Settings.H_Max;

        if IAPU.Executing then
          APU.Cycles := APU.Cycles - Settings.H_Max
        else
          APU.Cycles := 0;

        CPU.NextEvent := -1;

        Inc(CPU.V_Counter);
        // FIXME: SNES_MAX_VCOUNTER
        if CPU.V_Counter >= 262 then // (Settings.PAL ? SNES_MAX_PAL_VCOUNTER : SNES_MAX_NTSC_VCOUNTER) then
        begin
          CPU.V_Counter := 0;
          Memory.FillRAM[$213F] := Memory.FillRAM[$213F] xor $80;
          PPU.RangeTimeOver := 0;
          CPU.NMIActive := False;
          CPU.Flags := CPU.Flags or SCAN_KEYS_FLAG;
          StartHDMA;
        end;

        if PPU.VTimerEnabled and not PPU.HTimerEnabled and (CPU.V_Counter = PPU.IRQVBeamPos) then
          SetIRQSource(PPU_V_BEAM_IRQ_SOURCE);

        if CPU.V_Counter = PPU.ScreenHeight + FIRST_VISIBLE_LINE then // Início do V-blank
        begin
          EndScreenRefresh;
          IPPU.HDMA := 0;
          PPU.ForcedBlanking := Boolean((Memory.FillRAM[$2100] shr 7) and 1);

          if not PPU.ForcedBlanking then
          begin
            // Lógica de OAM...
          end;

          Memory.FillRAM[$4210] := $80; // or Model._5A22;

          if (Memory.FillRAM[$4200] and $80) <> 0 then
          begin
            CPU.Flags := CPU.Flags or NMI_FLAG;
            CPU.NMICycleCount := CPU.NMITriggerPoint;
          end;
        end;

        if CPU.V_Counter = PPU.ScreenHeight + 3 then
          UpdateJoypads;

        if CPU.V_Counter = FIRST_VISIBLE_LINE then
        begin
          Memory.FillRAM[$4210] := 0; // Model._5A22;
          CPU.Flags := CPU.Flags and not NMI_FLAG;
          StartScreenRefresh;
        end;

        if (CPU.V_Counter >= FIRST_VISIBLE_LINE) and (CPU.V_Counter < PPU.ScreenHeight + FIRST_VISIBLE_LINE) then
          RenderLine(CPU.V_Counter - FIRST_VISIBLE_LINE);

        // Lógica de Timers do APU
        if APU.TimerEnabled[2] then
        begin
          // ...
        end;
      end;
    HTIMER_BEFORE_EVENT, HTIMER_AFTER_EVENT:
      begin
        if PPU.HTimerEnabled and (not PPU.VTimerEnabled or (CPU.V_Counter = PPU.IRQVBeamPos)) then
          SetIRQSource(PPU_H_BEAM_IRQ_SOURCE);
      end;
  end;

  Reschedule;
end;

procedure DoHBlankProcessing_SFX;
begin
  // SuperFXExec(); // Chamada para a lógica do SuperFX
  DoHBlankProcessing_NoSFX;
end;

// --- Loop Principal de Execução ---

procedure MainLoop_Fast;
var
   Op: Byte;
   Opcodes: POpcodeTable;
begin
   repeat
      repeat
         if CPU.Flags <> 0 then
         begin
            if (CPU.Flags and NMI_FLAG) <> 0 then
            begin
               Dec(CPU.NMICycleCount);
               if CPU.NMICycleCount = 0 then
               begin
                  CPU.Flags := CPU.Flags and not NMI_FLAG;
                  if CPU.WaitingForInterrupt then
                  begin
                     CPU.WaitingForInterrupt := False;
                     Inc(ICPU.Registers.PCw.PC.W);
                  end;
                  OpcodeNMI;
               end;
            end;

            if (CPU.Flags and IRQ_FLAG) <> 0 then
            begin
               if CPU.IRQCycleCount = 0 then
               begin
                  if CPU.WaitingForInterrupt then
                  begin
                     CPU.WaitingForInterrupt := False;
                     Inc(ICPU.Registers.PCw.PC.W);
                  end;

                  if CPU.IRQActive = 0 then
                     CPU.Flags := CPU.Flags and not IRQ_FLAG
                  else
                     if not ((ICPU.Registers.P.W and (1 shl Ord(cfIRQ))) <> 0) then
                        OpcodeIRQ;
               end
               else
               begin
                  Dec(CPU.IRQCycleCount);
                  if (CPU.IRQCycleCount = 0) and ((ICPU.Registers.P.W and (1 shl Ord(cfIRQ))) <> 0) then
                     CPU.IRQCycleCount := 1;
               end;
            end;

            if (CPU.Flags and SCAN_KEYS_FLAG) <> 0 then
               Break; // Sai do loop interno de instruções
         end;

         CPU.PCAtOpcodeStart := ICPU.Registers.PCw.PC.W;

         if CPU.PCBase <> nil then
         begin
            Op := CPU.PCBase[ICPU.Registers.PCw.PC.W];
            CPU.Cycles := CPU.Cycles + CPU.MemSpeed;
            Opcodes := ICPU.Opcodes;
         end
         else
         begin
            Op := GetByte(ICPU.Registers.PCw.xPBPC);
            ICPU.OpenBus := Op;
            Opcodes := @OpcodesSlow;
         end;

         if ((ICPU.Registers.PCw.PC.W and MEMMAP_MASK) + ICPU.OpLengths[Op]) >= MEMMAP_BLOCK_SIZE then
         begin
            var oldPCBase := CPU.PCBase;
            SetPCBase(ICPU.ShiftedPB or Word(ICPU.Registers.PCw.PC.W + 4));
            if (oldPCBase <> CPU.PCBase) or ((ICPU.Registers.PCw.PC.W and not MEMMAP_MASK) = ($FFFF and not MEMMAP_MASK)) then
               Opcodes := @OpcodesSlow;
         end;

         Inc(ICPU.Registers.PCw.PC.W);
         Opcodes[Op].Opcode();

         // SA1_MAIN_LOOP; (Vazio para o MainLoop_Fast)

         if CPU.Cycles >= CPU.NextEvent then
            DoHBlankProcessing_NoSFX;

         if finishedFrame then
            Break;

         // APUExecute();

      until False; // Loop infinito, quebra com `Break`

      //ICPU.Registers.PC.W := IAPU.PC - IAPU.RAM; // Sincronização APU

      if not finishedFrame then
      begin
         PackStatus;
         //APUPackStatus;
         CPU.Flags := CPU.Flags and not SCAN_KEYS_FLAG;
      end
      else
      begin
         finishedFrame := False;
         Break; // Sai do loop principal do frame
      end;
   until finishedFrame;
end;

procedure MainLoop_SuperFX;
begin
   // Implementação similar a MainLoop_Fast, mas chamando DoHBlankProcessing_SFX
end;

procedure MainLoop_SA1;
begin
   // Implementação similar a MainLoop_Fast, mas chamando SA1MainLoop
end;

procedure SetMainLoop;
begin
   if Settings.Chip = CHIP_SA_1 then
      G_MainLoop := MainLoop_SA1
   else if Settings.Chip = CHIP_GSU then
      G_MainLoop := MainLoop_SuperFX
   else
      G_MainLoop := MainLoop_Fast;
end;

procedure SetIRQSource(source: Cardinal);
begin
   CPU.IRQActive := CPU.IRQActive or source;
   CPU.Flags := CPU.Flags or IRQ_FLAG;
   CPU.IRQCycleCount := 3;

   if CPU.WaitingForInterrupt then
   begin
      CPU.IRQCycleCount := 0;
      CPU.WaitingForInterrupt := False;
      Inc(ICPU.Registers.PCw.PC.W);
   end;
end;

procedure ClearIRQSource(source: Cardinal);
begin
   CPU.IRQActive := CPU.IRQActive and not source;
   if CPU.IRQActive = 0 then
      CPU.Flags := CPU.Flags and not IRQ_FLAG;
end;

function GetCPU(Address: Word): Byte;
var
   _byte: Byte;
begin
   if Address < $4200 then
   begin
      CPU.Cycles := CPU.Cycles + Settings.OneCycle;
      case Address of
         $4016:
         begin
            if (Memory.FillRAM[$4016] and 1) <> 0 then
               Exit(0);
            if PPU.Joypad1ButtonReadPos >= 16 then
               Exit(1);
            Result := (IPPU.Joypads[0] shr (PPU.Joypad1ButtonReadPos xor 15)) and 1;
            Inc(PPU.Joypad1ButtonReadPos);
            Exit;
         end;
         $4017:
         begin
            if (Memory.FillRAM[$4016] and 1) <> 0 then
            begin
               if IPPU.Controller = 4 then // SNES_MULTIPLAYER5
                  Exit(2);
               Exit(0);
            end;
            // ... Lógica para outros controles (Mouse, Justifier, etc)
            if PPU.Joypad2ButtonReadPos >= 16 then
               Exit(1);
            Result := (IPPU.Joypads[1] shr (PPU.Joypad2ButtonReadPos xor 15)) and 1;
            Inc(PPU.Joypad2ButtonReadPos);
            Exit;
         end;
         else
            Result := ICPU.OpenBus;
      end;
      Exit;
   end;

   if ((Address and $ff80) = $4300) and CPU.InDMA then
   begin
      Result := ICPU.OpenBus;
      Exit;
   end;

   case Address of
      $4210: // RDNMI
      begin
         CPU.WaitPC := CPU.PCAtOpcodeStart;
         _byte := Memory.FillRAM[$4210];
         Memory.FillRAM[$4210] := 0; // Model._5A22;
         Result := (_byte and $80) or (ICPU.OpenBus and $70); // or Model._5A22;
      end;
      $4211: // TIMEUP
      begin
         _byte := Ord((CPU.IRQActive and (PPU_V_BEAM_IRQ_SOURCE or PPU_H_BEAM_IRQ_SOURCE)) <> 0) shl 7;
         ClearIRQSource(PPU_V_BEAM_IRQ_SOURCE or PPU_H_BEAM_IRQ_SOURCE);
         Result := _byte or (ICPU.OpenBus and $7f);
      end;
      $4212: // HVBJOY
      begin
         CPU.WaitPC := CPU.PCAtOpcodeStart;
         Result := REGISTER_4212() or (ICPU.OpenBus and $3e);
      end;
      $4213..$421f: Result := Memory.FillRAM[Address];
      // ... (Lógica completa para todos os outros registradores de I/O da CPU)
      else
         Result := ICPU.OpenBus;
   end;
end;

procedure SetCPU(ByteValue: Byte; Address: Word);
var
   d: Integer;
begin
   if Address < $4200 then
   begin
      CPU.Cycles := CPU.Cycles + Settings.OneCycle;
      case Address of
         $4016:
         if ((ByteValue and 1) <> 0) and ((Memory.FillRAM[Address] and 1) = 0) then
         begin
            PPU.Joypad1ButtonReadPos := 0;
            PPU.Joypad2ButtonReadPos := 0;
            PPU.Joypad3ButtonReadPos := 0;
         end;
         $4017: Exit;
      end;
   end
   else if ((Address and $ff80) = $4300) and CPU.InDMA then
      Exit;

   case Address of
      $4200: // NMI enable and joypad auto-read enable
      begin
         // ... (Lógica de $4200)
      end;
      $4201:
      begin
         if ((ByteValue and $80) = 0) and ((Memory.FillRAM[$4213] and $80) = $80) then
            LatchCounters(True);
         Memory.FillRAM[$4201] := ByteValue;
         Memory.FillRAM[$4213] := ByteValue;
      end;
      // ... (Lógica completa para todos os outros registradores de I/O da CPU)
      $420B: // DMA Enable
      begin
         if (ByteValue and $01) <> 0 then
            DoDMA(0);
         if (ByteValue and $02) <> 0 then
            DoDMA(1);
         if (ByteValue and $04) <> 0 then
            DoDMA(2);
         if (ByteValue and $08) <> 0 then
            DoDMA(3);
         if (ByteValue and $10) <> 0 then
            DoDMA(4);
         if (ByteValue and $20) <> 0 then
            DoDMA(5);
         if (ByteValue and $40) <> 0 then
            DoDMA(6);
         if (ByteValue and $80) <> 0 then
            DoDMA(7);
      end;
      $420C:
      begin
         Memory.FillRAM[$420c] := ByteValue;
         IPPU.HDMA := ByteValue;
      end;
      // ... (etc.)
   end;

   Memory.FillRAM[Address] := ByteValue;
end;

procedure ResetCPU;
begin
   ICPU.Registers.PCw.xPBPC := GetWord( Cardinal($fffc), WRAP_NONE);
   ICPU.Registers.D.W := 0;
   ICPU.Registers.DB := 0;
   ICPU.Registers.S.H := 1;
   ICPU.Registers.S.L := $ff;
   ICPU.Registers.X.H := 0;
   ICPU.Registers.Y.H := 0;
   ICPU.Registers.P.W := 0;
   ICPU.ShiftedPB := 0;
   ICPU.ShiftedDB := 0;
   //SetFlags([cfMemoryFlag, cfIndexFlag, cfIRQ, cfEmulation]);
   //ClearFlags([cfDecimal]);

   CPU.BranchSkip := False;
   CPU.NMIActive := False;
   CPU.IRQActive := 0;
   CPU.WaitingForInterrupt := False;
   CPU.InDMA := False;
   CPU.PCBase := nil;
   CPU.PCAtOpcodeStart := 0;
   CPU.WaitPC := 0;
   CPU.WaitCounter := 1;
   CPU.V_Counter := 0;
   CPU.Cycles := 182;
   CPU.WhichEvent := HBLANK_START_EVENT;
   CPU.NextEvent := Settings.HBlankStart;
   CPU.MemSpeed := Settings.SlowOneCycle;
   CPU.MemSpeedx2 := Settings.SlowOneCycle * 2;
   CPU.FastROMSpeed := Settings.SlowOneCycle;
   CPU.SRAMModified := False;

   SetPCBase(ICPU.Registers.PCw.xPBPC);
   ICPU.Opcodes := @OpcodesE1;
   ICPU.OpLengths := @OpLengthsM1X1[0];
   CPU.NMICycleCount := 0;
   CPU.IRQCycleCount := 0;
   UnpackStatus;
end;

procedure CommonReset;
begin
   // (Porte da lógica de CommonReset de cpu.c)
   // if Settings.Chip = BS then ResetBSX;
   // ...
   ResetCPU;
   ResetDMA;
//   ResetAPU;
end;

procedure Reset;
begin
   FillChar(Memory.RAM, SizeOf(Memory.RAM), $55);
   FillChar(Memory.FillRAM, $8000, 0);

   ResetPPU;
   CommonReset;
end;

procedure SoftReset;
begin
   SoftResetPPU;
   CommonReset;
end;

end.
