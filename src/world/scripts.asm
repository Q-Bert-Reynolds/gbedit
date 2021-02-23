HouseText: DB "%s'S\nHOUSE",0
YourHouseSign:
  ld bc, user_name
  jr ShowHouseSignText

RivalHouseSign:
  ld bc, rival_name

ShowHouseSignText:
  ld hl, HouseText
  ld de, str_buffer
  call str_Replace
  ld hl, str_buffer
  call RevealTextAndWait
  HIDE_WIN
  WAITPAD_UP
  ret