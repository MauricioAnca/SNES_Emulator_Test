unit SNES.APU.DSP;

interface

uses
   SNES.DataTypes, SNES.Globals;

const
   // --- Constantes de Flags de Mixagem (de snesapu.h) ---
   MFLG_MUTE = $01; // Silenciar canal
   MFLG_KOFF = $02; // Canal em processo de Key Off
   MFLG_OFF  = $04; // Canal inativo
   MFLG_END  = $08; // Bloco final da amostra foi tocado
   MFLG_SSRC = $10; // Iniciar/Reiniciar a fonte da amostra (Start Source)

   // --- Constantes de Precisão de Envelope (de snesapu.h) ---
   E_SHIFT = 4; // Deslocamento para obter valor de 8 bits do envelope

type
   // --- Estruturas de `soundux.h` ---
   TSoundState = (SOUND_SILENT, SOUND_ATTACK, SOUND_DECAY, SOUND_SUSTAIN, SOUND_RELEASE, SOUND_GAIN, SOUND_INCREASE_LINEAR,
                  SOUND_INCREASE_BENT_LINE, SOUND_DECREASE_LINEAR, SOUND_DECREASE_EXPONENTIAL);

   TChannelMode = (MODE_NONE, MODE_ADSR, MODE_RELEASE, MODE_GAIN, MODE_INCREASE_LINEAR, MODE_INCREASE_BENT_LINE,
                   MODE_DECREASE_LINEAR, MODE_DECREASE_EXPONENTIAL);

   TSoundType = (SOUND_SAMPLE, SOUND_NOISE);

   // Armazena o estado de um canal para interface ou save state
   TChannel = packed record
      next_sample: SmallInt;
      decoded: array[0..15] of SmallInt;
      envx: Integer;
      mode: TChannelMode;
      state: TSoundState;
      type_: TSoundType;
      count: Cardinal;
      block_pointer: Cardinal;
      sample_pointer: Cardinal;
      block: PSmallInt;
   end;

   // Estrutura de alto nível para o estado do som
   TSSoundData = packed record
      echo_buffer_size: Integer;
      echo_enable: Integer;
      echo_feedback: Integer;
      echo_ptr: Integer;
      echo_write_enabled: Integer;
      pitch_mod: Integer;
      channels: array[0..NUM_CHANNELS - 1] of TChannel;
   end;

   // --- Estrutura principal de processamento do DSP (de snesapu.c) ---
   // Representa o estado interno de um dos 8 canais de áudio (vozes) do DSP.
   TVoiceMix = packed record
      // Forma de Onda (Waveform)
      bHdr: Byte;      // Cabeçalho do bloco BRR atual
      mFlg: Byte;      // Flags de mixagem (MFLG_...)
      bCur: Word;      // Ponteiro para o bloco BRR atual na ARAM
      bMixStart: Word; // Ponteiro de início para a mixagem
      bStart: Word;    // Ponteiro de início da amostra

      // Envelope
      eAdj: Integer;   // Valor a ser ajustado na altura do envelope
      eDest: Integer;  // Destino do envelope
      eVal: Integer;   // Valor atual do envelope
      eDec: Cardinal;  // Parte decimal do passo do envelope (ponto fixo .16)
      eRate: Cardinal; // Taxa de ajuste do envelope (ponto fixo 16.16)
      eMode: Byte;     // Modo atual do envelope (ADSR, Gain, etc.)
      eRIdx: Byte;     // Índice na tabela de taxas (0-31)
      _pad1: Byte;     // Padding para alinhamento

      // Amostras (Samples)
      sIdx: ShortInt;  // Índice da amostra atual no buffer sBuf
      sP1: Integer;    // Última amostra descomprimida (anterior 1)
      sP2: Integer;    // Penúltima amostra descomprimida (anterior 2)
      sBuf: array[0..31] of SmallInt; // Buffer para os 16 samples descomprimidos do bloco BRR

      // Mixagem
      mChnL: Integer;  // Volume do canal esquerdo (-24.7)
      mChnR: Integer;  // Volume do canal direito (-24.7)
      mOut: Integer;   // Última amostra de saída antes do volume do canal (usado para modulação de pitch)
      mDec: Cardinal;  // Parte decimal do pitch (ponto fixo .16) (usado como delta para interpolação)
      mOrgP: Cardinal; // Valor original do pitch lido do DSP
      mOrgRate: Cardinal; // Taxa de pitch antes da modulação (16.16)
      mRate: Cardinal;    // Taxa de pitch após a modulação (16.16)
   end;

var
   // --- Variáveis de Estado Globais do DSP ---
   SoundData: TSSoundData; // Estado de alto nível (de soundux.h)
   mix: array[0..7] of TVoiceMix; // Estado interno dos 8 canais de som
   voiceKon: Byte; // Máscara de bits dos canais com Key On

   // Volumes
   volMainL: Integer;
   volMainR: Integer;
   volEchoL: Integer;
   volEchoR: Integer;

   // Eco
   echoStart: Cardinal;
   echoDel: Cardinal;
   echoCur: Cardinal;
   echoFB: Integer;

   // Ruído
   nSmp: Integer;
   nDec: SmallInt;
   nRate: SmallInt;

   // Filtro de Eco (FIR)
   firCur: Byte;
   disEcho: Byte;
   FilterTaps: array[0..7] of ShortInt;
   Echo: array[0..ECHOBUF - 1] of Integer;
   Loop: array[0..FIRBUF - 1] of SmallInt;

// --- Procedimentos e Funções Públicas da Unit ---
procedure InitAPUDSP;
procedure ResetAPUDSP;
procedure SetPlaybackRate(rate: Integer);
procedure StoreAPUDSP;
procedure RestoreAPUDSP;
procedure SetAPUDSPAmp(amp: Integer);
procedure MixSamples(pBuf: PSmallInt; num: Integer);
procedure APUDSPIn(address: Byte; data: Byte);
procedure SetEchoEnable(byte: Byte);
procedure SetEchoFeedback(feedback: Integer);
procedure SetEchoDelay(rate, delay: Integer);
procedure SetFilterCoefficient(tap, value: Integer);
procedure ResetSound(full: Boolean);
procedure FixSoundAfterSnapshotLoad;

implementation

type
   // Tipo procedural para o nosso jump table de handlers
   TDSPRegWriteHandler = procedure(channel: Integer; data: Byte);

var
   // Tabela de ponteiros para os procedimentos que manipulam a escrita nos registradores do DSP
   dspRegs: array[0..$7F] of TDSPRegWriteHandler;

const
   // Tabela para converter o modo de envelope do DSP para o nosso enum TSoundState
   SAtoEMode: array[0..255] of TSoundState = (
      SOUND_SILENT, // 0 - E_DEC
      SOUND_DECREASE_EXPONENTIAL, // 1 - E_EXP
      SOUND_INCREASE_LINEAR, // 2 - E_INC
      SOUND_SILENT, // 3
      SOUND_SILENT, // 4
      SOUND_SILENT, // 5
      SOUND_INCREASE_BENT_LINE, // 6 - E_BENT
      SOUND_SILENT, // 7
      SOUND_RELEASE, // 8 - E_REL
      SOUND_SUSTAIN, // 9 - E_SUST
      SOUND_ATTACK, // 10 - E_ATT
      SOUND_SILENT, // 11
      SOUND_SILENT, // 12
      SOUND_DECAY, // 13 - E_DECAY
      // O resto é preenchido com SOUND_SILENT
      SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT,
      SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT,
      SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT,
      SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT,
      SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT,
      SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT,
      SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT,
      SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT,
      SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT,
      SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT,
      SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT,
      SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT,
      SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT,
      SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT,
      SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT,
      SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT,
      SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT,
      SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT,
      SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT,
      SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT,
      SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT,
      SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT, SOUND_SILENT);

// --- Rotinas Auxiliares de Envelope (Porte de snesapu.c) ---

procedure ChgSus(channel: Integer); forward;
procedure ChgDec(channel: Integer); forward;
procedure ChgAtt(channel: Integer); forward;

procedure ChgADSR(channel: Integer); inline;
begin
   case mix[channel].eMode of
      10: ChgAtt(channel); // E_ATT
      13: ChgDec(channel); // E_DECAY
      9, (128 or 9): if mix[channel].eVal > 0 then ChgSus(channel); // E_SUST, E_IDLE or E_SUST
   end;
end;

procedure ChgGain(channel: Integer); inline;
const
   A_GAIN = 1 shl E_SHIFT;
   A_LIN  = (128 * A_GAIN) div 64;
   D_MIN = 0;
   D_ATTACK = (128 * A_GAIN) - 1;
   D_BENT = (128 * A_GAIN * 3) div 4;
begin
   if (APU.DSP[chs[channel].o + APU_GAIN] and $80) = 0 then // Gain direto?
   begin
      mix[channel].eMode := Ord(SOUND_GAIN);
      mix[channel].eRIdx := 0;
      mix[channel].eRate := rateTab[mix[channel].eRIdx];
      mix[channel].eAdj  := 0; // A_EXP
      mix[channel].eVal  := (APU.DSP[chs[channel].o + APU_GAIN] and $7F) * A_GAIN;
      mix[channel].eDest := mix[channel].eVal;
      Exit;
   end;

   case APU.DSP[chs[channel].o + APU_GAIN] and $60 of
      $00: // Decrease Linear
      begin
         mix[channel].eRIdx := APU.DSP[chs[channel].o + APU_GAIN] and $1F;
         mix[channel].eRate := rateTab[mix[channel].eRIdx];
         mix[channel].eAdj  := A_LIN;
         mix[channel].eDest := D_MIN;
         if (mix[channel].eRate = 0) or (mix[channel].eVal <= D_MIN) then
         begin
            mix[channel].eMode := 128 or Ord(SOUND_DECREASE_LINEAR); // E_IDLE
            mix[channel].eDec  := 0;
         end
         else
            mix[channel].eMode := Ord(SOUND_DECREASE_LINEAR);
      end;
      $20: // Decrease Exponential
      begin
         mix[channel].eRIdx := APU.DSP[chs[channel].o + APU_GAIN] and $1F;
         mix[channel].eRate := rateTab[mix[channel].eRIdx];
         mix[channel].eAdj  := 0; // A_EXP
         mix[channel].eDest := D_MIN;
         if (mix[channel].eRate = 0) or (mix[channel].eVal <= D_MIN) then
         begin
            mix[channel].eMode := 128 or Ord(SOUND_DECREASE_EXPONENTIAL); // E_IDLE
            mix[channel].eDec  := 0;
         end
         else
            mix[channel].eMode := Ord(SOUND_DECREASE_EXPONENTIAL);
      end;
      $40: // Increase Linear
      begin
         mix[channel].eRIdx := APU.DSP[chs[channel].o + APU_GAIN] and $1F;
         mix[channel].eRate := rateTab[mix[channel].eRIdx];
         mix[channel].eAdj  := A_LIN;
         mix[channel].eDest := D_ATTACK;
         if (mix[channel].eRate = 0) or (mix[channel].eVal >= D_ATTACK) then
         begin
            mix[channel].eMode := 128 or Ord(SOUND_INCREASE_LINEAR); // E_IDLE
            mix[channel].eDec  := 0;
         end
         else
            mix[channel].eMode := Ord(SOUND_INCREASE_LINEAR);
      end;
      $60: // Increase Bent Line
      begin
         mix[channel].eRIdx := APU.DSP[chs[channel].o + APU_GAIN] and $1F;
         mix[channel].eRate := rateTab[mix[channel].eRIdx];
         if mix[channel].eVal < D_BENT then
         begin
            mix[channel].eAdj  := A_LIN;
            mix[channel].eDest := D_BENT;
         end
         else
         begin
            mix[channel].eAdj  := A_LIN div 4; // A_BENT
            mix[channel].eDest := D_ATTACK;
         end;

         if (mix[channel].eRate = 0) or (mix[channel].eVal >= D_ATTACK) then
         begin
            mix[channel].eMode := 128 or Ord(SOUND_INCREASE_BENT_LINE); // E_IDLE
            mix[channel].eDec  := 0;
         end
         else
            mix[channel].eMode := Ord(SOUND_INCREASE_BENT_LINE);
      end;
   end;
end;

procedure StartEnv(channel: Integer); inline;
begin
   if ((mix[channel].mFlg and (MFLG_OFF or MFLG_END)) <> 0) or ((mix[channel].eMode and 128) <> 0) then
      mix[channel].eDec := 0;

   if (APU.DSP[chs[channel].o + APU_ADSR1] and $80) <> 0 then
      ChgAtt(channel)
   else
      ChgGain(channel);
end;

procedure ChgSus(channel: Integer);
const
   A_EXP = 0;
   D_MIN = 0;
begin
   mix[channel].eRIdx := APU.DSP[chs[channel].o + APU_ADSR2] and $1F;
   mix[channel].eRate := rateTab[mix[channel].eRIdx];
   if (mix[channel].eRate = 0) or (mix[channel].eVal <= D_MIN) then
   begin
      mix[channel].eMode := 128 or Ord(SOUND_SUSTAIN); // E_IDLE | E_SUST
      mix[channel].eDec := 0;
   end
   else
      mix[channel].eMode := Ord(SOUND_SUSTAIN); // E_SUST
   mix[channel].eAdj := A_EXP;
   mix[channel].eDest := D_MIN;
end;

procedure ChgDec(channel: Integer);
const
   D_EXP = ((128 * (1 shl E_SHIFT)) div 8);
begin
   var sl := (APU.DSP[chs[channel].o + APU_ADSR2] shr 5);
   var eDest := (sl + 1) * D_EXP;

   if (sl = 7) or (mix[channel].eVal <= eDest) then
   begin
      ChgSus(channel);
      Exit;
   end;
   mix[channel].eRIdx := ((APU.DSP[chs[channel].o + APU_ADSR1] and $70) shr 3) + 16;
   mix[channel].eRate := rateTab[mix[channel].eRIdx];
   mix[channel].eAdj := 0; // A_EXP
   mix[channel].eDest := eDest;
   mix[channel].eMode := Ord(SOUND_DECAY); // E_DECAY
end;

procedure ChgAtt(channel: Integer);
const
   A_GAIN = 1 shl E_SHIFT;
   A_LIN  = (128 * A_GAIN) div 64;
   A_NOATT = (64 * A_GAIN);
   D_ATTACK = (128 * A_GAIN) - 1;
begin
   if mix[channel].eVal >= D_ATTACK then
   begin
      ChgDec(channel);
      Exit;
   end;
   var ar := APU.DSP[chs[channel].o + APU_ADSR1] and $0F;
   mix[channel].eRIdx := (ar shl 1) + 1;
   mix[channel].eRate := rateTab[mix[channel].eRIdx];
   mix[channel].eAdj := iif(ar = $0F, A_NOATT, A_LIN);
   mix[channel].eDest := D_ATTACK;
   mix[channel].eMode := Ord(SOUND_ATTACK); // E_ATT
end;

// --- Implementação dos Handlers de Registradores ---

procedure RVolL(channel: Integer; val: Byte);
begin
   mix[channel].mChnL := SmallInt(val);
end;

procedure RVolR(channel: Integer; val: Byte);
begin
   mix[channel].mChnR := SmallInt(val);
end;

procedure RPitch(channel: Integer; val: Byte);
var
   r: Int64;
begin
   mix[channel].mOrgP := DSPGetPitch(channel);
   r := Int64(mix[channel].mOrgP) * pitchAdj;
   mix[channel].mOrgRate := (r shr FIXED_POINT_SHIFT) + Ord((r and FIXED_POINT_REMAINDER) <> 0);
end;

procedure RADSR1(channel: Integer; val: Byte);
begin
   if (mix[channel].mFlg and MFLG_KOFF) <> 0 then
      Exit;
   if (APU.DSP[chs[channel].o + APU_ADSR1] and $80) <> 0 then
      ChgADSR(channel)
   else
      ChgGain(channel);
end;

procedure RADSR2(channel: Integer; val: Byte);
begin
   if ((mix[channel].mFlg and MFLG_KOFF) <> 0) or ((APU.DSP[chs[channel].o + APU_ADSR1] and $80) = 0) then
      Exit;
   ChgADSR(channel);
end;

procedure RGain(channel: Integer; val: Byte);
begin
   if ((mix[channel].mFlg and MFLG_KOFF) <> 0) or ((APU.DSP[chs[channel].o + APU_ADSR1] and $80) <> 0) then
      Exit;
   ChgGain(channel);
end;

procedure RMVolL(channel: Integer; val: Byte);
begin
   volMainL := (SmallInt(val) * volAdj) shr FIXED_POINT_SHIFT;
end;

procedure RMVolR(channel: Integer; val: Byte);
begin
   volMainR := (SmallInt(val) * volAdj) shr FIXED_POINT_SHIFT;
end;

procedure REVolL(channel: Integer; val: Byte);
begin
   volEchoL := (SmallInt(val) * volAdj) shr FIXED_POINT_SHIFT;
end;

procedure REVolR(channel: Integer; val: Byte);
begin
   volEchoR := (SmallInt(val) * volAdj) shr FIXED_POINT_SHIFT;
end;

procedure REFB(channel: Integer; val: Byte);
begin
   echoFB := SmallInt(val);
end;

procedure REDl(channel: Integer; val: Byte);
begin
   val := val and $0F;
   if val = 0 then
      echoDel := 2
   else
      echoDel := (Cardinal(val shl 4) * dspRate div 1000) shl 1;
end;

procedure RFCI(channel: Integer; val: Byte);
begin
   FilterTaps[channel] := ShortInt(val);
end;

procedure RKOn(channel: Integer; val: Byte);
var
   i: Integer;
begin
   if val <> 0 then
   begin
      for i := 0 to 7 do
      begin
         if (val and chs[i].m) <> 0 then
         begin
            dspRegs[chs[i].o + APU_VOL_LEFT](i, APU.DSP[chs[i].o + APU_VOL_LEFT]);
            dspRegs[chs[i].o + APU_VOL_RIGHT](i, APU.DSP[chs[i].o + APU_VOL_RIGHT]);
            RPitch(i, APU.DSP[chs[i].o + APU_P_LOW]);
            StartEnv(i);
            mix[i].bStart := DSPGetSrc(i);
            mix[i].mFlg := mix[i].mFlg or MFLG_SSRC;
            mix[i].mFlg := mix[i].mFlg and not (MFLG_KOFF or MFLG_OFF);
            voiceKon := voiceKon or chs[i].m;
         end;
      end;
   end;
end;

procedure RKOf(channel: Integer; val: Byte);
const
   A_KOF = ((128 * (1 shl E_SHIFT)) div 256);
var
   i: Integer;
begin
   val := val and voiceKon;
   if val = 0 then Exit;

   for i := 0 to 7 do
   begin
      if (val and chs[i].m) <> 0 then
      begin
         mix[i].eRIdx := $1F;
         mix[i].eRate := rateTab[mix[i].eRIdx];
         mix[i].eAdj := A_KOF;
         mix[i].eDest := 0; // D_MIN
         mix[i].eMode := Ord(SOUND_RELEASE); // E_REL
         mix[i].mFlg := mix[i].mFlg or MFLG_KOFF;
         voiceKon := voiceKon and not chs[i].m;
      end;
   end;
end;

procedure RFlg(channel: Integer; val: Byte);
begin
   disEcho := (disEcho and not APU_ECHO_DISABLED) or (val and APU_ECHO_DISABLED);
   APU.DSP[APU_FLG] := val;
   SetNoiseHertz;
end;

procedure RESA(channel: Integer; val: Byte);
begin
   echoStart := (Cardinal(val) * 64 * dspRate div SNES_SAMPLE_RATE) shl 1;
end;

procedure REndX(channel: Integer; val: Byte);
begin
   APU.DSP[APU_ENDX] := 0;
end;

procedure RNull(channel: Integer; val: Byte);
begin
  // Null register, does nothing.
end;

// --- Função Principal de Despacho e Inicialização ---

procedure APUDSPIn(address, data: Byte);
var
   channel: Integer;
begin
   if (address and $80) <> 0 then
      Exit; // Writes to 80-FFh have no effect

   channel := (address and $70) shr 4;

   // Atualiza o valor no array de registradores do DSP
   APU.DSP[address] := data;

   // Se o canal estiver desligado, não chama o handler (exceto para alguns registradores)
   if ((mix[channel].mFlg and MFLG_OFF) <> 0) and (address <> (chs[channel].o + APU_KON)) then
      Exit;

   // Chama o handler correto da tabela
   if Assigned(dspRegs[address]) then
      dspRegs[address](channel, data);
end;

procedure InitializeDSPHandlers;
begin
   // Associa os procedimentos aos seus endereços de registrador na tabela
   dspRegs[$00] := @RVolL;  dspRegs[$01] := @RVolR;  dspRegs[$02] := @RPitch; dspRegs[$03] := @RPitch; dspRegs[$04] := @RNull;  dspRegs[$05] := @RADSR1; dspRegs[$06] := @RADSR2; dspRegs[$07] := @RGain;
   dspRegs[$08] := @RNull;  dspRegs[$09] := @RNull;  dspRegs[$0A] := @RNull;  dspRegs[$0B] := @RNull;  dspRegs[$0C] := @RMVolL; dspRegs[$0D] := @REFB;   dspRegs[$0E] := @RNull;  dspRegs[$0F] := @RFCI;
   dspRegs[$10] := @RVolL;  dspRegs[$11] := @RVolR;  dspRegs[$12] := @RPitch; dspRegs[$13] := @RPitch; dspRegs[$14] := @RNull;  dspRegs[$15] := @RADSR1; dspRegs[$16] := @RADSR2; dspRegs[$17] := @RGain;
   dspRegs[$18] := @RNull;  dspRegs[$19] := @RNull;  dspRegs[$1A] := @RNull;  dspRegs[$1B] := @RNull;  dspRegs[$1C] := @RMVolR; dspRegs[$1D] := @RNull;  dspRegs[$1E] := @RNull;  dspRegs[$1F] := @RFCI;
   dspRegs[$20] := @RVolL;  dspRegs[$21] := @RVolR;  dspRegs[$22] := @RPitch; dspRegs[$23] := @RPitch; dspRegs[$24] := @RNull;  dspRegs[$25] := @RADSR1; dspRegs[$26] := @RADSR2; dspRegs[$27] := @RGain;
   dspRegs[$28] := @RNull;  dspRegs[$29] := @RNull;  dspRegs[$2A] := @RNull;  dspRegs[$2B] := @RNull;  dspRegs[$2C] := @REVolL; dspRegs[$2D] := @RNull;  dspRegs[$2E] := @RNull;  dspRegs[$2F] := @RFCI;
   dspRegs[$30] := @RVolL;  dspRegs[$31] := @RVolR;  dspRegs[$32] := @RPitch; dspRegs[$33] := @RPitch; dspRegs[$34] := @RNull;  dspRegs[$35] := @RADSR1; dspRegs[$36] := @RADSR2; dspRegs[$37] := @RGain;
   dspRegs[$38] := @RNull;  dspRegs[$39] := @RNull;  dspRegs[$3A] := @RNull;  dspRegs[$3B] := @RNull;  dspRegs[$3C] := @REVolR; dspRegs[$3D] := @RNull;  dspRegs[$3E] := @RNull;  dspRegs[$3F] := @RFCI;
   dspRegs[$40] := @RVolL;  dspRegs[$41] := @RVolR;  dspRegs[$42] := @RPitch; dspRegs[$43] := @RPitch; dspRegs[$44] := @RNull;  dspRegs[$45] := @RADSR1; dspRegs[$46] := @RADSR2; dspRegs[$47] := @RGain;
   dspRegs[$48] := @RNull;  dspRegs[$49] := @RNull;  dspRegs[$4A] := @RNull;  dspRegs[$4B] := @RNull;  dspRegs[$4C] := @RKOn;   dspRegs[$4D] := @RNull;  dspRegs[$4E] := @RNull;  dspRegs[$4F] := @RFCI;
   dspRegs[$50] := @RVolL;  dspRegs[$51] := @RVolR;  dspRegs[$52] := @RPitch; dspRegs[$53] := @RPitch; dspRegs[$54] := @RNull;  dspRegs[$55] := @RADSR1; dspRegs[$56] := @RADSR2; dspRegs[$57] := @RGain;
   dspRegs[$58] := @RNull;  dspRegs[$59] := @RNull;  dspRegs[$5A] := @RNull;  dspRegs[$5B] := @RNull;  dspRegs[$5C] := @RKOf;   dspRegs[$5D] := @RNull;  dspRegs[$5E] := @RNull;  dspRegs[$5F] := @RFCI;
   dspRegs[$60] := @RVolL;  dspRegs[$61] := @RVolR;  dspRegs[$62] := @RPitch; dspRegs[$63] := @RPitch; dspRegs[$64] := @RNull;  dspRegs[$65] := @RADSR1; dspRegs[$66] := @RADSR2; dspRegs[$67] := @RGain;
   dspRegs[$68] := @RNull;  dspRegs[$69] := @RNull;  dspRegs[$6A] := @RNull;  dspRegs[$6B] := @RNull;  dspRegs[$6C] := @RFlg;   dspRegs[$6D] := @RESA;   dspRegs[$6E] := @RNull;  dspRegs[$6F] := @RFCI;
   dspRegs[$70] := @RVolL;  dspRegs[$71] := @RVolR;  dspRegs[$72] := @RPitch; dspRegs[$73] := @RPitch; dspRegs[$74] := @RNull;  dspRegs[$75] := @RADSR1; dspRegs[$76] := @RADSR2; dspRegs[$77] := @RGain;
   dspRegs[$78] := @RNull;  dspRegs[$79] := @RNull;  dspRegs[$7A] := @RNull;  dspRegs[$7B] := @RNull;  dspRegs[$7C] := @REndX;  dspRegs[$7D] := @REDl;   dspRegs[$7E] := @RNull;  dspRegs[$7F] := @RFCI;
end;

end.
