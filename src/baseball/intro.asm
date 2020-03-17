
PlayIntro:
  ld de, $8800;_VRAM+$1000+_UI_FONT_TILE_COUNT*16
  ld bc, _CALVIN_BACK_TILE_COUNT
  ld hl, _CalvinBackTiles
  call SetBkgDataDoubled

  call GetCurrentOpponentPlayer
  call GetPlayerNumber
  ld de, _UI_FONT_TILE_COUNT+64
  call LoadPlayerBkgData

  call ShowPlayBallWindow

  xor a
  ld [_j], a
  ld bc, 0
.rowLoop; for (j = 0; j < 3; ++j)
    xor a
    ld [_i], a
.columnLoop; for (i = 0; i < _CALVIN_BACK_COLUMNS-1; ++i)

      ld de, _CALVIN_BACK_COLUMNS-1
      ld a, [_j]
      call math_Multiply
      ld b, 0
      ld a, [_i]
      ld c, a
      add hl, bc;j*(_CALVIN_BACK_COLUMNS-1)+i
      ld c, l

      ld d, 0
      ld a, [_j]
      ld e, a
      add hl, de;j*_CALVIN_BACK_COLUMNS+i
      ld de, _CalvinBackTileMap
      add hl, de;_calvin_back_map[j*_CALVIN_BACK_COLUMNS+i]
      ld a, [hl]
      add a, _UI_FONT_TILE_COUNT;_calvin_back_map[j*_CALVIN_BACK_COLUMNS+i]+_UI_FONT_TILE_COUNT
      ld d, a
      call gbdk_SetSpriteTile
      
      ld a, [_i]
      inc a
      ld [_i], a
      cp _CALVIN_BACK_COLUMNS-1
      jr nz, .columnLoop

    ld a, [_j]
    inc a
    ld [_j], a
    cp 3
    jr nz, .rowLoop

  ld d, 1
  ld e, 16-_CALVIN_BACK_ROWS
  ld h, _CALVIN_BACK_COLUMNS
  ld l, _CALVIN_BACK_ROWS-4
  ld bc, _CalvinBackTileMap + 3*_CALVIN_BACK_COLUMNS
  ld a, _UI_FONT_TILE_COUNT
  call SetBKGTilesWithOffset

  call GetCurrentOpponentPlayer
  call GetPlayerNumber
  call GetPlayerImgColumns
  ld c, a

  ld a, 19
  sub a, c
  ld b, a;x
  ld a, 7
  sub a, c
  ld c, a;y
  ld de, _UI_FONT_TILE_COUNT+64
  
  call GetCurrentOpponentPlayer
  call GetPlayerNumber
  call SetPlayerBkgTiles

  ld a, 160
  ld [rSCX], a
  xor a
  ld [rSCY], a
  ld [rVBK], a

  SET_LCD_INTERRUPT SlideInLCDInterrupt
  DISPLAY_ON

  ld a, 160
  ld [_x], a
.slideInLoop; for (x = 160; x >= 0; x-=2)
    call gbdk_WaitVBL
    ld a, [_x]
    sub a, 2
    ld [_x], a
    and a
    jr nz, .slideInLoop
  call gbdk_WaitVBL
  xor a
  ld [_x], a
  call gbdk_WaitVBL
  DISABLE_LCD_INTERRUPT

  call GetCurrentOpponentPlayer
  call GetPlayerNumber
  call GetPlayerName
  ld hl, UnsignedPlayerAppearedText
  ld de, str_buffer
  ld bc, name_buffer
  call str_Replace
  ld hl, str_buffer
  call RevealTextAndWait ;reveal_text(str_buff, PLAY_BALL_BANK);

  SET_LCD_INTERRUPT SlideOutLCDInterrupt

  xor a
  ld [_x], a
.slideOutLoop; for (x = 0; x > -80; x-=2)
    call gbdk_WaitVBL
    ld a, [_x]
    sub a, 2
    ld [_x], a
    cp -80
    jr nz, .slideOutLoop

  CLEAR_BKG_AREA 1, 16-_CALVIN_BACK_ROWS, _CALVIN_BACK_COLUMNS, _CALVIN_BACK_ROWS-4, " "
  DISABLE_LCD_INTERRUPT

  ld hl, _RightyBatterUserTiles
  ld de, $8800;_VRAM+$1000+_UI_FONT_TILE_COUNT*16
  ld bc, _RIGHTY_BATTER_USER_TILE_COUNT*16
  call mem_CopyVRAM

  ld de, 5
  ld h, _RIGHTY_BATTER_USER0_COLUMNS
  ld l, _RIGHTY_BATTER_USER0_ROWS
  ld bc, _RightyBatterUser0TileMap
  ld a, _UI_FONT_TILE_COUNT
  call SetBKGTilesWithOffset

  HIDE_ALL_SPRITES
  call gbdk_WaitVBL
  xor a
  ld [rSCX], a
  ld [rSCY], a

  ld hl, LetsGoText
  call RevealTextAndWait
  HIDE_WIN
  ret
