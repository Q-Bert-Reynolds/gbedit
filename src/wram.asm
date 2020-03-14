SECTION "Gloval Vars", WRAM0[$c000]
;debug
_breakpoint: DB

;map
map_x: DW
map_y: DW

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
player_base: DS 16
move_data: DS 8

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