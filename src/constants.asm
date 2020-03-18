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
OVERWORLD_BANK      EQU 20
ROLEDEX_BANK        EQU 21
MAPS_BANK           EQU 50

; GameBoy palettes
BG_PALETTE    EQU $E4
SPR_PALETTE_0 EQU $E4 
SPR_PALETTE_1 EQU $90

; sprite props
FLIP_X_PAL  EQU (OAMF_XFLIP | OAMF_PAL1 )
FLIP_Y_PAL  EQU (OAMF_YFLIP | OAMF_PAL1 )
FLIP_XY_PAL EQU (FLIP_X_PAL | FLIP_Y_PAL)
FLIP_XY     EQU (OAMF_XFLIP | OAMF_YFLIP)

; ui draw flags
DRAW_FLAGS_BKG     EQU %00000000
DRAW_FLAGS_WIN     EQU %00000001
DRAW_FLAGS_PAD_TOP EQU %00000010

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
BOX_JUNCTION      EQU 31
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

;status
STATUS_OK  EQU 0
STATUS_BRN EQU 1
STATUS_FRZ EQU 2
STATUS_PAR EQU 3
STATUS_PSN EQU 4
STATUS_SLP EQU 5

MAX_MOVES        EQU 4
NAME_LENGTH      EQU 8
NICKNAME_LENGTH  EQU 12
PLAYER_BASE_SIZE EQU 16
BUFFER_SIZE      EQU 512
MAP_STEP_SIZE    EQU 16
