SECTION "Keyboard Vars", WRAM0
key_buffer:: DS 16
key_count:: DB

SECTION "Keyboard Code", ROM0
KeyboardInterrupt::
  ; ld a, [rSB]
  ; and a
  ; jr z, .finish
  ; cp a, $ff
  ; jr z, .finish

  ld hl, key_buffer
  ld a, [key_count]
  ld b, 0
  ld c, a
  inc a
  ld [key_count], a
  add hl, bc
  ld a, [rSB]
  ld [hl], a
  
.finish
  xor a
  ld [rSB], a
  ret

ProcessKeyBuffer::
  xor a
  ld [str_buffer], a
  ld a, [key_count]
  and a
  jr z, .finish
  ld bc, key_buffer
.loop
    push af;count
    push bc;buffer

    ld a, [_y]
    ld e, a
    ld a, [_x]
    ld d, a
    inc a
    ld [_x], a
    cp a, 20
    jr c, .noWrap
    xor a
    ld [_x], a
    ld a, [_y]
    inc a
    ld [_y], a
    cp a, 18
    jr c, .noWrap
    xor a
    ld [_y], a

  .noWrap
    ld hl, $0101
    call gbdk_SetBkgTiles
    
    pop bc;buffer
    inc bc
    pop af;count
    dec a
    jr nz, .loop

.finish
  xor a
  ld [key_count], a
  ld a, %10000001
  ld [rSC], a
  ret

KeyboardDemo::
  di
  DISPLAY_OFF
  ld a, " "
  call ClearScreen
  DISPLAY_ON
  ei
  xor a
  ld [_x], a
  ld [_y], a
  ld a, %10000001
  ld [rSC], a
.loop
    call gbdk_WaitVBL
    call ProcessKeyBuffer
    jp .loop
  ret