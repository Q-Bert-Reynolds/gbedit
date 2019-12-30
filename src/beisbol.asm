IF !DEF(BEISBOL_ASM)
BEISBOL_ASM SET 1

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

ENDC
