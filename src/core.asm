SECTION "Core", ROM0

; SetBank                         a = bank ;TODO: handle more than 255 banks
; Trampoline                      b = bank, hl = address, can only use de and RAM for args, can't return anything in a
; UpdateInput
; DrawStateMap
; ClearTiles                      a = clear tile, display should be off
; ClearScreen                     a = clear tile, display should be off
; SetTiles                        a = draw flags, hl=wh, de=xy, bc=firstTile
; CopyToTileBuffer                hl=wh, de=xy, bc=firstTile
; SetBkgTilesWithOffset           hl=wh, de=xy, bc=in_tiles, a=offset
; SetWinTilesWithOffset           hl=wh, de=xy, bc=in_tiles, a=offset
; SetSpriteTiles                  bc = count, hl = map, de = offset\props
; SetSpriteTilesProps             bc = offset\count, hl = tilemap, de = propmap
; MoveSprites                     bc = xy in screen space, hl = wh in tiles, a = first sprite index
; SetSpriteTilesXY                bc = xy in screen space, hl = wh in tiles, de = tilemap, a = VRAM offset
; FlipTileMapX                    hl=wh; bc=in_tiles, de=out_tiles
; ReverseByte                     reverses a
; ScrollXYToTileXY                returns xy in de
; DistanceToScreenOrVRAMEdge      tile xy in de, returns wh in hl
; CopyBkgToWin
; CopyWinToBuffer
; CopyBufferToWin
; GetZeroPaddedNumber             a = number, returns padded number in str_buffer, affects str_buffer, all registers
; SignedRandom                    a = bitmask, returns signed random bytes in d and e
; SetPalettesIndirect             hl = palettes in PAL_SET (SGB) fromat
; SetPalettesDirect               a = SGB packet header, bc = paletteA, de = paletteB
; GBCSetPalette                   a = palette id, hl = colors
; CopyPalettesTo                  hl = destination
; CopyPalettesFrom                hl = source

CancelString::    DB "CANCEL", 0
YesNoText::       DB "YES\nNO",0
SaveGameText:     DB "Would you like to\nSAVE the game?",0
NowSavingText:    DB "Now saving...",0
SavedTheGameText: DB "%s saved\nthe game.",0

SetBank:: ;a = BANK ;TODO: handle more than 255 banks
  ld [loaded_bank], a
  ld [rROMB0], a
  ret
  
Trampoline:: ;b = bank, hl = address, can only use de and RAM for args, can't return anything in a
  ld a, [loaded_bank]
  push af;old bank
  ld a, b;new bank
  call SetBank
  ld bc, .bounceBack
  push bc ;put return addres on stack before jumping
  jp hl
.bounceBack
  pop af;old bank
  call SetBank
  ret

SerialInterrupt::
  push af
  push bc
  push de
  push hl
  call PS2KeyboardInterrupt
  pop hl 
  pop de
  pop bc
  pop af
  reti

LCDInterrupt::
  push af
  push bc
  push de
  push hl
  ld hl, rLCDInterrupt
  ld a, [hli]
  ld b, a
  ld a, [hl]
  ld h, b
  ld l, a
  ld bc, EndLCDInterrupt
  push bc ;put return address on stack before jumping
  jp hl
EndLCDInterrupt::
  pop hl 
  pop de
  pop bc
  pop af
  reti

VBLInterrupt::
  push af
  push bc
  push de
  push hl
  call _HRAM
  call UpdateTime
  call UpdateAudio
  ld a, 1
  ld [vbl_done], a
  pop hl 
  pop de
  pop bc
  pop af
  reti

UpdateTime::
  ld a, [vbl_timer]
  inc a
  ld [vbl_timer], a
  cp a, 60
  ret c
  xor a
  ld [vbl_timer], a

.testGameState
  ld a, [game_state]
  and a, GAME_STATE_CLOCK_STARTED
  ret z;if game hasn't started, don't increment game time

.incrementSeconds
  ld a, [seconds]
  inc a
  ld [seconds], a
  cp a, 60
  ret c

.incrementMinutes
  xor a
  ld [seconds], a
  ld a, [minutes]
  inc a
  ld [minutes], a
  cp a, 60
  ret c

.incrementHours
  xor a
  ld [minutes], a
  ld a, [hours]
  ld h, a
  ld a, [hours+1]
  ld l, a
  inc hl
  ld a, h
  ld [hours], a
  ld a, l
  ld [hours+1], a
  ret
 
UpdateInput::;https://gbdev.io/pandocs/#joypad-input
  push bc
  push hl

  ;copy button_state to last_button_state
  ld a, [button_state]
  ld [last_button_state], a

  ;read DPad
  ld hl, rP1
  ld a, P1F_GET_DPAD
  ld [hl], a ;switch to P15
REPT INPUT_REPEAT;multiple cycles to avoid button bounce
  ld a, [hl] ;load DPad
ENDR
  and %00001111 ;discard upper nibble
  swap a ;move low nibble to high nibble
  ld b, a ;store DPad in b

  ;read A,B,Select,Start
  ld a, P1F_GET_BTN
  ld [hl], a ;switch to P14
REPT INPUT_REPEAT
  ld a, [hl] ;load buttons
ENDR
  and %00001111 ;discard upper nibble
  or b ;combine DPad with other buttons
  cpl ;flip bits so 1 means pressed
  ld hl, button_state
  ld [hl], a

  pop hl
  pop bc
  ret

ClearTiles:: ;a = tile, display should be off
  ld bc, 32*32+20*18
  ld hl, _SCRN0
  call mem_Set
  ret

ClearScreen:: ;a = tile, display should be off
  call ClearTiles
  ld a, 166
  ld [rWX], a
  ld a, 143
  ld [rWY], a
  HIDE_ALL_SPRITES
  ret 

SetTiles::;a = draw flags, hl=wh, de=xy, bc=firstTile
  and a, DRAW_FLAGS_WIN
  jr z, .skip
  call gbdk_SetWinTiles
  ret
.skip
  call gbdk_SetBkgTiles
  ret

CopyToTileBuffer::;hl=wh, de=xy, bc=firstTile
  push hl;wh
  ld hl, tile_buffer;destination
  COPY_TILE_BLOCK OP_COPY_FROM, SKIP_VRAM

SetToTileBuffer::
  ld hl, tile_buffer
  push bc
  ld b, a
  COPY_TILE_BLOCK OP_SET_TO, SKIP_VRAM

CopyToTileBufferWithOffset: ;hl=wh, de=xy, bc=in_tiles, a=offset
  push de ;xy
  push hl ;wh
  push af ;offset
  push bc ;in_tiles

  ld d, 0
  ld e, h ;de = width
  ld a, l ;a = height
  call math_Multiply
  pop bc;in_tiles
  pop af;offset
  push hl;count
  push af;offset
  ld hl, tile_buffer
.loop ;for (i = w*h; i > 0; --i)
    ld a, [bc]
    inc bc
    ld d, a
    pop af ;offset
    push af ;offset
    add a, d
    ld [hli], a; tiles[i] = in_tiles[i]+offset;
    
    pop af;offset
    pop de;count
    dec de
    push de;count
    push af;offset

    ld a, d
    and a
    jr nz, .loop
    ld a, e
    and a
    jr nz, .loop

  pop af ;count
  pop af ;offset
  pop hl ;xy
  pop de ;wh
  ret

SetBkgTilesWithOffset:: ;hl=wh, de=xy, bc=in_tiles, a=offset
  call CopyToTileBufferWithOffset
  ld bc, tile_buffer
  call gbdk_SetBkgTiles
  ret
  
SetWinTilesWithOffset:: ;hl=wh, de=xy, bc=in_tiles, a=offset
  call CopyToTileBufferWithOffset
  ld bc, tile_buffer
  call gbdk_SetWinTiles
  ret

SetSpriteTiles:: ;bc = count, hl = map, de = offset\props
  xor a
  ld [_i], a
.loop
    push bc;count
    ld a, [_i]
    ld c, a
    ld a, [hli]
    push hl;map index
    add a, d;offset
    push de;offset\props
    ld d, a ;tile
    call gbdk_SetSpriteTile
    ld a, [_i]
    ld c, a
    pop de;offset\props
    push de;offset\props
    ld d, e
    call gbdk_SetSpriteProp
    pop de;offset\props
    pop hl;map index
    ld a, [_i]
    inc a
    ld [_i], a
    pop bc; count
    dec bc
    ld a, b
    or c
    jr nz, .loop
  ret

SetSpriteTilesProps:: ;bc = offset\count, hl = tilemap, de = propmap
  xor a
  ld [_i], a
.loop
    push bc;offset\count
    ld a, [_i]
    add a, b
    ld c, a
    ld a, [hli]
    push hl;tilemap index
    add a, b;offset
    push de;propmap
    ld d, a ;tile
    push bc;offset & sprite/prop num
    call gbdk_SetSpriteTile
    pop bc;offset & sprite/prop num
    pop de;propmap
    ld a, [de]
    inc de
    push de;propmap
    ld d, a
    call gbdk_SetSpriteProp
    pop de;propmap
    pop hl;tilemap
    ld a, [_i]
    inc a
    ld [_i], a
    pop bc; count
    dec c
    jr nz, .loop
  ret

; moves a grid of sprite tiles
MoveSprites:: ;bc = xy in screen space, hl = wh in tiles, a = first sprite index
  ld [_a], a
  xor a
  ld [_j], a
.rowLoop ;for (j = 0; j < h; j++)
    xor a
    ld [_i], a
  .columnLoop ;for (i = 0; i < w; i++)
      ld a, [_i]
      add a ;i*2
      add a ;i*4
      add a ;i*8
      add a, b ;i*8+x
      ld d, a

      ld a, [_j]
      add a; j*2
      add a; j*4
      add a; j*8
      add a, c ;j*8+y
      ld e, a

      push bc
      ld a, [_a]
      ld c, a
      inc a
      ld [_a], a

      push hl
      call gbdk_MoveSprite;move_sprite(a++, i*8+x, j*8+y);
      pop hl
      pop bc

      ld a, [_i]
      inc a
      ld [_i], a
      sub a, h
      jr nz, .columnLoop

    ld a, [_j]
    inc a
    ld [_j], a
    sub a, l
    jr nz, .rowLoop
  ret

;; sets and moves a grid of sprite tiles, skips tiles according to flags, resets sprite_first_tile to 0
SetSpriteTilesXY:: ;bc = xy in screen space, hl = wh in tiles, de = tilemap, a = VRAM offset
  ld [sprite_offset], a;offset
  push bc
  ld b, a
  ld a, [sprite_first_tile]
  add a, b
  ld [_a], a;first tile
  pop bc
  xor a
  ld [_j], a;row
.rowLoop ;for (j = 0; j < h; j++)
    xor a
    ld [_i], a
  .columnLoop ;for (i = 0; i < w; i++)
      push bc;xy
      push hl;wh

      ld a, [sprite_flags]
      and SPRITE_FLAGS_SKIP
      jr z, .noSkip
      ld a, [sprite_skip_id]
      ld h, a
      ld a, [de]
      cp h;skip me
      jr z, .skip
    .noSkip
      ld a, [_a]
      cp a, 40
      jr nc, .skip
      push de;tilemap
      
      ld e, a
      inc a
      ld [_a], a
      ld hl, oam_buffer
      sla e ;multiply e by 4
      sla e
      ld d, 0
      add hl, de

      ld a, [_j]
      add a; j*2
      add a; j*4
      add a; j*8
      add a, c ;j*8+y
      ld [hli], a;y

      ld a, [_i]
      add a ;i*2
      add a ;i*4
      add a ;i*8
      add a, b ;i*8+x
      ld [hli], a;x

      ld a, [sprite_offset];offset
      ld b, a
      pop de;tilemap
      ld a, [de]
      add a, b
      ld [hli], a;tile

      ld a, [sprite_props]
      ld [hli], a

    .skip
      inc de;tile index
      pop hl;wh
      pop bc;xy

      ld a, [_i]
      inc a
      ld [_i], a
      sub a, h
      jr nz, .columnLoop

    ld a, [_j]
    inc a
    ld [_j], a
    sub a, l
    jr nz, .rowLoop

  ld a, [sprite_flags]
  and SPRITE_FLAGS_CLEAR_END
  ret z

  ld a, [_a]
  ld e, a
  ld hl, oam_buffer
  sla e ;multiply e by 4
  sla e
  ld d, 0
  add hl, de
  ld a, 160
  sub a, e
  ld b, 0
  ld c, a
  xor a
  call mem_Set

  xor a
  ld [sprite_first_tile], a;reset first tile to zero ;TODO: handle this better

  ret

FlipTileMapX::;hl=wh; bc=in_tiles, de=out_tiles
  push hl;wh
  xor a
  ld [_j], a
.rowLoop
    pop hl;wh
    push hl
    ld a, h
    ld [_i], a

    push de;out_tiles
    ld d, 0
    ld e, a
    ld a, [_j]
    inc a
    call math_Multiply
    dec hl
    add hl, bc
    pop de;out_tiles
  .columnLoop
      ld a, [hld]
      ld [de], a
      inc de

      ld a, [_i]
      dec a
      ld [_i], a
      jr nz, .columnLoop
    ld a, [_j]
    inc a
    ld [_j], a
    pop hl;wh
    push hl
    cp l
    jr nz, .rowLoop

  pop hl
  ret

ReverseByte::;byte in a
  push bc
  ld b,a    ; a = 76543210
  rlca
  rlca      ; a = 54321076
  xor b
  and $AA
  xor b     ; a = 56341270
  ld b,a
  rlca
  rlca
  rlca      ; a = 41270563
  rrc b     ; b = 05634127
  xor b
  and $66
  xor b     ; a = 01234567
  pop bc
  ret

ScrollXYToTileXY::;returns xy in de
  ld a, [rSCX]
  rra;x/2
  rra;x/4
  rra;x/8
  ld d, a ; x
  
  ld a, [rSCY]
  rra;x/2
  rra;x/4
  rra;x/8
  ld e, a ; y
  ret

DistanceToScreenOrVRAMEdge::;tile xy in de, returns wh in hl
  ld a, 32
  sub a, d
  ld h, a ; w
  ld a, 20
  cp h
  jr nc, .skipWidth
  ld h, a
.skipWidth

  ld a, 32
  sub a, e
  ld l, a ; h
  ld a, 18
  cp l
  jr nc, .skipHeight
  ld l, a
.skipHeight

  ret 

CopyBkgToWin::
  call ScrollXYToTileXY;de
  call DistanceToScreenOrVRAMEdge;hl
  
.upperLeft
  push hl;wh
  push de;xy
  ld bc, bkg_buffer
  call gbdk_GetBkgTiles

  pop de;xy
  pop hl;wh
  push hl
  push de
  ld de, 0
  ld bc, bkg_buffer
  call gbdk_SetWinTiles

  pop de;xy
  pop hl;wh
  push hl
  push de

  ld a, 32-20
  cp d
  jp nc, .bottomLeft
  ld d, h;x = left width
  ld a, 20
  sub a, h
  ld h, a; right width

.upperRight
  push hl;wh
  push de;xy
  ld d, 0
  ld bc, bkg_buffer
  call gbdk_GetBkgTiles

  pop de;xy
  pop hl;wh
  push hl
  push de
  ld e, 0
  ld bc, bkg_buffer
  call gbdk_SetWinTiles

  pop de;xy
  pop hl;wh
  
  ld a, 32-18
  cp e
  jr nc, .bottomLeft;skip bottom right
  ld e, l;y = upper height
  ld a, 18
  sub a, l
  ld l, a; bottom right height

.bottomRight
  push hl;wh
  push de;xy
  ld de, 0
  ld bc, bkg_buffer
  call gbdk_GetBkgTiles

  pop de;xy
  pop hl;wh
  push hl;wh
  push de;xy
  ld bc, bkg_buffer
  call gbdk_SetWinTiles

  pop de;xy
  pop hl;wh

.bottomLeft
  pop de;xy
  pop hl;wh
  ld a, 32-18
  cp e
  jr nc, .checkGBC;skip bottom 
  ld e, l;y = upper height
  ld a, 18
  sub a, l
  ld l, a; bottom height

  push hl;wh
  push de;xy
  ld e, 0
  ld bc, bkg_buffer
  call gbdk_GetBkgTiles

  pop de;xy
  pop hl;wh
  push hl;wh
  push de;xy
  ld d, 0
  ld bc, bkg_buffer
  call gbdk_SetWinTiles

  pop de;xy
  pop hl;wh 

.checkGBC
  ld a, [sys_info]
  and a, SYS_INFO_GBC
  ret z

  ld a, [rVBK]
  bit 0, a
  jr nz, .resetVRAMBank;if rVBK == 1, we've already set colors, so we're done

  ld a, 1
  ld [rVBK], a
  jp CopyBkgToWin; otherwise, set rVBK to 1 and copy again

.resetVRAMBank
  xor a
  ld [rVBK], a
  ret

CopyWinToBuffer::
  ld hl, $1412;20,18
  ld de, 0
  ld bc, win_buffer
  call gbdk_GetWinTiles
  ld a, [sys_info]
  and a, SYS_INFO_GBC
  ret z
  ld a, 2
  ld [rSVBK], a
  dec a
  ld [rVBK], a
  ld hl, $1412;20,18
  ld de, 0
  ld bc, win_buffer
  call gbdk_GetWinTiles
  xor a
  ld [rSVBK], a
  ld [rVBK], a
  ret

CopyBufferToWin::
  ld hl, $1412;20,18
  ld de, 0
  ld bc, win_buffer
  call gbdk_SetWinTiles
  ld a, [sys_info]
  and a, SYS_INFO_GBC
  ret z
  ld a, 2
  ld [rSVBK], a
  dec a
  ld [rVBK], a
  ld hl, $1412;20,18
  ld de, 0
  ld bc, win_buffer
  call gbdk_SetWinTiles
  xor a
  ld [rSVBK], a
  ld [rVBK], a
  ret

GetZeroPaddedNumber::;a = number, returns padded number in str_buffer, affects str_buffer, all registers
  ld h, 0
  ld l, a
  ld de, name_buffer
  call str_Number

  ld hl, str_buffer
  ld a, "0"
  ld [hli], a
  ld [hli], a
  ld [hli], a

  ld hl, name_buffer
  call str_Length
  ld a, 3
  sub a, e
  ld e, a
  ld hl, str_buffer
  add hl, de
  ld d, h
  ld e, l
  ld hl, name_buffer
  call str_Copy
  ret

SignedRandom:: ;a = bitmask, returns signed random bytes in d and e
  push af
  call gbdk_Random
  pop af
  push af
  and a, d
  ld b, a
  ld a, d
  and %10000000
  jr z, .skipD
  ld a, b
  xor a, $FF
  add a, 1
  ld b, a
.skipD
  ld d, b

  pop af
  and a, e
  ld b, a
  ld a, e
  and %10000000
  jr z, .skipE
  ld a, b
  xor a, $FF
  add a, 1
  ld b, a
.skipE
  ld e, b

  ret

;----------------------------------------------------------------------
;
; SetPalettesIndirect - sets first 4 palettes by index
;   
;   works for both CGB and SGB
;
;   input: 
;     hl = palettes in PAL_SET (SGB) fromat
;
;----------------------------------------------------------------------
SetPalettesIndirect::;hl = palettes in PAL_SET (SGB) fromat
.checkCGB
  ld a, [sys_info]
  and a, SYS_INFO_GBC
  jr z, .checkSGB
.setPaletteCGB
  push hl;palettes
  inc hl;first palette index
  ld a, BCPSF_AUTOINC
  ld [rBCPS], a
  ld [rOCPS], a

  xor a
.loopPalettes
    push af;pal id
    ld a, [hli]
    ld c, a
    ld a, [hli]
    ld b, a
    pop af;pal id
    push af;pal id
    push hl;next palette label
    push af;pal id
    ld h, b
    ld l, c;index
    add hl, hl;hl*2
    add hl, hl;hl*4
    add hl, hl;hl*8
    ld bc, DefaultPalettes
    add hl, bc

    pop af;pal id
    call GBCSetPalette

    pop hl;palette label
    pop af
    inc a
    cp 4
    jr nz, .loopPalettes

  pop hl;palettes
.checkSGB
  ld a, [sys_info]
  and a, SYS_INFO_SGB
  ret z
.setPalettesSGB
  jp _sgb_PacketTransfer;no need to check sys info again

;----------------------------------------------------------------------
;
; SetPalettesDirect - sets 2 palettes
;   
;   works for both CGB and SGB
;
;   input: 
;     a = SGB packet header
;     bc = colorA
;     de = colorB
;
;----------------------------------------------------------------------
SetPalettesDirect::;a = SGB packet header, bc = paletteA, de = paletteB
  ld h, a;header
.checkCGB
  ld a, [sys_info]
  and a, SYS_INFO_GBC
  jr z, .checkSGB
.setPaletteCGB
  ld h, b
  ld l, c
  ld a, 2
  call GBCSetPalette
  ld h, d
  ld l, e
  ld a, 3
  call GBCSetPalette
.checkSGB
  ld a, [sys_info]
  and a, SYS_INFO_SGB
  ret z
.setPalettesSGB
  ld a, h;header
  jp sgb_SetPal

;TODO: SGB palette matching should be handled better than this
GBCSetPalette::;a = palette id, hl = colors
  sla a
  sla a
  sla a
  or a, BCPSF_AUTOINC
  ld [rBCPS], a
  ld [rOCPS], a
  ld a, 8;4 colors, 2 bytes each
.loopColors
    push af
    LCD_WAIT_VRAM
    ld a, [hli]
    ldh [rBCPD], a
    ldh [rOCPD], a
    pop af
    dec a
    jr nz, .loopColors
  ret

;----------------------------------------------------------------------
;
; SetColorBlocks - sets rectangles of color in screenspace
;   
;   works for both CGB and SGB
;
;   input: 
;     b = draw flags
;     hl = SGB ATTR_BLK
;
;----------------------------------------------------------------------
SetColorBlocks::
.checkCGB
  ld a, [sys_info]
  and a, SYS_INFO_GBC
  jr z, .checkSGB
.setColorBlocksCGB
  jp GBCSetColorBlocks
.checkSGB
  ld a, [sys_info]
  and a, SYS_INFO_SGB
  ret z
.setColorBlocksSGB
  jp _sgb_PacketTransfer

;assumes no window offset, only handles inside blocks
GBCSetColorBlocks::;b = draw flags, hl = SGB ATTR_BLK address
  inc hl;skip SGB_PACKET
  ld a, [hli];packet count
.loop
    push af;packet count
    push bc;draw flags
    call GBCSetColorBlock
    pop bc;draw flags
    pop af;packet count
    dec a
    jr nz, .loop
  ret

;TODO: handle outside and border cases
GBCSetColorBlock::;b = draw flags, hl = ATTR_BLK_PACKET address, returns address of next ATTR_BLK_PACKET if any
  push bc;draw flags
  ld a, [hli];bit 2 = outside block, bit 1 = on border, bit 0 = inisde block... not used here
  ld a, [hli];(outside << 4) + (border << 2) + inside XXoobbii
  and %00000011;toss outside and border palettes
  ld b, a;palette in b
  ld a, [hli];x
  ld d, a;x
  ld a, [hli];y
  ld e, a;y
  ld a, [hli];x+w-1
  sub a, d;w-1
  inc a;w
  ld c, a;w
  ld a, [hli];y+h-1
  sub a, e;h-1
  inc a;h
  push hl;next ATTR_BLK_PACKET
  ld h, c;w
  ld l, a;h
  push hl;wh
  push de;xy

  ld d, 0
  ld e, c;w
  call math_Multiply;hl = de * a = w * h, b untouched
  ld a, b;palette
  ld b, h
  ld c, l
  ld hl, tile_buffer
  call mem_Set;fills tile buffer with palette from above

  pop de;xy
  pop hl;wh
  pop bc;next ATTR_BLK_PACKET
  pop af;draw flags
  push bc;next ATTR_BLK_PACKET
  ld bc, tile_buffer
  call GBCSetPaletteMap
  pop hl;next ATTR_BLK_PACKET
  ret

GBCSetPaletteMap::;a = draw flags, hl = wh, de = xy, bc = firstTile
  and a, DRAW_FLAGS_WIN
  jr nz, GBCSetWinPaletteMap
  ;fall through to bkg pal map

GBCSetBkgPaletteMap::;hl = wh, de = xy, bc = firstTile
  ld a, [sys_info]
  and a, SYS_INFO_GBC
  ret z
  ld a, 1
  ld [rVBK], a
  call gbdk_SetBkgTiles
  xor a
  ld [rVBK], a
  ret

GBCSetWinPaletteMap::;hl = wh, de = xy, bc = firstTile
  ld a, [sys_info]
  and a, SYS_INFO_GBC
  ret z
  ld a, 1
  ld [rVBK], a
  call gbdk_SetWinTiles
  xor a
  ld [rVBK], a
  ret

CopyPalettesTo::;hl = dest
  push hl;dest
  ld bc, 8*2*4
  add hl, bc
  ld d, h
  ld e, l;de = dest+8*2*4
  pop hl;dest
  xor a
  ld c, 8*2*4;8 palettes * 2B / color * 4 colors / palette
.copyBkgPal
    ldh [rBCPS], a;set bkg palette index
    ldh [rOCPS], a;set obj palette index
    inc a
    push af;index
    LCD_WAIT_VRAM
    ldh a, [rBCPD];get bkg color
    ld [hli], a;store in tile_buffer
    ldh a, [rOCPD];get obj color
    ld [de], a;store in tile_buffer
    inc de
    pop af;index
    dec c
    jr nz, .copyBkgPal
  ret

CopyPalettesFrom::;hl = source
  push hl;dest
  ld bc, 8*2*4
  add hl, bc
  ld d, h
  ld e, l;de = dest+8*2*4
  pop hl;dest
  ld a, BCPSF_AUTOINC
  ldh [rBCPS], a
  ldh [rOCPS], a
  ld c, 8*2*4;8 palettes * 2B / color * 4 colors / palette
.loop
    LCD_WAIT_VRAM
    ld a, [hli]
    ldh [rBCPD], a
    ld a, [de]
    ldh [rOCPD], a
    inc de
    dec c
    jr nz, .loop
  ret