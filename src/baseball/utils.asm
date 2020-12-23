BASEBALL_SPRITE_ID EQU 0
AIM_CIRCLE_SPRITE_ID EQU 3
STRIKEZONE_SPRITE_ID EQU 10

BALLS_MASK   EQU %01110000
STRIKES_MASK EQU %00001100
OUTS_MASK    EQU %00000011

FIRST_BASE_MASK  EQU $000F
SECOND_BASE_MASK EQU $00F0
THIRD_BASE_MASK  EQU $0F00
HOME_MASK        EQU $F000

SECTION "Baseball Utils Bank 0", ROM0
; GetBalls                        returns (balls_strikes_outs & BALLS_MASK) >> 4 in a
; SetBalls                        a = balls
; GetStrikes                      returns (balls_strikes_outs & STRIKES_MASK) >> 2 in a
; SetStrikes                      a = strikes
; FoulBall                        increments strikes if less than 2
; AdvanceRunners                  b = bases to advance, c = runner to put on first, returns runs sored in a
; GetOuts                         returns balls_strikes_outs & OUTS_MASK in a
; SetOuts                         a = outs
; IncrementOuts                   returns outs in a
; CheckStrike                     returns ball (z) or strike (nz)
; GetPositionPlayerAndName        a = position number (1-9), returns position player in hl, name in [name_buffer]
; DistanceFromSpeedLaunchAngle    a = speed, c = launch angle, returns distance in a
; HeightFromSpeedLaunchAngle      a = speed, c = launch angle, returns height in a
; HangTimeFromSpeedLaunchAngle    a = speed, c = launch angle, returns hang time in a
; LocationFromDistSprayAngle      a = distance, b = spray angle, returns xy in de
; GetClosestFielderByLocation     de = xy, returns position number in a
; IsUserFielding                  nz = user is fielding, z = user is batting
; CurrentOrderInLineup            returns order in a
; GetPitchBreak                   b = path, c = z, returns xy offset in de

GetBalls::; returns (balls_strikes_outs & BALLS_MASK) >> 4 in a
  ld a, [balls_strikes_outs]
  and BALLS_MASK
  swap a
  ret

SetBalls::; a = balls
  swap a
  and BALLS_MASK
  ld b, a
  ld a, [balls_strikes_outs]
  and ~BALLS_MASK
  or a, b
  ld [balls_strikes_outs], a
  ret

GetStrikes::; returns (balls_strikes_outs & STRIKES_MASK) >> 2 in a
  ld a, [balls_strikes_outs]
  and STRIKES_MASK
  srl a
  srl a
  ret

SetStrikes::; a = strikes
  sla a
  sla a
  and STRIKES_MASK
  ld b, a
  ld a, [balls_strikes_outs]
  and ~STRIKES_MASK
  or a, b
  ld [balls_strikes_outs], a
  ret

FoulBall::
  call GetStrikes
  cp a, 2
  ret nc 
  inc a
  call SetStrikes
  ret

; b = bases to advance, c = batter (1-9) to put on first or 0
; returns runs scored in a, last scoring runner in upper nibble of runners_on_base
AdvanceRunners::
  xor a
  ld e, a;runs scored
.loop
  .clearHome
    ld a, [runners_on_base]
    and a, %00001111;clear run 
    ld [runners_on_base], a
  .firstToSecond
    ld a, [runners_on_base+1]
    swap a;first base runner moved to second
    ld d, a;second base runner in lower nibble
    and a, %11110000;clear first base
    or a, c;put batter (or nothing) on first
    ld c, 0;clear batter after first use
    ld [runners_on_base+1], a
    ld a, d;second base runner in lower nibble
    and %00001111;second base runner
  .secondToThird
    ld d, a;second base runner
    ld a, [runners_on_base]
    swap a;third base runner (if any) scores
    or a, d;second base runner moved to third
    ld [runners_on_base], a;store scoring runner (if any) and new runner on third
    and a, %11110000
    jr z, .checkDone
  .runScores
    inc e;score  
    ; TODO: add to runner stats
  .checkDone
    dec b;bases
    jr nz, .loop
.done
  ld a, e;runs scored
  and a
  ret z;done if no runs scored
  ;otherwise fall through to ScoreRuns

ScoreRuns::; a = runs, returns runs in a
  ld b, a
  call IsUserFielding
  ld a, [home_team]
  jr z, .userIsBatting
.opponentIsBatting
  and a
  jr z, .homeScored
  jr .awayScored
.userIsBatting
  and a
  jr nz, .homeScored
.awayScored
  ld a, [away_score]
  add a, b;add runs
  ld [away_score], a
  ld b, a;runs
  ret
.homeScored
  ld a, [home_score]
  add a, b;add runs
  ld [home_score], a
  ld a, b;runs
  ret

GetOuts::; returns balls_strikes_outs & OUTS_MASK in a
  ld a, [balls_strikes_outs]
  and OUTS_MASK
  ret

SetOuts::; a = outs
  and OUTS_MASK
  ld b, a
  ld a, [balls_strikes_outs]
  and ~OUTS_MASK
  or a, b
  ld [balls_strikes_outs], a
  ret

IncrementOuts::;increments outs, returns outs in a
  call GetOuts
  inc a
  cp 3
  jp z, .threeOuts
  call SetOuts
  ret
.threeOuts
  xor a
  ld [balls_strikes_outs], a
  ld [runners_on_base], a
  ld [runners_on_base+1], a
  TRAMPOLINE NextFrame
  TRAMPOLINE DrawCountOutsInning
  ld a, 3
  ret

CheckStrike:: ;returns ball (z) or strike (nz)
  ld a, [_b]
  ld b, a
  ld c, 100
  call GetPitchBreak
  ld a, [pitch_target_x]
  sra d
  add a, d
  BETWEEN -12, 12
  ret z
  ld a, [pitch_target_y]
  sra e
  add a, e
  BETWEEN -16, 16
  ret

;----------------------------------------------------------------------
;
; GetPositionPlayerAndName - returns current player/name at position 
;
;   input: a = position number (1-9)
;   returns: name_buffer = position player's name
;            hl = position player address
;
;----------------------------------------------------------------------
GetPositionPlayerAndName::
  ld b, a;position number
  ld a, [loaded_bank]
  push af;bank
  ld a, PLAY_BALL_BANK
  call SetBank
  push bc;position number
  call IsUserFielding
  jr nz, .userIsFielding
.opponentIsFielding
  pop af;position number
  call GetOpposingPlayerByPosition
  push hl;player
  ld a, [hl]
  call GetPlayerName
  jr .exit
.userIsFielding
  pop af;position number
  call GetUserPlayerByPosition
  push hl;player
  call GetUserPlayerName
.exit
  pop hl;player
  pop af;bank
  call SetBank
  ret

;----------------------------------------------------------------------
;
; DistanceFromSpeedLaunchAngle - calculates distance speed and angle
;
;   input: 
;     a = speed (0 to 255)
;     c = launch angle (-127 to 127)
;   returns:
;     a = distance
;
;----------------------------------------------------------------------
DistanceFromSpeedLaunchAngle::;a = speed, c = launch angle, returns distance in a
  push af;speed
  ld a, c
  cp a, 128;if 0<c<128, .inAir
  jr c, .inAir

.onGround
  pop af;speed
  srl a;d = speed/2 ... TODO: this could be done better
  ret

.inAir ;d = v^2 * sin(2 * ang) / g
  add a, a
  call math_Sin255
  ld b, a;sin(2*ang)*255
  pop af;speed
  push bc
  ld d, 0
  ld e, a
  call math_Multiply;v^2
  pop bc
  ld d, 0
  ld e, b
  call math_Multiply16;v^2 * sin(2*ang)*255
  ld a, c;v^2 * sin(2*ang)/g... bcde -> a, assumes b == 0, drops lower word
  ret

;----------------------------------------------------------------------
;
; HeightFromSpeedLaunchAngle
;   input:
;     a = speed
;     c = launch angle
;   returns:
;     a = height
;
;----------------------------------------------------------------------
HeightFromSpeedLaunchAngle::;a = speed, c = launch angle, returns height in a
  push af;speed
  ld a, c
  cp a, 128;if 0<c<128, .inAir
  jr c, .inAir

.onGround
  pop af;speed
  xor a
  ret

.inAir ;h = v^2 * sin(ang)^2 / 2*g
  call math_Sin255
  ld d, 0
  ld e, a;sin(ang)*255
  call math_Multiply;65025*sin(ang)^2
  pop af;speed
  push hl
  ld d, 0
  ld e, a
  call math_Multiply;v^2
  pop bc;b = 255 * sin(ang)^2

  ld d, 0
  ld e, b
  call math_Multiply16;v^2 * 255 * sin(ang)^2
  ld a, c;v^2 * sin(ang)^2/2*g... bcde -> a, assumes b == 0, drops lower word
  ret

;----------------------------------------------------------------------
;
; HangTimeFromSpeedLaunchAngle
;   input:
;     a = speed
;     c = launch angle
;   returns:
;     a = hang time (255 = 10 sec)
;
;----------------------------------------------------------------------
HangTimeFromSpeedLaunchAngle::
  push af;speed
  ld a, c
  cp a, 128;if 0<c<128, .inAir
  jr c, .inAir

.onGround
  pop af;speed
  xor a
  ret

.inAir ; t = 2 * v * sin(ang) / g
  call math_Sin255
  ld b, a;sin(ang)*255
  pop af;v
  push bc
  ld h, 0
  ld l, a;v
  add hl, hl;2*v
  pop bc
  ld d, 0
  ld e, b
  call math_Multiply16;2 * v * sin(ang)*255
  ld a, c;2 * v * sin(ang) / g... bcde -> a, 255 if c > 0, else d
  and a
  ld a, 255
  ret nz
  ld a, d
  ret

;----------------------------------------------------------------------
;
; LocationFromDistSprayAngle - calculates landing spot from dist spray angle
;
;   input: 
;     a = distance (0 to 255)
;     b = spray angle (-127 to 127)
;   returns:
;     de = xy position
;
;----------------------------------------------------------------------
LocationFromDistSprayAngle::;a = distance, b = spray angle, returns xy in de
  push af;distance
  ld a, b;spray
  cp 128
  ld b, a;spray
  ld a, 45
  jr c, .posSpray
.negSpray;-127 <= spray < 0
  sub a, b;45 <= angle <=172
  jr .posAng
.posSpray; 0 <= spray < 128
  sub a, b;-82 <= angle < 45
  jr nc, .posAng
  ld b, a;neg ang
  ld a, 255
  sub a, b

.negAng; -82 < angle < 0
  ld e, 0;y is foul
  jr .testX
.posAng; 0 <= angle < 172
  ld e, %10;y is fair

.testX
  cp a, 90
  jr c, .posX
.negX
  ld d, 0;x is foul
  jr .calcXY
.posX
  ld d, %01;x is fair

.calcXY
  ld b, a;angle
  ld a, d;x fair/foul
  or a, e;y fair/foul
  ld [_t], a;xy fair/foul
  pop af;distance
  ld d, 0
  ld e, a;distance
  ld a, b;angle
  push de;distance
  push af;angle
  call math_Cos255
  call math_Multiply
  ld a, h;discard lower byte
  ld [ball_pos_x], a

  pop af;angle
  pop de; distance
  call math_Sin255
  call math_Multiply
  ld a, h;discard lower byte
  ld [ball_pos_y], a

.offsetX
  ld a, [_t]
  and a, %01;test x
  ld a, [ball_pos_x]
  jr z, .xFoul
.xFair
  add a, HOME_PLATE_X
  ld d, a
  jr nc, .offsetY
  ld d, 255
  jr .offsetY
.xFoul
  ld b, a
  ld a, HOME_PLATE_X
  sub a, b
  ld d, a
  jr nc, .offsetY
  ld d, 0

.offsetY
  ld a, [_t]
  and a, %10;test y
  ld a, [ball_pos_y]
  jr z, .yFoul
.yFair
  ld b, a
  ld a, HOME_PLATE_Y
  sub a, b
  ld e, a
  ret nc
  ld e, 0
.yFoul
  add a, HOME_PLATE_Y
  ld e, a
  ret nc
  ld e, 255
  ret

XLocationsOfPositions::
  DB  82,  36, 128, 164,  63, 92, 88, 193, 216
YLocationsOfPositions::
  DB 174, 219, 199, 159, 119, 92, 38,  67, 191
GetClosestFielderByLocation::;de = xy, returns position number in a, distance in b
  ld a, 255
  ld [_t], a;min dist
  xor a
  ld [_i], a;index
  ld [_c], a;closest position
.loop
    push de;ball xy
    ld a, [_i]
    ld b, 0
    ld c, a
    ld hl, XLocationsOfPositions
    add hl, bc
    ld a, [hl]
    ld d, a;player x
    ld hl, YLocationsOfPositions
    add hl, bc
    ld a, [hl]
    ld e, a;player y
    pop hl;ball xy
    push hl;ball xy
    call math_Distance
    ld d, a;distance from player
    ld a, [_t];distance from closest player
    cp a, d
    jr c, .notCloser
.closer
    ld a, d
    ld [_t], a;distance from closest
    ld a, [_i]
    ld [_c], a;closest position
.notCloser
    pop de;ball xy
    ld a, [_i]
    inc a
    ld [_i], a
    cp a, 9
    jr nz, .loop
  ld a, [_t]
  ld b, a;distance
  ld a, [_c]
  inc a;position
  ret

IsUserFielding::;nz = user is fielding, z = user is batting
  push bc
  ld a, [home_team];1 = user is home team
  ld b, a
  ld a, [frame];1 = bottom
  and a, %00000001
  xor a, b;home != frame
  pop bc
  ret

CurrentOrderInLineup::;returns order in a
  call IsUserFielding
  ld a, [current_batter]
  jr z, .skip
  swap a;opponent is in upper nibble
.skip
  and a, %00001111;zero out other team
  ret

GetPitchBreak:: ;b = path, c = z, returns xy offset in de
  ld a, [loaded_bank]
  push af
  ld a, BANK(_GetPitchBreak)
  call SetBank
  call _GetPitchBreak
  pop af
  call SetBank
  ret

SECTION "Baseball Utils Bank X", ROMX, BANK[PLAY_BALL_BANK]
; StrikeZonePosition - returns strike zone pos in de; 
; PutBatterOnFirst - upper nibble of runners_on_base stores scoring runner (if any)
; HealthPctToString - a = health_pct, returns str_buff
; BattingAvgToString - de = batting average*1000, returns str_buff
; EarnedRunAvgToString - hl = ERA*100, returns str_buff
; NextFrame
; NextBatter
; ShowBatter
; ShowPitcher
; ShowUserPlayer
; ShowOpposingPlayer
; GetUserPitcher - puts user pitcher's player data in hl
; GetUserBatter - puts user batter's player data in hl
; GetOpponentPitcher - puts opposing pitcher's player data in hl
; GetOpponentBatter - puts opposing batter's player data in hl
; GetCurrentBatter - puts batter's player data in hl
; GetCurrentBatterName - puts batter's name in name_buffer
; GetCurrentPitcher - puts pitcher's player data in hl
; GetCurrentPitcherName - pust pitcher's name in name_buffer
; GetCurrentUserPlayer - puts user's current batter or pitcher player data in hl
; GetCurrentOpponentPlayer - puts opponent's current batter or pitcher player data in hl

_GetPitchBreak: ;b = path, c = z, returns xy offset in de
  ld de, 0

  ld a, b;path
  cp PITCH_PATH_STRAIGHT
  ret z
  cp PITCH_PATH_EEPHUS
  jr z, .eephus
  cp PITCH_PATH_KNUCKLE
  jr z, .knuckle

  ld hl, PitchPathBreak
  ld b, 0
  add hl, bc
  ld b, a;path
  ld a, [hl]
  ld c, a;break
  ld a, b;path

.curve
  cp PITCH_PATH_CURVE
  jr nz, .fade
  ld e, c
  jr .hand

.fade
  cp PITCH_PATH_FADE
  jr nz, .slider
  sra c
  ld a, 255
  sub a, c
  ld d, c
  jr .hand

.slider
  cp PITCH_PATH_SLIDER
  jr nz, .rise
  ld d, c
  jr .hand

.rise
  cp PITCH_PATH_RISE
  jr nz, .drop
  sra c
  ld a, 255
  sub a, c
  ld e, c
  jr .hand

.drop
  cp PITCH_PATH_DROP
  jr nz, .eephus
  sra c
  ld e, c
  jr .hand

.screw
  cp PITCH_PATH_SCREW
  jr nz, .slurve
  ld e, c
  ld a, 255
  sub a, c
  ld d, a
  jr .hand

.slurve
  cp PITCH_PATH_SLURVE
  jr nz, .cut
  ld d, c
  ld e, c
  jr .hand

.cut
  cp PITCH_PATH_CUT
  ret nz
  sra c
  ld e, c
  jr .hand

.eephus
  
.knuckle

.hand

  ret

PitchAI::;returns pitch_move_id
  ld a, %00001111
  call SignedRandom
  ld a, d
  ld [pitch_target_x], a
  ld a, e
  ld [pitch_target_y], a

  call GetCurrentPitcher
  push hl;pitcher
  ld d, PITCHING_MOVES
  call GetPlayerMoveCount
  ld c, a;move count
  ld a, [rand_lo]
  ld h, a
  ld a, [rand_hi]
  ld l, a
  call math_Divide; rand % move_count

  pop hl;pitcher
  ld d, PITCHING_MOVES
  call GetPlayerMove
  ld a, [move_data.id]
  ld [pitch_move_id], a
  ret

SwingAI:: ;returns [_w] = swing/no swing, [_x][_y][_z] = swing timing/location, selected [swing_move_id]
  call gbdk_Random
  ld a, [pitch_target_x]
  call math_Abs
  ld b, a
  ld a, [pitch_target_y]
  call math_Abs
  add a, b;Manhattan distance from center
  ld b, a
  ld a, 192
  sub a, b;less likely to swing the farther the ball is from dead center
  cp a, e
  jr c, .noSwing
.swing
  ld a, 1
  ld [_w], a

.setSwingXY
  ld a, d;rand
  and a, 31
  sub a, 15
  ld b, a
  ld a, [pitch_target_x]
  add a, b
  ld [_x], a

  ld a, d;rand
  swap a
  and a, 31
  sub a, 15
  ld b, a
  ld a, [pitch_target_y]
  add a, b
  ld [_y], a
  
.setSwingTiming
  ld a, e;rand
  and a, %10000111
  add a, 100
  ld [_z], a

.adjustSwingXYToZone
  call StrikeZonePosition
  ld a, [_x]
  add a, d
  ld [_x], a
  ld a, [_y]
  add a, e
  ld [_y], a

.addBreakOffsetToSwingXY
  call GetCurrentPitcher
  ld d, PITCHING_MOVES
  call GetPlayerMove
  ld a, [move_data.pitch_path]
  ld b, a
  ld c, 100
  call GetPitchBreak
  ld a, [_x]
  add a, d
  ld [_x], a
  ld a, [_y]
  add a, e
  ld [_y], a

  call GetCurrentBatter
  push hl;batter
  ld d, BATTING_MOVES
  call GetPlayerMoveCount
  ld c, a;move count
  ld a, [rand_lo]
  ld h, a
  ld a, [rand_hi]
  ld l, a
  call math_Divide; rand % move_count

  pop hl;batter
  ld d, BATTING_MOVES
  call GetPlayerMove
  ld a, [move_data.id]
  ld [swing_move_id], a

  ret
.noSwing
  xor a
  ld [_w], a
  ret

StrikeZonePosition:: ; returns strike zone pos in de
  call IsUserFielding
  jr nz, .userIsPitching
.userIsBatting
  call GetCurrentUserPlayer
  call GetPlayerHandedness
  ld b, a;handedness
  and a, BAT_LEFT
  jr nz, .userBatsLeft
.userBatsRight
  ld d, 52
  ld e, 87
  ret
.userBatsLeft
  ld a, b;handedness
  and BAT_RIGHT
  jr .userBatsSwitch
  ld d, 20
  ld e, 87
  ret
.userBatsSwitch
  ld d, 20
  ld e, 87
  ret
.userIsPitching
  call GetCurrentOpponentPlayer
  call GetPlayerHandedness
  ld b, a;handedness
  and a, BAT_LEFT
  jr nz, .opponentBatsLeft
.opponentBatsRight
  ld d, 114
  ld e, 42
  ret
.opponentBatsLeft
  ld a, b;handedness
  and BAT_RIGHT
  jr .opponentBatsSwitch
  ld d, 146
  ld e, 42
  ret
.opponentBatsSwitch
  ld d, 146
  ld e, 42
  ret

PutBatterOnFirst::;upper nibble of runners_on_base stores scoring runner (if any)
  ld a, [runners_on_base+1]
  and a, FIRST_BASE_MASK
  jr z, .putBatterOnFirst
.putRunnerOnSecond
  ld a, [runners_on_base+1]
  swap a
  ld b, a;second base runner in lower nibble
  and a, SECOND_BASE_MASK
  ld [runners_on_base+1], a;first base runner moved to second
  ld a, b;second base runner in lower nibble
  and %00001111;second base runner
  jr z, .putBatterOnFirst
.putRunnerOnThird
  ld b, a;second base runner
  ld a, [runners_on_base]
  swap a;third base runner (if any) scores
  or a, b;second base runner moved to third
  ld [runners_on_base], a;store scoring runner (if any) and new runner on third
.putBatterOnFirst
  ld a, [runners_on_base+1]
  and a, SECOND_BASE_MASK
  push af;second base runner
  call CurrentOrderInLineup
  inc a;current batter is 0 to 8, needs to be 1 to 9
  pop bc;b=second base runner
  or a, b
  ld [runners_on_base+1], a
  call DrawBases
  ret

HealthPctToString:: ;a = health_pct, returns str_buff
  ld hl, str_buffer
  cp 100; if (a >= 100) strcpy(str_buff, "100");
  jr c, .lessThan100
  ld a, "1"
  ld [hli], a
  ld a, "0"
  ld [hli], a
  ld [hli], a
  ret
.lessThan100
  cp 10 ; if (a < 10) sprintf(str_buff, "0%d%c", a, '%');
  jr nc, .doubleDigits
  push af
  ld a, " "
  ld [hli], a
  pop af
  add a, 48
  ld [hli], a
  ld a, "%"
  ld [hl], a
  ret
.doubleDigits; else sprintf(str_buff, "%d%c", a, '%');
  ld d, h
  ld e, l
  ld l, a
  xor a
  ld h, a
  call str_Number
  ld hl, str_buffer+2
  ld a, "%"
  ld [hl], a
  ret

BattingAvgToString:: ;de = batting average*1000, returns str_buff
  ld hl, str_buffer
  ld a, d
  cp $3
  jr c, .not1000
  ld a, e
  cp $E8
  jr c, .not1000; if (a >= 1000) strcpy(str_buff, "1.000");
    ld a, "1"
    ld [hli], a
    ld a, "."
    ld [hli], a
    ld a, "0"
    ld [hli], a
    ld [hli], a
    ld [hl], a
    ret
.not1000
  ld a, d
  and a
  jr nz, .notUnder100
  ld a, e
  cp 100
  jr c, .under100; else sprintf(str_buff, ".%d", a);
.notUnder100
    ld a, "."
    push de
    ld [hli], a
    ld d, h
    ld e, l
    pop hl
    call str_Number
    ret
.under100
  ld a, e
  cp 10
  jr c, .under10; else if (a < 100) sprintf(str_buff, ".0%d", a);
    ld a, "."
    ld [hli], a
    ld a, "0"
    ld [hli], a
    push de
    ld [hl], a
    ld d, h
    ld e, l
    pop hl
    call str_Number
    ret
.under10; else if (a < 10) sprintf(str_buff, ".00%d", a);
  ld a, "."
  ld [hli], a
  ld a, "0"
  ld [hli], a
  ld [hli], a
  ld a, e
  add a, 48
  ld [hl], a
  ret

;TODO: fix this broken function
EarnedRunAvgToString:: ;hl = ERA*100, returns str_buff
  ld a, 100
  call math_Divide; hl = hl/100, a = hl%100
  push af

  ld de, str_buffer
  ld a, h
  cp $3
  jr c, .not1000
  ld a, l
  cp $E8
  jr c, .not1000; if (hl >= 1000) sprintf(str_buff, "%d", hl);
  call str_Number
  pop af
  ret
.not1000; else sprintf(str_buff, "%d.%d", hl, a);
  ld de, str_buffer
  call str_Number

  ld hl, name_buffer
  ld a, "."
  ld [hli], a
  xor a
  ld [hld], a
  ld de, str_buffer
  call str_Append

  ld de, name_buffer
  pop af ;remainder
  ld h, 0
  ld l, a
  call str_Number

  ld de, str_buffer
  ld hl, name_buffer
  call str_Append
  dec de
  ld a, " "
  ld [de], a
  ret

;Show Player utils
NextFrame::
  ld a, [frame]
  inc a
  ld [frame], a
  TRAMPOLINE AnnounceBeginningOfFrame
  ret

NextBatter::
  call IsUserFielding
  jr nz, .nextOpponentBatter
.nextUserBatter
  ld a, [current_batter]
  and %00001111
  inc a
  cp 9
  jr c, .notTopOfUserLineup
  ld a, 0
.notTopOfUserLineup
  ld b, a
  ld a, [current_batter]
  and a, %11110000
  or a, b
  ld [current_batter], a
  ret
.nextOpponentBatter
  ld a, [current_batter]
  swap a
  and %00001111
  inc a
  cp 9
  jr c, .notTopOfOpponentLineup
  ld a, 0
.notTopOfOpponentLineup
  ld b, a
  swap b
  ld a, [current_batter]
  and a, %00001111
  or a, b
  ld [current_batter], a
  ret

ShowBatter::
  call IsUserFielding
  jp z, ShowUserPlayer
  jp ShowOpposingPlayer

ShowPitcher::
  call IsUserFielding
  jp z, ShowOpposingPlayer
  jp ShowUserPlayer

ShowUserPlayer::
  xor a
  call DrawPlayerUI
  call SetPlayerColors
  call LoadUserPlayerBkgTiles
  xor a
  call SetUserPlayerBkgTiles
  ret

ShowOpposingPlayer::
  ld a, 1
  call DrawPlayerUI
  call SetPlayerColors
  call LoadOpposingPlayerBkgTiles
  xor a
  call SetOpposingPlayerBkgTiles
  ret

; Get Player Data
GetUserPitcher::;puts user pitcher's player data in hl
  ld a, 1
  call GetUserPlayerByPosition
  ret

GetUserBatter::;puts user batter's player data in hl
  ld a, [current_batter]
  and a, %00001111
  call GetUserPlayerInLineup
  ret
  
GetOpponentPitcher::;puts opposing pitcher's player data in hl
  ld a, 1
  call GetOpposingPlayerByPosition
  ret

GetOpponentBatter::;puts opposing batter's player data in hl
  ld a, [current_batter]
  swap a
  and a, %00001111
  call GetOpposingPlayerInLineup
  ret

GetCurrentBatter:: ;puts batter's player data in hl
  call IsUserFielding
  jp nz, GetOpponentBatter
  jp GetUserBatter

GetCurrentBatterName:: ;puts batter's name in name_buffer
  call IsUserFielding
  jr nz, .getOpponentBatter
  call GetUserBatter
  call GetUserPlayerName
  ret
.getOpponentBatter
  call GetOpponentBatter
  call GetPlayerNumber
  call GetPlayerName
  ret

GetCurrentPitcher:: ;puts pitcher's player data in hl
  call IsUserFielding
  jp z, GetOpponentPitcher
  jp GetUserPitcher

GetCurrentPitcherName:: ;pust pitcher's name in name_buffer
  call IsUserFielding
  jr z, .getOpponentPitcher
  call GetUserPitcher
  call GetUserPlayerName
  ret
.getOpponentPitcher
  call GetOpponentPitcher
  call GetPlayerNumber
  call GetPlayerName
  ret

GetCurrentUserPlayer::;puts user's current batter or pitcher player data in hl
  call IsUserFielding
  jp z, GetUserBatter
  jp GetUserPitcher

GetCurrentOpponentPlayer::;puts opponent's current batter or pitcher player data in hl
  call IsUserFielding
  jp z, GetOpponentPitcher
  jp GetOpponentBatter