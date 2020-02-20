PLAYER_DATA: MACRO;\1 = team, \2 = order
\1Player\2:
.nickname DS NICKNAME_LENGTH
.number   DB
.level    DB
.xp       DS 3
.type1    DB
.type2    DB
.moves    DS MAX_MOVES
.pp       DS MAX_MOVES
.status   DB
.salary   DW
.hp       DB
.max_hp   DB 
.bat      DB
.field    DB
.speed    DB
.throw    DB
ENDM

OPPONENT_STATS: MACRO
.hits          DW
.at_bats       DW
.runs_allowed  DW
.outs_recorded DW
ENDM

PLAYER_STATS: MACRO
;hitting stats
.strikeouts       DW ;both looking and swinging
.sacrifices       DW ;both sac flies and sac bunts
.batted_outs      DW ;groundout, lineout, flyout, popout
.fielders_choice  DW
.singles          DW
.doubles          DW
.tripples         DW
.homeruns         DW
.runs             DW
.runs_batted_in   DW
.walks            DW
.reached_on_error DW
.hit_by_pitch     DW
.stolen_bases     DW
.caught_stealing  DW
;pitching stats
.batters_faced     DW
.outs_recorded     DW
.walks_allowed     DW
.hits_allowed      DW
.runs_allowed      DW ;earned only
.strikeouts_thrown DW
.wild_pitches      DW
.hit_batters       DW
ENDM

SECTION "Gloval Vars", WRAM0[$c000]
;debug
_breakpoint: DB

;banking
temp_bank: DB
vblank_bank: DB
loaded_bank: DB

;temp vars
_a: DB
_b: DB
_c: DB
_d: DB
_i: DB
_j: DB
_k: DB
_l: DB
_s: DB
_t: DB
_u: DB
_v: DB
_w: DW
_x: DW
_y: DW
_z: DW

;Audio
rCurrentSong: DW
current_song_bank: DB
song_has_intro: DB
music_tempo: DB
music_timer: DB
music_beats: DB
music_beat_num: DB
music_phrases: DB
music_phrase_num: DB

;location of LCD interrupt subroutine
rLCDInterrupt: DW

;Input
last_button_state: DB
button_state: DB

;buffers
tile_buffer: DS BUFFER_SIZE
bkg_buffer: DS BUFFER_SIZE
str_buffer: DS 64
name_buffer: DS 16
player_base: DS 14

;Baseball
balls_strikes_outs: DB; //0bxBBBSSOO
runners_on_base: DW; //0bHHHHTTTTSSSSFFFF
frame: DB
home_team: DB
away_team: DB
home_score: DB
away_score: DB
move_choice: DB
play_menu_selection: DB
swing_diff_x: DW
swing_diff_y: DW
swing_diff_z: DW
ball_x: DB
ball_y: DB

;Lineups
UserLineup: 
  PLAYER_DATA UserLineup, 1
  PLAYER_STATS
  PLAYER_DATA UserLineup, 2
  PLAYER_STATS
  PLAYER_DATA UserLineup, 3
  PLAYER_STATS
  PLAYER_DATA UserLineup, 4
  PLAYER_STATS
  PLAYER_DATA UserLineup, 5
  PLAYER_STATS
  PLAYER_DATA UserLineup, 6
  PLAYER_STATS
  PLAYER_DATA UserLineup, 7
  PLAYER_STATS
  PLAYER_DATA UserLineup, 8
  PLAYER_STATS
  PLAYER_DATA UserLineup, 9
  PLAYER_STATS
UserLineupEnd:

OpponentLineup: 
  PLAYER_DATA OpponentLineup, 1
  OPPONENT_STATS
  PLAYER_DATA OpponentLineup, 2
  OPPONENT_STATS
  PLAYER_DATA OpponentLineup, 3
  OPPONENT_STATS
  PLAYER_DATA OpponentLineup, 4
  OPPONENT_STATS
  PLAYER_DATA OpponentLineup, 5
  OPPONENT_STATS
  PLAYER_DATA OpponentLineup, 6
  OPPONENT_STATS
  PLAYER_DATA OpponentLineup, 7
  OPPONENT_STATS
  PLAYER_DATA OpponentLineup, 8
  OPPONENT_STATS
  PLAYER_DATA OpponentLineup, 9
  OPPONENT_STATS
