INCLUDE "img/field.asm"
INCLUDE "img/simulation.asm"

ShowField:
  DISPLAY_OFF
  ld de, $8800;_VRAM+$1000+_UI_FONT_TILE_COUNT*16
  ld bc, _FIELD_TILE_COUNT*16
  ld hl, _FieldTiles
  call mem_CopyVRAM

  ld hl, $2020
  ld de, 0
  ld bc, _FieldTileMap
  ld a, _UI_FONT_TILE_COUNT
  call SetBKGTilesWithOffset

  ld de, $8000
  ld bc, _SIMULATION_TILE_COUNT*16
  ld hl, _SimulationTiles
  call mem_CopyVRAM

  ld a, 20
  ld [rSCX], a
  ld a, 84
  ld [rSCY], a
  DISPLAY_ON
  ret

UpdateBall:
  ld a, [vbl_timer]
  and a, %00001111
  cp a, %00001111
  jr z, .updatePosition
  
; .updateVelocity
;   ld a, [ball_pos_z]
;   cp 0
;   jr z, .updatePosition
;   ld a, [ball_vel_z]
;   cp 128
;   jr nc, .updatePosition

  ld a, [ball_vel_z]
  add -1
  ld [ball_vel_z], a

.updatePosition
REPT 5
  ld a, [ball_vel_x]
  ld hl, ball_pos_x
  call math_AddSignedByteToWord

  ld a, [ball_vel_y]
  ld hl, ball_pos_y
  call math_AddSignedByteToWord

  ld a, [ball_vel_z]
  ld hl, ball_pos_z
  call math_AddSignedByteToWord
ENDR

.drawBall
  ld hl, oam_buffer
  ld a, [rSCY]
  ld b, a
  ld a, [ball_pos_y]
  sub a, b
  ld b, a
  ld a, [ball_pos_z]
  swap a
  and %00001111
  ld c, a
  ld a, b
  sub a, c
  ld [hli], a;y
  ld a, [rSCX]
  ld b, a
  ld a, [ball_pos_x]
  sub a, b
  ld [hli], a;x
  ld a, [ball_pos_z]
  swap a
  and %00001111
  ld [hli], a;tile
  xor a
  ld [hli], a;prop

.drawShadow
  ld a, [rSCY]
  ld b, a
  ld a, [ball_pos_y]
  sub a, b
  inc a
  ld [hli], a
  ld a, [rSCX]
  ld b, a
  ld a, [ball_pos_x]
  sub a, b
  inc a
  ld [hli], a
  ld a, 16
  ld [hli], a
  xor a
  ld [hl], a

  ret

RunSimulation::
  HIDE_WIN
  call ShowField

  ld a, 46
  ld [ball_pos_x], a
  ld a, 209
  ld [ball_pos_y], a
  ld a, 1
  ld [ball_pos_z], a

  xor a
  ld [ball_pos_x+1], a
  ld [ball_pos_y+1], a
  ld [ball_pos_z+1], a
  ld [ball_vel_x+1], a
  ld [ball_vel_y+1], a
  ld [ball_vel_z+1], a
  
  ld a, -10
  ld [ball_vel_y], a
  ld a, 10
  ld [ball_vel_x], a
  ld a, 100
  ld [ball_vel_z], a

.loop
    call UpdateBall
    call gbdk_WaitVBL
    jr .loop
  

  ;d = swing_diff_x > -12 && swing_diff_x < 12 && swing_diff_y > -12 && swing_diff_y < 12;
  ;if (swing_diff_z < 20 && swing_diff_z > -20) {
  ;    if (d) {
  ;        if (swing_diff_z == 0 && swing_diff_x == 0 && swing_diff_y == 0/* && rand < batting avg */) {
  ;            display_text("Critical hit!");
  ;        }
  ;        else {
  ;            display_text("Solid contact");
  ;        }
  ;    }
  ;    else display_text("Swing and a miss.");
  ;}
  ;else if (swing_diff_z >= 20) {
  ;    display_text("Late swing.");
  ;}
  ;else {
  ;    display_text("Early swing.");
  ;}
  xor a
  ld [rSCX], a
  ld [rSCY], a
  SHOW_WIN
  CLEAR_BKG_AREA 0,0,20,12," "
  call SetupGameUI
  ret