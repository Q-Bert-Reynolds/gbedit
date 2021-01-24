TESTS_ENABLED EQU 1  
INTRO_ENABLED EQU 1
TITLE_ENABLED EQU 1
WORLD_ENABLED EQU 1
PLAY_ENABLED  EQU 1

INCLUDE "src/beisbol.inc"

RUN_TESTS: MACRO
  ld a, OVERWORLD_BANK
  call SetBank
  call TestMap

;   call LoadFontTiles

; POWER = 50
; REPT 2

; LAUNCH = 30
; REPT 3

; SPRAY = -45
; REPT 18

;   ld a, SIM_BANK
;   call SetBank
;   TEST_SIM POWER, SPRAY, LAUNCH

;   ; ld a, ANNOUNCER_BANK
;   ; call SetBank
;   ; TEST_ANNOUNCER SPRAY

; SPRAY = SPRAY+5
; ENDR;SPRAY loop

; LAUNCH = LAUNCH+30
; ENDR;LAUNCH loop

; POWER = POWER+40
; ENDR;POWER loop

ENDM

TEST_SIM: MACRO ;\1 = speed, \2 = deg left/right, \3 = deg up/down
  ld a, \1
  ld b, \2
  ld c, \3
  call RunSimulation;a = exit velocity b = spray angle c = launch angle
ENDM

TEST_ANNOUNCER: MACRO ;\1 = angle left or right
  ld hl, str_buffer
  xor a
  ld [hl], a
  ld b, \1
  call AppendOutfieldLocationTextByAngle
  ld hl, str_buffer
  call RevealTextAndWait
ENDM

SECTION "Header", ROM0[$100]
Entry:
  nop
  jp Main
  NINTENDO_LOGO
IF DEF(_HOME)
  DB "BEISBOL HOME",0,0,0    ;Cart name - 15bytes
ELIF DEF(_AWAY)
  DB "BEISBOL AWAY",0,0,0    ;Cart name - 15bytes
ELSE
  DB "BEISBOL DEMO",0,0,0    ;Cart name - 15bytes
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
  call LoadOptions
  call CheckSave
  jp z, .start
  call LoadGame

IF TESTS_ENABLED == 1
  RUN_TESTS
ENDC

.start ;show intro credits, batting animation
IF INTRO_ENABLED == 1
  ld a, START_BANK
  call SetBank
  call Start
ENDC

IF TITLE_ENABLED == 1
.title ;show title drop, version slide, cycle of players, new game/continue screen
  ld a, TITLE_BANK
  call SetBank
  call Title ;sets a to 0 if new game pressed
  jr nz, .startClock

.newGame
  ld a, NEW_GAME_BANK
  call SetBank
  call NewGame
  ld a, TEMP_BANK
  call SetBank
  call Seed
ENDC

.startClock
  ld a, GAME_STATE_CLOCK_STARTED
  ld [game_state], a

.mainLoop
IF WORLD_ENABLED == 1
  .overworld; walk around, find a game, repeat
    ld a, [game_state]
    and a, ~GAME_STATE_PLAY_BALL
    ld [game_state], a
    ld a, OVERWORLD_BANK
    call SetBank
    call Overworld
ENDC

IF PLAY_ENABLED == 1
  .baseball
    ld a, [game_state]
    or a, GAME_STATE_PLAY_BALL
    ld [game_state], a
    ld a, PLAY_BALL_BANK
    call SetBank
    call StartGame
ENDC
    jr .mainLoop; TODO: if game finished, exit

  xor a
  call SetBank
  jp Main ;restart the game
  nop
  ret