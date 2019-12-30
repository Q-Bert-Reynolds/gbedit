IF !DEF(BEISBOL_INC)
BEISBOL_INC SET 1

INCLUDE "src/hardware.inc"
INCLUDE "src/memory1.asm"
INCLUDE "src/gbdk.asm"

; banks
UI_BANK         EQU 2
START_BANK      EQU 3
TITLE_BANK      EQU 4
NEW_GAME_BANK   EQU 5
PLAY_BALL_BANK  EQU 6
PLAYER_IMG_BANK EQU 10

; GameBoy palettes
BG_PALETTE    EQU $E4
SPR_PALETTE_0 EQU $E4 
SPR_PALETTE_1 EQU $90

; sprite props
FLIP_X_PAL  EQU (OAMF_XFLIP | OAMF_PAL1 )
FLIP_Y_PAL  EQU (OAMF_YFLIP | OAMF_PAL1 )
FLIP_XY_PAL EQU (FLIP_X_PAL | FLIP_Y_PAL)
FLIP_XY     EQU (OAMF_XFLIP | OAMF_YFLIP)

; UI Tiles
DOTTED_CIRCLE     EQU 10
BASEBALL          EQU 11
ARROW_LEFT        EQU 12
ARROW_RIGHT       EQU 13
ARROW_RIGHT_BLANK EQU 14
ARROW_DOWN        EQU 28
ARROW_UP          EQU 29
NUMBERS           EQU 48
BOX_UPPER_LEFT    EQU 17
BOX_UPPER_RIGHT   EQU 18
BOX_LOWER_LEFT    EQU 19
BOX_LOWER_RIGHT   EQU 20
BOX_HORIZONTAL    EQU 21
BOX_VERTICAL      EQU 22
EMPTY_BASE        EQU 23
OCCUPIED_BASE     EQU 24
LEVEL             EQU 16
EARNED_RUN_AVG    EQU 25
BATTING_AVG       EQU 26
INNING_BOTTOM     EQU 28
INNING_TOP        EQU 29

BUFFER_SIZE EQU 512

; baseball
BALLS_MASK   EQU $70
STRIKES_MASK EQU $0C
OUTS_MASK    EQU $03

FIRST_BASE_MASK  EQU $000F
SECOND_BASE_MASK EQU $00F0
THIRD_BASE_MASK  EQU $0F00
HOME_MASK        EQU $F000

SET_LCD_INTERRUPT: MACRO ;interrupt
  di
  ld hl, \1
  ld a, [hli]
  ld b, a
  ld a, [hl]
  ld c, a
  ld hl, rLCDInterrupt
  ld a, b
  ld [hli], a
  ld a, c
  ld [hl], a
  ei
ENDM


HIDE_ALL_SPRITES: MACRO
  xor a
  ld bc, a
  ld de, a
  ld hl, _OAMRAM
  ld a, 40
  ld [_i], a
.loop\@
  ld a, [_i]
  dec a
  ld [_i], a
  gbdk_SetOAM
  jr nz, .loop\@
ENDM

CLEAR_SCREEN: MACRO ;\1 = tile
  ld a, \1
  ld d, a
  ld bc, 1384
  ld hl, _SCRN0

.loop\@
  ld a, d
  ld [hli], a
  dec bc
  ld a, b
  and a
  jr nz, .loop\@
  ld a, c
  and a
  jr nz, .loop\@

  ld a, 167
  ld [rWX], a
  ld a, 144
  ld [rWY], a
  ; HIDE_ALL_SPRITES
ENDM

SET_BKG_TILES_WITH_OFFSET: MACRO ;x, y, w, h, offset, tile_map
  ld hl, \6
  ld de, tile_buffer
  ld bc, \2 * \3
  inc  b
  inc  c
  jr   .skip\@
.loop\@
  ld   a,[hl+]
  add \5
  ld   [de],a
  inc  de
.skip\@
  dec  c
  jr   nz, .loop\@
  dec  b
  jr   nz, .loop\@

  ld d, \1 ; x
  ld e, \2 ; y
  ld h, \3 ; w
  ld l, \4 ; h
  ld bc, tile_buffer
  call gbdk_SetBKGTiles
ENDM

FADE_OUT: MACRO
  ld a, $90
  ld [rBGP], a
  ld [rOBP0], a
  ld de, 200
  call gbdk_Delay
  ld a, $40
  ld [rBGP], a
  ld [rOBP0], a
  ld de, 200
  call gbdk_Delay
  xor a
  ld [rBGP], a
  ld [rOBP0], a
  ld de, 200
  call gbdk_Delay
ENDM

FADE_IN: MACRO
  ld a, $40
  ld [rBGP], a
  ld [rOBP0], a
  ld de, 200
  call gbdk_Delay
  ld a, $90
  ld [rBGP], a
  ld [rOBP0], a
  ld de, 200
  call gbdk_Delay
  ld a, BG_PALETTE
  ld [rBGP], a
  ld [rOBP0], a
  ld de, 200
  call gbdk_Delay
ENDM

ENDC ; BEISBOL_INC
