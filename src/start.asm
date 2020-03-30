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

IntroBattingSpriteMaps:
  DW _IntroWait0TileMap
  DW _IntroWait1TileMap
  DW _IntroReadyTileMap
  DW _IntroSwing0TileMap
  DW _IntroSwing1TileMap

IntroBattingSpriteSeq:
  DB 1, 1, 0, 0, 1, 1, 0, 0 ;waggle
  DB 0, 0, 0, 0, 0, 0, 0, 0 ;hold
  DB 1, 1, 0, 0, 1, 1, 0, 0 ;waggle
  DB 0, 0, 0, 0, 0, 0, 0, 0 ;hold
  DB 2, 2, 2, 2, 2, 2, 2, 2 ;ready
  DB 1, 1, 0, 0, 1, 1, 0, 0 ;waggle
  DB 0, 0, 0, 0, 0, 0, 0, 0 ;hold
  DB 1, 1, 0, 0, 1, 1, 0, 0 ;waggle
  DB 0, 0, 0, 0, 0, 0, 0, 0 ;hold
  DB 2, 2, 2, 2, 2, 2, 2, 2 ;ready
  DB 2, 4, 4, 4, 4, 4, 4, 4 ;swing

IntroBattingXSeq:
  DB  1,  1,  0,  0,  1,  1,  0,  0 ;waggle
  DB  0,  0,  0,  0,  0,  0,  0,  0 ;hold
  DB  1,  1,  0,  0,  1,  1,  0,  0 ;waggle
  DB  0,  0,  0,  0,  0,  0,  0,  0 ;hold
  DB  2,  2,  2,  2,  2,  2,  2,  2 ;ready
  DB  1,  1,  0,  0,  1,  1,  0,  0 ;waggle
  DB  0,  0,  0,  0,  0,  0,  0,  0 ;hold
  DB  1,  1,  0,  0,  1,  1,  0,  0 ;waggle
  DB  0,  0,  0,  0,  0,  0,  0,  0 ;hold
  DB  2,  2,  2,  2,  2,  2,  2,  2 ;ready
  DB  2,  4,  4,  4,  4,  4,  4,  4 ;swing

IntroPitchingTileMaps
  DW _IntroPitch0TileMap
  DW _IntroPitch1TileMap
  DW _IntroPitch2TileMap

IntroPitchingBGSeq:
  DB 0, 0, 0, 0, 0, 0, 0, 0 ;hold
  DB 0, 0, 0, 0, 0, 0, 0, 0 ;hold
  DB 0, 0, 0, 0, 0, 0, 0, 0 ;hold
  DB 0, 0, 0, 0, 0, 0, 0, 0 ;hold
  DB 1, 1, 1, 1, 2, 2, 2, 2 ;pitch
  DB 0, 0, 0, 0, 0, 0, 0, 0 ;hold
  DB 0, 0, 0, 0, 0, 0, 0, 0 ;hold
  DB 0, 0, 0, 0, 0, 0, 0, 0 ;hold
  DB 0, 0, 0, 0, 0, 0, 0, 0 ;hold
  DB 1, 1, 1, 1, 2, 2, 2, 2 ;pitch
  DB 2, 2, 2, 2, 2, 2, 2, 2 ;watch
  
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
  call gbdk_SetBkgTiles

  ld a, LCDCF_ON | LCDCF_BG8800 | LCDCF_OBJ8 | LCDCF_OBJOFF | LCDCF_BGON
  ld [rLCDC], a

  ld de, 2000
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
  call gbdk_SetBkgTiles

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
  
  EXITABLE_DELAY .pitchSequence, (PADF_START | PADF_A), 60

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
  call gbdk_SetBkgTiles

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

  EXITABLE_DELAY .pitchSequence, (PADF_START | PADF_A), 60

.pitchSequence
  LOAD_SONG LoadChargeSong
  ld d, 0 ; x
  ld e, 0 ; y
  ld h, _INTRO_PITCH_COLUMNS ; w
  ld l, _INTRO_PITCH_ROWS ; h
  ld bc, _IntroPitchTileMap
  call gbdk_SetBkgTiles 
  ld hl, rBGP
  ld [hl], BG_PALETTE

  xor a
  ld [_k], a
.slidePlayersLoop
    UPDATE_INPUT_AND_JUMP_TO_IF_BUTTONS .fadeOutAndExit, (PADF_START | PADF_A)
    ld a, [_k]
    add a, 32
    ld [rSCX], a

    sub a, 64
    ld b, a
    ld c, 80
    ld a, _INTRO_WAIT0_COLUMNS
    ld h, a
    ld a, _INTRO_WAIT0_ROWS
    ld l, a
    ld de, _IntroWait0TileMap
    ld a, OAMF_PRI
    ld [sprite_props], a
    ld a, SPRITE_FLAGS_SKIP
    ld [sprite_flags], a
    xor a;skip tile 0
    ld [sprite_skip_id], a
    ld a, _INTRO_SPRITES_TILE_COUNT
    call SetSpriteTilesXY ;bc = xy in screen space, hl = wh in tiles, de = tilemap, a = offset

    call gbdk_WaitVBL
    ld a, [_k] 
    inc a
    ld [_k], a
    sub 128
    jr nz, .slidePlayersLoop

  EXITABLE_DELAY .fadeOutAndExit, (PADF_START | PADF_A), 60

.battingSequence

  xor a
  ld b, a
  ld c, a
.battingSequenceLoop
    push bc;index
    ld hl, IntroBattingSpriteSeq
    add hl, bc
    ld a, [hl]
    add a, a
    ld b, 0
    ld c, a
    ld hl, IntroBattingSpriteMaps
    add hl, bc
    ld a, [hli]
    ld e, a
    ld a, [hl]
    ld d, a

    pop bc;index
    push bc
    ld hl, IntroBattingXSeq
    add hl, bc
    ld a, [hl]
    add a, 96

    ld b, a
    ld c, 80
    ld h, _INTRO_WAIT1_COLUMNS
    ld l, _INTRO_WAIT1_ROWS

    ld a, OAMF_PRI
    ld [sprite_props], a
    ld a, SPRITE_FLAGS_SKIP | SPRITE_FLAGS_CLEAR_END
    ld [sprite_flags], a
    xor a;skip tile 0
    ld [sprite_skip_id], a
    ld a, _INTRO_SPRITES_TILE_COUNT
    call SetSpriteTilesXY ;bc = xy in screen space, hl = wh in tiles, de = tilemap, a = offset

    pop bc;index
    push bc

    ld hl, IntroPitchingBGSeq
    add hl, bc
    ld a, [hl]
    add a, a
    ld b, 0
    ld c, a
    ld hl, IntroPitchingTileMaps
    add hl, bc
    ld a, [hli]
    ld c, a
    ld a, [hl]
    ld b, a

    ld h, _INTRO_PITCH0_COLUMNS
    ld l, _INTRO_PITCH0_ROWS
    ld d, 21
    ld e, 8
    call gbdk_SetBkgTiles
    
    pop bc
    inc bc

    ld a, IntroBattingXSeq - IntroBattingSpriteSeq
    cp a, c
    jr z, .fadeOutAndExit

    EXITABLE_DELAY .fadeOutAndExit, (PADF_START | PADF_A), 8;frames per step
    jr .battingSequenceLoop

.fadeOutAndExit
  call gbdk_WaitVBL
  FADE_OUT
  ret
