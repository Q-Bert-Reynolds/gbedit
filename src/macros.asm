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

CLEAR_TILES: MACRO ;\1 = tile
  ld a, \1
  ld bc, 32*32+20*18
  ld hl, _SCRN0
  call mem_Set
ENDM

CLEAR_SCREEN: MACRO ;\1 = tile
  CLEAR_TILES \1
  ld a, 166
  ld [rWX], a
  ld a, 143
  ld [rWY], a
  HIDE_ALL_SPRITES
ENDM

CLEAR_BKG_AREA: MACRO ;x, y, w, h, tile
  ld de, \3 * \4
  ld hl, tile_buffer
.tilesLoop\@
    ld a, \5
    ld [hli], a
    dec de
    ld a, d
    and a
    jr nz, .tilesLoop\@
    ld a, e
    and a
    jr nz, .tilesLoop\@
  ld d, \1
  ld e, \2
  ld h, \3
  ld l, \4
  ld bc, tile_buffer
  call gbdk_SetBkgTiles
ENDM

CLEAR_WIN_AREA: MACRO ;x, y, w, h, tile
  ld de, \3 * \4
  ld hl, tile_buffer
.tilesLoop\@
    ld a, \5
    ld [hli], a
    dec de
    ld a, d
    and a
    jr nz, .tilesLoop\@
    ld a, e
    and a
    jr nz, .tilesLoop\@
  ld d, \1
  ld e, \2
  ld h, \3
  ld l, \4
  ld bc, tile_buffer
  call gbdk_SetWinTiles
ENDM

FADE_OUT: MACRO
  ld a, $90
  ld [rBGP], a
  ld [rOBP0], a
  ld de, 200
  call gbdk_Delay
  ld a, $40
  ld [rBGP], a
  ld [rOBP0], a
  ld de, 200
  call gbdk_Delay
  xor a
  ld [rBGP], a
  ld [rOBP0], a
  ld de, 200
  call gbdk_Delay
ENDM

FADE_IN: MACRO
  ld a, $40
  ld [rBGP], a
  ld [rOBP0], a
  ld de, 200
  call gbdk_Delay
  ld a, $90
  ld [rBGP], a
  ld [rOBP0], a
  ld de, 200
  call gbdk_Delay
  ld a, BG_PALETTE
  ld [rBGP], a
  ld [rOBP0], a
  ld de, 200
  call gbdk_Delay
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
  ld a, [button_state]
  and a
  jr nz, .loop\@
ENDM

SET_DEFAULT_PALETTE: MACRO
  ld hl, rBGP
  ld [hl], BG_PALETTE
  ld hl, rOBP0
  ld [hl], SPR_PAL_BDL
  ld hl, rOBP1
  ld [hl], SPR_PAL_DLW
ENDM

RGB: MACRO ;\1 = red, \2 = green, \3 = blue
  dw (\3 << 10 | \2 << 5 | \1)
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