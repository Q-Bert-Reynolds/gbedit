INCLUDE "src/beisbol.inc"
INCLUDE "src/roledex.asm"
INCLUDE "src/core.asm"
INCLUDE "src/ui.asm"
INCLUDE "src/start.asm"
INCLUDE "src/title.asm"
INCLUDE "src/new_game.asm"
INCLUDE "src/play_ball.asm"

INCLUDE "src/wram.asm"
INCLUDE "src/sram.asm"

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
  reti
SECTION "LCDC", ROM0[$0048]
  jp LCDInterrupt
SECTION "TimerOverflow", ROM0[$0050]
  reti
SECTION "Serial", ROM0[$0058]
  reti
SECTION "p1thru4", ROM0[$0060]
  reti

SECTION "Main", ROM0
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
  
.setupAudio
  ld hl, rAUDENA
  ld [hl], AUDENA_ON
  xor a
  ld [rAUDTERM], a
  ld hl, rAUDVOL
  ld [hl], $FF
  
.setupDrawing
  CLEAR_SCREEN 0
  ld hl, rBGP
  ld [hl], BG_PALETTE
  ld hl, rOBP0
  ld [hl], SPR_PALETTE_0
  ld hl, rOBP1
  ld [hl], SPR_PALETTE_1

  ld a, LCDCF_OFF | LCDCF_WIN9C00 | LCDCF_BG8800 | LCDCF_OBJ8 | LCDCF_OBJON | LCDCF_BGON
  ld [rLCDC], a
  
.start ;show intro credits, batting animation
  SET_BANK START_BANK
  call Start
.title ;show title drop, version slide, cycle of players, new game/continue screen
  SET_BANK TITLE_BANK
  call Title ;should set a to 0 if new game pressed
  jr nz, .startGame
.newGame
  SET_BANK NEW_GAME_BANK
  call NewGame
.startGame
  SET_BANK PLAY_BALL_BANK
  call StartGame
  SET_BANK 0
  jp Main ;restart the game
  nop
  ret