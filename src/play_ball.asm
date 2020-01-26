INCLUDE "src/beisbol.inc"

SECTION "Play Ball", ROMX, BANK[PLAY_BALL_BANK]

INCLUDE "img/baseball.asm"
INCLUDE "img/circle.asm"
INCLUDE "img/strike_zone.asm"
INCLUDE "img/play/righty_batter_user/righty_batter_user.asm"
INCLUDE "img/play/righty_pitcher_opponent/righty_pitcher_opponent.asm"
INCLUDE "img/coaches/calvin_back.asm"

PlayMenuString:
  DB "PLAY  TEAM"
  DB "          "
  DB "ITEM  RUN "
TypeSlashText:
  DB "TYPE/", 0
QuittingIsNotAnOptionText:
  DB "Quitting is\nnot an option!", 0

; Player test_player;
; Move move1;
; Move move2;
; Move *moves[4];

; UBYTE balls   () { return (balls_strikes_outs & BALLS_MASK  ) >> 4; }
; UBYTE strikes () { return (balls_strikes_outs & STRIKES_MASK) >> 2; }
; UBYTE outs    () { return (balls_strikes_outs & OUTS_MASK   ); }

MoveCoach:
; LYC_REG = 0;
; SCX_REG = 256-x;
; for (j = 0; j < 3; ++j) {
;     for (i = 0; i < _CALVIN_BACK_COLUMNS-1; ++i) {
;         move_sprite(j*(_CALVIN_BACK_COLUMNS-1)+i, i*8+x+16, j*8+56);
  ret

SlideInLCDInterrupt::
; if (LY_REG == 0){
;     LYC_REG = 56;
;     SCX_REG = x;
; else if (LY_REG == 56) move_coach();
  ret

SlideOutLCDInterrupt::
; if (LY_REG == 0){
;     LYC_REG = 56;
;     SCX_REG = 0;
; else if (LY_REG == 56) move_coach();
  ret

HealthPct: ;input Player *p, returns str_buff
; a = p->hp; // * 100 / max_hp; 
; if (a >= 100) strcpy(str_buff, "100");
; if (a < 10) sprintf(str_buff, "0%d%c", a, '%');
; else sprintf(str_buff, "%d%c", a, '%');
; return str_buff;
  ret

BattingAvg: ;input Player *p, returns str_buff
;     a = p->hits * 1000 / p->at_bats;
;     if (a >= 1000) strcpy(str_buff, "1.000");
;     else if (a < 10) sprintf(str_buff, ".00%d", a);
;     else if (a < 100) sprintf(str_buff, ".0%d", a);
;     else sprintf(str_buff, ".%d", a);
;     return str_buff;
  ret

EarnedRunAvg: ;input Player *p, returns str_buff
;     a = p->runs_allowed * 2700 / p->outs_recorded;
;     b = a/100;
;     c = a%100;
;     if (b >= 1000) sprintf(str_buff, "%d", b);
;     else sprintf(str_buff, "%d.%d", b, c);
;     return str_buff;
  ret

; // TODO: this can probably be cleaned up a bit
SetBkgDataDoubled: ;de = first_tile, bc = nb_tiles, hl = data
;     for (i = 0; i < nb_tiles*16; i+=16) {
;         for (j = 0; j < 8; j+=2) {
;             b = data[i+j];
;             tiles[i*4+j*2]    = (b&128)|((b>>1)&96)|((b>>2)&24)|((b>>3)&6)|((b>>4)&1);
;             tiles[i*4+j*2+16] = ((b<<4)&128)|((b<<3)&96)|((b<<2)&24)|((b<<1)&6)|(b&1);
;             tiles[i*4+j*2+2]  = tiles[i*4+j*2];
;             tiles[i*4+j*2+18] = tiles[i*4+j*2+16];
;             b = data[i+j+1];
;             tiles[i*4+j*2+1]  = (b&128)|((b>>1)&96)|((b>>2)&24)|((b>>3)&6)|((b>>4)&1);
;             tiles[i*4+j*2+17] = ((b<<4)&128)|((b<<3)&96)|((b<<2)&24)|((b<<1)&6)|(b&1);
;             tiles[i*4+j*2+3]  = tiles[i*4+j*2+1];
;             tiles[i*4+j*2+19] = tiles[i*4+j*2+17];
;             b = data[i+j+8];
;             tiles[i*4+j*2+32] = (b&128)|((b>>1)&96)|((b>>2)&24)|((b>>3)&6)|((b>>4)&1);
;             tiles[i*4+j*2+48] = ((b<<4)&128)|((b<<3)&96)|((b<<2)&24)|((b<<1)&6)|(b&1);
;             tiles[i*4+j*2+34] = tiles[i*4+j*2+32];
;             tiles[i*4+j*2+50] = tiles[i*4+j*2+48];
;             b = data[i+j+9];
;             tiles[i*4+j*2+33] = (b&128)|((b>>1)&96)|((b>>2)&24)|((b>>3)&6)|((b>>4)&1);
;             tiles[i*4+j*2+49] = ((b<<4)&128)|((b<<3)&96)|((b<<2)&24)|((b<<1)&6)|(b&1);
;             tiles[i*4+j*2+35] = tiles[i*4+j*2+33];
;             tiles[i*4+j*2+51] = tiles[i*4+j*2+49];
;         }
;     }
  call mem_CopyVRAM; set_bkg_data(first_tile, nb_tiles*4, tiles);
  ret

PlayIntro:
  ld de, _UI_FONT_TILE_COUNT
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

;     for (j = 0; j < _CALVIN_BACK_ROWS-1; ++j) {
;         for (i = 0; i < _CALVIN_BACK_COLUMNS-1; ++i) {
;             if (j < 3) {
;                 set_sprite_tile(
;                     j*(_CALVIN_BACK_COLUMNS-1)+i, 
;                     _calvin_back_map[j*_CALVIN_BACK_COLUMNS+i]+_UI_FONT_TILE_COUNT
;                 );
;             }
;             else {
;                 tiles[(j-3)*(_CALVIN_BACK_COLUMNS-1)+i] = 
;                     _calvin_back_map[j*_CALVIN_BACK_COLUMNS+i]+_UI_FONT_TILE_COUNT;
;             }
;         }
;     }

  ld d, 1
  ld e, 16-_CALVIN_BACK_ROWS
  ld h, _CALVIN_BACK_COLUMNS-1
  ld l, _CALVIN_BACK_ROWS-4
  ld bc, tile_buffer
  call gbdk_SetBKGTiles ;set_bkg_tiles(1,16-_CALVIN_BACK_ROWS,_CALVIN_BACK_COLUMNS-1,_CALVIN_BACK_ROWS-4,tiles);

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

  DISABLE_LCD_INTERRUPT
  SET_LCD_INTERRUPT SlideInLCDInterrupt
  DISPLAY_ON
  ; for (x = 160; x >= 0; x-=2) {
  ;     update_vbl();
  ; }
  DISABLE_LCD_INTERRUPT

  ; sprintf(str_buff, "Unsigned %s\nappeared!", "LAGGARD");
  ld hl, str_buffer
  call RevealText ;reveal_text(str_buff, PLAY_BALL_BANK);

  SET_LCD_INTERRUPT SlideOutLCDInterrupt
;     for (x = 0; x > -80; x-=2) {
;         update_vbl();
;     }
  DISABLE_LCD_INTERRUPT

  CLEAR_BKG_AREA 1, 16-_CALVIN_BACK_ROWS, _CALVIN_BACK_COLUMNS-1, _CALVIN_BACK_ROWS-4, " "

  ld hl, _RightyBatterUserTiles
  ld de, $8800;_VRAM+$1000+_UI_FONT_TILE_COUNT*16
  ld bc, _RIGHTY_BATTER_USER_TILE_COUNT
  call mem_CopyVRAM ;set_bkg_data(_UI_FONT_TILE_COUNT, _RIGHTY_BATTER_USER_TILE_COUNT, _righty_batter_user_tiles); 

  ld de, 5 ;x = 0, y = 5
  ld h, _RIGHTY_BATTER_USER0_COLUMNS
  ld l, _RIGHTY_BATTER_USER0_ROWS
  ld bc, _RightyBatterUser0TileMap
  ld a, _UI_FONT_TILE_COUNT
  call SetBKGTilesWithOffset;set_bkg_tiles_with_offset(0,5,_RIGHTY_BATTER_USER0_COLUMNS,_RIGHTY_BATTER_USER0_ROWS,_UI_FONT_TILE_COUNT,_righty_batter_user0_map);

  HIDE_SPRITES
  call gbdk_WaitVBL
  xor a
  ld [rSCX], a
  ld [rSCY], a ;move_bkg(0,0);

  ; ld hl, LetsGoText
  call RevealText ;reveal_text("Let's go!", PLAY_BALL_BANK);
  HIDE_WIN
  ret

DrawPlayerUI: ;UBYTE team, Player *p
  ;if (team) x = 0, y = 2;
  ;else x = 8, y = 10;

  ;b = (team == home_team) != (frame % 2);

  ;tiles[0] = 0;
  ;for (i = 0; i < 10; i++) tiles[i+2] = BOX_HORIZONTAL;
  ;l = strlen(p->nickname);
  ;w = 1+(12-l)/2;
  ;for (i = 0; i < l; i++) tiles[w+i] = p->nickname[i];
  ;if (p->level == 100) {
  ;    tiles[12] = 49; 
  ;    tiles[13] = 48; 
  ;    tiles[14] = 48;
  ;}
  ;else {
  ;    tiles[12] = LEVEL;
  ;    if (p->level < 10) {
  ;        tiles[13] = 48+p->level;
  ;        tiles[14] = 0;
  ;    }
  ;    else {
  ;        tiles[13] = 48+p->level/10;
  ;        tiles[14] = 48+p->level%10;
  ;    }
  ;}
  ;if (b) {
  ;    tiles[1] = NUMBERS + p->batting_order;
  ;    tiles[15] = BATTING_AVG;
  ;}
  ;else {
  ;    tiles[1] = p->position;
  ;    tiles[15] = EARNED_RUN_AVG;
  ;}
  ;tiles[20] = 0;
  ;set_bkg_tiles(x,y,12,2,tiles);
  ;if (b) set_bkg_tiles(x+4,y+1,4,1,batting_avg(p));
  ;else set_bkg_tiles(x+4,y+1,4,1,earned_run_avg(p));
  ;set_bkg_tiles(x+9,y+1,3,1,health_pct(p));
  ret

DrawBases:
  ;for (i = 0; i < 5; i+=2) tiles[i] = 0;
  ;tiles[5] = (runners_on_base & FIRST_BASE_MASK) ? OCCUPIED_BASE : EMPTY_BASE;
  ;tiles[1] = (runners_on_base & SECOND_BASE_MASK) ? OCCUPIED_BASE : EMPTY_BASE;
  ;tiles[3] = (runners_on_base & THIRD_BASE_MASK) ? OCCUPIED_BASE : EMPTY_BASE;
  ;set_bkg_tiles(9,0,3,2,tiles);
  ret

DrawCountOutsInning:
  ;tiles[0] = (frame % 2 == 0) ? INNING_TOP : INNING_BOTTOM;
  ;tiles[1] = 49 + frame/2;
  ;set_bkg_tiles(1,13,2,1,tiles);
  ;set_bkg_tiles(1,14,1,3,"BSO");
  ;for (i = 0; i < 4; i++) tiles[0+i] = (i < balls()  ) ? BASEBALL : DOTTED_CIRCLE;
  ;for (i = 0; i < 3; i++) tiles[4+i] = (i < strikes()) ? BASEBALL : DOTTED_CIRCLE;
  ;tiles[7] = 0;
  ;for (i = 0; i < 3; i++) tiles[8+i] = (i < outs()   ) ? BASEBALL : DOTTED_CIRCLE;
  ;tiles[11] = 0;
  ;set_bkg_tiles(2,14,4,3,tiles);
  ret

DrawTeamNames:
  ;disable_interrupts();
  ;ENABLE_RAM_MBC5;
  ;memcpy(name_buff, user_name, 7);
  ;if (name_buff[0] == 0) {
  ;    set_bkg_tiles(0,0,4,1,"Home");
  ;    set_bkg_tiles(0,1,4,1,"Away");
  ;}
  ;else {
  ;    if (home_team) set_bkg_tiles(0,1,7,1,name_buff);
  ;    else set_bkg_tiles(0,0,7,1,name_buff);
  ;    memcpy(name_buff, rival_name, 8);
  ;    if (home_team) set_bkg_tiles(0,0,7,1,name_buff);
  ;    else set_bkg_tiles(0,1,7,1,name_buff);
  ;}
  ;DISABLE_RAM_MBC5;
  ;enable_interrupts();    
  ret

DrawScore:
  ;sprintf(name_buff, "%d", home_score);
  ;l = strlen(name_buff);
  ;set_bkg_tiles(9,0,l,1,name_buff);
  ;sprintf(name_buff, "%d", away_score);

  ld hl, name_buffer
  call str_Length;l = strlen(name_buff);

  ld h, e ;w
  ld l, 1 ;h
  ld d, 9 ;x
  ld e, 1 ;y
  ld bc, name_buffer
  call gbdk_SetBKGTiles ;set_bkg_tiles(9,1,l,1,name_buff);
  ret

DrawUI:
  call DrawTeamNames
  call DrawScore
  call DrawBases
  call DrawPlayerUI ;0, &test_player
  call DrawPlayerUI ;1, &test_player

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
  xor a
  ld [_x], a
  ld a, [play_menu_selection]
  bit 0, a
  jr z, .xIsZero
  ld a, 1
.xIsZero
  ld [_x], a ;x = play_menu_selection % 2;

  xor a
  ld [_y], a
  ld a, [play_menu_selection]
  bit 1, a
  jr z, .yIsZero
  ld a, 1
.yIsZero
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
  ld a, [_x]
  add a, a ;x*2
  ld b, a
  ld a, [_y];x*2+y
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

ShowMoveInfo: ;Move *m
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

  ; ld hl, types[0]
  ld de, name_buffer
  call str_Copy;strcpy(name_buff, types[0]);//m->type]);

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
  ;get_bkg_tiles(0,8,20,10,bkg_buff);
  ;draw_bkg_ui_box(5,12,15,6);
  ;c = 4;
  ;for (i = 0; i < 4; ++i) {
  ;  if (moves[i] == NULL) { c = i; break; }
  ;  memcpy(name_buff, moves[i]->name, 16);
  ;  set_bkg_tiles(7,13+i,strlen(name_buff),1,name_buff);
  ;if (c < 4) set_bkg_tiles(7,c+13,2,4-c,"--------");

  ;move_move_menu_arrow(move_choice);
  ;show_move_info();//p->moves[move_choice]);

  ;update_waitpadup();
  ;while (1) {
  ;  k = joypad();
  ;  if (k & J_UP && move_choice > 0) {
  ;    update_vbl();
  ;    --move_choice;
  ;    move_move_menu_arrow(move_choice);
  ;    show_move_info();//p->moves[move_choice]);
  ;    update_waitpadup();
  ;  else if (k & J_DOWN && move_choice < c-1) {
  ;    update_vbl();
  ;    ++move_choice;
  ;    move_move_menu_arrow(move_choice);
  ;    show_move_info();//p->moves[move_choice]);
  ;    update_waitpadup();
  ;  if (k & (J_START | J_A)) {
  ;    set_bkg_tiles(0,8,20,10,bkg_buff);
  ;    return move_choice+1;
  ;  else if (k & J_B) break;
  ;  update_vbl(); 
  ;}
  ;set_bkg_tiles(0,8,20,10,bkg_buff);
  xor a;return 0;
  ret

ShowAimCircle: ;a = size
  ;i = (size%8)+_BASEBALL_TILE_COUNT;
  ;set_sprite_tile(3, i);
  ;set_sprite_prop(3, 0);
  ;set_sprite_tile(4, i);
  ;set_sprite_prop(4, S_FLIPX);
  ;set_sprite_tile(5, i);
  ;set_sprite_prop(5, S_FLIPY);
  ;set_sprite_tile(6, i);
  ;set_sprite_prop(6, FLIP_XY);
  ret

ShowStrikeZone; de = xy
  ;top left
  ;set_sprite_tile(10, _BASEBALL_TILE_COUNT+_CIRCLE_TILE_COUNT);
  ;set_sprite_prop(10, S_PALETTE);
  ;move_sprite(10, x-8, y-12);
  ;top right
  ;set_sprite_tile(11, _BASEBALL_TILE_COUNT+_CIRCLE_TILE_COUNT);
  ;set_sprite_prop(11, FLIP_X_PAL);
  ;move_sprite(11, x+16, y-12);
  ;bottom left
  ;set_sprite_tile(12, _BASEBALL_TILE_COUNT+_CIRCLE_TILE_COUNT);
  ;set_sprite_prop(12, FLIP_Y_PAL);
  ;move_sprite(12, x-8, y+20);
  ;bottom right
  ;set_sprite_tile(13, _BASEBALL_TILE_COUNT+_CIRCLE_TILE_COUNT);
  ;set_sprite_prop(13, FLIP_XY_PAL);
  ;move_sprite(13, x+16, y+20);
  ret

HideStrikeZone:
  ;move_sprite(10, 0, 0);
  ;move_sprite(11, 0, 0);
  ;move_sprite(12, 0, 0);
  ;move_sprite(13, 0, 0);
  ret

HideBaseball;
  ;move_sprite(0,0,0);
  ;move_sprite(1,0,0);
  ;move_sprite(2,0,0);
  ret 

; WORD ball_x;
; WORD ball_y;
MoveBaseball:; a = i
  ;// pos = (start_pos * (128-i) + end_pos * i) >> 7;
  ;ball_x = (126*(128-i)+52*i)>>7;
  ;ball_y = (13*(128-i)+87*i)>>7;
  ;t = 6+(i/10)%4;
  ;move_sprite(0, ball_x, ball_y);
  ;set_sprite_tile(0, 1);
  ;set_sprite_prop(0, 0);
  ;move_sprite(1, ball_x, ball_y);
  ;set_sprite_tile(1, t);
  ;set_sprite_prop(1, S_PALETTE);
  ;move_sprite(2, 52, 87);
  ;set_sprite_tile(2, 4);
  ;set_sprite_prop(2, 0);
  ret

MoveAimCircle: ;de = xy
  ;move_sprite(3, x,   y);
  ;move_sprite(4, x+8, y);
  ;move_sprite(5, x,   y+8);
  ;move_sprite(6, x+8, y+8);
  ret

Pitch: ; (Player *p, UBYTE move) {
  ;sprintf(str_buff, "%s sets.", p->nickname);
  ;reveal_text(str_buff, PLAY_BALL_BANK);
  ;show_aim_circle(3);
  ;move_aim_circle(96,32);
  ret

; WORD swing_diff_x;
; WORD swing_diff_y;
; WORD swing_diff_z;
Swing:; (WORD x, WORD y, WORD z) {
  ;move_aim_circle(-8,-8);
  ;hide_strike_zone();
  ;swing_diff_x = x - ball_x;
  ;swing_diff_y = y - ball_y;
  ;swing_diff_z = z - 128;

  ;d = swing_diff_x > -12 && swing_diff_x < 12 && swing_diff_y > -12 && swing_diff_y < 12;
  ;if (swing_diff_z < 20 && swing_diff_z > -20) {
  ;    if (d) {
  ;        if (swing_diff_z == 0 && swing_diff_x == 0 && swing_diff_y == 0/* && rand < batting avg */) {
  ;            display_text("Critical hit!");
  ;        }
  ;        else {
  ;            display_text("Solid contact");
  ;        }
  ;    }
  ;    else display_text("Swing and a miss.");
  ;}
  ;else if (swing_diff_z >= 20) {
  ;    display_text("Late swing.");
  ;}
  ;else {
  ;    display_text("Early swing.");
  ;}
  ret

Bat:; (Player *p, UBYTE move) {
  ;set_bkg_data(_UI_FONT_TILE_COUNT+64, _RIGHTY_PITCHER_OPPONENT_TILE_COUNT, _righty_pitcher_opponent_tiles);
  ;set_bkg_tiles_with_offset(0,5,_RIGHTY_BATTER_USER0_COLUMNS,_RIGHTY_BATTER_USER0_ROWS,_UI_FONT_TILE_COUNT,_righty_batter_user0_map);
  ;set_bkg_tiles_with_offset(12,0,_RIGHTY_PITCHER_OPPONENT0_COLUMNS,_RIGHTY_PITCHER_OPPONENT0_ROWS,_UI_FONT_TILE_COUNT+64,_righty_pitcher_opponent0_map);
  ;show_aim_circle(7);
  ;move_aim_circle(49,85); //TODO: handle lefty batters
  ;show_strike_zone(49,85);
  ;sprintf(str_buff, "%s steps\ninto the box.", p->nickname);
  ;display_text(str_buff);
  ;a = 49<<1;
  ;b = 85<<1;
  ;swing_diff_x = 0;
  ;swing_diff_y = 0;
  ;for (i = 0; i < 60; ++i) {
  ;    k = joypad();
  ;    if (k & J_RIGHT) ++a;
  ;    else if (k & J_LEFT) --a;
  ;    if (k & J_DOWN) ++b;
  ;    else if (k & J_UP) --b;
  ;    move_aim_circle(a>>1, b>>1);
  ;    update_vbl();
  ;}
  ;sprintf(str_buff, "%s sets.", "LAGGARD");
  ;display_text(str_buff);
  ;for (i = 0; i < 60; ++i) { // TODO: quick pitch should decrease this time
  ;    k = joypad();
  ;    if (k & J_RIGHT) ++a;
  ;    else if (k & J_LEFT) --a;
  ;    if (k & J_DOWN) ++b;
  ;    else if (k & J_UP) --b;
  ;    move_aim_circle(a>>1, b>>1);

  ;    if (i == 30) {
  ;        set_bkg_tiles_with_offset(12,0,_RIGHTY_PITCHER_OPPONENT0_COLUMNS,_RIGHTY_PITCHER_OPPONENT0_ROWS,_UI_FONT_TILE_COUNT+64,_righty_pitcher_opponent1_map);
  ;    }
  ;    update_vbl();
  ;}
  ;set_bkg_tiles_with_offset(12,0,_RIGHTY_PITCHER_OPPONENT0_COLUMNS,_RIGHTY_PITCHER_OPPONENT0_ROWS,_UI_FONT_TILE_COUNT+64,_righty_pitcher_opponent2_map);
  ;display_text("And the pitch.");
  ;c = 0;
  ;s = 4; // speed
  ;for (i = 0; i < 200; i+=s) {
  ;    if (i == s*2) {
  ;        set_bkg_tiles_with_offset(12,0,_RIGHTY_PITCHER_OPPONENT0_COLUMNS,_RIGHTY_PITCHER_OPPONENT0_ROWS,_UI_FONT_TILE_COUNT+64,_righty_pitcher_opponent3_map);
  ;    }
  ;    k = joypad();
  ;    if (c == 0 && i > 0) {
  ;        if (k & J_RIGHT) ++a;
  ;        else if (k & J_LEFT) --a;
  ;        if (k & J_DOWN) ++b;
  ;        else if (k & J_UP) --b;
  ;        move_aim_circle(a>>1, b>>1);

  ;        if (k & J_A) {
  ;            c = i;
  ;            set_bkg_tiles_with_offset(0,5,_RIGHTY_BATTER_USER0_COLUMNS,_RIGHTY_BATTER_USER0_ROWS,_UI_FONT_TILE_COUNT,_righty_batter_user1_map);
  ;            swing(a>>1, b>>1, i);
  ;        }
  ;    }
  ;    else if (i == c+2*s) {
  ;        set_bkg_tiles_with_offset(0,5,_RIGHTY_BATTER_USER0_COLUMNS,_RIGHTY_BATTER_USER0_ROWS,_UI_FONT_TILE_COUNT,_righty_batter_user2_map);
  ;    }
  ;    move_baseball(i);
  ;    update_vbl();
  ;}
  ;hide_baseball();
  ;move_aim_circle(-8,-8);
  ;set_bkg_tiles_with_offset(0,5,_RIGHTY_BATTER_USER0_COLUMNS,_RIGHTY_BATTER_USER0_ROWS,_UI_FONT_TILE_COUNT,_righty_batter_user0_map);
  ;update_delay(100);
  ;update_waitpad(J_A);
  ret

PlayBall:; (Player *p, UBYTE move) {
  ;if (home_team == (frame % 2)) bat(p, move);
  ;else pitch(p, move);
  HIDE_WIN
  ret

StartGame::
  DISPLAY_OFF

  ld hl, rBGP
  ld [hl], BG_PALETTE
  ld hl, rOBP0
  ld [hl], SPR_PALETTE_0
  ld hl, rOBP1
  ld [hl], SPR_PALETTE_1

  xor a
  ld [rSCX], a
  ld [rSCY], a ;move_bkg(0,0);
  call LoadFontTiles
  CLEAR_SCREEN " "
  
  ld hl, _BaseballTiles
  ld de, _VRAM
  ld bc, _BASEBALL_TILE_COUNT*16
  call mem_CopyVRAM;set_sprite_data(0, _BASEBALL_TILE_COUNT, _baseball_tiles);

  ld hl, _CircleTiles
  ld de, _VRAM+_BASEBALL_TILE_COUNT*16
  ld bc, _CIRCLE_TILE_COUNT*16
  call mem_CopyVRAM;set_sprite_data(_BASEBALL_TILE_COUNT, _CIRCLE_TILE_COUNT, _circle_tiles);
  
  ld hl, _StrikeZoneTiles
  ld de, _VRAM+(_BASEBALL_TILE_COUNT+_CIRCLE_TILE_COUNT)*16
  ld bc, _STRIKE_ZONE_TILE_COUNT*16
  call mem_CopyVRAM;set_sprite_data(_BASEBALL_TILE_COUNT+_CIRCLE_TILE_COUNT, _STRIKE_ZONE_TILE_COUNT, _strike_zone_tiles);

  ld a, (3 << 4) | (2 << 2) | 1
  ld [balls_strikes_outs], a
  
  ld bc, (9 << 8) | 5
  ld hl, runners_on_base
  ld a, b
  ld [hli], a
  ld a, c
  ld [hl], a

  xor a
  ld [frame], a
  ld [move_choice], a
  ld [home_team], a
  ld a, 1
  ld [away_team], a
  ld [home_score], a
  ld a, 3
  ld [away_score], a

  ;test_player.position = 1;
  ;test_player.batting_order = 3;
  ;test_player.level = 77;
  ;test_player.hp = 97;
  ;test_player.at_bats = 100;
  ;test_player.hits = 32;
  ;strcpy(test_player.nickname, "TEST");

  ;moves[0] = &move1;
  ;moves[1] = &move2;
  ;strcpy(move1.name, "SWING");
  ;strcpy(move2.name, "BUNT");

  ; call PlayIntro
  call DrawUI

  xor a
  ld [play_menu_selection], a

.playBallLoop ;while (1) {
    call SelectPlayMenuItem
    ld a, [play_menu_selection];switch (play_menu_selection) {
.playMenuItemSelected ;case 0:
    and a
    jr nz, .teamMenuItemSelected
    call SelectMoveMenuItem ;b = select_move_menu_item(&test_player);
    and a
    jp z, .playBallLoop
    call PlayBall;if (b > 0) play_ball(&test_player, b-1);
    jr .playBallLoop
.teamMenuItemSelected ;case 1:
    cp 1
    jr nz, .itemMenuItemSelected
    jr .playBallLoop
.itemMenuItemSelected ;case 2:
    cp 2
    jr nz, .runMenuItemSelected
    jr .playBallLoop
.runMenuItemSelected ;case 3:
    cp 3
    jr nz, .playBallLoop
    ld hl, QuittingIsNotAnOptionText
    call RevealText;reveal_text("Quitting is\nnot an option!", PLAY_BALL_BANK);
    HIDE_WIN
    jp .playBallLoop
.exitPlayBallLoop
  ret
