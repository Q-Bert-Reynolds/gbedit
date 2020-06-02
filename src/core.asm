SECTION "Core", ROM0

; GetTypeString                   a = type, string in name_buffer
; GetStatusString                 a = status, string in name_buffer
; SetBank                         a = bank ;TODO: handle more than 255 banks
; Trampoline                      b = bank, hl = address, can only use de and RAM for args, can't return anything in a
; UpdateInput
; DrawStateMap
; SetTiles                        a = draw flags, hl=wh, de=xy, bc=firstTile
; SetBKGTilesWithOffset           hl=wh, de=xy, bc=in_tiles, a=offset
; DrawSaveStats                   draw flags, de = xy
; ShowRoledex
; LoadSimulation                  a = ball speed b = spray angle c = launch angle
; ShowLineupFromWorld
; ShowLineupFromGame
; ShowPlayBallIntro               a = unsigned player(0) or team(1), [_a] = player num or coach id
; SetSpriteTiles                  bc = count, hl = map, de = offset\props
; SetSpriteTilesProps             bc = offset\count, hl = tilemap, de = propmap
; MoveSprites                     bc = xy in screen space, hl = wh in tiles, a = first sprite index
; SetSpriteTilesXY                bc = xy in screen space, hl = wh in tiles, de = tilemap, a = VRAM offset
; SetHPBarTiles                   de = player, hl = address
; SetAgeTiles                     de = player, hl = address
; SetMovePPTiles                  a = move, de = player, hl = tile address
; ScrollXYToTileXY                returns xy in de
; DistanceToScreenOrVRAMEdge      tile xy in de, returns wh in hl
; CopyBkgToWin
; SaveGame
; GetZeroPaddedNumber             a = number, returns padded number in str_buffer, affects str_buffer, all registers
; SignedRandom                    a = bitmask, returns signed random bytes in d and e
; SetPalettesIndirect             hl = palettes in PAL_SET (SGB) fromat
; SetPalettesDirect               a = SGB packet header, bc = paletteA, de = paletteB

Types:
  DB "", 0
  DB "Normal", 0
  DB "Fire", 0
  DB "Water", 0
  DB "Electric", 0
  DB "Grass", 0
  DB "Ice", 0
  DB "Fighting", 0
  DB "Poison", 0
  DB "Ground", 0
  DB "Flying", 0
  DB "Psychic", 0
  DB "Bug", 0
  DB "Rock", 0
  DB "Ghost", 0
  DB "Dragon", 0

Status:
  DB "OK", 0
  DB "BRN", 0
  DB "FRZ", 0
  DB "PAR", 0
  DB "PSN", 0
  DB "SLP", 0

GetTypeString:: ;a = type, string in name_buffer
  ld b, 0
  ld c, a
  ld hl, Types
  call str_FromArray
  ld de, name_buffer
  call str_Copy
  ret

GetStatusString:: ;a = status, string in name_buffer
  ld b, 0
  ld c, a
  ld hl, Status
  ld de, name_buffer
  call str_FromArray
  ld de, name_buffer
  call str_Copy
  ret

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
  push bc ;put return addres on stack before jumping
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
  ld a, [vbl_timer]
  inc a
  ld [vbl_timer], a
  call UpdateAudio
  ld a, 1
  ld [vbl_done], a
  pop hl 
  pop de
  pop bc
  pop af
  reti
 
UpdateInput::
  push bc
  push hl

  ;copy button_state to last_button_state
  ld hl, button_state
  ld a, [hl]
  ld hl, last_button_state
  ld [hl], a

  ;read DPad
  ld hl, rP1
  ld a, P1F_5
  ld [hl], a ;switch to P15
  ld a, [hl] ;load DPad
  and %00001111 ;discard upper nibble
  swap a ;move low nibble to high nibble
  ld b, a ;store DPad in b

  ;read A,B,Select,Start
  ld hl, rP1
  ld a, P1F_4
  ld [hl], a ;switch to P14
  ld a, [hl] ;load buttons
  and %00001111 ;discard upper nibble
  or b ;combine DPad with other buttons
  cpl ;flip bits so 1 means pressed
  ld hl, button_state
  ld [hl], a

  pop hl
  pop bc
  ret

DrawStateMap::
  ld a, [loaded_bank]
  push af;bank
  ld a, UI_BANK
  call SetBank

  call UIDrawStateMap

  pop af;bank
  call SetBank
  ret

SetTiles::;a = draw flags, hl=wh, de=xy, bc=firstTile
  and a, DRAW_FLAGS_WIN
  jr z, .skip
  call gbdk_SetWinTiles
  ret
.skip
  call gbdk_SetBkgTiles
  ret

SetBKGTilesWithOffset:: ;hl=wh, de=xy, bc=in_tiles, a=offset
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
  ld bc, tile_buffer
  call gbdk_SetBkgTiles ;set_bkg_tiles(x,y,w,h,tiles);
  ret

DrawSaveStats::;draw flags, de = xy
  push af;draw flags
  push de;xy
  ld a, [loaded_bank]
  ld b, a;old bank
  ld a, UI_BANK
  call SetBank

  pop de;xy
  pop af;draw flags
  push bc;old bank
  call UIDrawSaveStats

  pop af;old bank
  call SetBank
  ret

ShowRoledex::
  ld a, ROLEDEX_BANK
  call SetBank

  call ShowRoledexUI
  
  ld a, OVERWORLD_BANK
  call SetBank
  ret

LoadSimulation::;a = ball speed b = spray angle c = launch angle
  push af;ball speed
  ld a, SIM_BANK
  call SetBank

  pop af;ball speed
  call RunSimulation
  
  ld a, PLAY_BALL_BANK
  call SetBank
  ret

ShowLineupFromWorld::
  ld a, LINEUP_BANK
  call SetBank

  ld a, 0
  call ShowLineup

  ld a, OVERWORLD_BANK
  call SetBank
  ret

ShowLineupFromGame::
  ld a, LINEUP_BANK
  call SetBank

  ld a, 1
  call ShowLineup

  ld a, PLAY_BALL_BANK
  call SetBank
  ret

ShowPlayBallIntro:: ;a - 0 = unsigned player, 1 = team, [_a] = player num or coach id
  push af;team or player
  ld a, PLAY_BALL_INTRO_BANK
  call SetBank

  pop af;team or player
  call PlayBallIntro

  ld a, PLAY_BALL_BANK
  call SetBank
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

;; moves a grid of sprite tiles
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
      push de;tilemap
      
      ld a, [_a]
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
  ld a, 40
  sub a, e
  sla a
  sla a
  ld b, 0
  ld c, a
  xor a
  call mem_Set

  xor a
  ld [sprite_first_tile], a;reset first tile to zero ;TODO: handle this better

  ret

FlipTileMapX;hl=wh; bc=in_tiles, de=out_tiles
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

ReverseByte:;byte in a
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

SetHPBarTiles::;de = player, hl = address
  push hl;address
  ld h, d
  ld l, e
  push hl;player
  call GetPlayerHP
  ld d, h
  ld e, l
  ld a, 96;makes the math easier than multiplying by 100
  call math_Multiply
  ld d, h
  ld e, l;hp*100
  pop hl;player
  call GetPlayerMaxHP
  ld b, h
  ld c, l;maxHP
  ld h, d
  ld l, e;hp*100
  call math_Divide16;de (remainder hl) = hl / bc
  ;de = HP * 100 / maxHP
  pop hl;address
  ld a, 128
  ld [hli], a

  ld b, 6
  ld c, 16
.loop
    ld a, c;tile*16
    sub a, e;hp pct
    jr nc, .drawPartial
    ld a, 129
    ld [hli], a
    jr .next
.drawPartial;c-e < 16
    cp 16
    jr nc, .drawEmpty
    srl a;(c-e)/2 < 8
    ld d, a
    ld a, 129
    add a, d
    ld [hli], a
    jr .next
.drawEmpty
    ld a, 137
    ld [hli], a
.next
    ld a, c
    add a, 16
    ld c, a
    
    dec b
    ld a, b
    and a
    jr nz, .loop  

  ld a, 138
  ld [hli], a
  ret

SetAgeTiles::;de = player, hl = address
  push hl;address
  push de;player
  ld a, AGE
  ld [hl], a

  pop hl;player
  call GetPlayerAge
  ld h, 0
  ld l, a
  pop de; address
  cp 100
  jr z, .age100
  inc de
.age100
  call str_Number
  ret

SetMovePPTiles::;a = move, b = move mask, de = player, hl = tile address
  push hl;address
  push de;player

  pop hl;player
  push hl;player  
  push af;move
  ld d, b;move mask
  push de;move mask
  call GetPlayerMove
  pop de;move mask
  pop af;move
  pop hl;player
  call GetPlayerMovePP
  ld h, 0
  ld l, a
  ld de, str_buffer
  cp 10
  jr nc, .twoDigitPP
  ld a, " "
  ld [de], a
  inc de
.twoDigitPP
  call str_Number

  ld hl, name_buffer
  ld a, "/"
  ld [hli], a
  xor a
  ld [hld], a
  ld de, str_buffer
  call str_Append

  ld hl, move_data.pp
  ld a, [hl]
  ld de, name_buffer
  cp 10
  jr nc, .twoDigitMaxPP
  ld a, " "
  ld [de], a
  inc de
.twoDigitMaxPP
  ld a, [hl]
  ld h, 0
  ld l, a
  call str_Number
  ld hl, name_buffer
  ld de, str_buffer
  call str_Append

  ld hl, str_buffer
  pop de; address
  call str_Copy

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
    jr nc, .skipRight
    ld d, h;x = left width
    ld a, 20
    sub a, h
    ld h, a; right width

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
    jr nc, .skipRight;skip bottom right
    ld e, l;y = upper height
    ld a, 18
    sub a, l
    ld l, a; bottom right height

    push hl;wh
    push de;xy
    ld de, 0
    ld bc, bkg_buffer
    call gbdk_GetBkgTiles

    pop de;xy
    pop hl;wh
    ld bc, bkg_buffer
    call gbdk_SetWinTiles
.skipRight

  pop de;xy
  pop hl;wh
  ld a, 32-18
  cp e
  jr nc, .skipBottom;skip bottom 
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
  ld d, 0
  ld bc, bkg_buffer
  call gbdk_SetWinTiles
.skipBottom
  
  ret

YesNoText:
  DB "YES\nNO",0

SaveGameText:
  DB "Would you like to\nSAVE the game?",0

SaveGame::
  ld d, 4
  ld e, 0
  ld a, DRAW_FLAGS_WIN
  call DrawSaveStats

  ld de, 12;(0,12)
  ld hl, SaveGameText
  ld a, DRAW_FLAGS_PAD_TOP | DRAW_FLAGS_WIN
  call RevealText

  ld hl, YesNoText
  ld de, str_buffer
  call str_Copy
  ld hl, name_buffer
  xor a
  ld [hl], a
  ld bc, 7;(0,7)
  ld d, 6
  ld e, 5
  ld a, DRAW_FLAGS_WIN
  call ShowListMenu
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
  ld a, %10000000
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

GBCSetPalette::;a = palette id, hl = colors
  sla a
  sla a
  sla a
  or a, %10000000
  ld [rBCPS], a
  ld [rOCPS], a
  ld a, 8;4 colors, 2 bytes each
.loopColors
    push af
.wait
      ldh a,[rSTAT]
      and STATF_BUSY
      jr nz, .wait
    ld a, [hli]
    ldh [rBCPD], a
    ldh [rOCPD], a
    pop af
    dec a
    jr nz, .loopColors
  ret

SetBkgPaletteMap::;hl = wh, de = xy, bc = firstTile
  ld a, [sys_info]
  and a, SYS_INFO_GBC
  ret z
  ld a, 1
  ld [rVBK], a
  call gbdk_SetBkgTiles
  xor a
  ld [rVBK], a
  ret

SetWinPaletteMap::;hl = wh, de = xy, bc = firstTile
  ld a, [sys_info]
  and a, SYS_INFO_GBC
  ret z
  ld a, 1
  ld [rVBK], a
  call gbdk_SetBkgTiles
  xor a
  ld [rVBK], a
  ret