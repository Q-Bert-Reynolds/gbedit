SECTION "Stack", WRAM0
stack_top: DS STACK_SIZE
stack_bottom:

SECTION "Display Buffers", WRAMX
_tile_buffer::
tile_buffer:: DS BUFFER_SIZE
win_buffer:: DS SCRN_X_B * OSK_ROWS
