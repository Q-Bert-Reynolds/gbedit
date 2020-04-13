;script
; "Unsigned GINGER appeared!" or  "CALVIN wants to play 3 innings."
; "Let's go!"
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

;positions
PositionTexts:              DB "pitcher",0
                            DB "catcher",0
                            DB "first baseman",0
                            DB "second baseman",0
                            DB "third baseman",0
                            DB "shortstop",0
                            DB "left fielder",0
                            DB "center fielder",0
                            DB "right fielder",0

InningTexts:                DB "1st",0
                            DB "2nd",0
                            DB "3rd",0
                            DB "4th",0
                            DB "5th",0
                            DB "6th",0
                            DB "7th",0
                            DB "8th",0
                            DB "9th",0
                            DB "10th",0
                            DB "11th",0
                            DB "12th",0

;bases
BaseTexts                   DB "first",0
                            DB "second",0
                            DB "third",0
                            DB "home plate",0

;intro
UnsignedPlayerAppearedText: DB "Unsigned %s\nappeared!",0
TeamChallengeText:          DB " wants to \nplay %s innings.",0
LetsGoText:                 DB "Let's go!",0

;menu
PlayMenuString:             DB "PLAY  TEAM"
                            DS 10
                            DB "ITEM  RUN "

;run selected
QuittingIsNotAnOptionText:  DB "Quitting is\nnot an option!",0

;play selected
TypeSlashText:              DB "TYPE/",0
BlankMoveText:              DB "--------",0

;move selected
BatterStepsIntoTheBoxText:  DB "%s steps\ninto the box.",0
PitcherSetsText:            DB "%s sets.",0

;beginning of play
AndThePitchText:            DB "And the pitch.",0

;append to "And the pitch." text, replace %s with pitch name
ThrewAPitchText:            DB "\nA %s.",0

;after pitch
EarlySwingText:             DB "Early swing.",0
LateSwingText:              DB "Late swing.",0
SwingAndMissText:           DB "Swing and a miss.",0

;hit to outfield - append outfield location
HitDeepFlyBallText:         DB "Deep fly ball ",0
HitFlyBallText:             DB "Fly ball ",0
HitShallowFlyBallText:      DB "Shallow fly ",0
HitPopFlyText:              DB "Pop fly ",0

;outfield location by angle
OutfieldLocationTexts:      DB "in foul\nterritory left.",0
                            DB "down\nthe 𝕃 line.",0
                            DB "to\nleft field.",0
                            DB "to\nleft center.",0
                            DB "to\ncenter field.",0
                            DB "to\nright center.",0
                            DB "to\nright field.",0
                            DB "down\nthe ℝ line.",0
                            DB "in foul\nterritory right.",0

;hit to infield - append infield location or "to the" position text
HitLineDriveText:           DB "Line drive ",0
HitGroundBallText:          DB "Ground ball ",0
HitChopperText:             DB "A chopper ",0
HitPopUpText:               DB "Popped up ",0
HitBuntText:                DB "Bunted ",0

;outfield location by angle
InfieldLocationTexts:       DB "in foul\nterritory left.",0
                            DB "down\nthe 𝟛 line",0
                            DB "\nto third.",0
                            DB "\nin the 𝕊-𝟛 hole.",0
                            DB "\nto short.",0
                            DB "\nup the middle.",0
                            DB "\nto second.",0
                            DB "\nin the 𝟙-𝟚 hole.",0
                            DB "\nto first.",0
                            DB "down\nthe 𝟙 line",0
                            DB "in foul\nterritory right.",0

;append to bunts and popups, replace %s with position
ToThePositionText:          DB "to the\n%s.",0 

;fielded, replace %s with player name
CaughtByText:               DB "%s\n makes the catch.",0
LeapingCatchByText:         DB "%s leaps\n and snags it.",0
DivingCatchByText:          DB "%s with\nthe diving grab.",0
FieldedByText:              DB "Fielded by\n%s.",0
OffTheGloveOfText:          DB "Off the glove of\n%s.",0

;throw, replace %s with player name, append base thrown to
ThrowsToText:               DB "Throws to %s.",0

;tag, replace %s with player name
PlacesTheTagText:           DB "%s\nplaces the tag."

;results
StrikeText:                 DB "Strike %s!",0
BallText:                   DB "Ball %s.",0
WalkText:                   DB "%s on base\nwith a walk.",0
HitByPitchText:             DB "That hit 'em.",0
BenchesClear:               DB "And the benches clear.",0
SafeText:                   DB "Safe!",0
OutText:                    DB "Out!",0
DoublePlayText:             DB "Double Play!",0
TriplePlayText:             DB "Triple Play!",0
HitFoulTipText:             DB "Foul tip.",0
HitFoulBackText:            DB "Foulled back.",0
HitFoulBallText:            DB "Foul Ball!",0
HitBaseHitText:             DB "Base hit!",0
HitDoubleText:              DB "Double!",0
HitTripleText:              DB "Triple!",0
HitHomeRunText:             DB "HOME RUN!",0
HitGrandSlamText:           DB "GRAND SLAM!",0
CriticalHitText:            DB "Critical hit!",0
PlayerScoresText:           DB "%s scores.",0
TwoPlayersScoreText:        DB " and\n%s score.",0
BasesClearedScoreText:      DB "And that clears\nthe bases.",0

;three outs
ThatBringsUsToTheText:      DB "That brings us to the\n",0
BottomOfTheText:            DB "bottom of the %s.",0
TopOfTheText:               DB "top of the %s.",0
AndThatsTheBallGameText:    DB "And that's the\nball game.",0