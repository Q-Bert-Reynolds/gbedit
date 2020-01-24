IF !DEF(ROLEDEX)
ROLEDEX SET 1

IMG_BANK_COUNT      EQU 9
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
  SWITCH_ROM_MBC5 PLAYER_STRINGS_BANK
  ; strcpy(name_buff, player_strings[number]);
  RETURN_BANK
  ret

GetPlayerDescription:: ; a = number, returns description in str_buffer
  SWITCH_ROM_MBC5 PLAYER_STRINGS_BANK
  ; strcpy(str_buff, (player_strings[number]+11));
  RETURN_BANK
  ret 

LoadPlayerBaseData:: ; a = number
  SWITCH_ROM_MBC5 PLAYER_DATA_BANK
  ; load_base_data(number);
  RETURN_BANK
  ret

LoadPlayerBkgData:: ; a = number, de = vram_offset
  push af ;a = num

  ld a, 16
  call Multiply ;returns 
  ld de, _VRAM+$1000
  add hl, de ;_VRAM+$1000+vram_offset*16
  ld d, h
  ld e, l

  SWITCH_ROM_MBC5 PLAYER_IMG_BANK
  pop af ;a = num
  ld hl, _001BubbiTiles
  ld bc, _001BUBBI_TILE_COUNT*16
  call mem_CopyToTileData
  RETURN_BANK
  ret 
  
GetPlayerImgColumns:: ; a = number, returns num columns of img in a
  push af ;num
  SWITCH_ROM_MBC5 PLAYER_IMG_BANK
  pop af ;num
  ld a, 5
  push af ;columns
  RETURN_BANK
  pop af ;columns
  ret ;return a
  
SetPlayerBkgTiles:: ; a = number, bc = xy, de = vram_offset
  dec a ;roledex entry 1 = index 0
  push bc ;xy
  push de ;vram off
  push af ;num
  SWITCH_ROM_MBC5 PLAYER_IMG_BANK
  ; xor a
  ; ld b, a
  ; pop af ;num
  ; push af
  ; ld c, a
  ; ld hl, PlayerTileMaps0
  ; add hl, bc
  ; add hl, bc ;address offset is 2 bytes
  ; ld a, [hli]
  ; ld b, a
  ; ld a, [hl]
  ; ld l, a
  ; ld h, b ;tile map
  ld hl, _001BubbiTileMap

  xor a
  ld b, a
  pop af ;num
  push hl ;tile map
  ld c, a
  ld hl, PlayerColumns0
  add hl, bc
  pop bc ;tile map
  ld a, [hl]
  ld h, a ;w = columns
  ld l, a ;h = rows = columns
  pop de ;vram_offset
  ld a, e 
  pop de ;xy
  call SetBKGTilesWithOffset

  RETURN_BANK
  ret


ENDC ;ROLEDEX
