unit SNES.APU.DSP;

interface

uses
   SNES.DataTypes,
   SNES.Globals;

// Procedimento principal para inicializar o estado do DSP.
procedure InitDSP;

// Procedimento chamado pela CPU para escrever em um registrador do DSP.
procedure APUDSPIn(address: Byte; data: Byte);

// Procedimento principal que processa 'cycles' do DSP.
procedure DSPProcess(cycles: Cardinal);

// Procedimento que mixa os 8 canais e retorna um par de amostras estéreo.
procedure DSPStereo(var l, r: Integer);

// Procedimento para resetar o estado do DSP.
procedure ResetDSP;

implementation

uses
   System.SysUtils, System.Math;

type
   TDSPRegFunc = procedure(channel: Integer; val: Byte);

var
   // --- Variáveis de Estado Global ---
   mMVolL, mMVolR: Byte;
   mEVolL, mEVolR: Byte;
   mEFB: Byte;
   mDIR: Byte;
   mESA: Byte;
   mEDL: Byte;
   voiceKon: Byte;
   disEcho: Byte;
   dspRegs: array [0 .. 127] of TDSPRegFunc;
   mix: array [0 .. 7] of TVoiceMix;

   // --- Tabelas de Lookup ---
   rateTab: array [0 .. 31] of Cardinal = ($FFFFFFFF, $FFFFFFFF, $00004000, $00003000, $00002800, $00002000, $00001800, $00001400, $00001000,
                                           $00000C00, $00000A00, $00000800, $00000700, $00000600, $00000500, $00000480, $00000400, $00000380,
                                           $00000300, $00000280, $00000200, $000001C0, $00000180, $00000140, $00000100, $000000E0, $000000C0,
                                           $000000A0, $00000080, $00000070, $00000060, $00000050);

   sustainTab: array [0 .. 31] of Cardinal; // Tabela de taxa para Sustain
   attackTab: array [0 .. 15] of Cardinal;  // Tabela de taxa para Attack
   // Tabela de interpolação para decodificação de amostras BRR
   brrTab: array [0 .. 511] of SmallInt;
   echoBuffer: array [0 .. ECHOBUF - 1] of SmallInt;
   echoWritePtr, echoReadPtr: Cardinal;
   echoLength: Cardinal;


function Clamp(val, min, max: Integer): Integer; inline;
begin
   if val < min then
      Result := min
   else if val > max then
      Result := max
   else
      Result := val;
end;

// ******************************************************************************
// Seção 2: Procedimentos Auxiliares e Handlers de Registradores
// ******************************************************************************

{
  DSPGetPitch
  ------------------------------------------------------------------------------
  Lê os registradores de pitch baixo (P_L) e alto (P_H) para um canal e os
  combina para formar o valor de pitch de 14 bits.
}
function DSPGetPitch(channel: Integer): Cardinal;
var
   addr_l, addr_h: Byte;
   pitch_l, pitch_h: Byte;
begin
   // Calcula o endereço dos registradores de pitch para o canal especificado
   addr_l := (channel * $10) + APU_P_L;
   addr_h := (channel * $10) + APU_P_H;

   // Lê os valores dos registradores do array DSP
   pitch_l := APU.DSP[addr_l];
   pitch_h := APU.DSP[addr_h];

   // Combina o byte baixo e os 6 bits relevantes do byte alto ($3F)
   Result := pitch_l or ((pitch_h and $3F) shl 8);
end;

{
  DSPGetSrc
  ------------------------------------------------------------------------------
  Encontra o endereço de início de uma amostra de som (source) na RAM da APU.
}
function DSPGetSrc(channel: Integer): Cardinal;
var
   dir_addr: Word;
   srcn_addr: Byte;
   entry_addr: Word;
begin
   // O registrador DIR ($5D) aponta para a página (high byte) do diretório de amostras
   dir_addr := mDIR shl 8;

   // O registrador SRCN ($x4) para o canal é o índice no diretório.
   // Cada entrada no diretório tem 4 bytes.
   srcn_addr := mix[channel].mSRCN;
   entry_addr := dir_addr + (srcn_addr * 4);

   // Lê 2 bytes (LSB, MSB) para obter o endereço de início da amostra
   Result := IAPU.RAM[entry_addr] or (IAPU.RAM[entry_addr + 1] shl 8);
end;

{
  SetNoiseHertz
  ------------------------------------------------------------------------------
  Configura a frequência do canal de ruído com base no valor do registrador FLG.
}
procedure SetNoiseHertz;
const
   // Tabela de frequências para cada valor do índice de ruído (0-31)
   hertz: array [0 .. 31] of Integer = (4000, 3846, 3703, 3571, 3448, 3333, 3225, 3125, 3030, 2941, 2857, 2777, 2702, 2631, 2564, 2500,
                                        2439, 2380, 2325, 2272, 2222, 2173, 2127, 2083, 2040, 2000, 1960, 1923, 1886, 1851, 1818, 1785);
var
   noise_rate: Integer;
begin
   if (APU.DSP[APU_FLG] and NOISE_ENABLE) <> 0 then
   begin
      noise_rate := APU.DSP[APU_FLG] and $1F;
      // TODO: Conectar a variável de estado de ruído à sua estrutura de mixagem.
      // Ex: mix[0].nRate := hertz[noise_rate];
   end;
end;

{
  RPitch
  ------------------------------------------------------------------------------
  Handler auxiliar chamado quando o pitch de um canal é alterado.
  Calcula a taxa de passo (mOrgRate) em formato de ponto fixo.
}
procedure RPitch(channel: Integer; val: Byte);
var
   r: Int64;
begin
   mix[channel].mOrgP := DSPGetPitch(channel);
   r := Int64(mix[channel].mOrgP) * pitchAdj;
   mix[channel].mOrgRate := (r shr FIXED_POINT_SHIFT) + Ord((r and FIXED_POINT_REMAINDER) <> 0);
end;

// --- Implementações dos Handlers de Registradores ---

procedure ChgADSR(channel: Integer); forward;
procedure ChgGain(channel: Integer); forward;
procedure StartEnv(channel: Integer); forward;

procedure RVolL(channel: Integer; val: Byte);
begin
   mix[channel].mVolL := val;
end;

procedure RVolR(channel: Integer; val: Byte);
begin
   mix[channel].mVolR := val;
end;

procedure RPitchL(channel: Integer; val: Byte);
begin
   mix[channel].mPitchL := val;
   RPitch(channel, val);
end;

procedure RPitchH(channel: Integer; val: Byte);
begin
   mix[channel].mPitchH := val;
   RPitch(channel, val);
end;

procedure RSRCN(channel: Integer; val: Byte);
begin
   mix[channel].mSRCN := val;
   if DSPGetSrc(channel) <> mix[channel].bStart then
      mix[channel].mFlg := mix[channel].mFlg or MFLG_SSRC;
end;

procedure RADSR1(channel: Integer; val: Byte);
begin
   mix[channel].mADSR1 := val;
   if mix[channel].eMode in [SOUND_ATTACK, SOUND_DECAY, SOUND_SUSTAIN] then
      ChgADSR(channel);
end;

procedure RADSR2(channel: Integer; val: Byte);
begin
   mix[channel].mADSR2 := val;
   if mix[channel].eMode in [SOUND_DECAY, SOUND_SUSTAIN] then
      ChgADSR(channel);
end;

procedure RGain(channel: Integer; val: Byte);
begin
   mix[channel].mGAIN := val;
   if mix[channel].eMode >= SOUND_GAIN then
      ChgGain(channel);
end;

procedure RMVolL(channel: Integer; val: Byte);
begin
   mMVolL := val;
end;

procedure RMVolR(channel: Integer; val: Byte);
begin
   mMVolR := val;
end;

procedure REVolL(channel: Integer; val: Byte);
begin
   mEVolL := val;
end;

procedure REVolR(channel: Integer; val: Byte);
begin
   mEVolR := val;
end;

procedure REFB(channel: Integer; val: Byte);
begin
   mEFB := val;
end;

procedure RDir(channel: Integer; val: Byte);
begin
   mDIR := val;
end;

procedure RESA(channel: Integer; val: Byte);
begin
   mESA := val;
end;

procedure REDL(channel: Integer; val: Byte);
begin
   mEDL := val and $0F;
end;

procedure RCOEF(channel: Integer; val: Byte);
begin
end; // Handler para coeficientes de eco

procedure RFlg(channel: Integer; val: Byte);
begin
   disEcho := (disEcho and not ECHO_ENABLE) or (val and ECHO_ENABLE);
   APU.DSP[APU_FLG] := val;
   SetNoiseHertz;
end;

procedure RKOn(channel: Integer; val: Byte);
var
   i: Integer;
begin
   if val <> 0 then
   begin
      voiceKon := voiceKon or val;
      for i := 0 to 7 do
      begin
         if (val and (1 shl i)) <> 0 then
         begin
            mix[i].mFlg := mix[i].mFlg and not(MFLG_KOFF or MFLG_OFF);
            StartEnv(i);
         end;
      end;
   end;
end;

procedure RKOff(channel: Integer; val: Byte);
var
   i: Integer;
begin
   for i := 0 to 7 do
   begin
      if (val and (1 shl i)) <> 0 then
      begin
         mix[i].mFlg := mix[i].mFlg or MFLG_KOFF;
      end;
   end;
end;

// --- Procedimento de Inicialização Principal ---

procedure InitDSP;
var
   i: Integer;
begin
   // Zera todos os ponteiros da tabela de dispatch
   FillChar(dspRegs, SizeOf(dspRegs), 0);

   // Associa cada endereço de registrador ao seu procedimento handler
   for i := 0 to 7 do
   begin
      dspRegs[i * $10 + APU_VOL_L] := @RVolL;
      dspRegs[i * $10 + APU_VOL_R] := @RVolR;
      dspRegs[i * $10 + APU_P_L] := @RPitchL;
      dspRegs[i * $10 + APU_P_H] := @RPitchH;
      dspRegs[i * $10 + APU_SRCN] := @RSRCN;
      dspRegs[i * $10 + APU_ADSR1] := @RADSR1;
      dspRegs[i * $10 + APU_ADSR2] := @RADSR2;
      dspRegs[i * $10 + APU_GAIN] := @RGain;
   end;

   dspRegs[APU_MVOL_L] := @RMVolL;
   dspRegs[APU_MVOL_R] := @RMVolR;
   dspRegs[APU_EVOL_L] := @REVolL;
   dspRegs[APU_EVOL_R] := @REVolR;
   dspRegs[APU_KON] := @RKOn;
   dspRegs[APU_KOF] := @RKOff;
   dspRegs[APU_FLG] := @RFlg;
   dspRegs[APU_EFB] := @REFB;
   dspRegs[APU_DIR] := @RDir;
   dspRegs[APU_ESA] := @RESA;
   dspRegs[APU_EDL] := @REDL;

   for i := 0 to 7 do
      dspRegs[$0F + i * $10] := @RCOEF;

   // Preenche as tabelas de lookup com base na 'rateTab'
   for i := 0 to 31 do
      sustainTab[i] := rateTab[i];
   for i := 0 to 15 do
      attackTab[i] := rateTab[i * 2 + 1];

   // Reseta o estado do DSP para os valores padrão
   ResetDSP;
end;

// *****************************************************
// --- Lógica de Processamento de Envelope e Amostra ---
// *****************************************************

{
  ChgADSR
  ------------------------------------------------------------------------------
  Configura o estado do envelope para um dos modos ADSR (Attack, Decay, Sustain, Release)
  com base nos valores dos registradores mADSR1 e mADSR2 do canal.
}
procedure ChgADSR(channel: Integer);
var
   ar, dr, sl, sr: Byte;
   distance: Integer;
begin
   ar := mix[channel].mADSR1 and $0F;
   dr := (mix[channel].mADSR1 and $70) shr 4;
   sl := (mix[channel].mADSR2 and $E0) shr 5;
   sr := mix[channel].mADSR2 and $1F;

   // Desmarca o modo IDLE, pois o envelope está ativo
   mix[channel].eMode := mix[channel].eMode and $7F;

   case (mix[channel].eMode and $7F) of
      SOUND_ATTACK:
      begin
         if ar = $0F then
         begin
            mix[channel].eVal := D_ATTACK;
            mix[channel].eMode := SOUND_DECAY;
            // Chama recursivamente para configurar o Decay imediatamente
            ChgADSR(channel);
         Exit;
         end
         else
         begin
            mix[channel].eAdj := A_LIN;
            mix[channel].eRate := attackTab[ar];
            mix[channel].eDest := D_ATTACK;

            // --- LÓGICA CORRIGIDA E SEGURA ---
            if mix[channel].eRate > 0 then
            begin
               distance := D_ATTACK - mix[channel].eVal;
               if distance > 0 then
                  // Calcula quantos ciclos de DSP são necessários para o ataque
                  mix[channel].eDec := (distance * dspRate) div mix[channel].eRate
               else
                  mix[channel].eDec := 0; // Já atingiu ou passou, sem duração
            end
            else
               mix[channel].eDec := 0; // Taxa zero, sem duração
         end;
      end;
      SOUND_DECAY:
         begin
            mix[channel].eAdj := 0; // Exponencial
            mix[channel].eRate := rateTab[dr + 16];
            mix[channel].eDest := (sl + 1) * (D_ATTACK + 1) div 8 - 1;
            mix[channel].eDec := Cardinal(-1); // Continua até atingir o destino
         end;
      SOUND_SUSTAIN:
         begin
            mix[channel].eAdj := 0; // Exponencial
            mix[channel].eRate := sustainTab[sr];
            mix[channel].eDest := D_MIN;
            mix[channel].eDec := Cardinal(-1); // Continua indefinidamente
         end;
      SOUND_RELEASE:
         begin
            mix[channel].eAdj := 0; // Exponencial
            mix[channel].eRate := rateTab[0]; // Taxa de release mais rápida
            mix[channel].eDest := D_MIN;
            mix[channel].eDec := Cardinal(-1); // Continua até atingir o destino (silêncio)
         end;
   end;
end;

{
  ChgGain
  ------------------------------------------------------------------------------
  Configura o estado do envelope para um dos modos GAIN, que são envelopes
  especiais não-ADSR.
}
procedure ChgGain(channel: Integer);
begin
   // Desmarca o modo IDLE
   mix[channel].eMode := mix[channel].eMode and $7F;

   // Verifica o bit 7 do registrador GAIN
   if (mix[channel].mGAIN and $80) <> 0 then // Modo: Direct GAIN
   begin
      mix[channel].eMode := SOUND_GAIN;
      mix[channel].eVal := (mix[channel].mGAIN and $7F) * A_GAIN;
      mix[channel].eDest := mix[channel].eVal;
      mix[channel].eMode := mix[channel].eMode or $80; // Fica IDLE imediatamente
      mix[channel].eDec := 0;
      Exit;
   end;

   // Modo: GAIN com envelope (Increase/Decrease)
   case mix[channel].mGAIN and $60 of
   $00: mix[channel].eMode := SOUND_DECREASE_LINEAR;
   $20: mix[channel].eMode := SOUND_DECREASE_EXPONENTIAL;
   $40: mix[channel].eMode := SOUND_INCREASE_LINEAR;
   $60: mix[channel].eMode := SOUND_INCREASE_BENT_LINE;
   end;

   mix[channel].eRIdx := mix[channel].mGAIN and $1F;
   mix[channel].eRate := rateTab[mix[channel].eRIdx];
   mix[channel].eDec := Cardinal(-1); // Continua até atingir o destino

   // Configura o destino e o ajuste com base no modo
   case mix[channel].eMode of
   SOUND_DECREASE_LINEAR, SOUND_DECREASE_EXPONENTIAL: mix[channel].eDest := D_MIN;
   SOUND_INCREASE_LINEAR, SOUND_INCREASE_BENT_LINE: mix[channel].eDest := D_ATTACK;
   end;

   if mix[channel].eMode = SOUND_INCREASE_BENT_LINE then
   begin
      if mix[channel].eVal < D_BENT then
         mix[channel].eAdj := A_LIN
      else
         mix[channel].eAdj := A_LIN div 4;
   end
   else
      if mix[channel].eMode = SOUND_INCREASE_LINEAR then
         mix[channel].eAdj := A_LIN
      else
         mix[channel].eAdj := 0; // Exponencial para os modos de Decrease
end;

{
  StartEnv
  ------------------------------------------------------------------------------
  Inicia o envelope de um canal, geralmente chamado por RKOn (Key On).
}
procedure StartEnv(channel: Integer);
begin
   // Se o canal estava em Release, reseta o valor do envelope para começar do zero.
   if mix[channel].eMode = SOUND_RELEASE then
      mix[channel].eVal := 0;

   // Só inicia o ataque se o envelope não estiver no máximo.
   if mix[channel].eVal < D_ATTACK then
   begin
      mix[channel].eMode := SOUND_ATTACK;
      mix[channel].eDec := 0;
      mix[channel].eDest := D_ATTACK;
      ChgADSR(channel);
   end;
end;

{
  DSPProcess
  ------------------------------------------------------------------------------
  O motor do DSP. Simula a passagem de 'cycles' de tempo, atualizando o estado
  de cada um dos 8 canais de áudio.
}
procedure DSPProcess(cycles: Cardinal);
var
   i: Integer;
begin
   for i := 0 to 7 do
   begin
      // 1. Processa o envelope (ADSR/GAIN) se não estiver no modo IDLE
      if (mix[i].eMode and $80) = 0 then
      begin
         // Aplica a mudança de envelope baseada na taxa e no tempo (cycles)
         // (A lógica exata de cálculo de 'eDec' e atualização de 'eVal' é complexa,
         // esta é uma implementação funcional representativa)
         case (mix[i].eMode and $7F) of
         SOUND_ATTACK, SOUND_INCREASE_LINEAR, SOUND_INCREASE_BENT_LINE:
            begin
               Inc(mix[i].eVal, mix[i].eRate * cycles);
               if mix[i].eVal >= mix[i].eDest then
               begin
                  mix[i].eVal := mix[i].eDest;
                  mix[i].eMode := mix[i].eMode or $80; // IDLE
               end;
            end;
         SOUND_DECAY, SOUND_SUSTAIN, SOUND_DECREASE_EXPONENTIAL, SOUND_DECREASE_LINEAR:
            begin
               Dec(mix[i].eVal, mix[i].eRate * cycles);
               if mix[i].eVal <= mix[i].eDest then
               begin
                  mix[i].eVal := mix[i].eDest;
                  if mix[i].eMode <> SOUND_SUSTAIN then // Sustain nunca fica IDLE
                     mix[i].eMode := mix[i].eMode or $80; // IDLE
               end;
            end;
         end;
      end;

      // 2. Processa a flag de Key Off
      if (mix[i].mFlg and MFLG_KOFF) <> 0 then
      begin
         mix[i].eMode := SOUND_RELEASE;
         ChgADSR(i);
         mix[i].mFlg := mix[i].mFlg and not MFLG_KOFF;
      end;

      // 3. Processa a flag de reinício de amostra
      if (mix[i].mFlg and MFLG_SSRC) <> 0 then
      begin
         mix[i].bPos := 0;
         mix[i].bLoop := False;
         mix[i].bCurrAddr := DSPGetSrc(i);
         // DecodeBRRBlock(i, mix[i].bCurrAddr); // Será implementado na Parte 4
         mix[i].mFlg := mix[i].mFlg and not MFLG_SSRC;
      end;

      // 4. Avança a posição da amostra se o canal estiver ativo
      if (mix[i].mFlg and MFLG_OFF) = 0 then
      begin
         // TODO: Implementar Pitch Modulation (PMON) aqui, se desejado.
         mix[i].mRate := mix[i].mOrgRate;

         Inc(mix[i].bPos, mix[i].mRate * cycles);

         // Verifica se o buffer de 16 amostras decodificadas terminou
         if (mix[i].bPos shr 16) >= 16 then
         begin
            // A lógica de decodificação do próximo bloco BRR será na Parte 4
            // DecodeBRRBlock(...);
            mix[i].bPos := mix[i].bPos and $FFFF; // Mantém a parte fracionária
         end;
      end;
   end;
end;

// ******************************************************************************
// Seção 4: Decodificação BRR, Mixagem Final e Reset
// ******************************************************************************

{
  DecodeBRRBlock
  ------------------------------------------------------------------------------
  Decodifica um único bloco de 9 bytes do formato de áudio comprimido BRR
  (Bit Rate Reduction) em 16 amostras PCM de 16 bits.
}
procedure DecodeBRRBlock(channel: Integer; block_addr: Cardinal);
var
   header: Byte;
   i: Integer;
   p1, p2, outv, s1, s2: Integer;
   shift, filter: Integer;
   sample1, sample2: Integer;
begin
   // Lê o byte de cabeçalho do bloco BRR
   header := IAPU.RAM[block_addr];
   mix[channel].bCurrAddr := block_addr;

   // Bits 0 e 1 do cabeçalho são flags de fim e loop
   mix[channel].bLoop := (header and 2) <> 0;
   mix[channel].mFlg := mix[channel].mFlg and not MFLG_END;
   if (header and 1) <> 0 then
   begin
      mix[channel].mFlg := mix[channel].mFlg or MFLG_END;
      if mix[channel].bLoop then
         mix[channel].bLoopAddr := DSPGetSrc(channel) + 2; // Endereço de loop de 2 bytes após o início
   end;

   shift := (header shr 4) and $F;
   filter := (header shr 2) and $3;

   // s1 e s2 são as duas amostras anteriores, cruciais para o filtro de previsão
   s1 := mix[channel].bPrev1;
   s2 := mix[channel].bPrev2;

   // Itera sobre os 8 bytes de dados do bloco
   for i := 0 to 7 do
   begin
      p1 := IAPU.RAM[block_addr + 1 + i];

      // --- Decodifica a primeira amostra (nibble alto) ---
      sample1 := (p1 and $F0) shr 4;
      if (sample1 and 8) <> 0 then
         sample1 := sample1 - 16; // Converte para 4-bit com sinal

      // Aplica o shift (escala)
      if shift <= 12 then
         outv := (sample1 shl shift) shr 1
      else // Valores de shift > 12 resultam em 0 ou -1, dependendo do sinal
         outv := (sample1 shr (16 - shift)) - (sample1 shr (15 - shift));

      // Aplica o filtro de previsão (recupera a forma de onda)
      case filter of
      1: outv := outv + s1 + ((-s1) shr 4);
      2: outv := outv + (s1 shl 1) + ((-s1 * 3) shr 5) - s2 + (s2 shr 4);
      3: outv := outv + (s1 shl 1) + ((-s1 * 13) shr 6) - s2 + ((s2 * 3) shr 4);
      end;

      outv := Clamp(outv, -32768, 32767);
      mix[channel].bBuf[i * 2] := outv; // Armazena a amostra decodificada
      s2 := s1;
      s1 := outv; // Atualiza as amostras anteriores

      // --- Decodifica a segunda amostra (nibble baixo) ---
      sample2 := (p1 and $0F);
      if (sample2 and 8) <> 0 then
         sample2 := sample2 - 16;

      if shift <= 12 then
         outv := (sample2 shl shift) shr 1
      else
         outv := (sample2 shr (16 - shift)) - (sample2 shr (15 - shift));

      case filter of
      1: outv := outv + s1 + ((-s1) shr 4);
      2: outv := outv + (s1 shl 1) + ((-s1 * 3) shr 5) - s2 + (s2 shr 4);
      3: outv := outv + (s1 shl 1) + ((-s1 * 13) shr 6) - s2 + ((s2 * 3) shr 4);
      end;

      outv := Clamp(outv, -32768, 32767);
      mix[channel].bBuf[i * 2 + 1] := outv;
      s2 := s1;
      s1 := outv;
   end;

   // Salva as duas últimas amostras para o próximo bloco
   mix[channel].bPrev1 := s1;
   mix[channel].bPrev2 := s2;
end;

{
  InterpolateSample
  ------------------------------------------------------------------------------
  Usa interpolação Gaussiana para calcular a amostra exata na posição de
  ponto fixo, resultando em um som mais suave e com pitch mais preciso.
}
function InterpolateSample(channel: Integer): SmallInt;
var
   pos: Cardinal;
   s1, s2, s3, s4: Integer; // Usar Integer para evitar overflow nos cálculos intermediários
   frac: Integer;
begin
   // Pega a posição inteira (índice 0-15) e a parte fracionária (12 bits)
   pos := (mix[channel].bPos shr 12) and $F;
   frac := mix[channel].bPos and $FFF;

   // Busca as 4 amostras ao redor do ponto de interpolação
   s1 := mix[channel].bBuf[(pos - 2) and $F];
   s2 := mix[channel].bBuf[(pos - 1) and $F];
   s3 := mix[channel].bBuf[pos];
   s4 := mix[channel].bBuf[(pos + 1) and $F];

   // Algoritmo de interpolação Gaussiana
   Result := s3 + (frac * (((s4 - s2) div 2) + (frac * ((((s2 + s1) div 2) - s3) + (((s4 - s1) div 2) - ((s4 - s2) div 2)) * frac div 4096)) div 4096)) div 4096;
end;

{
  DSPStereo
  ------------------------------------------------------------------------------
  Mixa a saída de todos os 8 canais, aplica volumes mestre e o efeito de eco,
  e retorna um par de amostras estéreo.
}
procedure DSPStereo(var l, r: Integer);
var
   i: Integer;
   env: Integer;
   sample: SmallInt;
   echo_l, echo_r: Integer;
begin
   l := 0;
   r := 0;

   for i := 0 to 7 do
   begin
      if (mix[i].mFlg and (MFLG_OFF or MFLG_MUTE)) = 0 then
      begin
         sample := InterpolateSample(i);
         env := (mix[i].eVal shr E_SHIFT);
         sample := (sample * env) shr 7;

         l := l + (sample * mix[i].mVolL);
         r := r + (sample * mix[i].mVolR);
      end;
   end;

   l := (l * mMVolL) shr 7;
   r := (r * mMVolR) shr 7;

   // Processamento de Eco
   if (disEcho and ECHO_ENABLE) = 0 then
   begin
      echo_l := echoBuffer[echoReadPtr];
      echo_r := echoBuffer[echoReadPtr + 1];

      l := l + ((echo_l * mEVolL) shr 7);
      r := r + ((echo_r * mEVolR) shr 7);

      echoBuffer[echoWritePtr] := Clamp(l + ((echo_l * mEFB) shr 7), -32768, 32767);
      echoBuffer[echoWritePtr + 1] := Clamp(r + ((echo_r * mEFB) shr 7), -32768, 32767);
   end;

   Inc(echoReadPtr, 2);
   Inc(echoWritePtr, 2);
   if echoReadPtr >= echoLength then
      echoReadPtr := 0;
   if echoWritePtr >= echoLength then
      echoWritePtr := 0;

   l := Clamp(l, -32768, 32767);
   r := Clamp(r, -32768, 32767);
end;

{
  ResetDSP
  ------------------------------------------------------------------------------
  Reseta todas as variáveis de estado do DSP para seus valores iniciais.
}
procedure ResetDSP;
var
   i: Integer;
begin
   FillChar(mix, SizeOf(mix), 0);
   mMVolL := 0;
   mMVolR := 0;
   mEVolL := 0;
   mEVolR := 0;
   mEFB := 0;
   mDIR := 0;
   mESA := 0;
   mEDL := 0;
   voiceKon := 0;
   disEcho := 0;
   FillChar(echoBuffer, SizeOf(echoBuffer), 0);
   echoWritePtr := 0;
   echoReadPtr := 0;
   echoLength := 0;

   for i := 0 to 7 do
   begin
      mix[i].mFlg := MFLG_OFF;
   end;
end;

procedure APUDSPIn(address: Byte; data: Byte);
var
   reg: Byte;
   voice: Integer;
begin
   reg := address and $7F;
   APU.DSP[reg] := data;
   if Assigned(dspRegs[reg]) then
   begin
      voice := reg and $0F;
      if voice > 7 then voice := voice - 7;
         dspRegs[reg](voice, data);
   end;
end;

end.
