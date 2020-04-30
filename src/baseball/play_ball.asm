INCLUDE "src/beisbol.inc"

SECTION "Play Ball SGB", ROMX, BANK[SGB_BANK+1]

INCLUDE "img/play/play_ball_sgb_border.asm"

SECTION "Play Ball", ROMX, BANK[PLAY_BALL_BANK]

INCLUDE "src/baseball/scale_tile_data_2x.asm"
INCLUDE "src/baseball/strings.asm"
INCLUDE "src/baseball/utils.asm"
INCLUDE "src/baseball/announcer.asm"
INCLUDE "src/baseball/interrupts.asm"
INCLUDE "src/baseball/intro.asm"
INCLUDE "src/baseball/ui.asm"

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
MoveBaseball:; a = z
  push af
  ld b, a
  ld a, 126;127-(i>>1)
  sub a, b
  ld d, a
  ld a, [pitch_target_x]
  add a, d
  ld d, a

  pop af
  push af
  ld b, a
  ld a, 13
  add a, b;13+(i>>1)
  ld e, a
  ld a, [pitch_target_y]
  add a, e
  ld e, a
  pop af;ball z
  push de;ball x, y

  ld h, 0
  ld l, a
  ld c, 10
  call math_Divide;i/10
  ld a, l
  and a, %00000011;(i/10)%4
  add a, 6;6+(i/10)%4
  ld [_t], a;t = 6+(i/10)%4

  ld hl, oam_buffer + BASEBALL_SPRITE_ID*4

  pop de
  ld a, e
  ld [hli], a;y
  ld a, d
  ld [hli], a;x
  ld a, 1
  ld [hli], a;outline tile
  xor a
  ld [hli], a;prop

  ld a, e
  ld [hli], a;y
  ld a, d
  ld [hli], a;x
  ld a, [_t]
  ld [hli], a;tile
  ld a, OAMF_PAL1
  ld [hli], a;prop
  
  ld a, [pitch_target_y]
  add a, STRIKE_ZONE_CENTER_Y
  ld [hli], a;y
  ld a, [pitch_target_x]
  add a, STRIKE_ZONE_CENTER_X
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

;
Pitch: ; (Player *p, UBYTE move) {
  ;sprintf(str_buff, "%s sets.", p->nickname);
  ;reveal_text(str_buff, PLAY_BALL_BANK);
  ;show_aim_circle(3);
  ;move_aim_circle(96,32);
  ret

Swing:; xy = de, z = a, returns contact made in a
  push af;z
  push de;xy
  ld d, -8
  ld e, -8
  call MoveAimCircle
  
  call HideStrikeZone

  ;TODO: replace with Opponent Pitcher AI
  ld a, [pitch_target_x]
  add a, STRIKE_ZONE_CENTER_X
  ld b, a
  ld a, [pitch_target_y]
  add a, STRIKE_ZONE_CENTER_Y
  ld c, a

  pop de;xy
  ld a, d
  sub a, b
  ld [swing_diff_x], a
  ld a, e
  sub a, c
  ld [swing_diff_y], a
  pop af;z
  sub a, 64
  ld [swing_diff_z], a

  ; ld a, [swing_diff_x]
  ; ld b, a
  ; ld a, [swing_diff_y]
  ; ld c, a
  ; ld a, [swing_diff_z]
  ; ld [_breakpoint], a

  ld a, [swing_diff_z]
  BETWEEN -20, 20
  jr nz, .checkHit
  ld a, [swing_diff_z]
  cp 128
  jr c, .late
.early
  ld hl, EarlySwingText
  ld a, DRAW_FLAGS_WIN
  call DisplayText
  xor a
  ret
.late
  ld hl, LateSwingText
  ld a, DRAW_FLAGS_WIN
  call DisplayText
  xor a
  ret
.checkHit;TODO: replace 12 with swing data
  ld a, [swing_diff_x]
  BETWEEN -12, 12
  jr z, .miss
  ld a, [swing_diff_y]
  BETWEEN -12, 12
  jr z, .miss

  ld a, [swing_diff_x]
  ld b, a
  ld a, [swing_diff_y]
  or a, b
  ld b, a
  ld a, [swing_diff_z]
  or a, b
  jr z, .criticalHit
  ld hl, CriticalHitText
  ld a, DRAW_FLAGS_WIN
  call DisplayText
  ld a, 1
  ret
.criticalHit
  ld hl, CriticalHitText
  ld a, DRAW_FLAGS_WIN
  call DisplayText
  ld a, 1
  ret
.miss
  ld hl, SwingAndMissText
  ld a, DRAW_FLAGS_WIN
  call DisplayText
  xor a
  ret

Aim: 
  call UpdateInput
.testRight;if (k & J_RIGHT) ++a;
  ld a, [button_state]
  and PADF_RIGHT
  jr z, .testLeft
  ld a, [aim_x]
  inc a
  inc a
  ld [aim_x], a
  jr .testDown
.testLeft;else if (k & J_LEFT) --a;
  ld a, [button_state]
  and PADF_LEFT
  jr z, .testDown
  ld a, [aim_x]
  dec a
  dec a
  ld [aim_x], a
.testDown;if (k & J_DOWN) ++b;
  ld a, [button_state]
  and PADF_DOWN
  jr z, .testUp
  ld a, [aim_y]
  inc a
  inc a
  ld [aim_y], a
  jr .updateAim
.testUp;else if (k & J_UP) --b;
  ld a, [button_state]
  and PADF_UP
  jr z, .updateAim
  ld a, [aim_y]
  dec a
  dec a
  ld [aim_y], a
.updateAim
  ld a, [aim_x]
  srl a
  ld d, a
  ld a, [aim_y]
  srl a
  ld e, a
  call MoveAimCircle;move_aim_circle(a>>1, b>>1);
  call gbdk_WaitVBL
  ret  

Bat:
  ld a, %00001111
  call SignedRandom
  ld a, d
  ld [pitch_target_x], a
  ld a, e
  ld [pitch_target_y], a

  call LoadOpposingPlayerBkgTiles
  call LoadUserPlayerBkgTiles
  
  xor a
  call SetOpposingPlayerBkgTiles
  xor a
  call SetUserPlayerBkgTiles

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
  ld a, DRAW_FLAGS_WIN
  call DisplayText

  ld a, 49<<1
  ld [aim_x], a;a = 49<<1;
  ld a, 85<<1
  ld [aim_y], a;b = 85<<1;
  
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
  ld a, DRAW_FLAGS_WIN
  call DisplayText

  xor a
.preWindupAimLoop
    ld [_i], a
    call Aim
    ld a, [_i]
    inc a
    cp 30
    jr nz, .preWindupAimLoop

  ld a, 1
  call SetOpposingPlayerBkgTiles

  xor a
.postWindupAimLoop
    ld [_i], a
    call Aim
    ld a, [_i]
    inc a
    cp 30
    jr nz, .postWindupAimLoop

  ld a, 2
  call SetOpposingPlayerBkgTiles

  ld hl, AndThePitchText
  ld a, DRAW_FLAGS_WIN
  call DisplayText;"And the pitch."

  call GetCurrentOpponentPlayer
  ld a, 0
  call GetPlayerMoveName

  ld hl, AndThePitchText
  ld de, str_buffer
  call str_Copy

  ld hl, ThrewAPitchText;"\nA %s."
  ld de, str_buffer
  call str_Append;"And the pitch.\nA %s."

  ld hl, name_buffer;pitch name
  ld de, str_buffer
  call str_Replace;"And the pitch.\nA PITCH_NAME."

  xor a
  ld [_c], a
  ld [pitch_z], a
  ld a, 4
  ld [_s], a;speed
.swingLoop;for (j = 0; j < 200; j+=s)
    ld a, [_s]
    add a, a;s*2
    ld b, a
    ld a, [pitch_z]
    cp b
    jr nz, .aim;if (j == s*2)

.setFinishPitchFrame
  ld a, 3
  call SetOpposingPlayerBkgTiles

.aim
    ld a, [_c]
    and a
    jp nz, .checkFinishSwing
    ld a, [pitch_z]
    and a
    jp z, .checkFinishSwing ;if (c == 0 && j > 0) {
      call Aim

      ld a, [button_state]
      and PADF_A
      jp z, .moveBaseball ;if (k & J_A) {
        ld a, [pitch_z]
        ld [_c], a

  ld a, 1
  call SetUserPlayerBkgTiles

        ld a, [aim_x];x
        srl a
        ld d, a
        ld a, [aim_y];y
        srl a
        ld e, a
        ld a, [pitch_z];z
        call Swing
        and a
        jr nz, .hitBall
      jp .moveBaseball

.checkFinishSwing
    ld a, [_s]
    add a, a
    ld b, a;s*2
    ld a, [_c]
    add a, b
    ld b, a;c+2*s
    ld a, [pitch_z]
    cp b
    jr nz, .moveBaseball;else if (j == c+2*s)
      ld a, 2
      call SetUserPlayerBkgTiles

.moveBaseball
    ld a, [pitch_z]
    call MoveBaseball
    call gbdk_WaitVBL

.increment
    ld a, [_s]
    ld b, a
    ld a, [pitch_z]
    add a, b;j+=s
    ld [pitch_z], a
    cp 200
    jp c, .swingLoop
  jp .noSwing

.hitBall
  call HideBaseball

  ld d, -8
  ld e, -8
  call MoveAimCircle
  
  ld a, [swing_diff_x]
  ld a, [swing_diff_y]
  ld a, [swing_diff_z]

  ld de, 10
  call gbdk_Delay

  ld a, 2
  call SetUserPlayerBkgTiles

  ld de, 10
  call gbdk_Delay

  ld a, 255;full power
  ld b, -45;up the middle
  ld c, 45;degrees up
  push af;exit velocity
  push bc;direction
  ld a, 0;TODO:read animation on/off from save ram 
  and a
  jr z, .announceContact
.loadSimulation
  pop bc;direction
  pop af;exit velocity
  call LoadSimulation;a = exit velocity b = spray angle c = launch angle
  call SetupGameUI
  jr .finish
.announceContact
  pop bc;direction
  pop af;exit velocity
  call AnnounceSwingContact;a = exit velocity b = spray angle c = launch angle
  jr .finish
.noSwing
  call AnnounceNoSwing
.finish
  call HideBaseball
  call HideStrikeZone

  ld d, -8
  ld e, -8
  call MoveAimCircle
  
  xor a
  call SetUserPlayerBkgTiles

  call DrawCountOutsInning
  
  ld de, 100
  call gbdk_Delay
  ret

PlayBall:; a = selected move
  call IsUserFielding
  jr nz, .pitching
.batting
  call Bat
  jr .exit
.pitching
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
  ld a, DRAW_FLAGS_WIN
  call DrawUIBox

  ld a, 7
  ld [rWX], a
  ld a, 96
  ld [rWY], a
  SHOW_WIN
  ret 

SGBPlayBallPalSet: PAL_SET PALETTE_UI, PALETTE_GREY, PALETTE_GREY, PALETTE_GREY
SGBPlayBallAttrBlk:
  ATTR_BLK 3
  ATTR_BLK_PACKET %111, 0,0,0, 0,0, 20,18 ;main UI
  ATTR_BLK_PACKET %001, 2,2,2, 0,4,   8,7 ;user player
  ATTR_BLK_PACKET %001, 3,3,3, 12,0,  8,7 ;opposing player
  
SetSGBMainColors:
  ld hl, SGBPlayBallPalSet               
  call SetPalettesIndirect
  ld hl, SGBPlayBallAttrBlk
  call sgb_PacketTransfer
  
  call GetCurrentUserPlayer
  call GetPlayerNumber
  call LoadPlayerBaseData
  ld hl, player_base+PLAYER_BASE_SGB_PAL
  ld a, [hli]
  ld c, a
  ld a, [hli]
  ld b, a
  push bc;user palette

  call GetCurrentOpponentPlayer
  call GetPlayerNumber
  call LoadPlayerBaseData
  ld hl, player_base+PLAYER_BASE_SGB_PAL
  ld a, [hli]
  ld e, a
  ld a, [hli]
  ld d, a;de = opponent palette

  pop bc;user palette
  ld a, [sgb_Pal23]
  call SetPalettesDirect
  ret

SetupGameUI:
  call SetPlayBallTiles
  call DrawPlayBallUI
  HIDE_WIN
  
  CLEAR_BKG_AREA 12, 0, 7, 7, " "

  call SetSGBMainColors

.setPlayerTiles
  call LoadOpposingPlayerBkgTiles
  call LoadUserPlayerBkgTiles

  xor a
  call SetOpposingPlayerBkgTiles
  xor a
  call SetUserPlayerBkgTiles

  ret

StartGame::
  ld a, BANK(PlayBallSgbBorderTiles)
  ld hl, PlayBallSgbBorderTiles
  ld de, PlayBallSgbBorderTileMap
  call sgb_SetBorder

  DISPLAY_OFF
  SET_DEFAULT_PALETTE

  xor a
  ld [rSCX], a
  ld [rSCY], a
  call LoadFontTiles
  CLEAR_SCREEN " "
  
  call SetPlayBallTiles

  ld a, 0;(3 << 4) | (2 << 2) | 1; 3 balls, 2 strikes, 1 out
  ld [balls_strikes_outs], a
  
  ld bc, 0;(9 << 8) | 5;9th batter on third, 5th batter on first
  ld hl, runners_on_base
  ld a, b
  ld [hli], a
  ld a, c
  ld [hl], a

  xor a
  ld [frame], a
  ld [move_choice], a
  ld [home_team], a
  ; ld a, 1
  ld [home_score], a
  ; ld a, 3
  ld [away_score], a

  ld a, 1; TODO: replace with team/random encounter
  call PlayIntro
  call SetupGameUI
  call AnnounceBeginningOfFrame

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
  call sgb_SetDefaultBorder
  ret
