IF !DEF(ROLEDEX)
ROLEDEX SET 1

IMG_BANK_COUNT EQU 6
PLAYERS_PER_BANK = 151 / IMG_BANK_COUNT

INCLUDE "data/move_data.asm"
INCLUDE "data/move_strings.asm"
INCLUDE "data/player_img.asm"
INCLUDE "data/player_data.asm"
INCLUDE "data/player_strings.asm"

; GetMoveName - a = move number, returns name_buffer
; GetPlayerName - a = number, returns name_buffer
; GetPlayerDescription - a = number, returns str_buffer
; LoadPlayerBaseData - a = number, returns player_base
; LoadPlayerBkgData - a = number, de = vram_offset
; GetPlayerImgColumns - a = number, returns num columns of img in a
; SetPlayerBkgTiles - a = number, de = vram_offset, de = xy
; SetPlayerBkgTilesFlipped - a = number, de = vram_offset, de = xy

SECTION "Roledex", ROM0
GetMoveName:: ; a = move number, returns name in name_buffer
  and a
  jr nz, .findName
  ld [name_buffer], a; 0 means no move
  ret

.findName
  dec a
  ld b, a;number
  ld a, [loaded_bank]
  ld [temp_bank], a
  ld a, PLAYER_STRINGS_BANK
  call SetBank

  ld hl, MoveNames
  dec b
.loop
    ld a, b
    and a
    jr z, .copy;found name
    ld a, [hli]
    and a
    jr nz, .loop
    dec b
    jr .loop
.copy
  ld de, name_buffer
  call str_Copy

  ld a, [temp_bank]
  call SetBank
  ret 

GetMove:: ; a = move number, returns move_data
  push bc
  push de
  and a
  jr nz, .loadMove

  ld de, move_data
  ld bc, 8
  xor a
  call mem_Set
  jr .exit

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
  ld bc, 8
  call mem_Copy

  ld a, [temp_bank]
  call SetBank
.exit
  pop de
  pop bc
  ret 

GetPlayerName:: ; a = number, returns name in name_buffer
  ld b, a;number
  ld a, [loaded_bank]
  ld [temp_bank], a
  ld a, PLAYER_STRINGS_BANK
  call SetBank

  ld hl, PlayerNames
  cp 152
  jr nc, .copy ;name outside of range, return Bubbi
  dec b
.loop
    ld a, b
    and a
    jr z, .copy;found name
    ld a, [hli]
    and a
    jr nz, .loop
    dec b
    jr .loop
.copy
  ld de, name_buffer
  call str_Copy

  ld a, [temp_bank]
  call SetBank
  ret

GetPlayerDescription:: ; a = number, returns description in str_buffer
  ld b, a;number
  ld a, [loaded_bank]
  ld [temp_bank], a
  ld a, PLAYER_STRINGS_BANK
  call SetBank

  ld hl, PlayerDescriptions
  cp 152
  jr nc, .copy ;name outside of range, return Bubbi's description
  dec b
.loop
    ld a, b
    and a
    jr z, .copy;found name
    ld a, [hli]
    and a
    jr nz, .loop
    dec b
    jr .loop
.copy
  ld de, str_buffer
  call str_Copy

  ld a, [temp_bank]
  call SetBank
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
  ld bc, PLAYER_BASE_SIZE
  call mem_Copy

  ld a, [temp_bank]
  call SetBank
  ret

PutPlayerTilesInHL: ;A000
  push af
  push bc
  ld hl, $4000
  ld a, [hli]
  ld b, a
  ld a, [hl]
  ld h, a
  ld l, b
  pop bc
  pop af
  ret

PutPlayerTileCountsInHL: ;A002
  push af
  push bc
  ld hl, $4002
  ld a, [hli]
  ld b, a
  ld a, [hl]
  ld h, a
  ld l, b
  pop bc
  pop af
  ret

PutPlayerColumnsInHL: ;A004
  push af
  push bc
  ld hl, $4004
  ld a, [hli]
  ld b, a
  ld a, [hl]
  ld h, a
  ld l, b
  pop bc
  pop af
  ret

PutPlayerTileMapsInHL: ;A006
  push af
  push bc
  ld hl, $4006
  ld a, [hli]
  ld b, a
  ld a, [hl]
  ld h, a
  ld l, b
  pop bc
  pop af
  ret

SwitchPlayerImageBank: ; a = number, return adjusted number in a
  ld b, a ;num
  ld c, 0 ;bank
  ld a, PLAYERS_PER_BANK
.findBankLoop
  push af
  cp b
  jr z, .skip
  jr nc, .setBank ;if num <= PLAYERS_PER_BANK * (c+1)
.skip
  ld a, c
  cp IMG_BANK_COUNT-1
  jr z, .setBank ;if bank == bank_count-1
  inc c
  pop af
  add a, PLAYERS_PER_BANK
  jr .findBankLoop
.setBank
  ld a, [loaded_bank]
  ld [temp_bank], a
  ld a, c
  add a, PLAYER_IMG_BANK
  call SetBank

  pop af 
  ld c, a ;PLAYERS_PER_BANK * (bank+1)
  ld a, b ;num
  sub a, c
  add a, PLAYERS_PER_BANK
  ret

PreLoadPlayerBkgData:
  dec a ;roledex entry 1 = index 0
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
  ld  a,[hl+]
  call ReverseByte
  ld  [de],a
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
  dec a ;roledex entry 1 = index 0
  call SwitchPlayerImageBank
  ld c, a
  xor a
  ld b, a
  call PutPlayerColumnsInHL
  add hl, bc
  ld a, [hl]
  push af ;columns

  ld a, [temp_bank]
  call SetBank
  
  pop af ;columns
  ret ;return a
  
PreSetPlayerBkgTiles:
  dec a ;roledex entry 1 = index 0
  push bc ;xy
  push de ;vram off
  call SwitchPlayerImageBank
  push af ;num
  xor a
  ld b, a
  pop af ;num
  push af
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

ENDC ;ROLEDEX
