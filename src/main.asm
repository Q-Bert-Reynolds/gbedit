INCLUDE "src/beisbol.inc"

SECTION "Header", ROM0[$100]
Entry:
  nop
  jp Main
  NINTENDO_LOGO
IF DEF(_HOME)
  DB "BEISBOL HOME",0,0,0  ;Cart name - 15bytes
ELSE
  DB "BEISBOL AWAY",0,0,0  ;Cart name - 15bytes
ENDC
  DB 0                     ;$143
  DB 0,0                   ;$144 - Licensee code (not important)
  DB 0                     ;$146 - SGB Support indicator
  DB CART_ROM_MBC5_RAM_BAT ;$147 - Cart type
  DB CART_ROM_2M           ;$148 - ROM Size
  DB CART_RAM_256K         ;$149 - RAM Size
  DB 1                     ;$14a - Destination code
  DB $33                   ;$14b - Old licensee code
  DB 0                     ;$14c - Mask ROM version
  DB 0                     ;$14d - Complement check (important)
  DW 0                     ;$14e - Checksum (not important)

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
  ld hl, _RAM+1;TODO: remove +1, currently skips clearing breakpoint
  ld bc, $2000
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

.seed ;load temp data
  ld a, TEMP_BANK
  call SetBank
  call Seed

.start ;show intro credits, batting animation
  ld a, START_BANK
  call SetBank
  call Start
  
.title ;show title drop, version slide, cycle of players, new game/continue screen
  ld a, TITLE_BANK
  call SetBank
  call Title ;should set a to 0 if new game pressed
  jr nz, .overworld

.newGame
  ld a, NEW_GAME_BANK
  call SetBank
  call NewGame

.overworld; walk around, find a game, repeat
    ld a, OVERWORLD_BANK
    call SetBank
    call Overworld

    ;black out tiles one by one
    PLAY_SONG tessie_data

.startGame
    ld a, PLAY_BALL_BANK
    call SetBank
    call StartGame

    jr .overworld; TODO: if game finished, exit

  xor a
  call SetBank
  jp Main ;restart the game
  nop
  ret