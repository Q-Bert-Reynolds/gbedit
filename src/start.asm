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
.showCopyrights
  DISPLAY_OFF

  ld hl, _CopyrightsTiles
  ld de, _VRAM+$1000
  ld bc, _COPYRIGHTS_TILE_COUNT*16
  call mem_CopyVRAM
  
  xor a
  ld d, a ; x
  ld e, a ; y
  ld h, _COPYRIGHT_COLUMNS ; w
  ld l, _COPYRIGHT_ROWS ; h
  ld bc, _CopyrightTileMap
  call gbdk_SetBKGTiles

  ld a, LCDCF_ON | LCDCF_BG8800 | LCDCF_OBJ8 | LCDCF_OBJOFF | LCDCF_BGON
  ld [rLCDC], a

  ld de, 1000
  call gbdk_Delay

.showIntroSequence
  DISPLAY_OFF
  ld hl, rBGP
  ld [hl], $E0

  ld hl, _IntroTiles
  ld de, _VRAM+$1000
  ld bc, _INTRO_TILE_COUNT*16
  call mem_CopyToTileData

  xor a
  ld d, a ; x
  ld e, a ; y
  ld h, _INTRO_LIGHTS_COLUMNS ; w
  ld l, _INTRO_LIGHTS_ROWS ; h
  ld bc, _IntroLightsTileMap
  call gbdk_SetBKGTiles

  ld hl, _IntroSpritesTiles
  ld de, _VRAM
  ld bc, _INTRO_SPRITES_TILE_COUNT*16
  call mem_CopyVRAM

  ld hl, _VersionSpritesTiles
  ld de, _VRAM+_INTRO_SPRITES_TILE_COUNT*16
  ld bc, _VERSION_SPRITES_TILE_COUNT*16
  call mem_CopyVRAM

  ld a, LCDCF_ON | LCDCF_WIN9C00 | LCDCF_BG8800 | LCDCF_OBJ8 | LCDCF_OBJON | LCDCF_BGON
  ld [rLCDC], a

  xor a
  ld c, a
  ld d, a ;x
  ld e, 152 ;y
  call gbdk_MoveSprite
  xor a
  ld c, a
  ld d, a ;tile
  call gbdk_SetSpriteTile
  xor a
  ld c, a
  ld d, a ;flags
  call gbdk_SetSpriteProp

.lightsSequence
  ld de, 1000
  call gbdk_Delay
  
  ld a, 60
  ld [_i], a
.exitableOneSecPauseLoop1
  UPDATE_INPUT_AND_JUMP_TO_IF_BUTTONS .pitchSequence, (PADF_START | PADF_A)
  call gbdk_WaitVBL
  ld a, [_i]
  sub a
  ld [_i], a
  jr nz, .exitableOneSecPauseLoop1

  ld a, -8
  ld [_y], a
  ld a, 156
  ld [_x], a
.ballFallingIntoLightsLoop 
  xor a
  ld c, a
  ld a, [_x]
  ld d, a ;x
  ld a, [_y]
  ld e, a ;y
  call gbdk_MoveSprite
  UPDATE_INPUT_AND_JUMP_TO_IF_BUTTONS .pitchSequence, (PADF_START | PADF_A)
  call gbdk_WaitVBL
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
  ld bc, _IntroLightOutTileMap
  call gbdk_SetBKGTiles
  
; TODO: start playing stars animation
  xor a
  ld [_x], a
  ld hl, LightsPalSeq
.ballBouncingOffLights
  push hl
  xor a
  ld c, a
  ld a, [_x]
  add a, 94
  ld d, a ;x
  ld a, [_y]
  ld e, a ;y
  call gbdk_MoveSprite
  pop hl ;pop has to happen before jump or return address will be incorrect
  UPDATE_INPUT_AND_JUMP_TO_IF_BUTTONS .pitchSequence, (PADF_START | PADF_A)
  call gbdk_WaitVBL
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
  UPDATE_INPUT_AND_JUMP_TO_IF_BUTTONS .pitchSequence, (PADF_START | PADF_A)
  call gbdk_WaitVBL
  ld a, [_i]
  sub a
  ld [_i], a
  jr nz, .exitableOneSecPauseLoop2

.pitchSequence
  ld d, 0 ; x
  ld e, 0 ; y
  ld h, _INTRO_PITCH_COLUMNS ; w
  ld l, _INTRO_PITCH_ROWS ; h
  ld bc, _IntroPitchTileMap
  call gbdk_SetBKGTiles 
  ld hl, rBGP
  ld [hl], BG_PALETTE

  SET_SPRITE_TILES (_INTRO0_COLUMNS*_INTRO0_ROWS), _Intro0TileMap, OAMF_PRI, _INTRO_SPRITES_TILE_COUNT

  xor a
  ld [_k], a
.slidePlayersLoop
  UPDATE_INPUT_AND_JUMP_TO_IF_BUTTONS .fadeOutAndExit, (PADF_START | PADF_A)
  ld a, [_k]
  add a, 32
  ld [rSCX], a

  sub a, 64
  ld b, a
  ld a, 80
  ld c, a
  ld a, _INTRO0_COLUMNS
  ld h, a
  ld a, _INTRO0_ROWS
  ld l, a
  xor a
  call MoveSprites ;bc = xy, hl = wh, a = offset

  call gbdk_WaitVBL
  ld a, [_k] 
  inc a
  ld [_k], a
  sub 128
  jr nz, .slidePlayersLoop

  ld a, 60
  ld [_i], a
.exitableOneSecPauseLoop3
  UPDATE_INPUT_AND_JUMP_TO_IF_BUTTONS .fadeOutAndExit, (PADF_START | PADF_A)
  call gbdk_WaitVBL
  ld a, [_i]
  sub a
  ld [_i], a
  jr nz, .exitableOneSecPauseLoop3

.fadeOutAndExit
  call gbdk_WaitVBL
  FADE_OUT
  nop
  ret
