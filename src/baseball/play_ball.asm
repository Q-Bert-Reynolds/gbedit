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

ShowAimCircle: ;hl = size
  ld c, 8
  call math_Divide ; hl (remainder a) = hl / c
  add a, _BASEBALL_TILE_COUNT
  ld [_i], a;i = (size%8)+_BASEBALL_TILE_COUNT;

  ld c, 3
  ld d, a
  call gbdk_SetSpriteTile;set_sprite_tile(3, i);
  ld c, 3
  ld d, 0
  call gbdk_SetSpriteProp;set_sprite_prop(3, 0);

  ld c, 4
  ld a, [_i]
  ld d, a
  call gbdk_SetSpriteTile;set_sprite_tile(4, i);
  ld c, 4
  ld d, OAMF_XFLIP
  call gbdk_SetSpriteProp;set_sprite_prop(4, S_FLIPX);

  ld c, 5
  ld a, [_i]
  ld d, a
  call gbdk_SetSpriteTile;set_sprite_tile(5, i);
  ld c, 5
  ld d, OAMF_YFLIP
  call gbdk_SetSpriteProp;set_sprite_prop(5, S_FLIPY);
  
  ld c, 6
  ld a, [_i]
  ld d, a
  call gbdk_SetSpriteTile;set_sprite_tile(6, i);
  ld c, 6
  ld d, FLIP_XY
  call gbdk_SetSpriteProp;set_sprite_prop(6, FLIP_XY);
  ret

ShowStrikeZone; de = xy
  ld hl, oam_buffer + 10*4
  ;top left
  ;set_sprite_tile(10, _BASEBALL_TILE_COUNT+_CIRCLE_TILE_COUNT);
  ;set_sprite_prop(10, S_PALETTE);
  ;move_sprite(10, x-8, y-12);
  ld a, e
  sub a, 12
  ld [hli], a;y
  ld a, d
  sub a, 8
  ld [hli], a;x
  ld a, _BASEBALL_TILE_COUNT+_CIRCLE_TILE_COUNT
  ld [hli], a;tile
  ld a, OAMF_PAL1
  ld [hli], a

  ;top right
  ;set_sprite_tile(11, _BASEBALL_TILE_COUNT+_CIRCLE_TILE_COUNT);
  ;set_sprite_prop(11, FLIP_X_PAL);
  ;move_sprite(11, x+16, y-12);
  ld a, e
  sub a, 12
  ld [hli], a;y
  ld a, d
  add a, 16
  ld [hli], a;x
  ld a, _BASEBALL_TILE_COUNT+_CIRCLE_TILE_COUNT
  ld [hli], a;tile
  ld a, FLIP_X_PAL
  ld [hli], a

  ;bottom left
  ;set_sprite_tile(12, _BASEBALL_TILE_COUNT+_CIRCLE_TILE_COUNT);
  ;set_sprite_prop(12, FLIP_Y_PAL);
  ;move_sprite(12, x-8, y+20);
  ld a, e
  add a, 20
  ld [hli], a;y
  ld a, d
  sub a, 8
  ld [hli], a;x
  ld a, _BASEBALL_TILE_COUNT+_CIRCLE_TILE_COUNT
  ld [hli], a;tile
  ld a, FLIP_Y_PAL
  ld [hli], a

  ;bottom right
  ;set_sprite_tile(13, _BASEBALL_TILE_COUNT+_CIRCLE_TILE_COUNT);
  ;set_sprite_prop(13, FLIP_XY_PAL);
  ;move_sprite(13, x+16, y+20);
  ld a, e
  add a, 20
  ld [hli], a;y
  ld a, d
  add a, 16
  ld [hli], a;x
  ld a, _BASEBALL_TILE_COUNT+_CIRCLE_TILE_COUNT
  ld [hli], a;tile
  ld a, FLIP_XY_PAL
  ld [hli], a
  ret

HideStrikeZone:
  ;move_sprite(10, 0, 0);
  ;move_sprite(11, 0, 0);
  ;move_sprite(12, 0, 0);
  ;move_sprite(13, 0, 0);
  ld hl, oam_buffer + 10*4
  ld bc, 4*4
  xor a
  call mem_Set
  ret

HideBaseball;
  ;move_sprite(0,0,0);
  ;move_sprite(1,0,0);
  ;move_sprite(2,0,0);
  ld hl, oam_buffer
  ld bc, 3*4
  xor a
  call mem_Set
  ret 

MoveBaseball:; a = i
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
  ld c, 3
  call gbdk_MoveSprite;move_sprite(3, x,   y);

  ld c, 4
  ld a, d
  add a, 8
  ld d, a
  call gbdk_MoveSprite;move_sprite(4, x+8, y);

  ld c, 5
  ld a, d
  sub a, 8 
  ld d, a
  ld a, e
  add a, 8
  ld e, a
  call gbdk_MoveSprite;move_sprite(5, x,   y+8);

  ld c, 6
  ld a, 8
  add a, d
  ld d, a
  call gbdk_MoveSprite;move_sprite(6, x+8, y+8);
  ret

Pitch: ; (Player *p, UBYTE move) {
  ;sprintf(str_buff, "%s sets.", p->nickname);
  ;reveal_text(str_buff, PLAY_BALL_BANK);
  ;show_aim_circle(3);
  ;move_aim_circle(96,32);
  ret

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

Aim: 
  call UpdateInput
.testRight;if (k & J_RIGHT) ++a;
  ld a, [button_state]
  and PADF_RIGHT
  jr z, .testLeft
  ld a, [_a]
  inc a
  ld [_a], a
  jr .testDown
.testLeft;else if (k & J_LEFT) --a;
  ld a, [button_state]
  and PADF_LEFT
  jr z, .testDown
  ld a, [_a]
  dec a
  ld [_a], a
.testDown;if (k & J_DOWN) ++b;
  ld a, [button_state]
  and PADF_DOWN
  jr z, .testUp
  ld a, [_b]
  inc a
  ld [_b], a
  jr .updateAim
.testUp;else if (k & J_UP) --b;
  ld a, [button_state]
  and PADF_UP
  jr z, .updateAim
  ld a, [_b]
  dec a
  ld [_b], a
.updateAim
  ld a, [_a]
  srl a
  ld d, a
  ld a, [_b]
  srl a
  ld e, a
  call MoveAimCircle;move_aim_circle(a>>1, b>>1);
  call gbdk_WaitVBL
  ret

Bat:; (Player *p, UBYTE move) {
  ld hl, _RightyPitcherOpponentTiles
  ld de, $8800 + 64*16
  ld bc, _RIGHTY_PITCHER_OPPONENT_TILE_COUNT*16
  call mem_CopyVRAM
  
  ld d, 0
  ld e, 5
  ld h, _RIGHTY_BATTER_USER0_COLUMNS
  ld l, _RIGHTY_BATTER_USER0_ROWS
  ld bc, _RightyBatterUser0TileMap
  ld a, _UI_FONT_TILE_COUNT
  call SetBKGTilesWithOffset
  
  ld d, 12
  ld e, 0
  ld h, _RIGHTY_PITCHER_OPPONENT0_COLUMNS
  ld l, _RIGHTY_PITCHER_OPPONENT0_ROWS
  ld bc, _RightyPitcherOpponent0TileMap
  ld a, _UI_FONT_TILE_COUNT+64
  call SetBKGTilesWithOffset

  ld hl, 7
  call ShowAimCircle
  
  ld d, 49
  ld e, 85
  call MoveAimCircle ;TODO: handle lefty batters
  
  ld d, 49
  ld e, 85
  call ShowStrikeZone
  
  ld bc, TEMP_PLAYER_NAME
  ld hl, BatterStepsIntoTheBoxText
  ld de, str_buffer
  call str_Replace
  ld hl, str_buffer
  call DisplayText

  ld a, 49<<1
  ld [_a], a;a = 49<<1;
  ld a, 85<<1
  ld [_b], a;b = 85<<1;
  
  xor a
.preSetAimLoop
    ld [_i], a
    call Aim
    ld a, [_i]
    inc a
    cp 60
    jr nz, .preSetAimLoop

  ld bc, TEMP_OPPONENT_NAME
  ld hl, PitcherSetsText
  ld de, str_buffer
  call str_Replace
  ld hl, str_buffer
  call DisplayText

  xor a
.preWindupAimLoop
    ld [_i], a
    call Aim
    ld a, [_i]
    inc a
    cp 30
    jr nz, .preWindupAimLoop

  ld d, 12
  ld e, 0
  ld h, _RIGHTY_PITCHER_OPPONENT0_COLUMNS
  ld l, _RIGHTY_PITCHER_OPPONENT0_ROWS
  ld bc, _RightyPitcherOpponent1TileMap
  ld a, _UI_FONT_TILE_COUNT+64
  call SetBKGTilesWithOffset

  xor a
.postWindupAimLoop
    ld [_i], a
    call Aim
    ld a, [_i]
    inc a
    cp 30
    jr nz, .postWindupAimLoop

  ld d, 12
  ld e, 0
  ld h, _RIGHTY_PITCHER_OPPONENT0_COLUMNS
  ld l, _RIGHTY_PITCHER_OPPONENT0_ROWS
  ld bc, _RightyPitcherOpponent2TileMap
  ld a, _UI_FONT_TILE_COUNT+64
  call SetBKGTilesWithOffset

  ld hl, AndThePitchText
  call DisplayText

  xor a
  ld [_c], a
  ld [_j], a
  ld a, 4
  ld [_s], a;speed
.swingLoop;for (i = 0; i < 200; i+=s) {
    ld a, [_s]
    add a, a;s*2
    ld b, a
    ld a, [_j]
    cp b
    jr nz, .aim;if (i == s*2) {

.setFinishPitchFrame
    ld d, 12
    ld e, 0
    ld h, _RIGHTY_PITCHER_OPPONENT0_COLUMNS
    ld l, _RIGHTY_PITCHER_OPPONENT0_ROWS
    ld bc, _RightyPitcherOpponent3TileMap
    ld a, _UI_FONT_TILE_COUNT+64
    call SetBKGTilesWithOffset

.aim
    ld a, [_c]
    and a
    jp nz, .checkFinishSwing
    ld a, [_j]
    and a
    jp z, .checkFinishSwing ;if (c == 0 && i > 0) {
      call Aim

      ld a, [button_state]
      and PADF_A
      jp z, .moveBaseball ;if (k & J_A) {
        ld a, [_j]
        ld [_c], a

        ld d, 0
        ld e, 5
        ld h, _RIGHTY_BATTER_USER0_COLUMNS
        ld l, _RIGHTY_BATTER_USER0_ROWS
        ld bc, _RightyBatterUser1TileMap
        ld a, _UI_FONT_TILE_COUNT
        call SetBKGTilesWithOffset

        call Swing;swing(a>>1, b>>1, i);
      jp .moveBaseball

.checkFinishSwing
    ld a, [_s]
    add a, a
    ld b, a;s*2
    ld a, [_c]
    add a, b
    ld b, a;c+2*s
    ld a, [_j]
    cp b
    jr nz, .moveBaseball;else if (i == c+2*s) {
      ld d, 0
      ld e, 5
      ld h, _RIGHTY_BATTER_USER0_COLUMNS
      ld l, _RIGHTY_BATTER_USER0_ROWS
      ld bc, _RightyBatterUser2TileMap
      ld a, _UI_FONT_TILE_COUNT
      call SetBKGTilesWithOffset

.moveBaseball
    ld a, [_j]
    call MoveBaseball
    call gbdk_WaitVBL

.increment
    ld a, [_s]
    ld b, a
    ld a, [_j]
    add a, b;i+=s
    ld [_j], a
    cp 200
    jp c, .swingLoop

  call HideBaseball

  ld d, -8
  ld e, -8
  call MoveAimCircle
  
  ld d, 0
  ld e, 5
  ld h, _RIGHTY_BATTER_USER0_COLUMNS
  ld l, _RIGHTY_BATTER_USER0_ROWS
  ld bc, _RightyBatterUser0TileMap
  ld a, _UI_FONT_TILE_COUNT
  call SetBKGTilesWithOffset
  
  ld de, 100
  call gbdk_Delay
  
  ;update_waitpad(J_A);
  ret

PlayBall:; (Player *p, UBYTE move) {
  ld a, [frame]
  and 1
  ld b, a
  ld a, [home_team]
  cp b
  jr z, .pitch ;if (home_team == (frame % 2)) bat(p, move);
  call Bat
  jr .exit
.pitch
  call Pitch;else pitch(p, move);
.exit
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

  ld a, 1
  ld [frame], a
  xor a
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
  ret
