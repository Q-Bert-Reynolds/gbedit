SECTION "Gloval Vars", WRAM0[_RAM]
;debug
_breakpoint:: DB

;system info
sys_info:: DB

;game state
game_state:: DB

;main save data
text_speed:: DB
animation_style:: DB
coaching_style:: DB
user_name:: DS NAME_LENGTH
rival_name:: DS NAME_LENGTH
hours:: DW
minutes:: DB
seconds:: DB
items:: DS MAX_ITEMS*2;each item is 2 bytes
money:: DS 3

;drawing
sprite_props:: DB
sprite_offset:: DB
sprite_flags:: DB ;0 = skip
sprite_skip_id:: DB
sprite_first_tile:: DB

;timers
vbl_timer:: DB ;counts to 60

;map
last_map_button_state:: DB
anim_frame:: DW
map_x:: DW
map_y:: DW

;banking
temp_bank:: DB
loaded_bank:: DB
map_bank:: DB

;temp vars
_a:: DB
_b:: DB
_c:: DB
_d:: DB
_i:: DB
_j:: DB
_k:: DB
_l:: DB
_s:: DB
_t:: DB
_u:: DB
_v:: DB
_w:: DW
_x:: DW
_y:: DW
_z:: DW

;audio
rCurrentSFX:: DW
current_sfx_bank:: DB
sfx_step:: DB
sfx_step_count:: DB
sfx_ticks:: DB
sfx_disable_mask:: DB

;location of LCD interrupt subroutine
rLCDInterrupt:: DW

;Input
last_button_state:: DB
button_state:: DB

;buffers
tile_buffer:: DS BUFFER_SIZE
bkg_buffer:: DS BUFFER_SIZE
cmd_buffer:: DS BUFFER_SIZE/2
str_buffer:: DS 64
name_buffer:: DS 16

;player base data struct
player_base::
.num::       DB
.type1::     DB
.type2::     DB
.ev_to::     DB
.ev_type::   DB
.ev_age::    DB
.height::    DB
.weight::    DW
.hp::        DB
.bat::       DB
.field::     DB
.speed::     DB
.throw::     DB
.body_id::   DB
.head_id::   DB
.hat_id::    DB
.gb_pal::    DB
.sgb_pal::   DW
.anim::      DS 32
.end::

; move data struct
move_data::
.id::           DB
.use::          DB ;pitching=0, batting=1
.type::         DB
.pp::           DB
.power::        DB
.accuracy::     DB
.pitch_path::
.launch_angle:: DB
.end::

;Baseball
balls_strikes_outs:: DB; XBBBSSOO
runners_on_base:: DW; lineup order of runners on base - HHHHTTTT SSSSFFFF
frame:: DB
current_batter:: DB;upper nibble is opponent, lower nibble is user
home_team:: DB;1 = user is home team
home_score:: DB
away_score:: DB
move_choice:: DB
pitch_move_id:: DB
swing_move_id:: DB
play_menu_selection:: DB
aim_x::
swing_diff_x:: DB
aim_y::
swing_diff_y:: DB
swing_diff_z:: DB
ball_pos_x:: DW ;used for pitch and sim
ball_pos_y:: DW
pitch_z::
ball_pos_z:: DW
pitch_target_x::;pitch target offset from center of strike zone
ball_vel_x:: DB;same location used for velocity in simulation
pitch_target_y::
ball_vel_y:: DB
ball_vel_z:: DB
ball_state:: DB; // 7 = stopped, 6 = hitGround, 5 = fair, 4 = inPlay, 3..0 = position player holding ball

;roledex
players_seen:: DS 151/8+1
players_sign:: DS 151/8+1