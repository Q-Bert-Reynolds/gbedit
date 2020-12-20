SECTION "Announcer Bank 0", ROM0

AnnounceSwingTiming:: ;hl = text address
  ld a, ANNOUNCER_BANK
  call SetBank
  
  ld a, DRAW_FLAGS_WIN | DRAW_FLAGS_PAD_TOP
  call DisplayText

  ld a, PLAY_BALL_BANK
  call SetBank
  ret

;----------------------------------------------------------------------
; AnnounceSwingContact - called if the player makes contact
;
;   "A deep fly ball to right center."
;   "CHU makes the catch."
;   "Out!"
;
;   input:
;      a = speed
;      b = spray angle
;      c = launch angle
;
;----------------------------------------------------------------------
AnnounceSwingContact::
  push af;speed
  ld a, ANNOUNCER_BANK
  call SetBank
  pop af;speed
  call _AnnounceSwingContact
  ld a, PLAY_BALL_BANK
  call SetBank
  ret

SECTION "Announcer Bank X", ROMX, BANK[ANNOUNCER_BANK]
;script
  ; "Unsigned GINGER appeared!" or  "CALVIN wants to play 3 innings."
  ; "Play ball!"
  ;
  ; "GINGER steps on the mound."
  ; "BUBBI walks up to the plate."
  ; 
  ; SHOW MENU, SELECT PLAY, SELECT A MOVE
  ;   "BUBBI steps into the box."
  ;   "GINGER sets."
  ;   "And the pitch."
  ;   "A fireball!"
  ;   "Swing and a miss."
  ;   "Strike 1."
  ;
  ; SHOW MENU, SELECT PLAY, SELECT A MOVE
  ;   "BUBBI steps into the box."
  ;   "GINGER sets."
  ;   "And the pitch."
  ;   "A changeup!"
  ;   "Foulled back."
  ;
  ; SHOW MENU, SELECT PLAY, SELECT A MOVE
  ;   "BUBBI steps into the box."
  ;   "GINGER sets."
  ;   "And the pitch."
  ;   "A changeup!"
  ;   "Ball 1."
  ;
  ; SHOW MENU, SELECT PLAY, SELECT A MOVE
  ;   "BUBBI steps into the box."
  ;   "GINGER sets."
  ;   "And the pitch."
  ;   "A fireball!"
  ;   "A deep fly ball to right center."
  ;   "CHU makes the catch."
  ;   "Out!"
  ;
  ; "YOGI walks up to the plate."
  ;
  ; SHOW MENU, SELECT PLAY, SELECT A MOVE
  ;   "YOGI steps into the box."
  ;   "GINGER sets."
  ;   "And the pitch."
  ;   "A fireball!"
  ;   "Line drive ball down the right field line."
  ;   "OT at the wall."
  ;   "HOME RUN!"
  ;
  ; "PIDGE walks up to the plate."
  ;
  ; SHOW MENU, SELECT PLAY, SELECT A MOVE
  ;   "PIDGE steps into the box."
  ;   "GINGER sets."
  ;   "And the pitch."
  ;   "A fireball!"
  ;   "Shallow fly to center field."
  ;   "Base hit!"
  ;
  ; "RATS walks up to the plate."
  ;
  ; SHOW MENU, SELECT PLAY, SELECT A MOVE
  ;   "RATS steps into the box."
  ;   "GINGER sets."
  ;   "And the pitch."
  ;   "A fireball!"
  ;   "Ground ball to short."
  ;   "Fielded by DUCK."
  ;   "Throws to second."
  ;   "Stoop makes the catch."
  ;   "Out at second."
  ;   "Throws to first."
  ;   "Double play!"
  ;
  ; "That brings us to the bottom of the 1st."
  ; "BRUH steps on the mound."
  ; "GINGER walks up to the plate."
  ;
  ; ...
  ;
  ; "That brings us to the top of the 9th."
  ; "GINGER takes the mound."
  ; "CHU walks up to the plate."
  ;
  ; ...
  ;
  ; SHOW MENU, SELECT TEAM, CHANGE PITCHER
  ;   "BUBBI takes the mound."
  ; 
  ;
  ; "And that's the ballgame."
  ;
  ;  OPPOSING COACH WIN/LOSS STATEMENT
  ;  "That win brings you to 16W - 5L"

INCLUDE "src/baseball/announcer_strings.asm"

;----------------------------------------------------------------------
; AnnounceBeginningOfFrame - called at beginning of each frame
;
;   "GINGER steps on the mound."
;   "BUBBI walks up to the plate."
; 
;----------------------------------------------------------------------
AnnounceBeginningOfFrame::
  call AnnouncePitcher
  call AnnounceBatter
  TRAMPOLINE DrawBases
  HIDE_WIN
  ret

AnnouncePitcher::
  TRAMPOLINE ShowPitcher
  TRAMPOLINE GetCurrentPitcherName
  ld bc, name_buffer
  ld hl, TakesTheMoundText
  ld de, str_buffer
  call str_Replace
  ld hl, str_buffer
  call RevealTextAndWait
  ret

AnnouncePitcherSets::
  TRAMPOLINE GetCurrentPitcherName
  ld bc, name_buffer
  ld hl, PitcherSetsText
  ld de, str_buffer
  call str_Replace
  ld hl, str_buffer
  ld a, DRAW_FLAGS_WIN | DRAW_FLAGS_PAD_TOP
  call DisplayText
  ret

AnnounceAndThePitch::
  ld hl, AndThePitchText
  ld a, DRAW_FLAGS_WIN | DRAW_FLAGS_PAD_TOP
  call DisplayText;"And the pitch."
  ret

AnnouncePitchName::
  ld a, [pitch_move_id]
  call GetMoveName;move in name_buffer
  ld hl, AndThePitchText
  ld de, str_buffer
  call str_Copy ;str_buffer = "And the pitch.""

  ld hl, ThrewAPitchText;"\nA %s."
  ld de, tile_buffer
  ld bc, name_buffer
  call str_Replace;str_buffer = "\nA PITCH_NAME."

  ld hl, tile_buffer
  ld de, str_buffer
  call str_Append;"And the pitch."

  ld hl, str_buffer
  ld a, DRAW_FLAGS_WIN | DRAW_FLAGS_PAD_TOP
  call DisplayText
  ret

AnnounceNextBatter
  xor a
  call SetBalls
  xor a
  call SetStrikes
  TRAMPOLINE NextBatter

AnnounceBatter::
  TRAMPOLINE DrawCountOutsInning
  TRAMPOLINE ShowBatter
  TRAMPOLINE GetCurrentBatterName
  ld bc, name_buffer
  ld hl, WalksToThePlateText
  ld de, str_buffer
  call str_Replace
  ld hl, str_buffer
  call RevealTextAndWait
  ret

AnnounceBatterStepsIntoBox::
  TRAMPOLINE GetCurrentBatterName
  ld bc, name_buffer
  ld hl, BatterStepsIntoTheBoxText
  ld de, str_buffer
  call str_Replace
  ld hl, str_buffer
  ld a, DRAW_FLAGS_WIN | DRAW_FLAGS_PAD_TOP
  call DisplayText
  ret

;----------------------------------------------------------------------
; AnnounceNoSwing - called if the player doesn't swing
;
;   "Ball 1."
;
;----------------------------------------------------------------------
AnnounceNoSwing::
  call CheckStrike
  jr z, .ball
.strike
  call GetStrikes
  cp a, 2
  jr nc, .strikeout
  inc a
  ld h, 0
  ld l, a
  push hl
  call SetStrikes
  TRAMPOLINE DrawCountOutsInning
  pop hl
  ld de, name_buffer
  call str_Number
  ld hl, StrikeText
  ld de, str_buffer
  ld bc, name_buffer
  call str_Replace
  ld hl, str_buffer
  call RevealTextAndWait
  ret

.strikeout
  TRAMPOLINE GetCurrentBatterName
  ld hl, StrikeOutLookingText
  ld de, str_buffer
  ld bc, name_buffer
  call str_Replace
  ld hl, str_buffer
  call RevealTextAndWait
  call IncrementOuts
  cp 3
  jp nz, AnnounceBatter
  TRAMPOLINE DrawCountOutsInning
  ret

.ball
  call GetBalls
  cp a, 3
  jr nc, .walk
  inc a
  ld h, 0
  ld l, a
  push hl
  call SetBalls
  TRAMPOLINE DrawCountOutsInning
  pop hl
  ld de, name_buffer
  call str_Number
  ld hl, BallText
  ld de, str_buffer
  ld bc, name_buffer
  call str_Replace
  ld hl, str_buffer
  call RevealTextAndWait
  ret

.walk
  TRAMPOLINE PutBatterOnFirst
  TRAMPOLINE GetCurrentBatterName
  ld hl, WalkText
  ld de, str_buffer
  ld bc, name_buffer
  call str_Replace
  ld hl, str_buffer
  call RevealTextAndWait
  call AnnounceRunScored
  jp AnnounceNextBatter

.hitByPitch
  TRAMPOLINE PutBatterOnFirst
  TRAMPOLINE GetCurrentBatterName
  ld hl, HitByPitchText;BenchesClearText
  ld de, str_buffer
  ld bc, name_buffer
  call str_Replace
  ld hl, str_buffer
  call RevealTextAndWait
  jp AnnounceNextBatter

.updateBaseRunners
  call AnnounceRunnersOn

  ret

AnnounceWildPitchOrPassedBall:
  ; PassedBallText
  ; WildPitchText
  ret

;----------------------------------------------------------------------
; AnnounceSwingMiss - called if the player swings and misses
;
;   "Swing and a miss."
;   "Strike 1."
;
;----------------------------------------------------------------------
AnnounceSwingMiss::

.checkPassedBallWildPitch;if any runners on
  ;TODO: check if xy way out of zone
  jr .showStrike;if not wild

.checkHitBatter
  ; TODO: check if hit batter
  jr .passedBallWildPitch
  ld hl, DeadBallText
  call RevealTextAndWait
  ret

.passedBallWildPitch
  call AnnounceWildPitchOrPassedBall
.checkDroppedThirdStrike;if 2 outs OR no runner on first
  ;check to see if batter gets on
.advanceRunners
  ;if so, advance runners
  ret

.showStrike
  call GetStrikes
  cp a, 2
  jr nc, .strikeout
  inc a
  ld h, 0
  ld l, a
  push hl
  call SetStrikes
  TRAMPOLINE DrawCountOutsInning
  pop hl
  ld de, name_buffer
  call str_Number
  ld hl, StrikeText
  ld de, str_buffer
  ld bc, name_buffer
  call str_Replace
  ld hl, str_buffer
  call RevealTextAndWait
  ret

.strikeout
  TRAMPOLINE GetCurrentBatterName
  ld hl, StrikeOutSwingingText
  ld de, str_buffer
  ld bc, name_buffer
  call str_Replace
  ld hl, str_buffer
  call RevealTextAndWait
  call IncrementOuts
  cp 3
  jp nz, AnnounceBatter
  ret

;cannot use Trampoline, too many inputs
_AnnounceSwingContact:;a = speed, b = spray angle, c = launch angle
  push af;speed
  ld a, c
  cp a, 128;if 0<c<128, .inAir
  jr c, .inAir

.onGround
  pop af;speed
  call AnnounceHitOnGround
  ret

.inAir
  pop af;speed
  call AnnounceHitInAir

; .checkBunt
;   cp a, 0
;   jr c, .tipped
;   pop bc;b=sparay angle, c=launch angle
;   call AnnounceBuntText
;   jr .finish
; .tipped
;   pop bc;b=sparay angle, c=launch angle
;   ld hl, HitFoulTipText
;   call RevealTextAndWait
.finish
  ret 

AnnounceHitOnGround:;a = speed, b = spray angle

AnnounceHitInAir:;a = speed, b = spray angle, c = launch angle
  push bc;spray, launch
  call DistanceFromSpeedLaunchAngle;a = speed, c = launch angle, returns distance in a
.outfield;wall at 240
  cp a, 96;bases at 90
  jr c, .infield 
  pop bc;b=sparay angle, c=launch angle
  call AnnounceHitInAirToOutfield
  ret
.infield
  pop bc;b=sparay angle, c=launch angle
  call AnnounceHitInAirToInfield
  ret

AnnounceHitInAirToOutfield:;a=distance, b=sparay angle, c=launch angle
  push bc;spray,launch
  push af;distance
.deepFly
  cp 220
  jr c, .flyBall
  ld hl, HitDeepFlyBallText
  jr .copyString
.flyBall
  cp 180
  jr c, .shallowFly
  ld hl, HitFlyBallText
  jr .copyString
.shallowFly
  cp 140
  jr c, .popFly
  ld hl, HitShallowFlyBallText
  jr .copyString
.popFly
  ld hl, HitPopFlyText
.copyString
  ld de, str_buffer
  call str_Copy

  call AppendOutfieldLocationTextByAngle
  ld hl, str_buffer
  call RevealTextAndWait

  pop af;distance
  pop bc;spray,launch
  cp a, 240
  jr c, .fieldBall
  ld a, b
  BETWEEN -45, 45
  jr z, .foulBall
.homeRun
  call CurrentOrderInLineup
  inc a;current batter is 0 to 8, needs to be 1 to 9
  ld c, a
  ld b, 4
  call AdvanceRunners
  cp a, 4
  jr z, .grandSlam
  ld hl, HitHomeRunText
  call RevealTextAndWait
  TRAMPOLINE DrawScore
  call AnnounceNextBatter
  ret
.grandSlam
  ld hl, HitGrandSlamText
  call RevealTextAndWait
  TRAMPOLINE DrawScore
  call AnnounceNextBatter
  ret
.foulBall
  call FoulBall
  ld hl, HitFoulBallText
  call RevealTextAndWait
  TRAMPOLINE DrawCountOutsInning
  ret
.fieldBall
  call LocationFromDistSprayAngle
  call GetClosestFielderByLocation
  jp AnnounceFieldingText

AppendOutfieldLocationTextByAngle:;b = spray angle, appends text to str_buffer
  ld a, b
  cp a, 45
  jr c, .outfieldLocation
  cp a, -46
  jr nc, .outfieldLocation
  ld hl, InFoulTerritoryText
  jr .append
.outfieldLocation
  add a, 46
  ld h, 0
  ld l, a
  ld c, 15
  call math_Divide
  ld b, h
  ld c, l
  ld hl, OutfieldLocationTexts;7 locations
  call str_FromArray
.append
  ld de, str_buffer
  call str_Append
  ret

AnnounceHitInAirToInfield:;a = distance, b = spray angle, c = launch angle  
  push bc;spray,launch
  push af;distance
.lineDrive
  cp 200
  jr c, .grounder
  ld hl, HitLineDriveText
  jr .copyString
.grounder
  cp 140
  jr c, .chopper
  ld hl, HitGroundBallText
  jr .copyString
.chopper
  cp 100
  jr c, .popUp
  ld hl, HitChopperText
  jr .copyString
.popUp
  ld hl, HitPopUpText
.copyString
  ld de, str_buffer
  call str_Copy

  call AppendInfieldLocationTextByAngle
  ld hl, str_buffer
  call RevealTextAndWait

  pop af;distance
  pop bc;spray,launch
  call LocationFromDistSprayAngle
  call GetClosestFielderByLocation
  jp AnnounceFieldingText

AppendInfieldLocationTextByAngle:;b = spray angle, appends text to str_buffer
  ld a, b
  cp a, 40
  jr c, .infieldLocation
  cp a, -40
  jr nc, .infieldLocation
  ld hl, InFoulTerritoryText
  jr .append
.infieldLocation
  add a, 40
  ld h, 0
  ld l, a
  ld c, 10
  call math_Divide
  ld b, h
  ld c, l
  ld hl, InfieldLocationTexts;9 locations
  call str_FromArray
.append
  ld de, str_buffer
  call str_Append
  ret

AnnounceBuntText:;a = launch angle, b = spray angle
  ld hl, HitBuntText
  ld de, tile_buffer
  call str_Copy

  ld hl, ToThePositionText
  ld de, tile_buffer
  call str_Append

  ld hl, PositionTexts
  ld bc, 1
  call str_FromArray

  ld hl, PositionTexts
  add hl, bc
  ld b, h
  ld c, l

  ld hl, tile_buffer
  ld de, str_buffer
  call str_Replace

  ld hl, str_buffer
  call RevealTextAndWait
  ret

AnnounceFieldingText:;a = position fielding the ball, b = dist from player
  ld [_breakpoint], a
  call GetPositionPlayerName
  
  ; caught 
  ; CaughtByText
  ; LeapingCatchByText
  ; DivingCatchByText

  ;fielded
  ld hl, FieldedByText

.showFieldingText
  ld bc, name_buffer
  ld de, str_buffer
  call str_Replace

  ld hl, str_buffer
  call RevealTextAndWait

  ; ;errors
  ; OffTheGloveOfText
  ; BobbledByText
  ; BadThrowByText

  ; ;throw
  ; ThrowsToText

  ; ;tag
  ; PlacesTheTagText

  ; ;tagging up
  ; TaggingFromTexts

  ; ;safe/out
  ; SafeText
  ; OutText
  ; DoublePlayText
  ; TriplePlayText

  ; ;foul
  ; HitFoulBackText
  ; HitFoulBallText

  ; ;hit
  ; HitBaseHitText
  ; HitDoubleText
  ; HitTripleText
  ; CriticalHitText
  ret

AnnounceAdvanceRunners:
  ret

AnnounceRunnersOn:
  ; RunnersOnBaseTexts
  ret

;TODO: handle more than one run -> TwoPlayersScoreText, BasesClearedScoreText
AnnounceRunScored: ;if upper nibble of [runners_on_base] non-zero, announces runner who scored
  ld a, [runners_on_base]
  ld b, a
  and a, %00001111
  ld [runners_on_base], a
  swap b
  ld a, b
  and a, %00001111
  ret z;no one scored if a == 0
  dec a
  ld b, a;batting order index(0-8)
  call IsUserFielding
  jr z, .userIsBatting
.opponentIsBatting
  ld a, [home_team]
  and a
  jr z, .opponentIsHome
.opponentIsAway
  ld a, [away_score]
  inc a
  ld [away_score], a
  jr .getOpponentPlayerName
.opponentIsHome
  ld a, [home_score]
  inc a
  ld [home_score], a
.getOpponentPlayerName
  push bc
  TRAMPOLINE DrawScore
  pop bc
  ld a, b
  call GetOpposingPlayerInLineup
  call GetPlayerName
  jr .announceScoringPlayer
.userIsBatting
  ld a, [home_team]
  and a
  jr nz, .userIsHome
.userIsAway
  ld a, [away_score]
  inc a
  ld [away_score], a
  jr .getUserPlayerName
.userIsHome
  ld a, [home_score]
  inc a
  ld [home_score], a
.getUserPlayerName
  push bc
  TRAMPOLINE DrawScore
  pop bc
  ld a, b
  call GetUserPlayerInLineup
  call GetUserPlayerName
.announceScoringPlayer
  ld hl, name_buffer
  ld de, str_buffer
  call str_Copy
  ld hl, PlayerScoresText
  ld de, str_buffer
  call str_Append
  ld hl, str_buffer
  call RevealTextAndWait
  ret

AnnounceEndOfGame::
  ; ;end of frame
  ; ThatBringsUsToTheFrameText
  ; BottomOfTheText
  ; TopOfTheText

  ; ;end of game
  ; AndThatsTheBallGameText
  ret