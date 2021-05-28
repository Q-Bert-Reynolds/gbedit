TRAMPOLINE: MACRO ;\1 = jump address
  ld b, BANK(\1)
  ld hl, \1
  call Trampoline
ENDM

PUSH_VAR: MACRO ;\1 = WRAM address
  ld a, [\1]
  push af
ENDM

POP_VAR: MACRO ;\1 = WRAM address
  pop af
  ld [\1], a
ENDM

;Debug messages can contain expressions between %%. 
;When enabled in the settings, whenever a debug message is encountered in the code, it will be logged to the debug messages window or log file.
;Debug messages also support ternary operators in the form: "%boolean expression%text if true;text if false;".
DEBUG_LOG_STRING: MACRO; \1 = string
  ld  d, d
  jr .end\@
  dw $6464
  dw $0000
  db \1,0
.end\@:
ENDM

DEBUG_LOG_ADDRESS: MACRO; \1 = address, \2 = bank
  ld  d, d
  jr .end\@
  dw $6464
  dw $0001
  db \1
  dw \2
.end\@:
ENDM

DEBUG_LOG_LABEL: MACRO; \1 = label
  DEBUG_LOG_ADDRESS \1, BANK(\1)
ENDM

SET_LCD_INTERRUPT: MACRO ;\1 = interrupt address
  di

  ld b, ~IEF_LCDC
  ld a, [rIE]
  and a, b
  ld [rIE], a

  xor a
  ld [rSTAT], a

  ld hl, rLCDInterrupt
  ld bc, \1
  ld a, b
  ld [hli], a
  ld a, c
  ld [hl], a

  ld b, IEF_LCDC
  ld a, [rIE]
  or a, b
  ld [rIE], a

  ld a, STATF_LYC
  ld [rSTAT], a
  
  ei
ENDM

DISABLE_LCD_INTERRUPT: MACRO
  di
    
  ld b, ~IEF_LCDC
  ld a, [rIE]
  and a, b
  ld [rIE], a

  xor a
  ld [rSTAT], a

  ld hl, rLCDInterrupt
  ld bc, EndLCDInterrupt
  ld a, b
  ld [hli], a
  ld a, c
  ld [hl], a

  ei
ENDM

HIDE_ALL_SPRITES: MACRO
  xor a
  ld b, 40
  ld hl, oam_buffer
.loop\@
  ld [hli], a
  ld [hli], a
  inc hl
  inc hl
  dec b
  jr nz, .loop\@
ENDM

CLEAR_SCREEN: MACRO ;\1 = tile
  ld a, \1
  call ClearScreen
ENDM

CLEAR_BKG_AREA: MACRO ;x, y, w, h, tile
  ld a, \5
  ld bc, \3 * \4
  ld hl, tile_buffer
  call mem_Set
  ld d, \1
  ld e, \2
  ld h, \3
  ld l, \4
  ld bc, tile_buffer
  call gbdk_SetBkgTiles
ENDM

CLEAR_WIN_AREA: MACRO ;x, y, w, h, tile
  ld a, \5
  ld bc, \3 * \4
  ld hl, tile_buffer
  call mem_Set
  ld d, \1
  ld e, \2
  ld h, \3
  ld l, \4
  ld bc, tile_buffer
  call gbdk_SetWinTiles
ENDM

UPDATE_INPUT_AND_JUMP_TO_IF_BUTTONS: MACRO ; \1=address, \2=buttons
  call UpdateInput
  JUMP_TO_IF_BUTTONS \1, \2
ENDM

JUMP_TO_IF_BUTTONS: MACRO ; \1=address, \2=buttons
  ld a, [last_button_state]
  and a
  jr nz, .skip\@
  ld a, [button_state]
  and \2
  jp nz, \1
.skip\@
ENDM

EXITABLE_DELAY: MACRO ; \1=address, \2=buttons, \3=frames
  ld a, \3
.loop\@
    push af
    UPDATE_INPUT_AND_JUMP_TO_IF_BUTTONS .jump\@, \2
    call gbdk_WaitVBL
    pop af
    dec a
    jr nz, .loop\@
  jr .exit\@
.jump\@
  pop af
  jp \1
.exit\@
ENDM

WAITPAD_UP: MACRO
.loop\@
  call gbdk_WaitVBL
  call UpdateInput
  ld a, [last_button_state]
  and a
  jr nz, .loop\@
ENDM

WAITPAD_UP_OR_FRAMES: MACRO ; \1=frames
  ld a, \1
.loop\@
    push af;frames
    call gbdk_WaitVBL
    call UpdateInput
    ld a, [last_button_state]
    and a
    jr z, .exit\@
    pop af;frames
    dec a
    jr nz, .loop\@
  push af;frames
.exit\@
  pop af;frames
ENDM

SET_DEFAULT_PALETTE: MACRO
  ld hl, rBGP
  ld [hl], DMG_PAL_BDLW
  ld hl, rOBP0
  ld [hl], DMG_PAL_BDLW
  ld hl, rOBP1
  ld [hl], DMG_PAL_DLWW
ENDM

RGB: MACRO ;\1 = red, \2 = green, \3 = blue
  DW (\3 << 10 | \2 << 5 | \1)
ENDM

D24: MACRO ;\1 = 24 bit number 
  DB (\1 & $FF0000) >> 16
  DB (\1 & $00FF00) >> 8
  DB (\1 & $0000FF)
ENDM

BETWEEN: MACRO; if \1 <= a < \2
IF \1 > \2
  PRINTT "ERROR: LOWER BOUND CAN'T BE HIGHER THAN UPPER BOUND."
ELIF \1 < 0 && \2 >= 0
  cp 128
  jr c, .positive\@
  cp \1
  jr nc, .true\@
  jr .false\@
.positive\@
  cp \2
  jr c, .true\@
  jr .false\@
ELSE
  cp \1
  jr c, .false\@
  cp \2
  jr nc, .false\@
  jr .true\@
ENDC
.false\@
  xor a
  jr .end\@
.true\@
  ld a, 1
  and a
.end\@
ENDM