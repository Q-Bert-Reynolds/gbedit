IF !DEF(ROLEDEX)
ROLEDEX SET 1

IMG_BANK_COUNT EQU 6
PLAYERS_PER_BANK = 151 / IMG_BANK_COUNT

INCLUDE "data/player_img.asm"
INCLUDE "data/player_data.asm"
INCLUDE "data/player_strings.asm"

; GetPlayerName - a = number, returns name_buffer
; GetPlayerDescription - a = number, returns str_buffer
; LoadPlayerBaseData - a = number
; LoadPlayerBkgData - a = number, de = vram_offset
; GetPlayerImgColumns - a = number, returns num columns of img in a
; SetPlayerBkgTiles - a = number, de = vram_offset, de = xy

SECTION "Roledex", ROM0
GetPlayerName:: ; a = number, returns name in name_buffer
  ld a, [loaded_bank]
  ld [temp_bank], a
  ld a, PLAYER_STRINGS_BANK
  call SetBank

  ; strcpy(name_buff, player_strings[number]);

  ld a, [temp_bank]
  call SetBank
  ret

GetPlayerDescription:: ; a = number, returns description in str_buffer
  ld a, [loaded_bank]
  ld [temp_bank], a
  ld a, PLAYER_STRINGS_BANK
  call SetBank

  ; strcpy(str_buff, (player_strings[number]+11));

  ld a, [temp_bank]
  call SetBank
  ret 

LoadPlayerBaseData:: ; a = number
  ld a, [loaded_bank]
  ld [temp_bank], a
  ld a, PLAYER_STRINGS_BANK
  call SetBank

  ; load_base_data(number);

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
  jr nc, .setBank ;if num <= PLAYERS_PER_BANK * (c+1)
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

LoadPlayerBkgData:: ; a = number, de = vram_offset
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
  call mem_CopyToTileData
  
  ld a, [temp_bank]
  call SetBank
  ret 
  
GetPlayerImgColumns:: ; a = number, returns num columns of img in a
  dec a ;roledex entry 1 = index 0
  call SwitchPlayerImageBank
  push af ;num
  xor a
  ld b, a
  pop af ;num
  ld c, a
  call PutPlayerColumnsInHL
  add hl, bc
  ld a, [hl]
  push af ;columns

  ld a, [temp_bank]
  call SetBank
  
  pop af ;columns
  ret ;return a
  
SetPlayerBkgTiles:: ; a = number, bc = xy, de = vram_offset
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
  call SetBKGTilesWithOffset

  ld a, [temp_bank]
  call SetBank
  ret


ENDC ;ROLEDEX