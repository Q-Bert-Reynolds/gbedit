INCLUDE "src/beisbol.inc"

SECTION "Play Ball", ROMX, BANK[PLAY_BALL_BANK]

INCLUDE "img/baseball.asm"
INCLUDE "img/circle.asm"
INCLUDE "img/strike_zone.asm"
INCLUDE "img/play/righty_batter_user/righty_batter_user.asm"
INCLUDE "img/play/righty_pitcher_opponent/righty_pitcher_opponent.asm"
INCLUDE "img/coaches/calvin_back.asm"

INCLUDE "src/baseball/scale_tile_data_2x.asm"
INCLUDE "src/baseball/strings.asm"
INCLUDE "src/baseball/utils.asm"
INCLUDE "src/baseball/interrupts.asm"
INCLUDE "src/baseball/intro.asm"
INCLUDE "src/baseball/ui.asm"

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

  call PlayIntro
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
  ld [_breakpoint], a
  ret
