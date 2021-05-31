SECTION "Keyboard Demo", ROM0
INCLUDE "src/keyboard/kb_debug_ui.asm"
AliceText:: INCBIN "data/Alice.txt"
AliceTextEnd:: DB, 0;string terminator

DrawCharacter::;a = ASCII value
  ld [tile_buffer], a

  ld a, [_y]
  ld e, a
  ld a, [_x]
  ld d, a;de = xy
.testXWrap
  inc a
  ld [_x], a
  cp a, 20
  jr c, .setTiles
  xor a
  ld [_x], a
.testYWrap
  ld a, [_y]
  inc a
  ld [_y], a
  cp a, 18
  jr c, .setTiles
  xor a
  ld [_y], a
.setTiles
  ld hl, $0101
  ld bc, tile_buffer
  call gbdk_SetBkgTiles
  ret

;TODO: handle backspace and delete differently
RemoveCharacter::
  ld a, [_x]
  dec a
  jr nc, .setX
.wrapX
  ld a, 19
  push af
  ld a, [_y]
  dec a
  jr nc, .setY
  ld a, 17
.setY
  ld [_y], a
  pop af
.setX
  ld [_x], a
  cp a, %00000111
  ld a, " "
  ld [tile_buffer], a
  ld a, [_y]
  ld e, a
  ld a, [_x]
  ld d, a;de = xy
  ld hl, $0101
  ld bc, tile_buffer
  call gbdk_SetBkgTiles  
  ret 

KeyboardDemo::
  di
  DISPLAY_OFF
  call LoadFontTiles
  ld a, " "
  call ClearScreen

  ld a, 1;cursor will be a 1 pixel vertical line
  ld de, _VRAM8000
  ld bc, 16
  call mem_SetVRAM

  DISPLAY_ON
  ei


  ld a, DRAW_FLAGS_BKG | DRAW_FLAGS_NO_SPACE
  ld hl, AliceText
  ld de, 0
  ld bc, -1
  call DrawText

  call SaveLine

  PLAY_SONG tessie_data, 1

  ld a, 7
  ld [rWX], a
  ld a, 144
  ld [rWY], a
  SHOW_WIN
  
  xor a
  ld [_x], a
  ld [_y], a
  ld [_i], a
  ld [kb_scan_code], a
  ld [rSB], a
  
  call DetectKeyboard
  ld a, [kb_mode]
  cp a, KB_MODE_PS2
  jr nz, .loop
.usePS2Clock
  ld a, SCF_TRANSFER_START | SCF_CLOCK_EXTERNAL
  ld [rSC], a;ask for bits using keyboard clock 
.loop
    call DrawCursor
    call gbdk_WaitVBL
    call ProcessKeyCodes
    call DrawKeyboardDebugData
    call UpdateInput
  .testAButton
    ld a, [button_state]
    and a, PADF_A
    jr z, .testBButton
    ld a, [last_button_state]
    and a, PADF_A
    jr nz, .testBButton
  .pressedAButton
    ld a, [_i]
    xor a, 1
    ld [_i], a
    jr nz, .hideDebug
  .showDebug
    ld a, 104
    ld [rWY], a
    jp .testBButton
  .hideDebug
    ld a, 144
    ld [rWY], a

  .testBButton
    ld a, [button_state]
    and a, PADF_B
    jp z, .loop
    ld a, [last_button_state]
    and a, PADF_B
    jp nz, .loop
  .pressedBButton
    call ToggleKBMode
    jp .loop
  ret

ToggleKBMode::
  xor a
  ld [rSC], a;stop transfer
  ld a, [kb_mode]
  and a, %0000001
  inc a
  ld [kb_mode], a
.checkPS2
  cp a, KB_MODE_PS2
  ret nz
  ld a, SCF_TRANSFER_START | SCF_CLOCK_EXTERNAL
  ld [rSC], a ;ask for more bits using keyboard clock   
  ret

DrawCursor::
  ld hl, oam_buffer
  ld a, [vbl_timer]
  cp a, 30
  jr c, .hide
.show
  ld a, [_y]
  add a, 16
  ld [hli], a
  ld a, [_x]
  add a, 8
  ld [hli], a
  xor a
  ld [hli], a
  ld [hli], a
  ret
.hide
  xor a
  ld [hli], a
  ld [hli], a
  ld [hli], a
  ld [hli], a
  ret

  