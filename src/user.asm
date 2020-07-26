SECTION "User Info Bank 0", ROM0
ShowUserInfo::
  ld a, USER_BANK
  call SetBank

  call _ShowUserInfo

  ld a, OVERWORLD_BANK
  call SetBank
  ret

SECTION "User Info Bank X", ROMX, BANK[ITEM_BANK]

INCLUDE "img/user_info.asm"

NameText:  DB "NAME/",0 
MoneyText: DB "MONEY/$",0
TimeText:  DB "TIME/"
PennantsText: DB "⚾︎PENNANTS⚾︎"

_ShowUserInfo:
  DISPLAY_OFF

  ld hl, _UserInfoTiles
  ld de, $8800;_VRAM+$1000+_UI_FONT_TILE_COUNT*16
  ld bc, _USER_INFO_TILE_COUNT*16
  call mem_CopyVRAM

  ld h, 20
  ld l, 18
  ld de, 0
  ld bc, _UserInfoTileMap
  ld a, _UI_FONT_TILE_COUNT
  call SetWinTilesWithOffset

.drawPennantsText
  ld bc, PennantsText
  ld hl, $0A01
  ld de, $0509
  ld a, DRAW_FLAGS_WIN
  call SetTiles

.drawUserName
  ld hl, NameText
  ld de, str_buffer
  call str_Copy

  ld hl, user_name
  ld de, str_buffer  
  call str_Append

  ld hl, str_buffer
  call str_Length

  ld bc, str_buffer
  ld h, e
  ld l, 1
  ld de, $0202
  ld a, DRAW_FLAGS_WIN
  call SetTiles

.drawMoney
  ld hl, MoneyText
  ld de, str_buffer
  call str_Copy

  ld a, [money]
  ld e, a
  ld a, [money+1]
  ld h, a
  ld a, [money+2]
  ld l, a
  ld bc, name_buffer
  call str_Number24

  ld hl, name_buffer
  ld de, str_buffer  
  call str_Append

  ld hl, str_buffer
  call str_Length

  ld bc, str_buffer
  ld h, e
  ld l, 1
  ld de, $0204
  ld a, DRAW_FLAGS_WIN
  call SetTiles

.drawTime
  ld bc, TimeText
  ld hl, $0501
  ld de, $0206
  ld a, DRAW_FLAGS_WIN
  call SetTiles

  call GetTimePlayedString

  ld hl, str_buffer
  call str_Length

  ld h, e
  ld l, 1
  ld bc, str_buffer
  ld de, $0706
  ld a, DRAW_FLAGS_WIN
  call SetTiles

.show
  HIDE_SPRITES
  ld a, 7
  ld [rWX], a
  xor a
  ld [rWY], a
  SHOW_WIN
  DISPLAY_ON

.loop
    UPDATE_INPUT_AND_JUMP_TO_IF_BUTTONS .exit, (PADF_START | PADF_A | PADF_B)
    call gbdk_WaitVBL
    jr .loop
    
.exit
  HIDE_WIN
  SHOW_SPRITES
  ret

GetTimePlayedString::;puts time in [str_buffer] in HHH:MM format
  ld a, [hours]
  ld h, a 
  ld a, [hours+1]
  ld l, a
  ld de, str_buffer
  call str_Number

  ld hl, name_buffer
  ld a, ":"
  ld [hli], a
  xor a
  ld [hld], a
  ld de, str_buffer
  call str_Append

  ld de, name_buffer
  ld h, 0
  ld a, [minutes]
  ld l, a
  cp a, 10
  jr nc, .skipTensDigit
  ld a, "0"
  ld [de], a
  inc de
.skipTensDigit
  call str_Number

  ld hl, name_buffer
  ld de, str_buffer
  call str_Append
  ret 