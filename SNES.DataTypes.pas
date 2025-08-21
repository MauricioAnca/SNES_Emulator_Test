unit SNES.DataTypes;

interface

uses
   System.SysUtils, System.Types;

// Constantes globais do emulador, traduzidas de vários arquivos .h

const
   // de chisnes.h
   ROM_NAME_LEN = 23;
   SAFE_ROM_NAME_LEN = (ROM_NAME_LEN * 3) + 1;
   ROM_ID_LEN = 5;
   SAFE_ROM_ID_LEN = ((ROM_ID_LEN - 1) * 3) + 1;

   SNES_WIDTH = 256;
   SNES_HEIGHT = 224;
   SNES_HEIGHT_EXTENDED = 239;
   MAX_SNES_WIDTH = SNES_WIDTH * 2;
   MAX_SNES_HEIGHT = SNES_HEIGHT_EXTENDED * 2;

   SNES_MAX_HCOUNTER = 341; // 0-340

   FIRST_VISIBLE_LINE = 1;

   // Constantes da Lógica de Clipping (de ppu.h)
   CLIP_OR = 0;
   CLIP_AND = 1;
   CLIP_XOR = 2;
   CLIP_XNOR = 3;

   MAP_CPU = 0;
   MAP_PPU = 1;
   MAP_LOROM_SRAM = 2;
   MAP_HIROM_SRAM = 3;
   MAP_DSP = 4;
   MAP_SA1RAM = 5;
   MAP_BWRAM = 6;
   MAP_BWRAM_BITMAP = 7;
   MAP_BWRAM_BITMAP2 = 8;
   MAP_SPC7110_ROM = 9;
   MAP_SPC7110_DRAM = 10;
   MAP_RONLY_SRAM = 11;
   MAP_CX4 = 12;
   MAP_OBC_RAM = 13;
   MAP_SETA_DSP = 14;
   MAP_BSX = 15;
   MAP_XBAND = 16;
   MAP_NONE = 17;
   MAP_LAST = 18;

   NMI_FLAG = (1 shl 0);
   IRQ_FLAG = (1 shl 1);
   SCAN_KEYS_FLAG = (1 shl 2);

   HBLANK_START_EVENT = 0;
   HBLANK_END_EVENT = 1;
   HTIMER_BEFORE_EVENT = 2;
   HTIMER_AFTER_EVENT = 3;
   NO_EVENT = 4;

   // de memmap.h
   MEMMAP_BLOCK_SIZE = $1000;
   MEMMAP_NUM_BLOCKS = $1000000 div MEMMAP_BLOCK_SIZE;
   MEMMAP_SHIFT = 12;
   MEMMAP_MASK = MEMMAP_BLOCK_SIZE - 1;
   MAX_ROM_SIZE = $C00000;

   // de soundux.h
   SNES_SAMPLE_RATE = 32000;
   NUM_CHANNELS = 8;
   FIRBUF = 16;
   ECHOBUF = 24576; // Valor calculado para 48kHz, ajustável

   // Constantes de IRQ e PPU adicionadas aqui (de ppu.h) ***
   PPU_H_BEAM_IRQ_SOURCE = (1 shl 0);
   PPU_V_BEAM_IRQ_SOURCE = (1 shl 1);
   GSU_IRQ_SOURCE        = (1 shl 2);
   SA1_DMA_IRQ_SOURCE    = (1 shl 3);
   SA1_IRQ_SOURCE        = (1 shl 4);

   // de ppu.h
   TILE_2BIT = 0;
   TILE_4BIT = 1;
   TILE_8BIT = 2;

   MAX_2BIT_TILES = 4096;
   MAX_4BIT_TILES = 2048;
   MAX_8BIT_TILES = 1024;

   // de ppu.h
   SignExtend: array[0..1] of Word = ($0000, $FF00);

   // Traduzido do enum em chisnes.h
   CHIP_NOCHIP     = 0;

   CHIP_V0         = 0;
   CHIP_V1         = 1;
   CHIP_V2         = 2;
   CHIP_V3         = 3;

   CHIP_DSP        = 1 shl 2;
   CHIP_GSU_SETA   = 1 shl 3;
   CHIP_PERIPHERAL = 1 shl 4;
   CHIP_OPTRTC     = 1 shl 5;
   CHIP_OTHERCHIP  = 1 shl 6;
   CHIP_RESERVED   = 1 shl 7;

   CHIP_DSP_1      = CHIP_DSP or CHIP_V0;
   CHIP_DSP_2      = CHIP_DSP or CHIP_V1;
   CHIP_DSP_3      = CHIP_DSP or CHIP_V2;
   CHIP_DSP_4      = CHIP_DSP or CHIP_V3;

   CHIP_GSU        = CHIP_GSU_SETA or CHIP_V0;
   CHIP_ST_010     = CHIP_GSU_SETA or CHIP_V1;
   CHIP_ST_011     = CHIP_GSU_SETA or CHIP_V2;
   CHIP_ST_018     = CHIP_GSU_SETA or CHIP_V3;

   CHIP_SFT        = CHIP_PERIPHERAL or CHIP_V0;
   CHIP_XBAND      = CHIP_PERIPHERAL or CHIP_V1;
   CHIP_BS         = CHIP_PERIPHERAL or CHIP_V2;
   CHIP_BSFW       = CHIP_PERIPHERAL or CHIP_V3;

   CHIP_S_RTC      = CHIP_OPTRTC or CHIP_V1;
   CHIP_SPC7110    = CHIP_OPTRTC or CHIP_V2;
   CHIP_SPC7110RTC = CHIP_OPTRTC or CHIP_V3;

   CHIP_SA_1       = CHIP_OTHERCHIP or CHIP_V0;
   CHIP_CX_4       = CHIP_OTHERCHIP or CHIP_V1;
   CHIP_S_DD1      = CHIP_OTHERCHIP or CHIP_V2;
   CHIP_OBC_1      = CHIP_OTHERCHIP or CHIP_V3;

   CHIP_NUMCHIPS   = $ff;

type
   // de 65c816.h - Estruturas básicas da CPU
   TPair = record
   case Integer of
      0: (W: Word);
      1: (L, H: Byte);
   end;

   TPC_t = record
   case Integer of
      0: (xPBPC: Cardinal);
      1: (PC: TPair; PB, Z: Byte);
   end;

   TRegisters = packed record
      DB: Byte;
      _pad1: Byte;
      A: TPair;
      D: TPair;
      P: TPair;
      S: TPair;
      X: TPair;
      Y: TPair;
      PCw: TPC_t;
   end;

   // Flags da CPU 65c816
   TCPUFlag = (cfCarry, cfZero, cfIRQ, cfDecimal, cfIndexFlag, cfMemoryFlag, cfOverflow, cfNegative, cfEmulation);
   TCPUFlags = set of TCPUFlag;

   // Ponteiro para uma função de Opcode (procedural type)
   TOpcodeFunc = procedure;

   TSOpcode = record
      Opcode: TOpcodeFunc;
   end;

   TOpcodeTable = array[0..255] of TSOpcode;
   POpcodeTable = ^TOpcodeTable;

   // de cpuexec.h
   TSICPU = record
      Carry: Boolean;
      Overflow: Boolean;
      Zero: Boolean;
      Negative: Byte;
      OpenBus: Byte;
      ShiftedDB: Cardinal;
      ShiftedPB: Cardinal;
      Registers: TRegisters;
      OpLengths: PByte;
      Opcodes: POpcodeTable;
   end;

   // de chisnes.h
   TSCPUState = packed record
      // Bitfields convertidos para Boolean. O `packed record` ajuda a economizar espaço.
      // O tamanho total e o layout devem ser verificados para compatibilidade de save state.
      BranchSkip: Boolean;
      InDMA: Boolean;
      NMIActive: Boolean;
      SRAMModified: Boolean;
      WaitingForInterrupt: Boolean;
      _pad_bits: array[0..1] of Byte; // Para alinhamento e compatibilidade de tamanho
      IRQActive: Byte;
      WhichEvent: Byte;
      PCAtOpcodeStart: Word;
      WaitPC: Word;
      Cycles: Integer;
      FastROMSpeed: Integer;
      MemSpeed: Integer;
      MemSpeedx2: Integer;
      NextEvent: Integer;
      V_Counter: Integer;
      Flags: Cardinal;
      IRQCycleCount: Cardinal;
      NMICycleCount: Cardinal;
      NMITriggerPoint: Cardinal;
      WaitCounter: Cardinal;
      PCBase: PByte;
   end;

   TSettings = packed record
      APUEnabled: Boolean;
      PAL: Boolean;
      ReduceSpriteFlicker: Boolean;
      Shutdown: Boolean;
      SecretOfEvermoreHack: Boolean;
      GetSetDMATimingHacks: Boolean;
      LoadBSXBIOS: Boolean;
      _pad1: Byte;
      OneCycle: Byte;
      SlowOneCycle: Byte;
      TwoCycles: Byte;
      ControllerOption: Byte;
      Chip: Byte;
      SuperFXSpeedPerLine: Word;
      H_Max: Integer;
      HBlankStart: Integer;
   end;

   TSEXTState = record
      NextAPUTimerPos: Integer;
      APUTimerCounter: Integer;
      APUTimerCounter_err: Cardinal;
      t64Cnt: Cardinal;
   end;

   // de ppu.h
   TClipData = record
      Count: array[0..5] of Cardinal;
      Left: array[0..5] of array[0..5] of Cardinal;
      Right: array[0..5] of array[0..5] of Cardinal;
   end;

   TInternalPPU = packed record
      ColorsChanged: Boolean;
      DirectColourMapsNeedRebuild: Boolean;
      DoubleWidthPixels: Boolean;
      DoubleHeightPixels: Boolean;
      FirstVRAMRead: Boolean;
      HalfWidthPixels: Boolean;
      Interlace: Boolean;
      OBJChanged: Boolean;
      RenderThisFrame: Boolean;
      _pad1: array[0..2] of Byte; // Alinhamento
      HDMA: Byte;
      ScreenColors: array[0..255] of Word;
      Controller: Integer;
      CurrentLine: Integer;
      PreviousLine: Integer;
      RenderedScreenWidth: Integer;
      RenderedScreenHeight: Integer;
      PrevMouseX, PrevMouseY: array[0..1] of Integer;
      FrameCount: Cardinal;
      SuperScope: Cardinal;
      Joypads: array[0..4] of Cardinal;
      Mouse: array[0..1] of Cardinal;
      Red, Green, Blue: array[0..255] of Cardinal;
      XB: PByte;
      TileCache: array[0..2] of PByte;
      TileCached: array[0..2] of PByte;
      Clip: array[0..1] of TClipData;
   end;

   TSOBJ = packed record
      HPos: SmallInt;
      VPos: Word;
      Name: Word;
      VFlip: Byte;
      HFlip: Byte;
      Priority: Byte;
      Palette: Byte;
      Size: Byte;
   end;

   TSDMA = packed record
      ReverseTransfer: Boolean;
      HDMAIndirectAddressing: Boolean;
      AAddressFixed: Boolean;
      AAddressDecrement: Boolean;
      FirstLine: Boolean;
      Repeat_: Boolean;
      _pad1: array[0..1] of Byte; // Alinhamento
      ABank: Byte;
      BAddress: Byte;
      IndirectBank: Byte;
      LineCount: Byte;
      TransferMode: Byte;
      Address: Word;
      AAddress: Word;
      IndirectAddress: Word;
      TransferBytes: Word;
   end;

   TSppuBG = record
      SCBase: Word;
      SCSize: Word;
      NameBase: Word;
      HOffset: Word;
      VOffset: Word;
      BGSize: Byte;
      _pad: Byte;
   end;

   TSppuVMA = record
      High: Boolean;
      Increment: Byte;
      Address: Word;
      FullGraphicCount: Word;
      Mask1: Word;
      Shift: Word;
   end;

   TSppu = packed record
      BGMode: Byte;
      BG3Priority: Byte;
      Brightness: Byte;
      OAMAddr: Word;
      OAMReadFlip: Boolean;
      OAMWriteRegister: Word;
      FirstSprite: Byte;
      OAMFlip: Byte;
      OAMPriorityRotation: Byte;
      SavedOAMAddr: Word;
      VMA: TSppuVMA;
      BG: array[0..3] of TSppuBG;
      CGFLIP: Boolean;
      CGFLIPRead: Boolean;
      CGADD: Byte;
      CGSavedByte: Byte;
      BGnxOFSbyte: Byte;
      FixedColourRed, FixedColourGreen, FixedColourBlue: Byte;
      ScreenHeight: Word;
      ForcedBlanking: Boolean;
      OBJNameBase: Word;
      OBJNameSelect: Word;
      OBJSizeSelect: Byte;
      MatrixA, MatrixB, MatrixC, MatrixD: SmallInt;
      CentreX, CentreY: SmallInt;
      HTimerPosition: SmallInt;
      Need16x8Multiply: Boolean;
      Mosaic: Byte;
      BGMosaic: array[0..3] of Boolean;
      Mode7HFlip, Mode7VFlip: Boolean;
      Mode7Repeat: Byte;
      Window1Left, Window1Right, Window2Left, Window2Right: Byte;
      ClipWindow1Enable, ClipWindow2Enable: array[0..5] of Boolean;
      ClipWindow1Inside, ClipWindow2Inside: array[0..5] of Boolean;
      ClipWindowOverlapLogic: array[0..5] of Byte;
      RecomputeClipWindows: Boolean;
      OpenBus1, OpenBus2: Byte;
      VTimerEnabled, HTimerEnabled: Boolean;

      Joypad1ButtonReadPos: Byte;
      Joypad2ButtonReadPos: Byte;
      Joypad3ButtonReadPos: Byte;

      IRQVBeamPos, IRQHBeamPos: Word;
      VBeamPosLatched, HBeamPosLatched: Word;
      HBeamFlip, VBeamFlip: Byte;
      RangeTimeOver: Byte;
      WRAM: Cardinal;
      CGDATA: array[0..255] of Word;
      OBJ: array[0..127] of TSOBJ;
      OAMData: array[0..543] of Byte; // 512 + 32
   end;

   // de spc700.h e apu.h
   TYAndA = record
   case Integer of
      0: (W: Word);
      1: (A, Y: Byte);
   end;

   TSAPURegisters = packed record
      P: Byte;
      YA: TYAndA;
      X: Byte;
      S: Byte;
      PC: Word;
   end;

   TSIAPU = packed record
      Executing: Boolean;
      Carry: Boolean;
      Overflow: Boolean;
      _pad1: array[0..2] of Byte;
      Bit: Byte;
      Zero: Byte;
      OneCycle: Integer;
      Address: Cardinal;
      WaitCounter: Cardinal;
      DirectPage: PByte;
      PC: PByte;
      RAM: PByte;
      WaitAddress1: PByte;
      WaitAddress2: PByte;
      Registers: TSAPURegisters;
   end;

   TSAPU = packed record
      ShowROM: Boolean;
      TimerEnabled: array[0..2] of Boolean;
      KeyedChannels: Byte;
      OutPorts: array[0..3] of Byte;
      DSP: array[0..$7F] of Byte;
      ExtraRAM: array[0..63] of Byte;
      Timer: array[0..2] of Word;
      TimerTarget: array[0..2] of Word;
      Cycles: Integer;
   end;

   // de gfx.h
   TSGFX = record
      Pseudo: Boolean;
      _pad1: Word;
      Z1, Z2: Byte;
      OBJVisibleTiles: array[0..127] of Byte;
      OBJWidths: array[0..127] of Byte;
      r212c, r212d, r2130, r2131: Byte;
      Delta: Integer;
      FixedColour: Cardinal;
      Mode7Mask: Cardinal;
      Mode7PriorityMask: Cardinal;
      PixSize: Cardinal;
      PPL: Cardinal;
      PPLx2: Cardinal;
      StartY, EndY: Cardinal;
      Pitch: Cardinal;
      RealPitch: Cardinal;
      ZPitch: Cardinal;
      DepthDelta: NativeInt;
      DB: PByte;
      S: PByte;
      Screen: PByte;
      SubScreen: PByte;
      ZBuffer: PByte;
      SubZBuffer: PByte;
      Zero: PWord;
      pCurrentClip: ^TClipData;
      // OBJLines não será portado diretamente aqui, pois é uma estrutura complexa que pode ser melhor gerenciada por uma classe ou array dinâmico.
   end;

   TSLineData = record
      BG: array[0..3] of record
         HOffset: Word;
         VOffset: Word;
      end;
   end;

   TSLineMatrixData = record
      MatrixA, MatrixB, MatrixC, MatrixD: SmallInt;
      CentreX, CentreY: SmallInt;
   end;

   TSBG = record
      DirectColourMode: Boolean;
      BitShift: Cardinal;
      Buffer: PByte;
      Buffered: PByte;
      NameSelect: Cardinal;
      PaletteMask: Cardinal;
      PaletteShift: Cardinal;
      SCBase: Cardinal;
      StartPalette: Cardinal;
      TileAddress: Cardinal;
      TileSize: Cardinal;
      TileShift: Cardinal;
   end;

   // de soundux.h
   TChannel = packed record
      next_sample: SmallInt;
      decoded: array[0..15] of SmallInt;
      envx: Integer;
      mode: Integer;
      state: Integer;
      type_: Integer; // `type` é uma palavra reservada
      count: Cardinal;
      block_pointer: Cardinal;
      sample_pointer: Cardinal;
      block: ^SmallInt;
   end;

   TSSoundData = record
      echo_buffer_size: Integer;
      echo_enable: Integer;
      echo_feedback: Integer;
      echo_ptr: Integer;
      echo_write_enabled: Integer;
      pitch_mod: Integer;
      channels: array[0..NUM_CHANNELS - 1] of TChannel;
   end;

   // A estrutura TMemory é a maior e mais importante
   TMemory = record
      // Ponteiros e Arrays
      Map, WriteMap: array[0..MEMMAP_NUM_BLOCKS - 1] of Pointer;
      BlockIsRAM, BlockIsROM: array[0..MEMMAP_NUM_BLOCKS - 1] of Byte; // Corrigido para Byte
      RAM: array[0..$20000 - 1] of Byte;
      SRAM: array[0..$20000 - 1] of Byte;
      VRAM: array[0..$10000 - 1] of Byte;

      // FillRAM é um grande buffer que contém a ROM e outras memórias.
      // É declarado como um array estático para espelhar a alocação do C.
      FillRAM: array[0..MAX_ROM_SIZE + $200 + $8000 - 1] of Byte;
      _FillRAM_ptr: PByte; // Ponteiro para uso interno, se necessário

      // Ponteiros para áreas dentro de FillRAM (configurados em InitMemory)
      ROM, OBC1RAM, BIOSROM, PSRAM, CX4RAM: PByte;

      // Informações da ROM
      LoROM: Boolean;
      ROMName: array[0..SAFE_ROM_NAME_LEN - 1] of AnsiChar;
      ROMId: array[0..SAFE_ROM_ID_LEN - 1] of AnsiChar;
      SRAMSize, ROMRegion, ROMSize, ROMSpeed, ROMType: Byte;
      CompanyId: Word;
      HeaderCount: Integer;
      CalculatedSize: Cardinal;
      SRAMMask: Cardinal;
      ExtendedFormat: Byte;
      BWRAM: PByte;
   end;

   // de dsp.h
   TSDSP1 = packed record
      waiting4command: Boolean;
      first_parameter: Boolean;
      command: Byte;
      parameters: array[0..511] of Byte;
      output: array[0..511] of Byte;
      // ... muitos outros campos...
   end;
  // Outras TSDSPx seriam definidas de forma similar.

  // de sa1.h
   TSSA1Registers = packed record
      DB: Byte;
      _pad: Byte;
      A: TPair;
      D: TPair;
      P: TPair;
      S: TPair;
      X: TPair;
      Y: TPair;
      PC: TPC_t;
   end;

   TSSA1 = record
      in_char_dma: Byte; // e outros bitfields combinados
      variable_bit_pos: Byte;
      Carry: Boolean;
      CumulativeOverflow: Boolean;
      Executing: Boolean;
      Overflow: Boolean;
      Waiting: Boolean;
      WaitingForInterrupt: Boolean;
      Zero: Boolean;
      arithmetic_op: Byte;
      UseVirtualBitmapFormat2: Boolean;
      NMIActive: Boolean;
      Negative: Byte;
      IRQActive: Byte;
      OpenBus: Byte;
      op1, op2: SmallInt;
      PCAtOpcodeStart: Word;
      WaitPC: Word;
      Flags: Cardinal;
      ShiftedPB: Cardinal;
      ShiftedDB: Cardinal;
      WaitCounter: Cardinal;
      sum: Int64;
      Registers: TSSA1Registers;
      // Ponteiros não são serializados e serão inicializados em tempo de execução
      BWRAM: PByte;
      PCBase: PByte;
      WaitByteAddress1: PByte;
      WaitByteAddress2: PByte;
      OpLengths: PByte;
      Opcodes: POpcodeTable;
      Map, WriteMap: array[0..MEMMAP_NUM_BLOCKS-1] of Pointer;
   end;

   // de bsx.h
   TStream_t = packed record
      first: Boolean;
      pf_latch_enable: Boolean;
      dt_latch_enable: Boolean;
      _pad1: Byte;
      count: Byte;
      queue: Word;
      _file: Pointer; // Em C é RFILE*, aqui será um ponteiro genérico ou um objeto TStream
   end;

   TSBSX = packed record
      dirty: Boolean;
      dirty2: Boolean;
      write_enable: Boolean;
      read_enable: Boolean;
      flash_csr: Boolean;
      flash_gsr: Boolean;
      flash_bsr: Boolean;
      flash_mode: Boolean;
      out_index: Byte;
      MMC: array[0..15] of Byte;
      prevMMC: array[0..15] of Byte;
      PPU: array[0..31] of Byte;
      flash_command: Cardinal;
      old_write: Cardinal;
      new_write: Cardinal;
      sat_stream1: TStream_t;
      sat_stream2: TStream_t;
   end;

   // E assim por diante para todas as outras estruturas...
   // SRTC, OBC1, FX, etc.
   TSRTCData = record
      reg: array[0..19] of Byte;
   end;

   TSOBC1 = record
      address: Word;
      basePtr: Word;
      shift: Word;
   end;


implementation

end.