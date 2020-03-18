INCLUDE "src/beisbol.inc"

SECTION "Roledex UI", ROMX, BANK[ROLEDEX_BANK]

RoledexHeadingText:
  DB "REPORTS"

RoledexSeenSignText:
  DB "SEEN    "
  DB "    SIGN"

RoledexMenuText:
  DB "DATA    "
  DB "CRY     "
  DB "AREA    "
  DB "QUIT"

DrawRoledexBaseUI:
  CLEAR_BKG_AREA 0,0,20,18," "

  ld de, $0101
  ld hl, $0701
  ld bc, RoledexHeadingText
  ld a, DRAW_FLAGS_BKG
  call SetTiles

  ld de, $1002
  ld hl, $0404
  ld bc, RoledexSeenSignText
  ld a, DRAW_FLAGS_BKG
  call SetTiles

  ld de, $100A
  ld hl, $0407
  ld bc, RoledexMenuText
  ld a, DRAW_FLAGS_BKG
  call SetTiles

  ld hl, tile_buffer
  ld a, BOX_VERTICAL
  ld [hli], a
  ld c, 9
.loop
    ld a, BOX_VERTICAL
    ld [hli], a
    ld a, BOX_JUNCTION
    ld [hli], a
    dec c
    jr nz, .loop

  ld de, $0E00
  ld hl, $0112
  ld bc, tile_buffer
  ld a, DRAW_FLAGS_BKG
  call SetTiles

  ld hl, tile_buffer
  ld a, BOX_HORIZONTAL
  ld bc, 5
  call mem_Set

  ld de, $0F08
  ld hl, $0501
  ld bc, tile_buffer
  ld a, DRAW_FLAGS_BKG
  call SetTiles

  ret

DrawRoledexListEntry:;a = number, de = xy
  push af;number
  push de;xy
  call GetZeroPaddedNumber

  pop de;xy
  push de;xy
  ld h, 4
  ld l, 1
  ld bc, str_buffer
  ld a, DRAW_FLAGS_BKG
  call SetTiles

  ld hl, tile_buffer
  ld a, " "
  ld bc, NICKNAME_LENGTH
  call mem_Set

  pop de;xy
  inc d
  inc d;x+2
  inc e;y+1
  pop af;number
  push af;number
  push de;xy

  dec d
  ld h, NICKNAME_LENGTH
  ld l, 1
  ld bc, tile_buffer
  ld a, DRAW_FLAGS_BKG
  call SetTiles

  ;TODO: check if number is caught/seen yet

  pop de;xy
  pop af;number
  push af;number
  push de;xy
  call GetPlayerName

  ld a, BASEBALL
  ld hl, tile_buffer
  ld [hl], a
  
  ld hl, name_buffer
  ld de, tile_buffer+1
  call str_Copy

  ld hl, tile_buffer
  call str_Length
  ld h, e
  ld l, 1
  pop de;xy
  push de
  ld bc, tile_buffer
  ld a, DRAW_FLAGS_BKG
  call SetTiles
  
  pop de;xy
  pop af;num

  ret

ShowRoledexPage:
  ld a, [_s]
  and a
  cp 1
  jr c, .numTooLow
  cp 145;TODO; should be maxNum-6
  jr nc, .numTooHigh
  jr .draw
.numTooLow
  ld a, 1
  ld [_s], a
  jr .draw
.numTooHigh
  ld a, 145;TODO; should be maxNum-6
  ld [_s], a
.draw
  ld de, $0102
  ld c, 7
.loop
    push bc;count
    push af;num
    push de;xy
    call DrawRoledexListEntry
    pop de;xy
    inc e
    inc e;y+=2
    pop af;num
    inc a;num++
    pop bc;count
    dec c
    jr nz, .loop
  ret

ShowRoledexPlayer:
  ;show page
  ret

ShowRoledexUI::
  ld a, [rSCX]
  ld h, a
  ld a, [rSCY]
  ld l, a
  push hl
  xor a
  ld [rSCX], a
  ld [rSCY], a
  HIDE_ALL_SPRITES
  HIDE_WIN

  call DrawRoledexBaseUI

  xor a
  ld [_j], a
  ld a, 1
  ld [_s], a
  call ShowRoledexPage
  ld a, 7
  ld [_c], a
  ld de, 3
  ld a, DRAW_FLAGS_BKG
  call DrawListMenuArrow
.loop
    call UpdateInput
    ld a, [_j]
    push af;old _j
    ld de, 3
    ld a, DRAW_FLAGS_BKG
    call MoveListMenuArrow;returns -1,0,1
    ld b, a;store dir
    pop af;old _j
    ld c, a;old _j in c
    ld a, [_j]
    sub a, c;change in _j
    cp b;check if change is same as expected
    jr z, .checkMovePageLeft
    ld a, [_s]
    add a, b
    ld [_s], a
    call ShowRoledexPage
    jr .waitAndLoop
.checkMovePageLeft
    ld a, [button_state]
    and a, PADF_LEFT
    jr z, .checkMovePageRight
    ld a, [_s]
    cp 7
    jr c, .showFirstPage
    sub a, 7
    ld [_s], a
    call ShowRoledexPage
    WAITPAD_UP
    jr .waitAndLoop
.showFirstPage
    ld a, 1
    ld [_s], a
    call ShowRoledexPage
    WAITPAD_UP
    jr .waitAndLoop
.checkMovePageRight
    ld a, [button_state]
    and a, PADF_RIGHT
    jr z, .checkAPressed
    ld a, [_s]
    add a, 7
    ld [_s], a
    call ShowRoledexPage
    WAITPAD_UP
    jr .waitAndLoop
.checkAPressed
    ld a, [button_state]
    and a, PADF_A
    jr z, .checkBPressed
    call ShowRoledexPlayer
    jr .waitAndLoop
.checkBPressed
    ld a, [button_state]
    and a, PADF_B
    jr nz, .exit
.waitAndLoop
    call gbdk_WaitVBL
    jp .loop
.exit
  SHOW_WIN
  pop hl
  ld a, h
  ld [rSCX], a
  ld a, l
  ld [rSCY], a
  ret