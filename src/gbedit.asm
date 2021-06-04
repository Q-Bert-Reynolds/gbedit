SECTION "Highlight Interrupt Variables", HRAM[$FF8A]
selection_x1:: DB
selection_y1:: DB
selection_x2:: DB
selection_y2:: DB

SECTION "Keyboard Demo", ROM0
INCLUDE "src/keyboard/kb_debug_ui.asm"
INCLUDE "img/sprite_font.asm"

AliceText:: INCBIN "data/Alice.txt"
AliceTextEnd:: DB, 0;string terminator

HighlightInterrupt::
  push af
  push bc
  ldh a, [rLY]
  inc a;check next line
  srl a
  srl a
  srl a;tileY = LY/8
  ld b, a;tileY
  ldh a, [selection_y1]
  cp a, b
  jp z, .firstLine;if LY == y1
  jp nc, .beforeFirstLine;if LY < y1
  ldh a, [selection_y2]
  cp a, b
  jp z, .lastLine;if LY == y2
  jp c, .afterLastLine; if LY > y2

.middleLines;otherwise
  sla a
  sla a
  sla a;selection_y2*8
  dec a;y2*8-1
  ldh [rLYC], a
  jp .highlighted

.beforeFirstLine
  sla a
  sla a
  sla a;selection_y1*8
  dec a;y1*8-1
  ldh [rLYC], a
  jp .notHighlighted

.firstLine;a = selection_y1
  ldh a, [rLY]
  add a, 8
  ldh [rLYC], a
  
  ld a, [rSTAT]
  ld c, a
  xor STATF_MODE00 | STATF_MODE10 ; Need to remove Mode 0 to avoid STAT blocking
  ldh [rSTAT], a
  xor a
  ldh [rIF], a

  ld a, DMG_PAL_NORMAL
  ld [rBGP], a
  halt ; Halt with intterrupts disabled to sync with Mode 2
  nop  ; avoid halt bug

  ldh a, [selection_x1]
  sla a
  sla a
  sla a
.wait
    dec a
    jr nz, .wait
  
  ld a, DMG_PAL_INVERT
  ldh [rBGP], a

  ; ldh a, [selection_y2]
  ; ld c, a
  ; ldh a, [selection_y1]
  ; cp a, c
  ; jr nz, .waitForEnd

  ld a, c
  ld [rSTAT], a
  jp .done

; .waitForEnd
;   ldh a, [selection_x2]
;   sla a
;   sla a
;   sla a
; .wait2
;     dec a
;     jr nz, .wait2

;   ld a, DMG_PAL_INVERT
;   ldh [rBGP], a
  
.lastLine
  ldh a, [rLY]
  add a, 8
  ld [rLYC], a
  ldh a, [selection_x2]
  cp a, 10
  jp c, .notHighlighted
  jp .highlighted

.afterLastLine
  xor a
  ldh [rLYC], a

.notHighlighted
  ld a, DMG_PAL_NORMAL
  jp .setPalette

.highlighted
  ld a, DMG_PAL_INVERT

.setPalette
  ldh [rBGP], a

.done
  ldh a, [rIF]
  and ~IEF_LCDC
  ldh [rIF], a
  pop bc
  pop af
  reti


KeyboardDemo::
  di
  DISPLAY_OFF
  call LoadFontTiles
  ld a, " "
  call ClearScreen

  ld hl, _SpriteFontTiles
  ld de, _VRAM8000
  ld bc, _SPRITE_FONT_TILE_COUNT*16
  call mem_CopyVRAM

  ld a, 1;cursor will be a 1 pixel vertical line
  ld hl, _VRAM8000
  ld bc, 16
  call mem_SetVRAM


  ld a, DMG_PAL_BLWW
  ld [rOBP0], a;normal
  ld a, DMG_PAL_WLBW
  ld [rOBP1], a;highlighted

  DISPLAY_ON
  ei

  ld a, DRAW_FLAGS_BKG | DRAW_FLAGS_NO_SPACE
  ld hl, AliceText
  ld de, 0
  ld bc, -1
  call DrawText

  call SaveLine

  PLAY_SONG tessie_data, 1

.setupInterrupt
  ld a, 2
  ldh [selection_x1], a
  ld a, 3
  ldh [selection_y1], a
  ld a, 16
  ldh [selection_x2], a
  ld a, 7
  ldh [selection_y2], a
  
  ld a, STATF_LYCF
  ldh [rSTAT], a
  xor a

.setupMenu
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
  ld a, OAMF_PAL1
  ld [hli], a
  ret
.hide
  xor a
  ld [hli], a
  ld [hli], a
  ld [hli], a
  ld [hli], a
  ret
