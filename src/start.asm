INCLUDE "src/beisbol.inc"

SECTION "Start", ROMX, BANK[START_BANK]

INCLUDE "img/title/copyrights/copyrights.asm"
INCLUDE "img/title/intro/intro.asm"
INCLUDE "img/title/intro/intro_sprites/intro_sprites.asm"

IF DEF(_HOME)
  INCLUDE "img/home_version/version_sprites/version_sprites.asm"
ELSE
  INCLUDE "img/away_version/version_sprites/version_sprites.asm"
ENDC

LightsPalSeq:
  DB $E0, $E0, $E0, $E0, $E8, $E8, $E8, $E8, $E0, $E0
  DB $E0, $E0, $E8, $E8, $E8, $E8, $E0, $E0, $E0, $E0
  DB $E8, $E8, $E8, $E8, $E0, $E0, $E0, $E0, $E8, $E8
  DB $E8, $E8, $EC, $EC, $EC, $EC, $EC, $EC, $EC, $EC

Start::
  xor a
  ld [rVBK], a
  ld [rSTAT], a
.showCopyrights
  DISPLAY_OFF

  ld hl, CopyrightsTiles
  ld de, _VRAM+$1000
  ld bc, _COPYRIGHTS_TILE_COUNT*16
  call mem_CopyVRAM
  
  xor a
  ld d, a ; x
  ld e, a ; y
  ld h, _COPYRIGHT_COLUMNS ; w
  ld l, _COPYRIGHT_ROWS ; h
  ld bc, CopyrightTileMap
  call gbdk_SetBKGTiles

  ld a, LCDCF_ON | LCDCF_BG8800 | LCDCF_OBJ8 | LCDCF_OBJOFF | LCDCF_BGON
  ld [rLCDC], a

  ld de, 1000
  call gbdk_Delay

.showIntroSequence
  DISPLAY_OFF
  ld hl, rBGP
  ld [hl], $E0

  ld hl, IntroTiles
  ld de, _VRAM+$1000
  ld bc, _INTRO_TILE_COUNT*16
  call mem_CopyToTileData

  xor a
  ld d, a ; x
  ld e, a ; y
  ld h, _INTRO_LIGHTS_COLUMNS ; w
  ld l, _INTRO_LIGHTS_ROWS ; h
  ld bc, IntroLightsTileMap
  call gbdk_SetBKGTiles

  ld a, LCDCF_ON | LCDCF_WIN9800 | LCDCF_BG8800 | LCDCF_OBJ8 | LCDCF_OBJON | LCDCF_BGON
  ld [rLCDC], a

  ld hl, IntroSpritesTiles
  ld de, _VRAM
  ld bc, _INTRO_SPRITES_TILE_COUNT*16
  call mem_CopyVRAM

  ld hl, VersionSpritesTiles
  ld de, _VRAM+_INTRO_SPRITES_TILE_COUNT*16
  ld bc, _VERSION_SPRITES_TILE_COUNT*16
  call mem_CopyVRAM

  ld hl, _OAMRAM; + N * 4
  xor a
  ld b, a ;x
  ld c, 152 ;y
  ld d, a ;tile
  ld e, a ;flags
  call gbdk_SetOAM

.lightsSequence
  ld de, 1000
  call gbdk_Delay
  
  ld a, 60
  ld [_i], a
.exitableOneSecPauseLoop1
  call UpdateInput
  ld a, [button_state]
  and PADF_START | PADF_A
  jp nz, .fadeOutAndExit
  call gbdk_WaitVBLDone
  ld a, [_i]
  sub a
  ld [_i], a
  jr nz, .exitableOneSecPauseLoop1

  ld a, -8
  ld [_y], a
  ld a, 156
  ld [_x], a
.ballFallingIntoLightsLoop 
  ld hl, _OAMRAM ;OAM+N*4
  ld a, [_x]
  ld b, a ;x
  ld a, [_y]
  ld c, a ;y
  xor a
  ld d, a ;tile
  ld e, a ;flags
  call gbdk_SetOAM
  call UpdateInput
  ld a, [button_state]
  and PADF_START | PADF_A
  jp nz, .fadeOutAndExit
  call gbdk_WaitVBLDone
  ld a, [_y]
  add a, 3
  ld [_y], a
  ld a, [_x]
  sub a, 2
  ld [_x], a
  sub a, 94
  jr nz, .ballFallingIntoLightsLoop

  ld d, 10 ; x
  ld e, 8  ; y
  ld h, _INTRO_LIGHT_OUT_COLUMNS ; w
  ld l, _INTRO_LIGHT_OUT_ROWS ; h
  ld bc, IntroLightOutTileMap
  call gbdk_SetBKGTiles
  
; TODO: start playing stars animation
  xor a
  ld [_x], a
  ld hl, LightsPalSeq
.ballBouncingOffLights
  push hl
  ld hl, _OAMRAM ;OAM+N*4
  ld a, [_x]
  add a, 94
  ld b, a ;x
  ld a, [_y]
  ld c, a ;y
  xor a
  ld d, a ;tile
  ld e, a ;flags
  call gbdk_SetOAM
  call UpdateInput
  ld a, [button_state]
  and PADF_START | PADF_A
  jp nz, .fadeOutAndExit
  call gbdk_WaitVBLDone
  pop hl
  ld a, [hli]
  ld [rBGP], a
  ld a, [_y]
  add a, 4
  ld [_y], a
  ld a, [_x]
  inc a
  ld [_x], a
  sub a, 40
  jr nz, .ballBouncingOffLights

  ld a, 60
  ld [_i], a
.exitableOneSecPauseLoop2
  call UpdateInput
  ld a, [button_state]
  and PADF_START | PADF_A
  jp nz, .fadeOutAndExit
  call gbdk_WaitVBLDone
  ld a, [_i]
  sub a
  ld [_i], a
  jr nz, .exitableOneSecPauseLoop2

.pitchSequence
  ld d, 0 ; x
  ld e, 0 ; y
  ld h, _INTRO_PITCH_COLUMNS ; w
  ld l, _INTRO_PITCH_ROWS ; h
  ld bc, IntroPitchTileMap
  call gbdk_SetBKGTiles 

  ld hl, rBGP
  ld [hl], BG_PALETTE

  ld de, 1000
  call gbdk_Delay

  xor a
  ld [_i], a
  ld hl, _OAMRAM
  ld bc, Intro0TileMap + _INTRO_SPRITES_TILE_COUNT
.setIntroSpriteTiles
  push bc
  xor a
  ld b, a ;x
  ld c, a ;y
  xor a
  ld d, a ;tile
  ld e, OAMF_PRI ;flags
  call gbdk_SetOAM
  pop bc
  inc bc
  ld a, [_i]
  inc a
  ld [_i], a
  sub _INTRO0_COLUMNS * _INTRO0_ROWS
  jr nz, .setIntroSpriteTiles

  xor a
  ld [_k], a
.slidePlayersLoop
  call UpdateInput
  ld a, [button_state]
  and PADF_START | PADF_A
  jr nz, .fadeOutAndExit
  ld a, [_k]
  add a, 32
  ld [rSCX], a
; a = 0;
; for (j = 0; j < _INTRO0_ROWS; j++) {
;  for (i = 0; i < _INTRO0_COLUMNS; i++) {
;   move_sprite(a++, k+i*8-32, j*8+80);
;  }
; }
  call gbdk_WaitVBLDone
  ld a, [_k] 
  inc a
  ld [_k], a
  sub 128
  jr nz, .slidePlayersLoop

  ld a, 60
  ld [_i], a
.exitableOneSecPauseLoop3
  call UpdateInput
  ld a, [button_state]
  and PADF_START | PADF_A
  jr nz, .fadeOutAndExit
  call gbdk_WaitVBLDone
  ld a, [_i]
  sub a
  ld [_i], a
  jr nz, .exitableOneSecPauseLoop3

.fadeOutAndExit
  FADE_OUT
  ret
