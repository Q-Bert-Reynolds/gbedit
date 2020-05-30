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

; GetBalls - returns (balls_strikes_outs & BALLS_MASK) >> 4 in a
; SetBalls - a = balls
; GetStrikes - returns (balls_strikes_outs & STRIKES_MASK) >> 2 in a
; SetStrikes - a = strikes
; GetOuts - returns balls_strikes_outs & OUTS_MASK in a
; SetOuts - a = outs
; IncrementOuts - returns outs in a
; CheckStrike - returns ball (z) or strike (nz)
; StrikeZonePosition - returns strike zone pos in de; 
; PutBatterOnFirst - upper nibble of runners_on_base stores scoring runner (if any)
; HealthPctToString - a = health_pct, returns str_buff
; BattingAvgToString - de = batting average*1000, returns str_buff
; EarnedRunAvgToString - hl = ERA*100, returns str_buff
; CurrentOrderInLineup - returns order in a
; NextFrame
; NextBatter
; ShowBatter
; ShowPitcher
; ShowUserPlayer
; ShowOpposingPlayer
; GetUserPitcher
; GetUserBatter
; GetOpponentPitcher
; GetOpponentBatter
; GetCurrentBatter - puts batter's player data in hl
; GetCurrentBatterName - puts batter's name in name_buffer
; GetCurrentPitcher - puts pitcher's player data in hl
; GetCurrentPitcherName - pust pitcher's name in name_buffer
; GetCurrentUserPlayer - puts user's current batter or pitcher player data in hl
; GetCurrentOpponentPlayer - puts opponent's current batter or pitcher player data in hl
; GetPositionPlayerName - a = position number (1-9), returns position player's name in name_buffer

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

IncrementOuts::;returns outs in a
  call NextBatter
  ld a, [balls_strikes_outs]
  and OUTS_MASK
  inc a
  cp 3
  jp z, .threeOuts
  ld [balls_strikes_outs], a
  ret
.threeOuts
  xor a
  ld [balls_strikes_outs], a
  ld [runners_on_base], a
  ld [runners_on_base+1], a
  call NextFrame
  ld a, 3
  ret

CheckStrike:: ;returns ball (z) or strike (nz)
  ld b, PITCH_PATH_CURVE
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

GetPitchBreak:: ;b = path, c = z, returns xy offset in de
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
  ld d, PITCHING_MOVES
  call GetPlayerMoveCount
  ld c, a;move count
  ld a, [rand_lo]
  ld h, a
  ld a, [rand_hi]
  ld l, a
  call math_Divide
  ld [pitch_move_id], a; rand % move_count
  ret

;TODO: offset swing location by break
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

  ld a, d
  and a, 31
  sub a, 15
  ld b, a
  ld a, [pitch_target_x]
  add a, b
  ld [_x], a

  ld a, d
  swap a
  and a, 31
  sub a, 15
  ld b, a
  ld a, [pitch_target_y]
  add a, b
  ld [_y], a

  call StrikeZonePosition
  ld a, [_x]
  add a, d
  ld [_x], a
  ld a, [_y]
  add a, e
  ld [_y], a

  ld a, e
  and a, %10000111
  add a, 100
  ld [_z], a

  call GetCurrentBatter
  ld d, BATTING_MOVES
  call GetPlayerMoveCount
  ld c, a;move count
  ld a, [rand_lo]
  ld h, a
  ld a, [rand_hi]
  ld l, a
  call math_Divide
  ld [swing_move_id], a; rand % move_count

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
  ret

CurrentOrderInLineup::;returns order in a
  call IsUserFielding
  ld a, [current_batter]
  jr nz, .opponentBatting
  and a, %00001111
  ret
.opponentBatting
  ld a, [current_batter]
  swap a
  and a, %00001111
  ret

;Show Player utils
NextFrame::
  ld a, [frame]
  inc a
  ld [frame], a
  call AnnounceBeginningOfFrame
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
GetUserPitcher::
  ld a, 1
  call GetUserPlayerByPosition
  ret

GetUserBatter::
  ld a, [current_batter]
  and a, %00001111
  call GetUserPlayerInLineup
  ret
  
GetOpponentPitcher::
  ld a, 1
  call GetOpposingPlayerByPosition
  ret

GetOpponentBatter::
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

;----------------------------------------------------------------------
;
; GetPositionPlayerName - returns the name of position player 
;
;   input: a = position number (1-9)
;   returns: name_buffer = position player's name
;
;----------------------------------------------------------------------
GetPositionPlayerName::
  push af;position number
  call IsUserFielding
  jr z, .userPlayer;home team in the top or away team in the bottom
.opposingPlayer
  pop af;position number
  call GetOpposingPlayerByPosition
  call GetPlayerName
  ret
.userPlayer
  pop af;position number
  call GetUserPlayerByPosition
  call GetUserPlayerName
  ret