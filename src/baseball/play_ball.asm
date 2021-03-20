INCLUDE "src/beisbol.inc"
INCLUDE "src/baseball/intro.asm"
INCLUDE "src/baseball/announcer.asm"
INCLUDE "src/baseball/utils.asm"

SECTION "Play Ball SGB", ROMX, BANK[SGB_BANK+1]

INCLUDE "img/play/play_ball_sgb_border.asm"

SECTION "Play Ball", ROMX, BANK[PLAY_BALL_BANK]

DISPLAY_PITCH_NAME_DELAY EQU 6

INCLUDE "src/baseball/play_ball_strings.asm"
INCLUDE "src/baseball/ui.asm"
INCLUDE "src/baseball/pitch_path.asm"

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

ShowStrikeZone:
  call StrikeZonePosition
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

HideBaseball:
  ld hl, oam_buffer + BASEBALL_SPRITE_ID*4
  ld bc, 3*4
  xor a
  call mem_Set
  ret

HideAimCircle:
  ld hl, oam_buffer + AIM_CIRCLE_SPRITE_ID*4
  ld bc, 4*4
  xor a
  call mem_Set
  ret

GetPitchPathOffset: ;a = speed, b = path, c = z[0,100], returns xy offset in hl 
  push bc;path, z
  ld hl, 0
  cp a, 100
  jr nc, .addBreak;no arc if >= 100

.setArc
  ld e, a;speed
  ld hl, PitchPathArc
  ld b, 0
  add hl, bc
  ld a, [hl]
  ld h, 0
  ld l, a;arc
  ld a, e;speed
  cp a, 70
  jr c, .addBreak;speed < 70, full arc

  ld a, l
  sra a
  ld l, a
  ld a, e;speed
  cp a, 80
  jr c, .addBreak;speed < 80, half arc

  ld a, l
  sra a
  ld l, a
  ld a, e;speed
  cp a, 90
  jr c, .addBreak;speed < 90, quarter arc

  ld a, l
  sra a
  ld l, a;speed < 100, 1/16 arc

.addBreak
  pop bc;path, z
  push hl;arc
  call GetPitchBreak
  pop hl;arc
  add hl, de
  ret

MovePitch: ;a = show projection, b = pitch path, c = z[0,100], de = start xy, hl = end xy, [_s] = pitch speed
  push af;show projection
  push bc;path,z
  push de;start xy
  push hl;end xy
  ld a, d;start x
  ld b, h;end x
  call math_Lerp;x

  pop hl;end xy
  pop de;start xy
  pop bc;path,z
  push bc;path,z
  push af;x
  ld a, e;start y
  ld b, l;end y
  call math_Lerp;y
  
  ld e, a;y
  pop af;x
  ld d, a;x
  pop bc;path,z
  push bc;path,z
  push de;ball x, y

  ld a, [_s]
  call GetPitchPathOffset
  push hl;offset

  ;TODO: baseball animation should be based on move
  ld h, 0
  ld l, a
  ld c, 10
  call math_Divide;i/10
  ld a, l
  and a, %00000011;(i/10)%4
  add a, 6;6+(i/10)%4
  ld [_t], a;t = 6+(i/10)%4
  pop hl;offset
  pop de;ball xy
  add hl, de
  ld d, h
  ld e, l

  ; ball outline
  ld hl, oam_buffer + BASEBALL_SPRITE_ID*4
  ld a, e
  add a, 4
  ld [hli], a;y
  ld a, d
  add a, 4
  ld [hli], a;x
  ld a, 1
  ld [hli], a;outline tile
  xor a
  ld [hli], a;prop

  ; ball animation
  ld a, e
  add a, 4
  ld [hli], a;y
  ld a, d
  add a, 4
  ld [hli], a;x
  ld a, [_t]
  ld [hli], a;tile
  ld a, OAMF_PAL1
  ld [hli], a;prop

  pop bc;path,z
  ld a, 100
  cp a, c
  jr nc, .skip
  ld c, 100
.skip
  push hl;store OAM address
  call GetPitchBreak
  pop hl;restore OAM address

  pop af;show
  and a
  ret z

  ;projection
  push de;break
  push hl;store OAM address
  call StrikeZonePosition
  pop hl;restore OAM address
  pop bc;break
  ld a, [pitch_target_y]
  add a, e
  add a, c
  add a, 4
  ld [hli], a;y
  ld a, [pitch_target_x]
  add a, d
  add a, b
  add a, 4
  ld [hli], a;x
  ld a, 4
  ld [hli], a;projection tile
  xor a
  ld [hli], a;prop
  ret

MoveAimCircle: ;de = xy
  ld c, AIM_CIRCLE_SPRITE_ID
  call gbdk_MoveSprite;move_sprite(3, x,   y);

  ld c, AIM_CIRCLE_SPRITE_ID+1
  ld a, d
  add a, 8
  ld d, a
  call gbdk_MoveSprite;move_sprite(4, x+8, y);

  ld c, AIM_CIRCLE_SPRITE_ID+2
  ld a, d
  sub a, 8 
  ld d, a
  ld a, e
  add a, 8
  ld e, a
  call gbdk_MoveSprite

  ld c, AIM_CIRCLE_SPRITE_ID+3
  ld a, 8
  add a, d
  ld d, a
  call gbdk_MoveSprite
  ret

Pitch:
  ld a, 0
  call SetUserPlayerBkgTiles
  ld a, 0
  call SetOpposingPlayerBkgTiles

  TRAMPOLINE AnnouncePitcherSets
  call ShowStrikeZone

.setAimSize; 100% accuracy = size 0, 50% accuracy = size 10
  ld a, [pitch_move_id]
  call GetMove
  ld a, [move_data.accuracy]
  srl a
  srl a
  srl a
  ld h, 0
  ld l, a
  call ShowAimCircle

.setPitchPath
  ld a, [move_data.pitch_path]
  ld [_b], a

.setPitchSpeed
  ld a, [move_data.power]
  ld [_s], a

  call StrikeZonePosition
  ld a, d
  ld [aim_x], a
  ld a, e
  ld [aim_y], a
  call MoveAimCircle

  TRAMPOLINE AnnounceBatterStepsIntoBox
  
  xor a
.preSetAimLoop
    ld [_i], a
    call Aim
    ld a, [_i]
    inc a
    cp 10
    jr nz, .preSetAimLoop

  TRAMPOLINE AnnouncePitcherSets

  xor a
.preWindupAimLoop
    ld [_i], a
    call Aim
    ld a, [_i]
    inc a
    cp 30
    jr nz, .preWindupAimLoop

  ld a, 1
  call SetUserPlayerBkgTiles

  xor a
.postWindupAimLoop
    ld [_i], a
    call Aim
    ld a, [_i]
    inc a
    cp 20
    jr nz, .postWindupAimLoop

  ld a, 2
  call SetUserPlayerBkgTiles

  TRAMPOLINE AnnounceAndThePitch
  
.checkPitchAccuracy
  ld a, [move_data.accuracy]
  cp a, 100
  jr nc, .getSwingAI;skip if 100% accurate
  ld c, %1
  cp a, 90
  jr nc, .offsetPitchTargetByAccuracy
  ld c, %11
  cp a, 75
  jr nc, .offsetPitchTargetByAccuracy
  ld c, %111
  cp a, 60
  jr nc, .offsetPitchTargetByAccuracy
  ld c, %1111

.offsetPitchTargetByAccuracy
  ld a, c
  call SignedRandom
  ld a, [aim_x]
  add a, d
  ld [aim_x], a
  ld a, [aim_y]
  add a, e
  ld [aim_y], a

.setPitchTarget
  call StrikeZonePosition
  ld a, [aim_x]
  sub a, d
  ld [pitch_target_x], a
  ld a, [aim_y]
  sub a, e
  ld [pitch_target_y], a

.getSwingAI
  call SwingAI;populates _w_x_y_z and swing_move_id

  xor a
  ld [_u], a; _u = swing frame
  ld [pitch_z], a
  ld [pitch_z+1], a
  ld [_v], a;step
.pitchLoop
    ld d, 25;TODO: differentiate between lefties and righties
    ld e, 41
    ld a, [aim_x]
    ld h, a
    ld a, [aim_y]
    ld l, a
    ld a, [pitch_z]
    ld c, a
    ld a, [_b]
    ld b, a
    xor a
    call MovePitch

    call gbdk_WaitVBL

    ld a, [_v]
    inc a
    ld [_v], a
    cp a, DISPLAY_PITCH_NAME_DELAY
    jr z, .displayPitchName
    cp a, 4
    jr nz, .skip
    ld a, 3
    call SetUserPlayerBkgTiles  
    jr .skip

.displayPitchName
    TRAMPOLINE AnnouncePitchName 

.skip
    ld a, [_w]
    and a
    jr z, .updatePitchZ
    ld a, [_u]
    and a
    jr nz, .checkFinishSwing
.checkSwing
    ld a, [pitch_z]
    ld b, a
    ld a, [_z]
    cp a, b
    jr nc, .updatePitchZ
.swing
      ld a, 1
      call SetOpposingPlayerBkgTiles
      ld a, [_x]
      ld d, a
      ld a, [_y]
      ld e, a
      ld a, [pitch_z]
      ld [_u], a
      call Swing
      and a
      jr nz, .contactMade
      jr .updatePitchZ
.checkFinishSwing
    ld a, [_u]
    add a, 4
    ld b, a
    ld a, [_i]
    cp b
    jr nz, .updatePitchZ
      ld a, 2
      call SetOpposingPlayerBkgTiles
.updatePitchZ
    ld a, [_s];pitch speed
    ld de, 8
    call math_Multiply
    ld de, 200
    add hl, de
    ld a, [pitch_z]
    ld d, a
    ld a, [pitch_z+1]
    ld e, a
    add hl, de
    ld a, l
    ld [pitch_z+1], a
    ld a, h
    ld [pitch_z], a

    cp a, 200
    jr nc, .noSwing;if pitch_z >= 200
    ld a, [oam_buffer + BASEBALL_SPRITE_ID*4 + 1];ball x
    cp a, 168
    jp c, .pitchLoop
  
  ld a, [_u]
  and a
  jr z, .noSwing
.swingAndMiss
  TRAMPOLINE AnnounceSwingMiss
  jp FinishPitch
.contactMade
  jp HitBall
.noSwing
  TRAMPOLINE AnnounceNoSwing
  jp FinishPitch

Swing:; aim xy = de, pitch z = a, returns contact made in a
  push af;pitch z
  push de;aim xy

  call HideAimCircle  
  call HideStrikeZone

  call StrikeZonePosition
  ld a, [pitch_target_x]
  add a, d
  ld b, a
  ld a, [pitch_target_y]
  add a, e
  ld c, a;bc = pitch xy

  pop de;aim xy
  ld a, b
  sub a, d
  ld [swing_diff_x], a
  ld a, e
  sub a, c
  ld [swing_diff_y], a
  pop af;z
  sub a, 100
  ld [swing_diff_z], a

  ld a, [swing_diff_z]
  BETWEEN -20, 20
  jr nz, .checkHit
  ld a, [swing_diff_z]
  cp 128
  jr c, .late
.early
  ld hl, EarlySwingText
  call AnnounceDisplayText
  xor a
  ret
.late
  ld hl, LateSwingText
  call AnnounceDisplayText
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
  jr z, .barrel
  ld a, 1
  ret
.barrel
  ld hl, HitBarrelText
  call AnnounceDisplayText
  ld a, 1
  ret
.miss
  ld hl, SwingAndMissText
  call AnnounceDisplayText
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
  ld d, a
  ld a, [aim_y]
  ld e, a
  call MoveAimCircle;move_aim_circle(a>>1, b>>1);
  call gbdk_WaitVBL
  call gbdk_WaitVBL
  ret  

Bat:
.getPitch
  call PitchAI

.setPitchPath
  ld a, [move_data.pitch_path]
  ld [_b], a

.setPitchSpeed
  ld a, [move_data.power]
  ld [_s], a

  call LoadOpposingPlayerBkgTiles
  call LoadUserPlayerBkgTiles
  
  xor a
  call SetOpposingPlayerBkgTiles
  xor a
  call SetUserPlayerBkgTiles

.setAimSize; 100% accuracy = size 10, 50% accuracy = size 0
  ld a, [swing_move_id]
  call GetMove
  ld a, [move_data.accuracy]
  srl a
  srl a
  srl a
  ld l, a
  ld a, 255
  sub a, l
  ld h, 0
  ld l, a
  call ShowAimCircle
  
  call StrikeZonePosition
  ld a, d
  ld [aim_x], a
  ld a, e
  ld [aim_y], a
  call MoveAimCircle ;TODO: handle lefty batters
  call ShowStrikeZone

  TRAMPOLINE AnnounceBatterStepsIntoBox
  
  xor a
.preSetAimLoop
    ld [_i], a
    call Aim
    ld a, [_i]
    inc a
    cp 10
    jr nz, .preSetAimLoop

  call GetCurrentPitcherName

  TRAMPOLINE AnnouncePitcherSets

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
    cp 20
    jr nz, .postWindupAimLoop

  ld a, 2
  call SetOpposingPlayerBkgTiles

  TRAMPOLINE AnnounceAndThePitch

  xor a
  ld [_u], a; c = swing frame
  ld [pitch_z], a
  ld [_v], a
.swingLoop
    ld a, [_v]
    inc a
    ld [_v], a
    cp a, 4
    jr z, .setFinishPitchFrame
    cp a, DISPLAY_PITCH_NAME_DELAY
    jr z, .displayPitchName
    jr .aim

.setFinishPitchFrame
    ld a, 3
    call SetOpposingPlayerBkgTiles
    jr .aim

.displayPitchName
    TRAMPOLINE AnnouncePitchName

.aim
    ld a, [_u]
    and a
    jp nz, .checkFinishSwing
      call Aim

      ld a, [button_state]
      and PADF_A
      jp z, .moveBaseball
        ld a, [_v]
        ld [_u], a

        ld a, 1
        call SetUserPlayerBkgTiles

        ld a, [aim_x];x
        ld d, a
        ld a, [aim_y];y
        ld e, a
        ld a, [pitch_z];z
        call Swing
        and a
        jr nz, .hitBall

.checkFinishSwing
    ld a, [_u]
    add a, 4
    ld b, a
    ld a, [_v]
    cp b
    jr nz, .moveBaseball
      ld a, 2
      call SetUserPlayerBkgTiles

.moveBaseball
    call StrikeZonePosition
    ld a, [pitch_target_x]
    add a, d
    ld h, a
    ld a, [pitch_target_y]
    add a,e
    ld l, a
    ld d, 126;release point, TODO: differentiate between lefties and righties
    ld e, 13
    ld a, [pitch_z]
    ld c, a
    ld a, [_b]
    ld b, a
    ld a, 1
    call MovePitch
    push de;ball pos
    call gbdk_WaitVBL

.updatePitchZ
    ld a, [_s];pitch speed
    ld de, 20
    call math_Multiply
    ld de, 1000
    add hl, de
    ld a, [pitch_z]
    ld d, a
    ld a, [pitch_z+1]
    ld e, a
    add hl, de
    ld a, l
    ld [pitch_z+1], a
    ld a, h
    ld [pitch_z], a

    pop de;ball pos
    cp a, 120
    jr nc, .exitSwingLoop
    ld a, d
    cp a, 168
    jp c, .swingLoop
.exitSwingLoop
  ld a, [_u]
  and a
  jr nz, .swingAndMiss
  jp .noSwing
.hitBall
  jr HitBall
.noSwing
  TRAMPOLINE AnnounceNoSwing
  jp FinishPitch
.swingAndMiss
  TRAMPOLINE AnnounceSwingMiss
  jp FinishPitch

HitBall:
  call HideBaseball
  call HideAimCircle  

  ld de, 100;TODO: replace delay with ball flying off screen
  call gbdk_Delay

  call IsUserFielding
  ld a, 2
  jr z, .userBatting
.opponentBatting
  call SetOpposingPlayerBkgTiles
  jr .delay
.userBatting
  call SetUserPlayerBkgTiles
.delay
  ld de, 100
  call gbdk_Delay

  call GetExitVelocityAndAngle
  
  push af;exit velocity
  ld a, [animation_style]
  and a
  jr nz, .announceContact
.loadSimulation
  pop af;exit velocity
  call LoadSimulation;a = exit velocity b = spray angle c = launch angle
  call SetupGameUI
  call ShowPitcher
  call ShowBatter
  jr FinishPitch
.announceContact
  pop af;exit velocity
  call AnnounceSwingContact;a = exit velocity b = spray angle c = launch angle
  ;fall through to FinishPitch  

FinishPitch:
  call HideBaseball
  call HideStrikeZone

  ld d, -8
  ld e, -8
  call MoveAimCircle

  xor a
  call SetUserPlayerBkgTiles
  xor a
  call SetOpposingPlayerBkgTiles
  
  ld de, 100
  call gbdk_Delay
  ret

GetExitVelocityAndAngle:;returns velocity in a, spray in b, launch in c  
  ld a, [swing_move_id]
  call GetMove

  ld a, [move_data.accuracy]
  ld b, a
  ld a, 110
  sub a, b
  srl a
  ld d, 0
  ld e, a
  push de;110-accuracy

.xAccuracy
  ld a, [swing_diff_x]
  call math_SignedMultiply
  ld a, h
  and a, %10000000;discard everything but sign from upper byte
  srl l;discard lowest bit from lower byte
  or a, l;combine sign with lower byte
  ld b, a;degrees left or right, discards upper byte, keeps sign
  ;TODO: multiply by move_data.spray_angle, divide by max x diff
  ;TODO: offset by move_data.pull * 45 * handedness

.yAccuracy
  pop de;110-accuracy
  ld a, [swing_diff_y]
  call math_SignedMultiply
  ld a, h
  and a, %10000000;discard everything but sign from upper byte
  srl l;discard lowest bit from lower byte
  or a, l;combine sign with lower byte
  ld c, a;degrees up or down, discards upper byte, keeps sign
  
  ;.addMoveLaunchAngle
  ; ld a, [move_data.launch_angle]
  ; add a, c
  ; ld c, a;launch angle

  push bc;spray,launch

  call GetCurrentBatter
  call GetPlayerBat
  ld d, h
  ld e, l
  ld a, [move_data.power]
  call math_Multiply;hl =power * bat
  sla h
  jr nc, .skip
  ld h, 255
.skip
  ld a, [swing_diff_z]
  call math_Abs
  srl a
  ld d, a
  ld a, h;discard lower byte
  add a, 127
  sub a, d;reduce power by swing diff

  pop bc;spray,launch
  ret

PlayBall:; a = selected move
  push af;move
  call GetCurrentUserPlayer
  call IsUserFielding
  jr nz, .userPitching
.userBatting
  ld d, BATTING_MOVES
  pop af;move
  call GetPlayerMove
  ld a, [move_data.id]
  ld [swing_move_id], a
  call Bat
  jr .exit
.userPitching
  ld d, PITCHING_MOVES
  pop af;move
  call GetPlayerMove
  ld a, [move_data.id]
  ld [pitch_move_id], a
  call Pitch
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

SGBPlayBallPalSet: PAL_SET PALETTE_UI, PALETTE_DARK, PALETTE_GREY, PALETTE_GREY
SGBPlayBallAttrBlk:
  ATTR_BLK 3
  ATTR_BLK_PACKET %001, 0,0,0, 0,0, 20,18 ;main UI
  ATTR_BLK_PACKET %001, 2,2,2, 0,5,   8,7 ;user player
  ATTR_BLK_PACKET %001, 3,3,3, 12,0,  8,7 ;opposing player
  
SetPlayerColors::;since SGB requires 2 palettes to change at the same time, always set both players
  ld hl, SGBPlayBallPalSet               
  call SetPalettesIndirect
  ld hl, SGBPlayBallAttrBlk
  ld b, DRAW_FLAGS_BKG
  call SetColorBlocks
  
  call GetCurrentUserPlayer
  call GetPlayerNumber
  call LoadPlayerBaseData
  ld hl, player_base.sgb_pal
  ld a, [hli]
  ld c, a
  ld a, [hli]
  ld b, a
  push bc;user palette

  call GetCurrentOpponentPlayer
  call GetPlayerNumber
  call LoadPlayerBaseData
  ld hl, player_base.sgb_pal
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
  SHOW_SPRITES
  
  CLEAR_BKG_AREA 12, 0, 7, 7, " "
  ret

Transition:
  call CopyBkgToWin
  ld a, 7
  ld [rWX], a
  xor a
  ld [rWY], a
  SHOW_WIN
  ld hl, tile_buffer
  xor a
  ld [hli], a
  ld a, OCCUPIED_BASE
  ld [hli], a
  xor a
  ld [hli], a
  ld [hl], a
  ld de, 0
.rowLoop
  .columnLoop
      push de
      ld hl, $0201
      ld bc, tile_buffer
      call gbdk_SetWinTiles

      pop de
      push de
      ld a, 17
      sub a, e
      ld e, a
      ld a, 19
      sub a, d
      ld d, a
      
      ld hl, $0201
      ld bc, tile_buffer+2
      jr z, .skip
      dec bc
    .skip
      call gbdk_SetWinTiles

      ld de, 10
      call gbdk_Delay
      pop de
      inc d
      ld a, 20
      cp a, d
      jr nz, .columnLoop
    ld d, 0
    inc e
    ld a, 9
    cp a, e
    jr nz, .rowLoop
  ret 

StartGame::
  PLAY_SONG tessie_data, 1
  call LoadFontTiles
  call Transition

.loadBaseball
  DISPLAY_OFF
  SET_DEFAULT_PALETTE

  ld a, BANK(PlayBallSgbBorderTiles)
  ld hl, PlayBallSgbBorderTiles
  ld de, PlayBallSgbBorderTileMap
  call sgb_SetBorder

  ld hl, SGBPlayBallPalSet
  call SetPalettesIndirect

  xor a
  ld [rSCX], a
  ld [rSCY], a
  CLEAR_SCREEN " "
  
  call SetPlayBallTiles

  ;EXAMPLE: ld a, (3 << 4) | (2 << 2) | 1 ;3 balls, 2 strikes, 1 out
  xor a;0 balls, 0 strikes, 0 outs
  ld [balls_strikes_outs], a
  
  ;EXAMPLE: ld bc, (9 << 8) | 5 ;9th batter on third, 5th batter on first
  ld bc, 0; nobody on
  ld hl, runners_on_base
  ld a, b
  ld [hli], a
  ld a, c
  ld [hl], a

  xor a
  ld [frame], a
  ld [move_choice], a
  ld [home_score], a
  ld [away_score], a
  ld [current_batter], a
  ; ld a, 1
  ld [home_team], a

  call GetCurrentOpponentPlayer
  call GetPlayerNumber
  ld [_a], a; player num

  ld a, [game_state]
  and a, ~GAME_STATE_UNSIGNED_PLAYER
  or a, GAME_STATE_UNSIGNED_PLAYER; TODO: replace with team/random encounter
  ld [game_state], a

  call ShowPlayBallIntro
  call SetupGameUI
  TRAMPOLINE AnnounceBeginningOfFrame

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
    call GetUserPitcherOrder
    push af
    ld b, 0
    call ShowLineup
    call GetUserPitcherOrder
    push af;current pitcher
    call SetupGameUI
    call ShowBatter
    pop af;current pitcher
    pop bc;previous pitcher
    cp a, b
    jr z, .skip
    call IsUserFielding
    jr z, .skip
    TRAMPOLINE AnnouncePitcher
    HIDE_WIN
.skip
    call ShowPitcher
    jr .playBallLoop
.itemMenuItemSelected
    cp 2
    jr nz, .runMenuItemSelected
    call CopyBkgToWin
    ld a, 7
    ld [rWX], a
    xor a
    ld [rWY], a
    SHOW_WIN
    ld a, INVENTORY_MODE_USE
    ld [inventory_mode], a
    call ShowInventory
    HIDE_WIN
    call SetupGameUI
    call ShowPitcher
    call ShowBatter
    jr .playBallLoop
.runMenuItemSelected
    cp 3
    jr nz, .playBallLoop
    ; ld hl, QuittingIsNotAnOptionText
    ; call RevealTextAndWait
    ; HIDE_WIN
    ; jp .playBallLoop
.exitPlayBallLoop
  call sgb_SetDefaultBorder
  ret
