SECTION "User Info Bank 0", ROM0
ShowUserInfo::
  ld a, USER_BANK
  call SetBank

  call _ShowUserInfo

  ld a, OVERWORLD_BANK
  call SetBank
  ret

SECTION "User Info Bank X", ROMX, BANK[ITEM_BANK]
_ShowUserInfo:
  HIDE_SPRITES
  CLEAR_WIN_AREA 0,0,20,18,0
  ld a, 7
  ld [rWX], a
  xor a
  ld [rWY], a

  ld bc, 0
  ld d, 20
  ld e, 8
  ld a, DRAW_FLAGS_WIN
  call DrawUIBox
  SHOW_WIN
.loop
  UPDATE_INPUT_AND_JUMP_TO_IF_BUTTONS .exit, (PADF_START | PADF_A | PADF_B)
  call gbdk_WaitVBL
  jr .loop
.exit
  HIDE_WIN
  SHOW_SPRITES
  ret