SECTION "Fade", ROMX, BANK[FX_BANK]

FadeIn::
  DISPLAY_ON
  ld a, [sys_info]
  and a, SYS_INFO_GBC
  jr nz, .fadeInGBC
  
.fadeInDMG
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
  ld a, DMG_PAL_BDLW
  ld [rBGP], a
  ld [rOBP0], a
  ld de, 200
  call gbdk_Delay
  ret

.fadeInGBC
  ld hl, tile_buffer+16*4*2;palettes * colors/palette * bytes/color
  call CopyPalettesTo
  ld c, 16;palettes
  ld hl, tile_buffer
.setToWhitePaletteLoop
    ld b, 4
  .setToWhiteColorLoop
      ld a, [ColorWhite]
      ld [hli], a
      ld a, [ColorWhite+1]
      ld [hli], a
      dec b
      jr nz, .setToWhiteColorLoop
    dec c
    jr nz, .setToWhitePaletteLoop
  ld hl, tile_buffer
  call CopyPalettesFrom
  ld a, 32;max steps
.fadeInGBCLoop
    push af;steps left
    ld hl, tile_buffer
    ld bc, 16*4;16 palettes * 4 colors / palette
  .loopColors
      push bc;colors left
    .lerpRed
      ld a, [hl];GGGRRRRR
      ld e, a;save green for later
      and a, %00011111
      call LerpRedChannel
      ld d, a;red
      inc hl
    .lerpGreen
      ld a, [hld];xBBBBBGG
      ld b, a;save blue for later
      swap a     ;BBGGxBBB
      srl a      ;xBBGGxBB
      and a,     %00011000
      ld c, a    ;xxxGGxxx
      ld a, e    ;GGGRRRRR
      swap a     ;RRRRGGGR
      srl a      ;xRRRRGGG
      and a,     %00000111
      or a, c    ;xxxGGGGG
      call LerpGreenChannel
      ld e, a;save green for later
      swap a     ;GGGGxxxG
      sla a      ;GGGxxxGx
      and a,     %11100000
      or a, d    ;GGGRRRRR
      ld [hli], a
    .lerpBlue
      ld a, b    ;xBBBBBGG
      srl a      ;xxBBBBBG
      srl a      ;xxxBBBBB
      call LerpBlueChannel
      sla a      ;xxBBBBBx
      sla a      ;xBBBBBxx
      ld b, a;blue
      ld a, e    ;xxxGGGGG
      srl a      ;xxxxGGGG
      srl a      ;xxxxxGGG
      srl a      ;xxxxxxGG
      or a, b    ;xBBBBBGG
      ld [hli], a
      pop bc;colors left
      dec c
      jr nz, .loopColors
    ld de, 18
    call gbdk_Delay
    ld hl, tile_buffer
    call CopyPalettesFrom
    pop af;steps left
    dec a
    jr nz, .fadeInGBCLoop
  ret

LerpRedChannel:; a = red, hl = address of current color, returns new red in a, bc,de,hl unchanged
  push bc
  push de
  push hl
  ld bc, 16*4*2;palettes * colors/palette * bytes/color
  add hl, bc;address of target color
  ld d, a;current red
  ld a, [hl]
  and a, %00011111;target red
  cp a, d;if target < current
  jr z, .done
  jr c, .decrement
.increment
  inc d
  jr .done
.decrement
  dec d
.done
  ld a, d;red
  pop hl
  pop de
  pop bc
  ret

LerpGreenChannel:; a = green, hl = address of current color, returns new red in a, bc,de,hl unchanged
  push bc
  push de
  push hl
  ld d, a;current green
  ld bc, 16*4*2;palettes * colors/palette * bytes/color
  add hl, bc;address of target color
  ld a, [hli];GGGRRRRR
  swap a     ;RRRRGGGR
  srl a      ;xRRRRGGG
  and a,     %00000111
  ld e, a
  ld a, [hld];xBBBBBGG
  swap a     ;BBGGxBBB
  srl a      ;xBBGGxBB
  and a,     %00011000
  or a, e    ;xxxGGGGG
  cp a, d;if target < current
  jr z, .done
  jr c, .decrement
.increment
  inc d
  jr .done
.decrement
  dec d
.done
  ld a, d;green
  pop hl
  pop de
  pop bc
  ret

LerpBlueChannel:; a = blue, hl = address of current color, returns new red in a, bc,de,hl unchanged
  push bc
  push de
  push hl
  ld bc, 16*4*2;palettes * colors/palette * bytes/color
  add hl, bc;address of target color
  ld d, a;current blue
  ld a, [hl]
  and a, %01111100;target blue
  srl a  ;00BBBBB0
  srl a  ;000BBBBB
  cp a, d;if target < current
  jr z, .done
  jr c, .decrement
.increment
  inc d
  jr .done
.decrement
  dec d
.done
  ld a, d;blue
  pop hl
  pop de
  pop bc
  ret

FadeOut::
  ld a, [sys_info]
  and a, SYS_INFO_GBC
  jr nz, .fadeOutGBC

.fadeOutDMG  
  jr .delayDMG
.fadeOutDMGLoop
    sla a
    sla a
    ld [rBGP], a
    ld [rOBP0], a
  .delayDMG
    ld de, 200
    call gbdk_Delay
    ld a, [rBGP]
    and a
    jr nz, .fadeOutDMGLoop
  jp .finish
  
.fadeOutGBC
  ld hl, tile_buffer
  call CopyPalettesTo
  ld a, 32;max steps
.fadeOutGBCLoop
    push af;steps left
    ld hl, tile_buffer
    ld c, 16*4;16 palettes * 4 colors / palette
  .loopColors
      push bc;colors left
    .incrementRed
      ld a, [hli];GGGRRRRR
      ld e, a;save green for later
      and a, %00011111
      ld d, a;red
      cp a, WHITE_R
      jr nc, .incrementGreen
      inc d;red
    .incrementGreen
      ld a, [hld];xBBBBBGG
      ld b, a;save blue for later
      swap a     ;BBGGxBBB
      srl a      ;xBBGGxBB
      and a,     %00011000
      ld c, a    ;xxxGGxxx
      ld a, e    ;GGGRRRRR
      swap a     ;RRRRGGGR
      srl a      ;xRRRRGGG
      and a,     %00000111
      or a, c    ;xxxGGGGG
      cp a, WHITE_G
      jr nc, .setRedGreen
      inc a;green
    .setRedGreen
      ld e, a;green
      swap a     ;GGGGxxxG
      sla a      ;GGGxxxGx
      and a,     %11100000
      or a, d    ;GGGRRRRR
      ld [hli], a
    .incrementBlue
      ld a, b    ;xBBBBBGG
      srl a      ;xxBBBBBG
      srl a      ;xxxBBBBB
      cp a, WHITE_B
      jr nc, .setBlue
      inc a
    .setBlue
      sla a      ;xxBBBBBx
      sla a      ;xBBBBBxx
      ld b, a;blue
      ld a, e    ;xxxGGGGG
      srl a      ;xxxxGGGG
      srl a      ;xxxxxGGG
      srl a      ;xxxxxxGG
      or a, b    ;xBBBBBGG
      ld [hli], a
      pop bc;colors left
      dec c
      jr nz, .loopColors
    ld de, 18
    call gbdk_Delay
    ld hl, tile_buffer
    call CopyPalettesFrom
    pop af;steps left
    dec a
    jr nz, .fadeOutGBCLoop
.finish
  DISPLAY_OFF
  ret