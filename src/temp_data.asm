INCLUDE "src/beisbol.inc"

SECTION "Temp Data", ROMX, BANK[TEMP_BANK]
TempItems:
  DB POTION_ITEM,      12
  DB BASEBALL_ITEM,    10
  DB TM01_ITEM,        1
  DB TM06_ITEM,        1
  DB SUPER_POTION_ITEM,2
  DB STEROIDS_ITEM,    99
  DB TOWN_MAP_ITEM,    0
  DB DREAM_SCOPE_ITEM, 0
  DB HARMONICA_ITEM,   0
  DB EXP_ALL_ITEM,     0
  DB ANTIDOTE_ITEM,    7
  DB BICYCLE_ITEM,     0
EndTempItems:
  DS MAX_ITEMS*BYTES_PER_ITEM - (EndTempItems-TempItems)

TempPCItems:
  DB POTION_ITEM,      1
EndTempPCItems:
  DS MAX_PC_ITEMS*BYTES_PER_ITEM - (EndTempPCItems-TempPCItems)

TempUserLineup:
  DB NUM_BUBBI,      5, SHORTSTOP,      THROW_RIGHT | BAT_SWITCH
  DB NUM_SQUIRT,     5, CATCHER,        THROW_RIGHT | BAT_RIGHT
  DB NUM_ZAPH,      65, RIGHT_FIELDER,  THROW_RIGHT | BAT_RIGHT
  DB NUM_BEAR,      28, FIRST_BASEMAN,  THROW_RIGHT | BAT_RIGHT
  DB NUM_GIO,       27, LEFT_FIELDER,   THROW_RIGHT | BAT_RIGHT
  DB NUM_STARCHILD, 15, THIRD_BASEMAN,  THROW_RIGHT | BAT_RIGHT
  DB NUM_META,       8, SECOND_BASEMAN, THROW_RIGHT | BAT_LEFT
  DB NUM_CHU,       23, CENTER_FIELDER, THROW_RIGHT | BAT_RIGHT
  DB NUM_BIG_RED,   33, PITCHER,        THROW_LEFT  | BAT_RIGHT
  
TempOpponentLineup:
  DB NUM_ASH,       45, CATCHER,        THROW_RIGHT | BAT_RIGHT
  DB NUM_GINGER,     8, SHORTSTOP,      THROW_RIGHT | BAT_SWITCH
  DB NUM_MORTY,     65, RIGHT_FIELDER,  THROW_RIGHT | BAT_RIGHT
  DB NUM_MACOBB,    28, FIRST_BASEMAN,  THROW_RIGHT | BAT_RIGHT
  DB NUM_RAT_TAIL,  27, LEFT_FIELDER,   THROW_RIGHT | BAT_RIGHT
  DB NUM_STARMAN,   15, THIRD_BASEMAN,  THROW_RIGHT | BAT_RIGHT
  DB NUM_BUTTERFLY,  8, SECOND_BASEMAN, THROW_RIGHT | BAT_LEFT
  DB NUM_EVIE,      23, CENTER_FIELDER, THROW_RIGHT | BAT_RIGHT
  DB NUM_RAI,       33, PITCHER,        THROW_LEFT  | BAT_RIGHT

; TempUserName: DB "Nolan",0
; TempRivalName: DB "Calvin",0
Seed::
  ; ld hl, TempUserName
  ; ld de, user_name
  ; call str_Copy

  ; ld hl, TempRivalName
  ; ld de, rival_name
  ; call str_Copy

.userLineup 

  ld hl, TempUserLineup
  ld de, UserLineup
  ld bc, UserLineupPlayer2-UserLineupPlayer1
  call CreateLineup
                      ;lineup address     name             pay
  ADD_USER_PLAYER_DATA UserLineupPlayer1, "Buttercup",      42
  ADD_USER_PLAYER_DATA UserLineupPlayer2, "",               69
  ADD_USER_PLAYER_DATA UserLineupPlayer3, "Zaphod",       8000
  ADD_USER_PLAYER_DATA UserLineupPlayer4, "",               42
  ADD_USER_PLAYER_DATA UserLineupPlayer5, "",               35
  ADD_USER_PLAYER_DATA UserLineupPlayer6, "",              420
  ADD_USER_PLAYER_DATA UserLineupPlayer7, "",               20
  ADD_USER_PLAYER_DATA UserLineupPlayer8, "",               75
  ADD_USER_PLAYER_DATA UserLineupPlayer9, "Ruby",     16777215

.opposingLineup
  ld hl, TempOpponentLineup
  ld de, OpponentLineup
  ld bc, OpponentLineupPlayer2-OpponentLineupPlayer1
  call CreateLineup

.seenSigned
  ld hl, 2020
  call gbdk_Seed
  ld hl, players_seen
  ld de, players_sign
  ld c, 151/8
.loop
    push de;signed
    push hl;seen
    call gbdk_Random
    ld a, e
    pop hl;seen
    ld [hli], a
    and a, d
    pop de;signed
    ld [de], a
    inc de

    dec c
    jr nz, .loop

  push de;signed
  push hl;seen
  call gbdk_Random
  ld a, e
  and a, $FE
  pop hl;seen
  ld [hl], a
  and a, d
  and a, $FE
  pop de;signed
  ld [de], a

  ld hl, players_seen
  ld a, %11000011
  ld [hli], a
  ld a, %01111111
  ld [hl], a
  
  ld hl, players_sign
  ld a, %00000011
  ld [hli], a
  ld a, %01111000
  ld [hl], a

.items
  ld hl, TempItems
  ld de, inventory
  ld bc, MAX_ITEMS*BYTES_PER_ITEM
  call mem_Copy

  ld hl, TempPCItems
  ld de, pc_items
  ld bc, MAX_PC_ITEMS*BYTES_PER_ITEM
  call mem_Copy

.money
  ld hl, money
  ld a, $e4; $e4e1c0 == 15,000,000
  ld [hli], a
  ld a, $e1
  ld [hli], a
  ld a, $c0
  ld [hli], a
  ret