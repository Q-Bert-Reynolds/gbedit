
PlayIntro:
  ld de, $8800;_VRAM+$1000+_UI_FONT_TILE_COUNT*16
  ld bc, _CALVIN_BACK_TILE_COUNT
  ld hl, _CalvinBackTiles
  call SetBkgDataDoubled ;set_bkg_data_doubled(_UI_FONT_TILE_COUNT, _CALVIN_BACK_TILE_COUNT, _calvin_back_tiles); 

  ld a, 80
  ld de, _UI_FONT_TILE_COUNT+64
  call LoadPlayerBkgData ;load_player_bkg_data(80, _UI_FONT_TILE_COUNT+64, PLAY_BALL_BANK);

  ld bc, 0
  ld d, 20
  ld e, 6
  call DrawWinUIBox ;draw_win_ui_box(0,0,20,6);

  ld a, 7
  ld [rWX], a
  ld a, 96
  ld [rWY], a;move_win(7,96);
  SHOW_WIN

  xor a
  ld [_j], a
  ld bc, 0
.rowLoop; for (j = 0; j < 3; ++j) {
    xor a
    ld [_i], a
.columnLoop; for (i = 0; i < _CALVIN_BACK_COLUMNS-1; ++i) {

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
      cp 3
      jr nz, .columnLoop

    ld a, [_j]
    inc a
    ld [_j], a
    cp _CALVIN_BACK_ROWS-1
    jr nz, .rowLoop

  ld d, 1
  ld e, 16-_CALVIN_BACK_ROWS
  ld h, _CALVIN_BACK_COLUMNS
  ld l, _CALVIN_BACK_ROWS-4
  ld bc, _CalvinBackTileMap + 3*_CALVIN_BACK_COLUMNS
  ld a, _UI_FONT_TILE_COUNT
  call SetBKGTilesWithOffset

  ld a, 80
  call GetPlayerImgColumns;c = get_player_img_columns(80, PLAY_BALL_BANK);
  ld c, a

  ld a, 19
  sub a, c
  ld b, a;x
  ld a, 7
  sub a, c
  ld c, a;y
  ld a, 80
  ld de, _UI_FONT_TILE_COUNT+64
  call SetPlayerBkgTiles ;set_player_bkg_tiles(19-c, 7-c, 80, _UI_FONT_TILE_COUNT+64, PLAY_BALL_BANK);

  ld a, 160
  ld [rSCX], a
  xor a
  ld [rSCY], a ;move_bkg(160,0);
  ld [rVBK], a ;VBK_REG = 0;

  SET_LCD_INTERRUPT SlideInLCDInterrupt
  DISPLAY_ON

  ld a, 160
  ld [_x], a
.slideInLoop; for (x = 160; x >= 0; x-=2) {
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

  ld hl, UnsignedPlayerAppearedText
  ld de, str_buffer
  ld bc, TEMP_OPPONENT_NAME
  call str_Replace; sprintf(str_buff, "Unsigned %s\nappeared!", "LAGGARD");
  ld hl, str_buffer
  call RevealText ;reveal_text(str_buff, PLAY_BALL_BANK);

  SET_LCD_INTERRUPT SlideOutLCDInterrupt

  xor a
  ld [_x], a
.slideOutLoop; for (x = 0; x > -80; x-=2) {
    call gbdk_WaitVBL
    ld a, [_x]
    sub a, 2
    ld [_x], a
    cp -80
    jr nz, .slideOutLoop
  DISABLE_LCD_INTERRUPT

  CLEAR_BKG_AREA 1, 16-_CALVIN_BACK_ROWS, _CALVIN_BACK_COLUMNS, _CALVIN_BACK_ROWS-4, " "

  ld hl, _RightyBatterUserTiles
  ld de, $8800;_VRAM+$1000+_UI_FONT_TILE_COUNT*16
  ld bc, _RIGHTY_BATTER_USER_TILE_COUNT*16
  call mem_CopyVRAM ;set_bkg_data(_UI_FONT_TILE_COUNT, _RIGHTY_BATTER_USER_TILE_COUNT, _righty_batter_user_tiles); 

  ld de, 5 ;x = 0, y = 5
  ld h, _RIGHTY_BATTER_USER0_COLUMNS
  ld l, _RIGHTY_BATTER_USER0_ROWS
  ld bc, _RightyBatterUser0TileMap
  ld a, _UI_FONT_TILE_COUNT
  call SetBKGTilesWithOffset;set_bkg_tiles_with_offset(0,5,_RIGHTY_BATTER_USER0_COLUMNS,_RIGHTY_BATTER_USER0_ROWS,_UI_FONT_TILE_COUNT,_righty_batter_user0_map);

  HIDE_ALL_SPRITES
  call gbdk_WaitVBL
  xor a
  ld [rSCX], a
  ld [rSCY], a ;move_bkg(0,0);

  ld hl, LetsGoText
  call RevealText ;reveal_text("Let's go!", PLAY_BALL_BANK);
  HIDE_WIN
  ret
