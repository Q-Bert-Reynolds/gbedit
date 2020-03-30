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
SIM_BANK            EQU 22
MAPS_BANK           EQU 50

; GameBoy palettes
BG_PALETTE  EQU %11100100 ;normal
SPR_PAL_BDL EQU %11100100 ;black, dark,  light
SPR_PAL_DLW EQU %10010000 ;dark,  light, white
SPR_PAL_BDW EQU %11100000 ;black, dark,  white
SPR_PAL_BLW EQU %11010000 ;black, light, white

; sprite props
FLIP_X_PAL  EQU (OAMF_XFLIP | OAMF_PAL1 )
FLIP_Y_PAL  EQU (OAMF_YFLIP | OAMF_PAL1 )
FLIP_XY_PAL EQU (FLIP_X_PAL | FLIP_Y_PAL)
FLIP_XY     EQU (OAMF_XFLIP | OAMF_YFLIP)

; sprite draw flags
SPRITE_FLAGS_SKIP      EQU %00000001
SPRITE_FLAGS_CLEAR_END EQU %00000010

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
BUFFER_SIZE      EQU 512
MAP_STEP_SIZE    EQU 16

;rolédex
PLAYER_BASE_NUM     EQU 0
PLAYER_BASE_TYPE1   EQU PLAYER_BASE_NUM     + 1
PLAYER_BASE_TYPE2   EQU PLAYER_BASE_TYPE1   + 1
PLAYER_BASE_EV_TO   EQU PLAYER_BASE_TYPE2   + 1
PLAYER_BASE_EV_TYPE EQU PLAYER_BASE_EV_TO   + 1
PLAYER_BASE_EV_LVL  EQU PLAYER_BASE_EV_TYPE + 1
PLAYER_BASE_HEIGHT  EQU PLAYER_BASE_EV_LVL  + 1
PLAYER_BASE_WEIGHT  EQU PLAYER_BASE_HEIGHT  + 1
PLAYER_BASE_HP      EQU PLAYER_BASE_WEIGHT  + 2
PLAYER_BASE_BAT     EQU PLAYER_BASE_HP      + 1
PLAYER_BASE_FIELD   EQU PLAYER_BASE_BAT     + 1
PLAYER_BASE_SPEED   EQU PLAYER_BASE_FIELD   + 1
PLAYER_BASE_THROW   EQU PLAYER_BASE_SPEED   + 1
PLAYER_BASE_BODY_ID EQU PLAYER_BASE_THROW   + 1
PLAYER_BASE_HEAD_ID EQU PLAYER_BASE_BODY_ID + 1
PLAYER_BASE_HAT_ID  EQU PLAYER_BASE_HEAD_ID + 1
PLAYER_BASE_GB_PAL  EQU PLAYER_BASE_HAT_ID  + 1
PLAYER_BASE_SIZE    EQU PLAYER_BASE_GB_PAL  + 1
