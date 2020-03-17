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

BASEBALL_SPRITE_ID EQU 0
AIM_CIRCLE_SPRITE_ID EQU 3
STRIKEZONE_SPRITE_ID EQU 10

ShowAimCircle: ;hl = size
  ld c, 8
  call math_Divide ; hl (remainder a) = hl / c
  add a, _BASEBALL_TILE_COUNT
  ld [_i], a;i = (size%8)+_BASEBALL_TILE_COUNT;

  ld bc, 2
  ld hl, oam_buffer + AIM_CIRCLE_SPRITE_ID*4 + 2
  ld [hli], a;tile
  xor a
  ld [hli], a;prop

  add hl, bc
  ld a, [_i]
  ld [hli], a;tile
  ld a, OAMF_XFLIP
  ld [hli], a;prop

  add hl, bc
  ld a, [_i]
  ld [hli], a;tile
  ld a, OAMF_YFLIP
  ld [hli], a;prop
  
  add hl, bc
  ld a, [_i]
  ld [hli], a;tile
  ld a, FLIP_XY
  ld [hl], a;prop
  ret

ShowStrikeZone; de = xy
  ld hl, oam_buffer + STRIKEZONE_SPRITE_ID*4

  ;top left
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
  ld hl, oam_buffer + STRIKEZONE_SPRITE_ID*4
  ld bc, 4*4
  xor a
  call mem_Set
  ret

HideBaseball
  ld hl, oam_buffer + BASEBALL_SPRITE_ID*4
  ld bc, 3*4
  xor a
  call mem_Set
  ret 

;start = (126,13), end = (52,87)
MoveBaseball:; a = i
  push af
  ld b, a
  ld a, 126;127-(i>>1)
  sub a, b
  ld [ball_x], a

  pop af
  push af
  ld b, a
  ld a, 13
  add a, b;13+(i>>1)
  ld [ball_y], a

  pop af
  ld h, 0
  ld l, a
  ld c, 10
  call math_Divide;i/10
  ld a, l
  and a, %00000011;(i/10)%4
  add a, 6;6+(i/10)%4
  ld [_t], a;t = 6+(i/10)%4

  ld hl, oam_buffer + BASEBALL_SPRITE_ID*4

  ld a, [ball_y]
  ld [hli], a;y
  ld a, [ball_x]
  ld [hli], a;x
  ld a, 1
  ld [hli], a;outline tile
  xor a
  ld [hli], a;prop

  ld a, [ball_y]
  ld [hli], a;y
  ld a, [ball_x]
  ld [hli], a;x
  ld a, [_t]
  ld [hli], a;tile
  ld a, OAMF_PAL1
  ld [hli], a;prop
  
  ld a, 87
  ld [hli], a;y
  ld a, 52
  ld [hli], a;x
  ld a, 4
  ld [hli], a;projection tile
  xor a
  ld [hli], a;prop
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

Swing:; xy = de, z = a
  ld d, -8
  ld e, -8
  call MoveAimCircle
  
  call HideStrikeZone
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
  
  call GetCurrentUserPlayer
  call GetUserPlayerName

  ld bc, name_buffer
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

  call GetCurrentOpponentPlayer
  call GetPlayerNumber
  call GetPlayerName

  ld bc, name_buffer
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
.swingLoop;for (j = 0; j < 200; j+=s)
    ld a, [_s]
    add a, a;s*2
    ld b, a
    ld a, [_j]
    cp b
    jr nz, .aim;if (j == s*2)

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
    jp z, .checkFinishSwing ;if (c == 0 && j > 0) {
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

        ld a, [_a];x
        srl a
        ld d, a
        ld a, [_b];y
        srl a
        ld e, a
        ld a, [_j];z
        call Swing
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
    jr nz, .moveBaseball;else if (j == c+2*s)
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
    add a, b;j+=s
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

PlayBall:; a = selected move
  ld a, [frame]
  and 1
  ld b, a
  ld a, [home_team]
  xor b
  jr nz, .pitch ;if (home_team == (frame % 2)) bat(p, move);
  call Bat
  jr .exit
.pitch
  call Pitch;else pitch(p, move);
.exit
  HIDE_WIN
  ret

SetPlayBallTiles:
  ld hl, _BaseballTiles
  ld de, _VRAM
  ld bc, _BASEBALL_TILE_COUNT*16
  call mem_CopyVRAM

  ld hl, _CircleTiles
  ld de, _VRAM+_BASEBALL_TILE_COUNT*16
  ld bc, _CIRCLE_TILE_COUNT*16
  call mem_CopyVRAM
  
  ld hl, _StrikeZoneTiles
  ld de, _VRAM+(_BASEBALL_TILE_COUNT+_CIRCLE_TILE_COUNT)*16
  ld bc, _STRIKE_ZONE_TILE_COUNT*16
  call mem_CopyVRAM
  ret 

ShowPlayBallWindow:
  ld bc, 0
  ld d, 20
  ld e, 6
  call DrawWinUIBox

  ld a, 7
  ld [rWX], a
  ld a, 96
  ld [rWY], a
  SHOW_WIN
  ret 

SetupGameUI:
  call SetPlayBallTiles
  call DrawPlayBallUI
  HIDE_WIN
  
  call GetCurrentOpponentPlayer
  call GetPlayerNumber
  push af
  ld de, _UI_FONT_TILE_COUNT+64
  call LoadPlayerBkgData
  pop af
  push af
  call GetPlayerImgColumns
  ld c, a

  ld a, 19
  sub a, c
  ld b, a;x
  ld a, 7
  sub a, c
  ld c, a;y
  ld de, _UI_FONT_TILE_COUNT+64
  pop af
  call SetPlayerBkgTiles

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

  ret

StartGame::
  DISPLAY_OFF
  SET_DEFAULT_PALETTE

  xor a
  ld [rSCX], a
  ld [rSCY], a
  call LoadFontTiles
  CLEAR_SCREEN " "
  
  call SetPlayBallTiles

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

  call PlayIntro
  call SetupGameUI

  xor a
  ld [play_menu_selection], a

.playBallLoop
    call SelectPlayMenuItem
    ld a, [play_menu_selection]
.playMenuItemSelected
    cp 0
    jr nz, .teamMenuItemSelected
    call SelectMoveMenuItem ;returns selection in a
    and a
    jp z, .playBallLoop;if selection is 0, back pressed
    dec a;selected move
    call PlayBall
    jr .playBallLoop
.teamMenuItemSelected
    cp 1
    jr nz, .itemMenuItemSelected
    call ShowLineupFromGame
    call SetupGameUI
    jr .playBallLoop
.itemMenuItemSelected
    cp 2
    jr nz, .runMenuItemSelected
    jr .playBallLoop
.runMenuItemSelected
    cp 3
    jr nz, .playBallLoop
    ld hl, QuittingIsNotAnOptionText
    call RevealTextAndWait
    HIDE_WIN
    jp .playBallLoop
.exitPlayBallLoop
  ret
