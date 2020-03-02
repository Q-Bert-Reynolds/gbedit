PLAYER_DATA: MACRO;\1 = team, \2 = order
\1Player\2:
.number   DB
.level    DB
.position DB
.moves    DS MAX_MOVES
.pp       DS MAX_MOVES
.status   DB
.hp       DW
.max_hp   DW 
.bat      DW
.field    DW
.speed    DW
.throw    DW
ENDM

USER_PLAYER_DATA: MACRO
.nickname          DS NICKNAME_LENGTH
.xp                DS 3
.pay               DW ;paid each game
;hitting stats
.strikeouts        DW ;both looking and swinging
.sacrifices        DW ;both sac flies and sac bunts
.batted_outs       DW ;groundout, lineout, flyout, popout, GIDP, etc
.fielders_choice   DW
.singles           DW
.doubles           DW
.tripples          DW
.homeruns          DW
.runs              DW
.runs_batted_in    DW
.walks             DW
.reached_on_error  DW
.hit_by_pitch      DW
.stolen_bases      DW
.caught_stealing   DW
;pitching stats
.batters_faced     DW
.outs_recorded     DW
.walks_allowed     DW
.hits_allowed      DW
.runs_allowed      DW ;earned only
.strikeouts_thrown DW
.wild_pitches      DW
.hit_batters       DW
ENDM

OPPONENT_PLAYER_DATA: MACRO ;only needs data for BA and ERA
.hits          DW
.at_bats       DW
.runs_allowed  DW
.outs_recorded DW
ENDM

SECTION "Player RAM", WRAM0[$c500]
;Lineups
UserLineup: 
  PLAYER_DATA UserLineup, 1
  USER_PLAYER_DATA
  PLAYER_DATA UserLineup, 2
  USER_PLAYER_DATA
  PLAYER_DATA UserLineup, 3
  USER_PLAYER_DATA
  PLAYER_DATA UserLineup, 4
  USER_PLAYER_DATA
  PLAYER_DATA UserLineup, 5
  USER_PLAYER_DATA
  PLAYER_DATA UserLineup, 6
  USER_PLAYER_DATA
  PLAYER_DATA UserLineup, 7
  USER_PLAYER_DATA
  PLAYER_DATA UserLineup, 8
  USER_PLAYER_DATA
  PLAYER_DATA UserLineup, 9
  USER_PLAYER_DATA
UserLineupEnd:

OpponentLineup: 
  PLAYER_DATA OpponentLineup, 1
  OPPONENT_PLAYER_DATA
  PLAYER_DATA OpponentLineup, 2
  OPPONENT_PLAYER_DATA
  PLAYER_DATA OpponentLineup, 3
  OPPONENT_PLAYER_DATA
  PLAYER_DATA OpponentLineup, 4
  OPPONENT_PLAYER_DATA
  PLAYER_DATA OpponentLineup, 5
  OPPONENT_PLAYER_DATA
  PLAYER_DATA OpponentLineup, 6
  OPPONENT_PLAYER_DATA
  PLAYER_DATA OpponentLineup, 7
  OPPONENT_PLAYER_DATA
  PLAYER_DATA OpponentLineup, 8
  OPPONENT_PLAYER_DATA
  PLAYER_DATA OpponentLineup, 9
  OPPONENT_PLAYER_DATA

SECTION "Player Utils", ROM0

NoMove: DB "--------", 0
GetPlayerMoveName: ;hl = player, a = move num, returns move name in name_buffer
  push bc
  push de
  ld bc, UserLineupPlayer1.moves - UserLineupPlayer1
  add hl, bc
  ld b, 0
  ld c, a
  add hl, bc
  ld a, [hl]
  and a
  jr z, .noMove
  inc a
  call GetMoveName
  jr .exit
.noMove
  ld hl, NoMove
  ld de, name_buffer
  call str_Copy
.exit
  pop de
  pop bc
  ret 

GetPlayerMoveCount:;hl = player, returns move count in a
  push bc
  ld bc, UserLineupPlayer1.moves - UserLineupPlayer1
  add hl, bc
  xor a
  ld c, a;count
  ld b, MAX_MOVES
.loop
    ld a, [hli]
    and a
    jr z, .skip
    inc c
.skip
    dec b
    ld a, b
    and a
    jr nz, .loop
  ld a, c;count
  pop bc
  ret

GetPlayerMove: ;hl = player, a = player move num, returns move in move_data
  push bc
  push de
  ld bc, UserLineupPlayer1.moves - UserLineupPlayer1
  add hl, bc
  ld b, 0
  ld c, a
  add hl, bc
  ld a, [hl]
  and a
  jr z, .noMove
  call GetMove
  jr .exit
.noMove
  ld hl, move_data
  ld a, 0
  ld bc, 8
  call mem_Set
.exit
  pop de
  pop bc
  ret 

GetPlayerMovePP: ;hl = player, a = player move num, returns pp in a
  push bc
  ld bc, UserLineupPlayer1.pp - UserLineupPlayer1
  add hl, bc
  ld b, 0
  ld c, a
  add hl, bc
  ld a, [hl]
  pop bc
  ret

GetPlayerNumber: ;hl = player, returns number in a
  push bc
  ld bc, UserLineupPlayer1.number - UserLineupPlayer1
  add hl, bc
  pop bc
  ld a, [hl]
  ret
  
GetPlayerLevel: ;hl = player, returns level in a
  push bc
  ld bc, UserLineupPlayer1.level - UserLineupPlayer1
  add hl, bc
  pop bc
  ld a, [hl]
  ret

GetPlayerPosition: ;hl = player, returns position in a
  push bc
  ld bc, UserLineupPlayer1.position - UserLineupPlayer1
  add hl, bc
  pop bc
  ld a, [hl]
  ret

GetPlayerStatus: ;hl = player, returns status in a
  push bc
  ld bc, UserLineupPlayer1.status - UserLineupPlayer1
  add hl, bc
  pop bc
  ld a, [hl]
  ret

GetPlayerHP: ;hl = player, returns hp in hl
  push bc
  ld bc, UserLineupPlayer1.hp - UserLineupPlayer1
  add hl, bc
  ld a, [hli]
  ld b, a
  ld a, [hl]
  ld h, a
  ld l, b
  pop bc
  ret

GetPlayerMaxHP: ;hl = player, returns max hp in hl
  push bc
  ld bc, UserLineupPlayer1.max_hp - UserLineupPlayer1
  add hl, bc
  ld a, [hli]
  ld b, a
  ld a, [hl]
  ld h, a
  ld l, b
  pop bc
  ret

GetPlayerBat: ;hl = player, returns bat in hl
  push bc
  ld bc, UserLineupPlayer1.bat - UserLineupPlayer1
  add hl, bc
  ld a, [hli]
  ld b, a
  ld a, [hl]
  ld h, a
  ld l, b
  pop bc
  ret

GetPlayerField: ;hl = player, returns field in hl
  push bc
  ld bc, UserLineupPlayer1.field - UserLineupPlayer1
  add hl, bc
  ld a, [hli]
  ld b, a
  ld a, [hl]
  ld h, a
  ld l, b
  pop bc
  ret

GetPlayerSpeed: ;hl = player, returns speed in hl
  push bc
  ld bc, UserLineupPlayer1.speed - UserLineupPlayer1
  add hl, bc
  ld a, [hli]
  ld b, a
  ld a, [hl]
  ld h, a
  ld l, b
  pop bc
  ret

GetPlayerThrow: ;hl = player, returns throw in hl
  push bc
  ld bc, UserLineupPlayer1.throw - UserLineupPlayer1
  add hl, bc
  ld a, [hli]
  ld b, a
  ld a, [hl]
  ld h, a
  ld l, b
  pop bc
  ret

GetUserPlayerPay: ;hl = player, returns pay in hl
  push bc
  ld bc, UserLineupPlayer1.pay - UserLineupPlayer1
  add hl, bc
  ld a, [hli]
  ld b, a
  ld a, [hl]
  ld h, a
  ld l, b
  pop bc
  ret

GetUserPlayerName:;hl = user player, returns name in name_buffer
  push bc
  push hl;user's player
  ld bc, UserLineupPlayer1.nickname - UserLineupPlayer1
  add hl, bc
  ld a, [hl]
  and a
  jr z, .getBaseName
  ld de, name_buffer
  call str_Copy
  pop hl
  pop bc
  ret
.getBaseName
  pop hl;user's player
  call GetPlayerNumber
  call GetPlayerName
  pop bc
  ret