INCLUDE "src/gb.inc"

SECTION "Header", ROM0[$100]
Entry:
  nop
  jp Main
  NINTENDO_LOGO
  DB "TEXT EDITOR",0,0,0,0   ;Cart name - 15bytes
  DB CART_COMPATIBLE_DMG_GBC ;$143
  DB 0,0                     ;$144 - Licensee code (not important)
  DB CART_INDICATOR_SGB      ;$146 - SGB Support indicator
  DB CART_ROM_MBC5_RAM_BAT   ;$147 - Cart type
  DB CART_ROM_1024KB         ;$148 - ROM Size 
  DB CART_SRAM_32KB          ;$149 - RAM Size
  DB 1                       ;$14a - Destination code
  DB $33                     ;$14b - Old licensee code
  DB 0                       ;$14c - Mask ROM version
  DB 0                       ;$14d - Complement check (important)
  DW 0                       ;$14e - Checksum (not important)

SECTION "VBlank", ROM0[$0040]
  jp VBLInterrupt
SECTION "LCDC", ROM0[$0048]
  ; jp LCDInterrupt
  jp HighlightInterrupt
SECTION "TimerOverflow", ROM0[$0050]
  reti
SECTION "Serial", ROM0[$0058]
  jp SerialInterrupt
SECTION "p1thru4", ROM0[$0060]
  reti

SECTION "Main", ROM0[$0150]
Main::
.gbcCheck ;must happen first
  cp a, BOOTUP_A_MGB;is this a Pocket
  jr z, .gbp
  ; NOTE: Never actually checking for DMG. 
  ;       Assumes DMG if other tests fail. 
  ;       Used to check emulators.
  ;       https://github.com/ISSOtm/Aevilia-GB/blob/master/home.asm
  ; cp a, BOOTUP_A_DMG
  ; jr z, .dmg
  cp a, BOOTUP_A_CGB;is this a GBC
  ld a, 0;don't xor here
  jr nz, .setSysInfo
  bit 0, b;is it also a GBA
  jr z, .gbc
.gba;BOOTUP_B_AGB
  or a, SYS_INFO_GBA
.gbc;BOOTUP_B_CGB
  or a, SYS_INFO_GBC
  jr .setSysInfo
.gbp
  ld a, SYS_INFO_GBP
.setSysInfo
  ld [sys_info], a

.setupGameBoyColor
  ld a, [sys_info]
  and a, SYS_INFO_GBC
  jr z, .setup
  call gbdk_CPUFast; GBC always in fast mode
  CGB_COMPATIBILITY

.setup
  di
  ld sp, $ffff
  DISPLAY_OFF
  DISABLE_LCD_INTERRUPT
  xor a
  ld [rSCX], a
  ld [rSCY], a
  ld [rWX], a
  ld [rWY], a
  
  SETUP_DMA_TRANSFER

.clearRAM;don't clear breakpoint or sys_info
  ld hl, _RAM
  ld bc, _breakpoint-_RAM
  xor a
  call mem_Set
  ld hl, sys_info+1
  ld bc, (_RAM+$2000)-sys_info
  xor a
  call mem_Set

.setupAudio
  ld hl, rAUDENA
  ld [hl], AUDENA_OFF
  ld a, $FF
  ld [rAUDTERM], a
  ld [rAUDVOL], a
  
.setupDrawing
  CLEAR_SCREEN 0
  SET_DEFAULT_PALETTE

  ld a, LCDCF_OFF | LCDCF_WIN9C00 | LCDCF_BG8800 | LCDCF_OBJ8 | LCDCF_OBJON | LCDCF_BGON
  ld [rLCDC], a

.setupInterrupts
  ld a, IEF_VBLANK | IEF_SERIAL
  ld [rIE], a
  ei

.setupSuperGameBoy
  ld a, SGB_BANK
  call SetBank
  call sgb_Init
  SET_DEFAULT_PALETTE
  
.startClock
  ld a, GAME_STATE_CLOCK_STARTED
  ld [game_state], a

.mainLoop
    call KeyboardDemo
    ; ld a, EDITOR_BANK
    ; call SetBank
    ; call OpenEditor
    jr .mainLoop; TODO: if game finished, exit

  xor a
  call SetBank
  jp Main ;restart the game
  nop
  ret