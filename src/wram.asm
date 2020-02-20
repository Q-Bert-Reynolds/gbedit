PLAYER_DATA: MACRO;\1 = team, \2 = order
\1Player\2:
.number   DB
.level    DB
.position DB
.moves    DS MAX_MOVES
.pp       DS MAX_MOVES
.status   DB
.hp       DW
.max_hp   DW 
.bat      DW
.field    DW
.speed    DW
.throw    DW
ENDM

USER_PLAYER_DATA: MACRO
.nickname          DS NICKNAME_LENGTH
.xp                DS 3
.pay               DS 3;paid each game
;hitting stats
.strikeouts        DW ;both looking and swinging
.sacrifices        DW ;both sac flies and sac bunts
.batted_outs       DW ;groundout, lineout, flyout, popout, GIDP, etc
.fielders_choice   DW
.singles           DW
.doubles           DW
.tripples          DW
.homeruns          DW
.runs              DW
.runs_batted_in    DW
.walks             DW
.reached_on_error  DW
.hit_by_pitch      DW
.stolen_bases      DW
.caught_stealing   DW
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

OPPONENT_PLAYER_DATA: MACRO ;only needs data for BA and ERA
.hits          DW
.at_bats       DW
.runs_allowed  DW
.outs_recorded DW
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
  USER_PLAYER_DATA
  PLAYER_DATA UserLineup, 2
  USER_PLAYER_DATA
  PLAYER_DATA UserLineup, 3
  USER_PLAYER_DATA
  PLAYER_DATA UserLineup, 4
  USER_PLAYER_DATA
  PLAYER_DATA UserLineup, 5
  USER_PLAYER_DATA
  PLAYER_DATA UserLineup, 6
  USER_PLAYER_DATA
  PLAYER_DATA UserLineup, 7
  USER_PLAYER_DATA
  PLAYER_DATA UserLineup, 8
  USER_PLAYER_DATA
  PLAYER_DATA UserLineup, 9
  USER_PLAYER_DATA
UserLineupEnd:

OpponentLineup: 
  PLAYER_DATA OpponentLineup, 1
  OPPONENT_PLAYER_DATA
  PLAYER_DATA OpponentLineup, 2
  OPPONENT_PLAYER_DATA
  PLAYER_DATA OpponentLineup, 3
  OPPONENT_PLAYER_DATA
  PLAYER_DATA OpponentLineup, 4
  OPPONENT_PLAYER_DATA
  PLAYER_DATA OpponentLineup, 5
  OPPONENT_PLAYER_DATA
  PLAYER_DATA OpponentLineup, 6
  OPPONENT_PLAYER_DATA
  PLAYER_DATA OpponentLineup, 7
  OPPONENT_PLAYER_DATA
  PLAYER_DATA OpponentLineup, 8
  OPPONENT_PLAYER_DATA
  PLAYER_DATA OpponentLineup, 9
  OPPONENT_PLAYER_DATA
