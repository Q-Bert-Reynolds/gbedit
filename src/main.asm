INCLUDE "src/beisbol.inc"

SECTION "Header", ROM0[$100]
Entry:
  nop
  jp Main
  NINTENDO_LOGO
IF DEF(_HOME)
  DB "BEISBOL HOME",0,0,0    ;Cart name - 15bytes
ELSE
  DB "BEISBOL AWAY",0,0,0    ;Cart name - 15bytes
ENDC
  DB CART_COMPATIBLE_DMG_GBC ;$143
  DB 0,0                     ;$144 - Licensee code (not important)
  DB CART_COMPATIBLE_SGB     ;$146 - SGB Support indicator
  DB CART_ROM_MBC5_RAM_BAT   ;$147 - Cart type
  DB CART_ROM_2M             ;$148 - ROM Size
  DB CART_RAM_256K           ;$149 - RAM Size
  DB 1                       ;$14a - Destination code
  DB $33                     ;$14b - Old licensee code
  DB 0                       ;$14c - Mask ROM version
  DB 0                       ;$14d - Complement check (important)
  DW 0                       ;$14e - Checksum (not important)

SECTION "VBlank", ROM0[$0040]
  jp VBLInterrupt
SECTION "LCDC", ROM0[$0048]
  jp LCDInterrupt
SECTION "TimerOverflow", ROM0[$0050]
  reti
SECTION "Serial", ROM0[$0058]
  reti
SECTION "p1thru4", ROM0[$0060]
  reti

SECTION "Main", ROM0[$0150]
Main::
.gbcCheck ;must happen first
  cp a, $11;is this a GBC
  ld a, 0;don't xor here
  jr nz, .setSysInfo
  bit 0, b;is it also a GBA
  jr z, .gbc
.gba
  or a, SYS_INFO_GBA
.gbc
  or a, SYS_INFO_GBC
.setSysInfo
  ld [sys_info], a

.setupGameBoyColor
  ld a, [sys_info]
  and a, SYS_INFO_GBC
  jr z, .setup
  call gbdk_CPUFast; GBC always in fast mode

.setup
  di
  ld sp, $ffff
  DISPLAY_OFF
  CGB_COMPATIBILITY
  DISABLE_LCD_INTERRUPT
  xor a
  ld [rSCX], a
  ld [rSCY], a
  ld [rWX], a
  ld [rWY], a
  
  SETUP_DMA_TRANSFER

.clearRAM
  ld hl, sys_info+1;don't clear breakpoint or sys_info
  ld bc, $2000-(1+sys_info-_RAM)
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
  ld a, IEF_VBLANK
  ld [rIE], a
  ei

.setupSuperGameBoy
  ld a, SGB_BANK
  call SetBank
  call sgb_Init
  SET_DEFAULT_PALETTE

.seed ;load temp data
  ld a, TEMP_BANK
  call SetBank
  call Seed

.loadGame
  call CheckSave
  jr z, .start
  call LoadGame

.start ;show intro credits, batting animation
;   ld a, START_BANK
;   call SetBank
;   call Start

; .title ;show title drop, version slide, cycle of players, new game/continue screen
;   ld a, TITLE_BANK
;   call SetBank
;   call Title ;sets a to 0 if new game pressed
;   jr nz, .startClock

; .newGame
;   ld a, NEW_GAME_BANK
;   call SetBank
;   call NewGame

.startClock
  ld a, GAME_STATE_CLOCK_STARTED
  ld [game_state], a

.overworld; walk around, find a game, repeat
    ld a, [game_state]
    and a, ~GAME_STATE_PLAY_BALL
    ld [game_state], a
    ld a, OVERWORLD_BANK
    call SetBank
    call Overworld

    ;TODO: black out tiles one by one
    PLAY_SONG tessie_data, 1

.startGame
    ld a, [game_state]
    or a, GAME_STATE_PLAY_BALL
    ld [game_state], a
    ld a, PLAY_BALL_BANK
    call SetBank
    call StartGame

    jr .overworld; TODO: if game finished, exit

  xor a
  call SetBank
  jp Main ;restart the game
  nop
  ret