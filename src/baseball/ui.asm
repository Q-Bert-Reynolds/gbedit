
DrawPlayerUI: ;a = team
  push af;team
  
  xor a
  ld [_x], a
  ld a, 2
  ld [_y], a;if (team) x = 0, y = 2;

  pop af
  push af;team
  and a
  jr nz, .skip 
  ld a, 8
  ld [_x], a
  ld a, 10
  ld [_y], a ;else x = 8, y = 10;
.skip

  ld a, 1
  ld b, a
  pop af
  push af;team
  ld c, a
  ld a, [home_team]
  cp c
  jr z, .teamIsHome
  xor a
  ld b, a
.teamIsHome
  xor a
  ld [_b], a
  ld a, [frame]
  and a, 1
  cp b
  jr z, .teamIsPitching
  ld a, 1
  ld [_b], a;team is batting
.teamIsPitching ;b = (team == home_team) != (frame % 2);

  xor a
  ld hl, tile_buffer
  ld [hli], a;tiles[0] = 0;
  inc hl

  xor a
  ld [_i], a
.nameBarLoop;for (i = 0; i < 10; i++) 
    ld a, BOX_HORIZONTAL
    ld [hli], a ;tiles[i+2] = BOX_HORIZONTAL;
    ld a, [_i]
    inc a
    ld [_i], a
    cp 10
    jr nz, .nameBarLoop

  pop af;team
  push af
  and a
  jr nz, .setOpponentName
  call GetCurrentUserPlayer
  call GetUserPlayerName
  jr .drawName
.setOpponentName
  call GetCurrentOpponentPlayer
  call GetPlayerNumber
  call GetPlayerName
.drawName
  ld hl, name_buffer
  call str_Length;de = len
  ld a, 12
  sub a, e;(12-len)
  srl a;(12-len)/2
  inc a;1+(12-len)/2
  ld b, d
  ld c, e; bc = len
  ld hl, tile_buffer
  ld d, 0
  ld e, a;de = 1+(12-len)/2
  add hl, de
  ld d, h
  ld e, l;de = tile_buffer+1+(12-len)/2
  ld hl, name_buffer
  call mem_Copy

  pop af;team
  push af
  and a
  jr nz, .setOpponentLevel
  call GetCurrentUserPlayer
  call GetPlayerLevel
  jr .drawLevel
.setOpponentLevel
  call GetCurrentOpponentPlayer
  call GetPlayerLevel
.drawLevel
  push af ;level
  cp 100
  jr nz, .levelNot100;if (p->level == 100) {
    ld hl, tile_buffer+12
    ld a, "1"
    ld [hli], a ;tiles[12] = 49; 
    ld a, "0"
    ld [hli], a ;tiles[13] = 48; 
    ld [hli], a ;tiles[14] = 48;
    pop af ;level
    jr .doneWithLevel
.levelNot100 ;else {
    ld hl, tile_buffer+12
    ld a, LEVEL
    ld [hli], a ;tiles[12] = LEVEL;
    pop af ;level
    push af
    cp 10
    jr nc, .level10Plus ;if (p->level < 10) {
      add a, 48
      ld [hli], a ;tiles[13] = 48+p->level;
      xor a
      ld [hl], a ;tiles[14] = 0;
      jr .doneWithLevel
.level10Plus ;else {
      push hl;tiles
      ld l, a
      xor a
      ld h, a
      ld c, 10
      call math_Divide
      ld b, l ;lv/10
      ld c, a ;lv%10
      pop hl;tiles
      ld a, b
      add a, 48
      ld [hli], a ;tiles[13] = 48+p->level/10;
      ld a, c
      add a, 48
      ld [hl], a ;tiles[14] = 48+p->level%10;
.doneWithLevel
  pop af;level
  ld a, [_b]
  and a
  jr z, .isPitcher ;if (b) {
    ld hl, tile_buffer+1
    ld a, "1";TODO: should be batting order
    ld [hl], a ;tiles[1] = NUMBERS + p->batting_order;
    ld hl, tile_buffer+15
    ld a, BATTING_AVG
    ld [hl], a ;tiles[15] = BATTING_AVG;
    jr .doneWithPlayerStats
.isPitcher ;else {
    ld hl, tile_buffer+1
    ld a, "ℙ"
    ld [hl], a ;tiles[1] = p->position;
    ld hl, tile_buffer+15
    ld a, EARNED_RUN_AVG
    ld [hl], a ;tiles[15] = EARNED_RUN_AVG;
.doneWithPlayerStats

  xor a
  ld hl, tile_buffer+20 ;tiles[20] = 0;
  
  ld a, [_x]
  ld d, a
  ld a, [_y]
  ld e, a
  ld h, 12
  ld l, 2
  ld bc, tile_buffer
  call gbdk_SetBKGTiles;set_bkg_tiles(x,y,12,2,tiles);

  ld a, [_b]
  and a
  jr z, .setERA;if (b) 

  pop af;team
  push af
  ld de, 324
  call BattingAvgToString
  ld a, [_x]
  add a, 4
  ld d, a
  ld a, [_y]
  inc a
  ld e, a
  ld h, 4
  ld l, 1
  ld bc, str_buffer
  call gbdk_SetBKGTiles ;set_bkg_tiles(x+4,y+1,4,1,batting_avg(p));
  jr .setHealthPct

.setERA
  pop af;team
  push af
  ld hl, 902
  call EarnedRunAvgToString
  ld a, [_x]
  add a, 4
  ld d, a
  ld a, [_y]
  inc a
  ld e, a
  ld h, 4
  ld l, 1
  ld bc, str_buffer
  call gbdk_SetBKGTiles ;else set_bkg_tiles(x+4,y+1,4,1,earned_run_avg(p));

.setHealthPct 
  pop af;team
  ld a, 85
  call HealthPctToString
  ld a, [_x]
  add a, 9
  ld d, a
  ld a, [_y]
  inc a
  ld e, a
  ld h, 3
  ld l, 1
  ld bc, str_buffer
  call gbdk_SetBKGTiles;set_bkg_tiles(x+9,y+1,3,1,health_pct(p));
  ret

DrawBases:
  xor a;for (i = 0; i < 5; i+=2) tiles[i] = 0;
  ld hl, tile_buffer
  ld [hl], a
  ld hl, tile_buffer+2
  ld [hl], a
  ld hl, tile_buffer+4
  ld [hl], a

  ld hl, tile_buffer+5 ;tiles[5] = (runners_on_base & FIRST_BASE_MASK) ? OCCUPIED_BASE : EMPTY_BASE;
  ld a, EMPTY_BASE
  ld [hl], a
  ld a, [runners_on_base+1]
  and a, FIRST_BASE_MASK
  and a
  jr z, .notOnFirst
  ld a, OCCUPIED_BASE
  ld [hl], a
.notOnFirst

  ld hl, tile_buffer+1 ;tiles[1] = (runners_on_base & SECOND_BASE_MASK) ? OCCUPIED_BASE : EMPTY_BASE;
  ld a, EMPTY_BASE
  ld [hl], a
  ld a, [runners_on_base+1]
  and a, SECOND_BASE_MASK
  and a
  jr z, .notOnSecond
  ld a, OCCUPIED_BASE
  ld [hl], a
.notOnSecond
  
  ld hl, tile_buffer+3 ;tiles[3] = (runners_on_base & THIRD_BASE_MASK) ? OCCUPIED_BASE : EMPTY_BASE;
  ld a, EMPTY_BASE
  ld [hl], a
  ld a, [runners_on_base]
  and a, THIRD_BASE_MASK >> 8
  and a
  jr z, .notOnThird
  ld a, OCCUPIED_BASE
  ld [hl], a
.notOnThird

  ld d, 9;x
  ld e, 0;y
  ld h, 3;w
  ld l, 2;h
  ld bc, tile_buffer
  call gbdk_SetBKGTiles;set_bkg_tiles(9,0,3,2,tiles);
  ret

DrawCountOutsInning:
  ld hl, tile_buffer
  ld [hl], INNING_BOTTOM
  ld a, [frame]
  bit 0, a
  jr nz, .skip ;tiles[0] = (frame % 2 == 0) ? INNING_TOP : INNING_BOTTOM;
  ld [hl], INNING_TOP
.skip
  inc hl
  ld d, h
  ld e, l
  srl a;frame/2
  inc a
  ld l, a
  xor a
  ld h, a
  call str_Number;tiles[1] = 49 + frame/2;

  ld hl, tile_buffer
  call str_Length
  ld h, e;w
  ld l, 1;h
  ld d, 1;x
  ld e, 13;y
  ld bc, tile_buffer
  call gbdk_SetBKGTiles;set_bkg_tiles(1,13,len,1,tiles);

  ld hl, tile_buffer
  ld a, "B"
  ld [hli], a
  ld a, "S"
  ld [hli], a
  ld a, "O"
  ld [hl], a
  ld h, 1;w
  ld l, 3;h
  ld d, 1;x
  ld e, 14;y
  ld bc, tile_buffer
  call gbdk_SetBKGTiles;set_bkg_tiles(1,14,1,3,"BSO");

  ld hl, tile_buffer
  xor a
  ld [_i], a
.setBallsLoop ;for (i = 0; i < 4; i++) tiles[0+i] = (i < balls()  ) ? BASEBALL : DOTTED_CIRCLE;
    ld a, DOTTED_CIRCLE
    ld [hl], a
    call Balls
    ld b, a
    ld a, [_i]
    cp b
    jr nc, .skipBall
    ld a, BASEBALL
    ld [hl], a
.skipBall
    ld a, [_i]
    inc a
    inc hl
    ld [_i], a
    cp 4
    jr nz, .setBallsLoop

  xor a
  ld [_i], a
.setStrikesLoop ;for (i = 0; i < 3; i++) tiles[4+i] = (i < strikes()) ? BASEBALL : DOTTED_CIRCLE;
    ld a, DOTTED_CIRCLE
    ld [hl], a
    call Strikes
    ld b, a
    ld a, [_i]
    cp b
    jr nc, .skipStrike
    ld a, BASEBALL
    ld [hl], a
.skipStrike
    ld a, [_i]
    inc a
    inc hl
    ld [_i], a
    cp 3
    jr nz, .setStrikesLoop
  
  xor a
  ld [hli], a;tiles[7] = 0;

  xor a
  ld [_i], a
.setOutsLoop ;for (i = 0; i < 3; i++) tiles[8+i] = (i < outs()   ) ? BASEBALL : DOTTED_CIRCLE;
    ld a, DOTTED_CIRCLE
    ld [hl], a
    call Outs
    ld b, a
    ld a, [_i]
    cp b
    jr nc, .skipOut
    ld a, BASEBALL
    ld [hl], a
.skipOut
    ld a, [_i]
    inc a
    inc hl
    ld [_i], a
    cp 3
    jr nz, .setOutsLoop

  xor a
  ld [hl], a;tiles[11] = 0;

  ld d, 2;x
  ld e, 14;y
  ld h, 4;w
  ld l, 3;h
  ld bc, tile_buffer
  call gbdk_SetBKGTiles;set_bkg_tiles(2,14,4,3,tiles);
  ret

DrawTeamNames:
  di
  ENABLE_RAM_MBC5

  ld hl, user_name
  ld de, name_buffer
  ld bc, 8
  call mem_Copy;memcpy(name_buff, user_name, 8);
  
  ld hl, name_buffer
  call str_Length;l = strlen(name_buff);
  ld h, e ;w
  ld l, 1
  ld de, 0;x = y = 0
  ld a, [home_team]
  and a
  jr z, .setPlayerAway
  ld de, 1;x = 0, y = 1  
.setPlayerAway
  ld bc, name_buffer
  call gbdk_SetBKGTiles;set_bkg_tiles(0,y,7,1,name_buff);

  ld hl, rival_name
  ld de, name_buffer
  ld bc, 8
  call mem_Copy;memcpy(name_buff, rival_name, 8);

  ld hl, name_buffer
  call str_Length;l = strlen(name_buff);
  ld h, e ;w
  ld l, 1
  ld de, 0;x = y = 0
  ld a, [home_team]
  and a
  jr nz, .setOpponentAway
  ld de, 1;x = 0, y = 1  
.setOpponentAway
  ld bc, name_buffer
  call gbdk_SetBKGTiles;set_bkg_tiles(0,1,7,1,name_buff);

  DISABLE_RAM_MBC5
  ei
  ret

DrawScore:
  xor a
  ld h, a
  ld a, [home_score]
  ld l, a
  ld de, name_buffer
  call str_Number;sprintf(name_buff, "%d", home_score);

  ld hl, name_buffer
  call str_Length;l = strlen(name_buff);
  ld h, e ;w
  ld l, 1 ;h
  ld d, 8 ;x
  ld e, 0 ;y
  ld bc, name_buffer
  call gbdk_SetBKGTiles ;set_bkg_tiles(9,0,l,1,name_buff);
  
  xor a
  ld h, a
  ld a, [away_score]
  ld l, a
  ld de, name_buffer
  call str_Number;sprintf(name_buff, "%d", away_score);

  ld hl, name_buffer
  call str_Length;l = strlen(name_buff);

  ld h, e ;w
  ld l, 1 ;h
  ld d, 8 ;x
  ld e, 1 ;y
  ld bc, name_buffer
  call gbdk_SetBKGTiles ;set_bkg_tiles(9,1,l,1,name_buff);
  ret

DrawUI:
  call DrawTeamNames
  call DrawScore
  call DrawBases

  xor a
  call DrawPlayerUI ;0
  ld a, 1
  call DrawPlayerUI ;1

  ld b, 0
  ld c, 12
  ld d, 20
  ld e, 6
  call DrawBKGUIBox ;draw_bkg_ui_box(0,12,20,6);

  call DrawCountOutsInning

  ld d, 9
  ld e, 14
  ld h, 10
  ld l, 3
  ld bc, PlayMenuString
  call gbdk_SetBKGTiles;set_bkg_tiles(9,14,10,3,

  DISPLAY_ON
  ret 

MovePlayMenuArrow:
  xor a
  ld [_i], a
.columnLoop ;for (i = 0; i < 2; i++) {
    xor a
    ld [_j], a
.rowLoop ;for (j = 0; j < 2; j++) {
      ld hl, tile_buffer
      xor a
      ld [hl], a
      ld a, [_x]
      ld b, a
      ld a, [_i]
      cp b
      jr nz, .notArrow
      ld a, [_y]
      ld b, a
      ld a, [_j]
      cp b
      jr nz, .notArrow
      ld a, ARROW_RIGHT
      ld [hl], a
.notArrow ;tiles[0] = (x==i && y==j) ? ARROW_RIGHT : 0;
      ld a, [_i]
      add a, a;i*2
      add a, a;i*4
      ld b, a
      ld a, [_i]
      add a, a;i*2
      add a, b;i*6
      add a, 8;i*6+8
      ld d, a ;x
      ld a, [_j]
      add a, a;j*2
      add a, 14;j*2+14
      ld e, a;y
      ld a, 1
      ld h, a
      ld l, a
      ld bc, tile_buffer
      call gbdk_SetBKGTiles;set_bkg_tiles(i*6+8,j*2+14,1,1,tiles);

      ld a, [_j]
      inc a
      ld [_j], a
      cp 2
      jr nz, .rowLoop
    ld a, [_i]
    inc a
    ld [_i], a
    cp 2
    jr nz, .columnLoop
  ret

SelectPlayMenuItem:
  ld a, [play_menu_selection]
  and 1
  ld [_x], a ;x = play_menu_selection % 2;

  ld a, [play_menu_selection]
  and 2
  srl a 
  ld [_y], a ;y = (play_menu_selection & 2) >> 1;

  call MovePlayMenuArrow
  WAITPAD_UP
.moveMenuArrowLoop ;while (1) {
    call UpdateInput ;k = joypad();
.testUpPressed ;if (k & J_UP && y == 1) { y = 0; move_play_menu_arrow(); }
    ld a, [button_state]
    and a, PADF_UP
    jr z, .testDownPressed
    ld a, [_y]
    cp 1
    jr nz, .testDownPressed
    xor a
    ld [_y], a
    jr .moveArrow
.testDownPressed ;else if (k & J_DOWN && y == 0) { y = 1; move_play_menu_arrow(); }
    ld a, [button_state]
    and a, PADF_DOWN
    jr z, .testLeftPressed
    ld a, [_y]
    and a
    jr nz, .testLeftPressed
    ld a, 1
    ld [_y], a
    jr .moveArrow    
.testLeftPressed ;else if (k & J_LEFT && x == 1) { x = 0; move_play_menu_arrow(); }
    ld a, [button_state]
    and a, PADF_LEFT
    jr z, .testRightPressed
    ld a, [_x]
    cp 1
    jr nz, .testRightPressed
    xor a
    ld [_x], a
    jr .moveArrow
.testRightPressed ;else if (k & J_RIGHT && x == 0) { x = 1; move_play_menu_arrow(); }
    ld a, [button_state]
    and a, PADF_RIGHT
    jr z, .testAPressed
    ld a, [_x]
    xor a
    jr nz, .testAPressed
    ld a, 1
    ld [_x], a
.moveArrow
    call MovePlayMenuArrow
    
.testAPressed ;if (k & J_A) break;
    ld a, [button_state]
    and a, PADF_A
    jr nz, .exitMoveMenuArrowLoop
    call gbdk_WaitVBL
    jr .moveMenuArrowLoop
.exitMoveMenuArrowLoop
  ld a, [_y]
  add a, a ;y*2
  ld b, a
  ld a, [_x];y*2+x
  add a, b 
  ld [play_menu_selection], a
  ret

MoveMoveMenuArrow:; y
  xor a
  ld [_i], a
  ld hl, tile_buffer
.setTilesLoop ;for (i = 0; i < 4; i++) {
    ld a, [_i]
    ld b, a
    ld a, [_y]
    ld a, ARROW_RIGHT
    cp b
    jr z, .setTile
    xor a
.setTile
    ld [hli], a;tiles[i] = (i == y) ? ARROW_RIGHT : 0;
    ld a, [_i]
    inc a
    ld [_i], a
    cp 4
    jr nz, .setTilesLoop

  ld d, 6
  ld e, 13
  ld h, 1
  ld l, 4
  ld bc, tile_buffer
  call gbdk_SetBKGTiles;set_bkg_tiles(6,13,1,4,tiles);
  ret

ShowMoveInfo:
  ld b, 0
  ld c, 8
  ld d, 11
  ld e, 5
  call DrawBKGUIBox;draw_bkg_ui_box(0,8,11,5);

  ld d, 1
  ld e, 9
  ld h, 5
  ld l, 1
  ld bc, TypeSlashText
  call gbdk_SetBKGTiles;set_bkg_tiles(1,9,5,1,"TYPE/");

  ; call GetPlayerMove
  ; push hl ;move

  ld a, [hl]
  call GetTypeString

  ld hl, name_buffer
  call str_Length
  ld h, e
  ld l, 1
  ld d, 2
  ld e, 10
  ld bc, name_buffer
  call gbdk_SetBKGTiles;set_bkg_tiles(2,10,strlen(name_buff),1,name_buff);
  
  ld d, 5
  ld e, 11
  ld h, 5
  ld l, 1
  ; ld bc, "22/35"
  call gbdk_SetBKGTiles;set_bkg_tiles(5,11,5,1,"22/35"); //TODO: use real numbers
  ret

SelectMoveMenuItem: ;returns selection in a, input = Player *p // input should be move struct
  ld d, 0
  ld e, 8
  ld h, 20
  ld l, 10
  ld bc, bkg_buffer
  call gbdk_GetBkgTiles;get_bkg_tiles(0,8,20,10,bkg_buff);

  ld b, 5
  ld c, 12
  ld d, 15
  ld e, 6
  call DrawBKGUIBox;draw_bkg_ui_box(5,12,15,6);

  ld a, 4
  ld [_c], a

.drawMoveNames
  xor a
  ld [_i], a
  call GetCurrentUserPlayer
  push hl
.loopMoves
    pop hl;player
    push hl
    ld a, [_i]
    call GetPlayerMoveName

    ld hl, name_buffer
    call str_Length

    ld h, e
    ld l, 1
    ld d, 7
    ld a, [_i]
    add a, 13
    ld e, a
    
    ld bc, name_buffer
    call gbdk_SetBKGTiles

    ld a, [_i]
    inc a
    ld [_i], a
    cp 4
    jr nz, .loopMoves
  pop hl;player

  call MoveMoveMenuArrow
  call ShowMoveInfo

  WAITPAD_UP;update_waitpadup();
.loop ;while (1) {
    call gbdk_WaitVBL
    call UpdateInput;  k = joypad();
.checkButtonUp;  if (k & J_UP && move_choice > 0) {
    ld a, [button_state]
    and PADF_UP
    jr z, .checkButtonDown
    ld a, [move_choice]
    and a
    jr z, .checkButtonDown
    dec a ;--move_choice;
    ld [move_choice], a
    call MoveMoveMenuArrow
    call ShowMoveInfo
    WAITPAD_UP
    jp .loop

.checkButtonDown;  else if (k & J_DOWN && move_choice < c-1) {
    ld a, [button_state]
    and PADF_DOWN
    jr z, .checkButtonStartA
    ld a, [_c]
    dec a
    ld c, a
    ld a, [move_choice]
    cp c
    jr nc, .checkButtonStartA
    inc a ;++move_choice;
    ld [move_choice], a
    call MoveMoveMenuArrow
    call ShowMoveInfo
    WAITPAD_UP
    jp .loop

.checkButtonStartA;  if (k & (J_START | J_A)) {
    ld a, [button_state]
    and PADF_START | PADF_A
    jp z, .checkButtonB
    jr .exit

.checkButtonB;  else if (k & J_B) break;
    ld a, [button_state]
    and PADF_B
    jp z, .loop
    ld a, -1
    ld [move_choice], a

.exit
  call gbdk_WaitVBL
  ld d, 0
  ld e, 8
  ld h, 20
  ld l, 10
  ld bc, bkg_buffer
  call gbdk_SetBKGTiles;set_bkg_tiles(0,8,20,10,bkg_buff);

  ld a, [move_choice]
  inc a
  ret
