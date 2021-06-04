SECTION "Gloval Vars", WRAM0
;debug
_breakpoint:: DB

;system info
sys_info:: DB

;game state
game_state:: DB

;text editor
line_buffer:: DS 1024
line_bank:: DB
line_address:: DW
line_index:: DW
line_column:: DB

;UI
list_selection:: DB

;main save data
user_name:: DS NAME_LENGTH
text_speed:: DB
hours:: DW
minutes:: DB
seconds:: DB

;drawing
sprite_props:: DB
sprite_offset:: DB
sprite_flags:: DB ;0 = skip
sprite_skip_id:: DB
sprite_first_tile:: DB

;timers
vbl_timer:: DB ;counts to 60

;banking
loaded_bank:: DB

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

SECTION "Buffers", WRAMX
;buffers
tile_buffer:: DS BUFFER_SIZE
bkg_buffer:: DS BUFFER_SIZE
win_buffer:: DS BUFFER_SIZE
cmd_buffer:: DS BUFFER_SIZE/2
str_buffer:: DS 128
name_buffer:: DS NAME_LENGTH
