INCLUDE "src/beisbol.inc"
INCLUDE "src/start.asm"
INCLUDE "src/title.asm"

SECTION "Gloval Vars", WRAM0
rLCDInterrupt: DW
last_button_state: DB
button_state: DB
_a: DB
_b: DB
_c: DB
_d: DB
_i: DB
_j: DB
_k: DB
_x: DW
_y: DW
_z: DW
tmp: DB
tile_buffer: DS 512

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
  call LCDInterrupt
SECTION "TimerOverflow", ROM0[$0050]
  reti
SECTION "Serial", ROM0[$0058]
  reti
SECTION "p1thru4", ROM0[$0060]
  reti

SECTION "Main", ROM0
Main::
  ld sp, $ffff
  DISPLAY_OFF

  di
  CGB_COMPATIBILITY
  call gbdk_CPUFast
  ei

  SET_LCD_INTERRUPT NoInterrupt

  ; audio  
  ld hl, rAUDENA
  ld [hl], AUDENA_ON
  xor a
  ld [rAUDTERM], a
  ld hl, rAUDVOL
  ld [hl], $FF
  
  ; drawing
  SPRITES_8x8
  ld hl, rBGP
  ld [hl], BG_PALETTE
  ld hl, rOBP0
  ld [hl], SPR_PALETTE_0
  ld hl, rOBP1
  ld [hl], SPR_PALETTE_1
  
  SHOW_SPRITES
  SHOW_BKG
  
  SWITCH_RAM_MBC5 0
  SWITCH_ROM_MBC5 START_BANK
  call Start

  SWITCH_ROM_MBC5 TITLE_BANK
  call Title
  ; if (!title()) {
  ;     SWITCH_ROM_MBC5 NEW_GAME_BANK
  ;     new_game();
  ; }

  ; SWITCH_ROM_MBC5 PLAY_BALL_BANK
  ; start_game();

  SWITCH_ROM_MBC5 0
End::
  call gbdk_WaitVBLDone
  jr End

UpdateInput::
  ;copy button_state to last_button_state
  ld hl, button_state
  ld a, [hl]
  ld hl, last_button_state
  ld [hl], a

  ;read DPad
  ld hl, rP1
  ld a, P1F_5
  ld [hl], a ;switch to P15
  ld a, [hl] ;load DPad
  and %00001111 ;discard upper nibble
  swap a ;move low nibble to high nibble
  ld b, a ;store DPad in b

  ;read A,B,Select,Start
  ld hl, rP1
  ld a, P1F_4
  ld [hl], a ;switch to P14
  ld a, [hl] ;load buttons
  and %00001111 ;discard upper nibble
  or b ;combine DPad with other buttons
  cpl ;flip bits so 1 means pressed
  ld hl, button_state
  ld [hl], a
  ret

LCDInterrupt::
  ld hl, rLCDInterrupt
  ld a, [hli]
  ld b, a
  ld a, [hl]
  ld h, b
  ld l, a
  jp hl
NoInterrupt::
  reti