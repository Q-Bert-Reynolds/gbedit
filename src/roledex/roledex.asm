IF !DEF(ROLEDEX)
ROLEDEX SET 1

LEFTY_BATTER_USER       EQU 0
RIGHTY_BATTER_USER      EQU 1
LEFTY_PITCHER_USER      EQU 2
RIGHTY_PITCHER_USER     EQU 3
LEFTY_BATTER_OPPONENT   EQU 4
RIGHTY_BATTER_OPPONENT  EQU 5
LEFTY_PITCHER_OPPONENT  EQU 6
RIGHTY_PITCHER_OPPONENT EQU 7

INCLUDE "data/move_data.asm"
INCLUDE "data/move_strings.asm"
INCLUDE "data/player_img.asm"
INCLUDE "data/player_data.asm"
INCLUDE "data/player_strings.asm"

; GetMoveName - a = move number, returns name_buffer
; GetMove - a = move number, returns move_data

; GetPlayerName - a = number, returns name_buffer
; GetPlayerDescription - a = number, returns str_buffer

; CheckSeenSigned - a = number, returns seen/sign in a
; GetSeenSignedCounts - d = seen, e = signed
; GetLastSeen - returns highest number seen in a

; LoadPlayerBaseData - a = number, returns player_base
; LoadPlayerBkgData - a = number, de = vram_offset

; GetPlayerImgColumns - a = number, returns num columns of img in a
; SetPlayerBkgTiles - a = number, de = vram_offset, bc = xy
; SetPlayerBkgTilesFlipped - a = number, de = vram_offset, bc = xy

; LoadUserPlayerBkgTiles
; LoadOpposingPlayerBkgTiles
; SetUserPlayerBkgTiles - a = frame
; SetOpposingPlayerBkgTiles -  - a = frame


SECTION "Roledex", ROM0
GetMoveName:: ; a = move number, returns name in name_buffer
  and a
  jr nz, .findName
  ld [name_buffer], a; 0 means no move
  ret

.findName
  dec a
  ld b, 0
  ld c, a;number
  ld a, [loaded_bank]
  ld [temp_bank], a
  ld a, PLAYER_STRINGS_BANK
  call SetBank

  ld hl, MoveNames
  call str_FromArray
  ld de, name_buffer
  call str_Copy

  ld a, [temp_bank]
  call SetBank
  ret 

GetMove:: ; a = move number, returns move_data
  push bc
  push de
  push hl
  and a
  jr nz, .loadMove
  ld a, STRUGGLE_MOVE
.loadMove
  dec a;since 0 means no move
  ld h, 0
  ld l, a;number
  add hl, hl
  ld b, h
  ld c, l
  ld a, [loaded_bank]
  ld [temp_bank], a
  ld a, PLAYER_DATA_BANK
  call SetBank

  ld hl, MoveList
  add hl, bc
  ld a, [hli]
  ld b, a
  ld a, [hl]
  ld h, a
  ld l, b
  ld de, move_data
  ld bc, move_data.end - move_data
  call mem_Copy

  ld a, [temp_bank]
  call SetBank
.exit
  pop hl
  pop de
  pop bc
  ret 

GetPlayerName:: ; a = number, returns name in name_buffer
  dec a
  ld c, a;number
  ld a, [loaded_bank]
  ld [temp_bank], a
  ld a, PLAYER_STRINGS_BANK
  call SetBank

  ld hl, PlayerNames
  ld a, c
  cp 151
  jr nc, .copy ;name outside of range, return Bubbi
  ld b, 0
  call str_FromArray
.copy
  ld de, name_buffer
  call str_Copy

  ld a, [temp_bank]
  call SetBank
  ret

GetPlayerDescription:: ; a = number, returns description in str_buffer
  dec a
  ld c, a;number
  ld a, [loaded_bank]
  ld [temp_bank], a
  ld a, PLAYER_STRINGS_BANK
  call SetBank

  ld hl, PlayerDescriptions
  ld a, c
  cp 152
  jr nc, .copy ;name outside of range, return Bubbi's description
  ld b, 0
  call str_FromArray
.copy
  ld de, str_buffer
  call str_Copy

  ld a, [temp_bank]
  call SetBank
  ret 

CheckSeenSigned:: ;a = number, returns seen/signed in a (1=seen,2=signed)
  dec a
  ld h, 0
  ld l, a
  ld c, 8
  call math_Divide
  ld d, a
  ld a, 7
  sub a, d
  ld d, a;bit to test
  push hl;byte

  ld bc, players_seen
  add hl, bc
  ld a, [hl]
  ld e, a
  push de;bit
  call math_TestBit
  pop de;bit
  pop hl;byte
  ret z;player not seen

  ld bc, players_sign
  add hl, bc
  ld a, [hl]
  ld e, a
  call math_TestBit
  jr z, .notSigned
  ld a, 2
  ret
.notSigned
  ld a, 1
  ret

GetSeenSignedCounts:: ;returns d = seen, e = signed
  ld hl, players_seen
  ld d, 0
  ld c, 151/8+1
.seenLoop
    ld a, [hli]
    call math_CountBits
    add a, d
    ld d, a

    dec c
    jr nz, .seenLoop

  ld hl, players_sign
  ld e, 0
  ld c, 151/8+1
.signedLoop
    ld a, [hli]
    call math_CountBits
    add a, e
    ld e, a

    dec c
    jr nz, .signedLoop

  ret

;TODO: FIXME
GetLastSeen:: ;returns highest number seen in a
  ld hl, players_seen+151/8+1
  ld b, 8
  ld c, 143
.byteLoop
    ld a, [hl]
    and a
    jr nz, .bitLoop
    dec hl
    ld a, c
    sub a, b
    ld c, a
    jr nz, .byteLoop
.bitLoop
    ld a, [hl]
    ld e, a
    ld a, 8
    sub a, b
    ld d, a
    push hl
    push bc
    call math_TestBit
    pop bc
    pop hl
    jr nz, .exit
    dec b
    jr nz, .bitLoop
.exit
  ld a, b
  add a, c
  ret

LoadPlayerBaseData:: ; a = number
  dec a
  ld b, 0
  ld c, a;number
  ld a, [loaded_bank]
  ld [temp_bank], a
  ld a, PLAYER_DATA_BANK
  call SetBank

  ld hl, Roledex
  add hl, bc
  add hl, bc
  ld a, [hli]
  ld b, a
  ld a, [hl]
  ld h, a
  ld l, b
  ld de, player_base
  ld bc, player_base.end - player_base
  call mem_Copy

  ld a, [temp_bank]
  call SetBank
  ret

PutPlayerTilesInHL:
  ld hl, $4000
  call PutPlayerAddressInHL
  ret

PutPlayerTileCountsInHL:
  ld hl, $4002
  call PutPlayerAddressInHL
  ret

PutPlayerColumnsInHL:
  ld hl, $4004
  call PutPlayerAddressInHL
  ret

PutPlayerTileMapsInHL:
  ld hl, $4006
  call PutPlayerAddressInHL
  ret

PutPlayerAddressInHL: ;hl = address
  push af
  push bc
  ld a, [hli]
  ld b, a
  ld a, [hl]
  ld h, a
  ld l, b
  pop bc
  pop af
  ret

SwitchPlayerImageBank: ; a = number (1-151), return adjusted number in a (0-PLAYERS_PER_BANK)
  dec a
  ld h, 0
  ld l, a
  ld c, PLAYERS_PER_BANK+1
  call math_Divide
  push af

  ld a, [loaded_bank]
  ld [temp_bank], a
  ld a, l
  add a, PLAYER_IMG_BANK
  call SetBank

  pop af
  ret

PreLoadPlayerBkgData: ;a = number, de = vram offset
  push af ;a = num

  ld a, 16
  call math_Multiply 
  ld de, _VRAM+$1000
  add hl, de ;_VRAM+$1000+vram_offset*16
  ld a, $98
  cp a, h
  jr nc, .noWrap
  ld a, h
  sub a, $10
  ld h, a
.noWrap
  ld d, h
  ld e, l
  pop af
  push de ;vram dest
  call SwitchPlayerImageBank
  push af ;num
  xor a
  ld b, a
  pop af ;num
  ld c, a
  push bc ;num
  call PutPlayerTileCountsInHL
  add hl, bc
  ld a, [hl]
  ld de, 16
  call math_Multiply
  ld b, h
  ld c, l

  pop de ;num
  push bc ;tile count
  call PutPlayerTilesInHL
  add hl, de
  add hl, de ;address offset is 2 bytes
  ld a, [hli]
  ld b, a
  ld a, [hl]
  ld h, a
  ld l, b ;tiles

  pop bc ;tile count
  pop de ;vram dest
  ret

LoadPlayerBkgData:: ; a = number, de = vram_offset
  call PreLoadPlayerBkgData
  call mem_CopyToTileData
  ld a, [temp_bank]
  call SetBank
  ret 

CopyToTileDataFlipped:
  inc b
  inc c
  jr  .skip
.loop
  ld a, $98
  cp a, d
  jr nz, .noWrap
  sub $10
  ld d, a
.noWrap
  di
  LCD_WAIT_VRAM
  ld  a, [hli]
  call ReverseByte
  ld  [de], a
  ei
  inc de
.skip
  dec c
  jr  nz,.loop
  dec b
  jr  nz,.loop
  ret

LoadPlayerBkgDataXFlipped:: ; a = number, de = vram_offset
  call PreLoadPlayerBkgData
  call CopyToTileDataFlipped
  ld a, [temp_bank]
  call SetBank
  ret 

GetPlayerImgColumns:: ; a = number, returns num columns of img in a
  call SwitchPlayerImageBank
  ld b, 0
  ld c, a
  call PutPlayerColumnsInHL
  add hl, bc
  ld a, [hl]
  push af ;columns

  ld a, [temp_bank]
  call SetBank
  
  pop af ;columns
  ret ;return a
  
PreSetPlayerBkgTiles:
  push bc ;xy
  push de ;vram off
  call SwitchPlayerImageBank
  push af ;num
  ld b, 0
  ld c, a
  call PutPlayerTileMapsInHL
  add hl, bc
  add hl, bc ;address offset is 2 bytes
  ld a, [hli]
  ld b, a
  ld a, [hl]
  ld h, a
  ld l, b ;tile map
  
  xor a
  ld b, a
  pop af ;num
  push hl ;tile map
  ld c, a
  call PutPlayerColumnsInHL
  add hl, bc
  pop bc ;tile map
  ld a, [hl]
  ld h, a ;w = columns
  ld l, a ;h = rows = columns
  pop de ;vram_offset
  ld a, e 
  pop de ;xy
  ret

SetPlayerBkgTiles:: ; a = number, bc = xy, de = vram_offset
  call PreSetPlayerBkgTiles
  call SetBKGTilesWithOffset

  ld a, [temp_bank]
  call SetBank
  ret

SetPlayerBkgTilesFlipped:: ; a = number, bc = xy, de = vram_offset
  call PreSetPlayerBkgTiles
  push hl
  push de
  push af
  ld de, str_buffer
  call FlipTileMapX;hl=wh; bc=in_tiles, de=out_tiles
  pop af
  pop de
  pop hl
  ld bc, str_buffer;because SetBKGTilesWithOffset uses tile buffer
  call SetBKGTilesWithOffset;hl=wh, de=xy, bc=in_tiles, a=offset

  ld a, [temp_bank]
  call SetBank
  ret

LoadUserPlayerBkgTiles::
  call GetCurrentUserPlayer
  push hl;current player
  call GetPlayerNumber
  call LoadPlayerBaseData
  pop hl;current player
  call GetPlayerHandedness
  ld [_v], a;handedness

  ld a, [loaded_bank]
  ld [temp_bank], a
  call IsUserFielding
  jr nz, .userIsPitching
.userIsBatting
  ld a, [_v];handedness
  and BAT_LEFT
  jr nz, .batsLeft
.batsRight
  ld hl, player_base.anim+4*RIGHTY_BATTER_USER
  jr .setBank
.batsLeft
  ld a, [_v];handedness
  and BAT_RIGHT
  jr .batsSwitch
  ld hl, player_base.anim+4*LEFTY_BATTER_USER
  jr .setBank  
.batsSwitch;TODO: change this depending on pitcher handedness
  ld hl, player_base.anim+4*LEFTY_BATTER_USER
  jr .setBank  
.userIsPitching
  ld a, [_v];handedness
  and a, THROW_RIGHT
  jr z, .throwsLeft
.throwsRight
  ld hl, player_base.anim+4*RIGHTY_PITCHER_USER
  jr .setBank
.throwsLeft
  ld hl, player_base.anim+4*LEFTY_PITCHER_USER
.setBank
  ld a, [hli]
  call SetBank

  ld a, [hli]
  ld e, a
  ld a, [hli]
  ld d, a;tiles
  
  push de;tiles
  ld a, [hli];tile count
  ld de, 16
  call math_Multiply
  ld b, h
  ld c, l

  pop hl;tiles
  ld de, $8800;_VRAM+$1000+_UI_FONT_TILE_COUNT*16

  call mem_CopyVRAM
  
  ld a, [temp_bank]
  call SetBank
  
  ret 

LoadOpposingPlayerBkgTiles::
  call GetCurrentOpponentPlayer
  push hl;current player
  call GetPlayerNumber
  call LoadPlayerBaseData
  pop hl;current player
  call GetPlayerHandedness
  ld [_v], a;handedness

  ld a, [loaded_bank]
  ld [temp_bank], a
  call IsUserFielding
 jr nz, .opponentIsBatting 
.opponentIsPitching
  ld a, [_v];handedness
  and a, THROW_RIGHT
  jr z, .throwsLeft
.throwsRight
  ld hl, player_base.anim+4*RIGHTY_PITCHER_OPPONENT
  jr .setBank
.opponentIsBatting
  ld a, [_v];handedness
  and BAT_LEFT
  jr nz, .batsLeft
.batsRight
  ld hl, player_base.anim+4*RIGHTY_BATTER_OPPONENT
  jr .setBank
.batsLeft
  ld a, [_v];handedness
  and BAT_RIGHT
  jr .batsSwitch
  ld hl, player_base.anim+4*LEFTY_BATTER_OPPONENT
  jr .setBank  
.batsSwitch;TODO: change this depending on pitcher handedness
  ld hl, player_base.anim+4*LEFTY_BATTER_OPPONENT
  jr .setBank 
.throwsLeft
  ld hl, player_base.anim+4*LEFTY_PITCHER_OPPONENT
.setBank
  ld a, [hli]
  call SetBank

  ld a, [hli]
  ld e, a
  ld a, [hli]
  ld d, a
  push de;tiles

  ld a, [hli]
  ld de, 16
  call math_Multiply
  ld b, h
  ld c, l

  pop hl;tiles
  ld de, $8800+64*16
  call mem_CopyToTileData

  ld a, [temp_bank]
  call SetBank
  
  ret  

SetUserPlayerBkgTiles:: ;a = frame
  ld de, 56
  call math_Multiply
  push hl;tile map for frame

  call GetCurrentUserPlayer
  push hl;current player
  call GetPlayerNumber
  call LoadPlayerBaseData
  pop hl;current player
  call GetPlayerHandedness
  ld [_v], a;handedness

  ld a, [loaded_bank]
  ld [temp_bank], a
  call IsUserFielding
  jr nz, .userIsPitching
.userIsBatting
  ld a, [_v];handedness
  and BAT_LEFT
  jr nz, .batsLeft
.batsRight
  ld hl, player_base.anim+4*RIGHTY_BATTER_USER
  jr .setBank
.batsLeft
  ld a, [_v];handedness
  and BAT_RIGHT
  jr .batsSwitch
  ld hl, player_base.anim+4*LEFTY_BATTER_USER
  jr .setBank  
.batsSwitch;TODO: change this depending on pitcher handedness
  ld hl, player_base.anim+4*LEFTY_BATTER_USER
  jr .setBank  
.userIsPitching
  ld a, [_v];handedness
  and a, THROW_RIGHT
  jr z, .throwsLeft
.throwsRight
  ld hl, player_base.anim+4*RIGHTY_PITCHER_USER
  jr .setBank
.throwsLeft
  ld hl, player_base.anim+4*LEFTY_PITCHER_USER
.setBank
  ld a, [hli]
  call SetBank

  ld a, [hli]
  ld e, a
  ld a, [hli]
  ld d, a
  push de;tiles

  ld a, [hli]
  ld de, 16
  call math_Multiply
  ld b, h
  ld c, l

  pop hl;tiles
  add hl, bc;tiles + tile_count*16
  pop de;tile map for frame offset
  add hl, de
  ld b, h
  ld c, l

  ld hl, $0807;wh
  ld de, $0005;xy
  ld a, _UI_FONT_TILE_COUNT
  call SetBKGTilesWithOffset

  ld a, [temp_bank]
  call SetBank
  ret

SetOpposingPlayerBkgTiles:: ;a = frame
  ld de, 56
  call math_Multiply
  push hl;frame
  call GetCurrentOpponentPlayer
  push hl;current player
  call GetPlayerNumber
  call LoadPlayerBaseData
  pop hl;current player
  call GetPlayerHandedness
  ld [_v], a;handedness

  ld a, [loaded_bank]
  ld [temp_bank], a
  call IsUserFielding
  jr nz, .opponentIsBatting
.opponentIsPitching
  ld a, [_v];handedness
  and a, THROW_RIGHT
  jr z, .throwsLeft
.throwsRight
  ld hl, player_base.anim+4*RIGHTY_PITCHER_OPPONENT
  jr .setBank
.throwsLeft
  ld hl, player_base.anim+4*LEFTY_PITCHER_OPPONENT
  jr .setBank
.opponentIsBatting
  ld a, [_v];handedness
  and BAT_LEFT
  jr nz, .batsLeft
.batsRight
  ld hl, player_base.anim+4*RIGHTY_BATTER_OPPONENT
  jr .setBank
.batsLeft
  ld a, [_v];handedness
  and BAT_RIGHT
  jr .batsSwitch
  ld hl, player_base.anim+4*LEFTY_BATTER_OPPONENT
  jr .setBank  
.batsSwitch;TODO: change this depending on pitcher handedness
  ld hl, player_base.anim+4*LEFTY_BATTER_OPPONENT
.setBank
  ld a, [hli]
  call SetBank

  ld a, [hli]
  ld e, a
  ld a, [hli]
  ld d, a
  push de;tiles

  ld a, [hli]
  ld de, 16
  call math_Multiply
  ld b, h
  ld c, l

  pop hl;tiles
  add hl, bc;tiles + tile_count*16
  pop de;tile map for frame offset
  add hl, de
  ld b, h
  ld c, l

  ld hl, $0807;wh
  ld de, $0C00;xy
  ld a, _UI_FONT_TILE_COUNT+64
  call SetBKGTilesWithOffset

  ld a, [temp_bank]
  call SetBank
  
  ret 


ENDC ;ROLEDEX
