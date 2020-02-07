SECTION "Gloval Vars", WRAM0

;temp vars
_a: DB
_b: DB
_c: DB
_d: DB
_i: DB
_j: DB
_k: DB
_l: DB
_w: DW
_x: DW
_y: DW
_z: DW

;Audio
music_timer: DB
beat: DW
loop_num: DB

;current main bank
_bank: DB

;location of LCD interrupt subroutine
rLCDInterrupt: DW

;Input
last_button_state: DB
button_state: DB

;buffers
tile_buffer: DS 512
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