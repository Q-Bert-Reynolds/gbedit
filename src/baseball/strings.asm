;positions
PositionTexts::               DB "pitcher",0
                              DB "catcher",0
                              DB "first baseman",0
                              DB "second baseman",0
                              DB "third baseman",0
                              DB "shortstop",0
                              DB "left fielder",0
                              DB "center fielder",0
                              DB "right fielder",0

InningTexts::                 DB "1st",0
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
BaseTexts::                   DB "first",0
                              DB "second",0
                              DB "third",0
                              DB "home plate",0

;intro
UnsignedPlayerAppearedText::  DB "Unsigned %s\nappeared!",0
TeamChallengeText::           DB " wants to \nplay %s innings.",0
PlayBallText::                DB "Play ball!",0

;beginning of frame
TakesTheMoundText::           DB "%s\ntakes the mound.",0;also used for relievers
WalksToThePlateText::         DB "%s walks\nup to the plate.",0

;menu
PlayMenuString::              DB "PLAY  TEAM"
                              DS 10
                              DB "ITEM  RUN "

;run selected
QuittingIsNotAnOptionText::   DB "Quitting is\nnot an option!",0

;play selected
TypeSlashText::               DB "TYPE/",0
BlankMoveText::               DB "--------",0

;move selected
BatterStepsIntoTheBoxText::   DB "%s steps\ninto the box.",0
PitcherSetsText::             DB "%s sets.",0

;beginning of play
AndThePitchText::             DB "And the pitch.",0

;append to "And the pitch." text, replace %s with pitch name
ThrewAPitchText::             DB "\nA %s.",0

;after pitch
EarlySwingText::              DB "Early swing.",0
LateSwingText::               DB "Late swing.",0
SwingAndMissText::            DB "Swing and a miss.",0

;hit to outfield - append outfield location
HitDeepFlyBallText::          DB "Deep fly ball ",0
HitFlyBallText::              DB "Fly ball ",0
HitShallowFlyBallText::       DB "Shallow fly ",0
HitPopFlyText::               DB "Pop fly ",0

;outfield location by angle
OutfieldLocationTexts::       DB "in\nfoul territory.",0
                              DB "down\nthe 𝕃 line.",0
                              DB "to\nleft field.",0
                              DB "to\nleft center.",0
                              DB "to\ncenter field.",0
                              DB "to\nright center.",0
                              DB "to\nright field.",0
                              DB "down\nthe ℝ line.",0
                              DB "in\nfoul territory.",0

;hit to infield - append infield location or "to the" position text
HitLineDriveText::            DB "Line drive ",0
HitGroundBallText::           DB "Ground ball ",0
HitChopperText::              DB "A chopper ",0
HitPopUpText::                DB "Popped up ",0
HitBuntText::                 DB "Bunted ",0

;outfield location by angle
InfieldLocationTexts::        DB "in\nfoul territory.",0
                              DB "down\nthe 𝟛 line",0
                              DB "\nto third.",0
                              DB "\nin the 𝕊-𝟛 hole.",0
                              DB "\nto short.",0
                              DB "\nup the middle.",0
                              DB "\nto second.",0
                              DB "\nin the 𝟙-𝟚 hole.",0
                              DB "\nto first.",0
                              DB "down\nthe 𝟙 line",0
                              DB "in\nfoul territory.",0

;append to bunts and popups, replace %s with position
ToThePositionText::           DB "to the\n%s.",0 

;fielded, replace %s with player name
CaughtByText::                DB "%s\n makes the catch.",0
LeapingCatchByText::          DB "%s leaps\n and snags it.",0
DivingCatchByText::           DB "%s with\nthe diving grab.",0
FieldedByText::               DB "Fielded by\n%s.",0

;errors
OffTheGloveOfText::           DB "Off the glove of\n%s.",0
BobbledByText::               DB "Bobbled by\n%s.",0
BadThrowByText::              DB "A bad throw\nfrom %s.",0

;throw, replace %s with player name, append base thrown to
ThrowsToText::                DB "Throws to %s.",0

;tag, replace %s with player name
PlacesTheTagText::            DB "%s\nplaces the tag."

;dead ball
DeadBallText::                DB "Dead ball!",0

;strike
StrikeText::                  DB "Strike %s!",0
StrikeOutLookingText::        DB "%s strikes\nout looking!",0
StrikeOutSwingingText::       DB "%s strikes\nout swinging!",0

;no swing
BallText::                    DB "Ball %s.",0
WalkText::                    DB "%s on base\nwith a walk.",0
PassedBallText::              DB "Wild pitch!",0
WildPitchText::               DB "Passed ball!",0
HitByPitchText::              DB "That hit 'em, so\n%s is on 𝟙.",0
BenchesClear::                DB "And the benches clear.",0

;runners on
RunnersOnBaseTexts::          DB "Nobody on base.",0              ;000
                              DB "Runner on first.",0             ;001
                              DB "Runner on second.",0            ;010
                              DB "Runners on first\nand second.",0;011
                              DB "Runner on second.",0            ;100
                              DB "Runners on first\nand third.",0 ;101
                              DB "Runners on second\nand third.",0;110
                              DB "Bases loaded.",0                ;110

;tagging up
TaggingFromTexts::            DB "%s tags from first."
                              DB "%s will\ntag from second."
                              DB "Tagging from third\nis %s."

;safe/out
SafeText::                    DB "Safe!",0
OutText::                     DB "Out!",0
DoublePlayText::              DB "Double Play!",0
TriplePlayText::              DB "Triple Play!",0

;foul
HitFoulTipText::              DB "Foul tip.",0
HitFoulBackText::             DB "Foulled back.",0
HitFoulBallText::             DB "Foul Ball!",0

;hit
HitBaseHitText::              DB "Base hit!",0
HitDoubleText::               DB "Double!",0
HitTripleText::               DB "Triple!",0
HitHomeRunText::              DB "HOME RUN!",0
HitGrandSlamText::            DB "GRAND SLAM!",0
CriticalHitText::             DB "Critical hit!",0

;score
PlayerScoresText::            DB "%s scores.",0
TwoPlayersScoreText::         DB " and\n%s score.",0
BasesClearedScoreText::       DB "And that clears\nthe bases.",0

;end of frame
ThatBringsUsToTheFrameText::  DB "That brings us to the\n",0
BottomOfTheText::             DB "bottom of the %s.",0
TopOfTheText::                DB "top of the %s.",0

;end of game
AndThatsTheBallGameText::     DB "And that's the\nball game.",0