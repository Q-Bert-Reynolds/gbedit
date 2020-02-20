IF !DEF(BEISBOL_INC)
BEISBOL_INC SET 1

INCLUDE "src/hardware.inc"
INCLUDE "src/memory1.asm"
INCLUDE "src/charmap.asm"
INCLUDE "src/strings.asm"
INCLUDE "src/gbdk.asm"
INCLUDE "src/math.asm"

; banks
TEMP_BANK           EQU 255
SONG_BANK           EQU 1
UI_BANK             EQU 2
START_BANK          EQU 3
TITLE_BANK          EQU 4
NEW_GAME_BANK       EQU 5
PLAY_BALL_BANK      EQU 6
LINEUP_BANK         EQU 7
PLAYER_STRINGS_BANK EQU 8
PLAYER_DATA_BANK    EQU 9
PLAYER_IMG_BANK     EQU 10

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

;types
NONE     EQU 0
NORMAL   EQU 1
FIRE     EQU 2
WATER    EQU 3
ELECTRIC EQU 4
GRASS    EQU 5
ICE      EQU 6
FIGHTING EQU 7
POISON   EQU 8
GROUND   EQU 9
FLYING   EQU 10
PSYCHIC  EQU 11
BUG      EQU 12
ROCK     EQU 13
GHOST    EQU 14
DRAGON   EQU 15

;constants
MAX_MOVES       EQU 4
NAME_LENGTH     EQU 8
NICKNAME_LENGTH EQU 12
BUFFER_SIZE     EQU 512

SET_LCD_INTERRUPT: MACRO ;interrupt
  di

  ld b, ~IEF_LCDC
  ld a, [rIE]
  and a, b
  ld [rIE], a

  xor a
  ld [rSTAT], a

  ld hl, rLCDInterrupt
  ld bc, \1
  ld a, b
  ld [hli], a
  ld a, c
  ld [hl], a

  ld b, IEF_LCDC
  ld a, [rIE]
  or a, b
  ld [rIE], a

  ld a, STATF_LYC
  ld [rSTAT], a
  
  ei
ENDM

DISABLE_LCD_INTERRUPT: macro
  di
    
  ld b, ~IEF_LCDC
  ld a, [rIE]
  and a, b
  ld [rIE], a

  xor a
  ld [rSTAT], a

  ld hl, rLCDInterrupt
  ld bc, EndLCDInterrupt
  ld a, b
  ld [hli], a
  ld a, c
  ld [hl], a

  ei
ENDM

HIDE_ALL_SPRITES: MACRO
  xor a
  ld b, 160
  ld hl, oam_buffer
.loop\@
  ld [hl], a
  inc l
  dec b
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

  ld a, 166
  ld [rWX], a
  ld a, 143
  ld [rWY], a
  HIDE_ALL_SPRITES
ENDM

CLEAR_BKG_AREA: MACRO ;x, y, w, h, tile
  xor a
  ld [_i], a
  ld hl, tile_buffer
.tilesLoop\@
  ld a, \5
  ld [hli], a
  ld a, [_i]
  inc a
  ld [_i], a
  sub a, \3 * \4
  jr nz, .tilesLoop\@
  ld d, \1
  ld e, \2
  ld h, \3
  ld l, \4
  ld bc, tile_buffer
  call gbdk_SetBKGTiles
ENDM

CLEAR_WIN_AREA: MACRO ;x, y, w, h, tile
  xor a
  ld [_i], a
  ld hl, tile_buffer
.tilesLoop\@
  ld a, \5
  ld [hli], a
  ld a, [_i]
  inc a
  ld [_i], a
  sub a, \3 * \4
  jr nz, .tilesLoop\@
  ld d, \1
  ld e, \2
  ld h, \3
  ld l, \4
  ld bc, tile_buffer
  call gbdk_SetWinTiles
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

SET_SPRITE_TILES: MACRO ;count, map, flags, offset
  xor a
  ld [_i], a
  ld hl, \2
  ld e, \3 ;flags
.setSprite\@
  ld a, [_i]
  ld c, a
  ld a, [hli]
  push hl
  add a, \4
  ld d, a ;tile
  call gbdk_SetSpriteTile
  ld a, [_i]
  ld c, a
  ld d, e
  call gbdk_SetSpriteProp
  pop hl
  ld a, [_i]
  inc a
  ld [_i], a
  sub a, \1
  jr nz, .setSprite\@
ENDM

UPDATE_INPUT_AND_JUMP_TO_IF_BUTTONS: MACRO ;address, buttons
  call UpdateInput
  JUMP_TO_IF_BUTTONS \1, \2
ENDM

JUMP_TO_IF_BUTTONS: MACRO ; address, buttons
  ld a, [last_button_state]
  and a
  jr nz, .skip\@
  ld a, [button_state]
  and \2
  jp nz, \1
.skip\@
ENDM

WAITPAD_UP: MACRO
.loop\@
  call gbdk_WaitVBL
  call UpdateInput
  ld a, [button_state]
  and a
  jr nz, .loop\@
ENDM

ENDC ; BEISBOL_INC
