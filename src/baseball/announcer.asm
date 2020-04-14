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


;----------------------------------------------------------------------
; AnnounceBeginningOfFrameText - called at beginning of each frame
;
;   "GINGER steps on the mound."
;   "BUBBI walks up to the plate."
; 
;----------------------------------------------------------------------
AnnounceBeginningOfFrame::
  ; StepsOnTheMoundText
  ; WalksToThePlateText
  ret


;----------------------------------------------------------------------
; AnnounceNoSwingText - called if the player doesn't swing
;
;   "Ball 1."
;
;----------------------------------------------------------------------
AnnounceNoSwing::

.strike
  ; ;strike
  ; StrikeText
  ; StrikeOutLookingText

.ball
  ; BallText
  ; WalkText

.hitByPitch
  ; ;hit by pitch
  ; HitByPitchText
  ; BenchesClear

.updateBaseRunners
  ; update runners on base
  call AnnounceRunnersOn

  ret

AnnounceWildPitchOrPassedBall:
  ; PassedBallText
  ; WildPitchText
  ret


;----------------------------------------------------------------------
; AnnounceSwingMissText - called if the player swings and misses
;
;   "Swing and a miss."
;   "Strike 1."
;
;----------------------------------------------------------------------
AnnounceSwingMiss::;de = pitch xy

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
  ld hl, StrikeText
  call RevealText
  ret


;----------------------------------------------------------------------
; AnnounceSwingContactText - called if the player makes contact
;
;   "A deep fly ball to right center."
;   "CHU makes the catch."
;   "Out!"
;
;   input:
;      a = exit speed
;      b = spray angle
;      c = launch angle
;      de = swing
;      hl = pitch
;
;----------------------------------------------------------------------
AnnounceSwingContact::
  push bc;b=sparay angle, c=launch angle
  call DistanceFromSpeedLaunchAngle;a = exit speed, c = launch angle
.checkOutfield;wall at 240
  cp 96;bases at 90
  jr c, .checkInfield 
  pop bc;b=sparay angle, c=launch angle
  call AnnounceHitToOutfieldText
  jr .finish
.checkInfield
  cp 64;pitcher's mound at 60
  jr c, .checkBunt
  pop bc;b=sparay angle, c=launch angle
  call AnnounceHitToInfieldText
  jr .finish
.checkBunt
  cp a, 0
  jr c, .tipped
  pop bc;b=sparay angle, c=launch angle
  call AnnounceBuntText
  jr .finish
.tipped
  pop bc;b=sparay angle, c=launch angle
  ld hl, HitFoulTipText
  call RevealText
.finish
  ret 

AnnounceHitToOutfieldText:;a = distance, b = spray angle
  ; ;hit to outfield
  ; HitDeepFlyBallText
  ; HitFlyBallText
  ; HitShallowFlyBallText
  ; HitPopFlyText

  ; ;outfield location by angle
  ; OutfieldLocationTexts

AnnounceHitToInfieldText:;a = distance, b = spray angle, c = launch angle
  ; ;hit to infield - 
  ; HitLineDriveText
  ; HitGroundBallText
  ; HitChopperText
  ; HitPopUpText

  ; ;outfield location by angle
  ; InfieldLocationTexts

  ; ;append to bunts and popups
  ; ToThePositionText
  ret 

AnnounceBuntText:;a = launch angle, b = spray angle
  ret

AnnounceFieldingText:
  ; ;fielded
  ; CaughtByText
  ; LeapingCatchByText
  ; DivingCatchByText
  ; FieldedByText

  ld a, 9;right fielder
  call GetPositionPlayerName

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
  ; HitHomeRunText
  ; HitGrandSlamText
  ; CriticalHitText

AnnounceRunnersOn:
  ; RunnersOnBaseTexts
  ret

AnnounceRunScored:
  ; ;score
  ; PlayerScoresText
  ; TwoPlayersScoreText
  ; BasesClearedScoreText
  ret

AnnounceEndOfGame::
  ; ;end of frame
  ; ThatBringsUsToTheFrameText
  ; BottomOfTheText
  ; TopOfTheText

  ; ;end of game
  ; AndThatsTheBallGameText
  ret