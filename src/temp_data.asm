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

TempUserName: DB "NOLAN",0
TempRivalName: DB "CALVIN",0
Seed::
  ld hl, TempUserName
  ld de, user_name
  call str_Copy

  ld hl, TempRivalName
  ld de, rival_name
  call str_Copy

.userLineup
  CREATE_PLAYER        UserLineupPlayer1, 9,   45, CATCHER,        THROW_RIGHT | BAT_RIGHT
  ADD_USER_PLAYER_DATA UserLineupPlayer1, "", 4200
  CREATE_PLAYER        UserLineupPlayer2, 1,   8,  SHORTSTOP,      THROW_RIGHT | BAT_SWITCH
  ADD_USER_PLAYER_DATA UserLineupPlayer2, "BUTTERCUP", 69
  CREATE_PLAYER        UserLineupPlayer3, 145, 65, RIGHT_FIELDER,  THROW_RIGHT | BAT_RIGHT
  ADD_USER_PLAYER_DATA UserLineupPlayer3, "ZAPH", 8000
  CREATE_PLAYER        UserLineupPlayer4, 143, 28, FIRST_BASEMAN,  THROW_RIGHT | BAT_RIGHT
  ADD_USER_PLAYER_DATA UserLineupPlayer4, "", 42
  CREATE_PLAYER        UserLineupPlayer5, 17,  27, LEFT_FIELDER,   THROW_RIGHT | BAT_RIGHT
  ADD_USER_PLAYER_DATA UserLineupPlayer5, "", 35
  CREATE_PLAYER        UserLineupPlayer6, 120, 15, THIRD_BASEMAN,  THROW_RIGHT | BAT_RIGHT
  ADD_USER_PLAYER_DATA UserLineupPlayer6, "", 420
  CREATE_PLAYER        UserLineupPlayer7, 11,  8,  SECOND_BASEMAN, THROW_RIGHT | BAT_LEFT
  ADD_USER_PLAYER_DATA UserLineupPlayer7, "", 20
  CREATE_PLAYER        UserLineupPlayer8, 25,  23, CENTER_FIELDER, THROW_RIGHT | BAT_RIGHT
  ADD_USER_PLAYER_DATA UserLineupPlayer8, "", 75
  CREATE_PLAYER        UserLineupPlayer9, 6,   33, PITCHER,        THROW_LEFT  | BAT_RIGHT
  ADD_USER_PLAYER_DATA UserLineupPlayer9, "Ruby", 16777215

.opposingLineup
  CREATE_PLAYER OpponentLineupPlayer1, 9,   45, CATCHER,        THROW_RIGHT | BAT_RIGHT
  CREATE_PLAYER OpponentLineupPlayer2, 1,   8,  SHORTSTOP,      THROW_RIGHT | BAT_SWITCH
  CREATE_PLAYER OpponentLineupPlayer3, 145, 65, RIGHT_FIELDER,  THROW_RIGHT | BAT_RIGHT
  CREATE_PLAYER OpponentLineupPlayer4, 143, 28, FIRST_BASEMAN,  THROW_RIGHT | BAT_RIGHT
  CREATE_PLAYER OpponentLineupPlayer5, 17,  27, LEFT_FIELDER,   THROW_RIGHT | BAT_RIGHT
  CREATE_PLAYER OpponentLineupPlayer6, 120, 15, THIRD_BASEMAN,  THROW_RIGHT | BAT_RIGHT
  CREATE_PLAYER OpponentLineupPlayer7, 11,  8,  SECOND_BASEMAN, THROW_RIGHT | BAT_LEFT
  CREATE_PLAYER OpponentLineupPlayer8, 25,  23, CENTER_FIELDER, THROW_RIGHT | BAT_RIGHT
  CREATE_PLAYER OpponentLineupPlayer9, 6,   33, PITCHER,        THROW_LEFT  | BAT_RIGHT

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

.money
  ld hl, money
  ld a, $e4; $e4e1c0 == 15,000,000
  ld [hli], a
  ld a, $e1
  ld [hli], a
  ld a, $c0
  ld [hli], a
  ret