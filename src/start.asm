INCLUDE "src/beisbol.inc"

SECTION "Start", ROMX, BANK[START_BANK]

INCLUDE "img/title/copyrights/copyrights.asm"
INCLUDE "img/title/intro/intro.asm"
INCLUDE "img/title/intro/intro_sprites/intro_sprites.asm"

IF DEF(_HOME)
StartPalSet: PAL_SET PALETTE_START_LIGHTS, PALETTE_MACOBB, PALETTE_MUCHACHO, PALETTE_GREY
INCLUDE "img/home_version/version_sprites/version_sprites.asm"
ELSE
StartPalSet: PAL_SET PALETTE_START_LIGHTS, PALETTE_MACOBB, PALETTE_PUFF, PALETTE_GREY
INCLUDE "img/away_version/version_sprites/version_sprites.asm"
ENDC

SGBStartLightsAttrBlk:
  ATTR_BLK 1
  ATTR_BLK_PACKET %111, 0,0,0, 0,0, 20,18

SGBStartBattleSlideAttrBlk:
  ATTR_BLK 1
  ATTR_BLK_PACKET %111, 3,2,2, 0,4, 20,10

SGBStartBattleAnimAttrBlk:
  ATTR_BLK 3
  ATTR_BLK_PACKET %111, 3,1,1, 0,4, 20,10
  ATTR_BLK_PACKET %001, 1,1,1, 0,7, 12,7
  ATTR_BLK_PACKET %001, 2,2,2, 11,7, 8,7

SGBFadeOutAttrBlk:
  ATTR_BLK 1
  ATTR_BLK_PACKET %100, 3,3,3, 0,3, 21,12

LightsPalSeq:
  DB $E0, $E0, $E0, $E0, $E8, $E8, $E8, $E8, $E0, $E0
  DB $E0, $E0, $E8, $E8, $E8, $E8, $E0, $E0, $E0, $E0
  DB $E8, $E8, $E8, $E8, $E0, $E0, $E0, $E0, $E8, $E8
  DB $E8, $E8, $EC, $EC, $EC, $EC, $EC, $EC, $EC, $EC

IntroBattingSpriteMaps:
  DW _IntroStance0TileMap
  DW _IntroStance1TileMap
  DW _IntroWatch0TileMap
  DW _IntroWatch1TileMap
  DW _IntroSwing0TileMap
  DW _IntroSwing1TileMap

IntroBattingSpriteSeq:
  DB 1, 1, 0, 0, 1, 1, 0, 0 ;waggle
  DB 0, 0, 0, 0, 0, 0, 0, 0 ;hold
  DB 1, 1, 0, 0, 1, 1, 0, 0 ;waggle
  DB 0, 0, 0, 0, 0, 0, 0, 0 ;hold
  DB 0, 0, 2, 2, 2, 2, 2, 2 ;ready
  DB 2, 2, 2, 2, 3, 3, 3, 3 ;ready
  DB 3, 3, 3, 3, 3, 3, 0, 0 ;watch
  DB 1, 1, 0, 0, 1, 1, 0, 0 ;waggle
  DB 0, 0, 0, 0, 0, 0, 0, 0 ;hold
  DB 1, 1, 0, 0, 1, 1, 0, 0 ;waggle
  DB 0, 0, 0, 0, 0, 0, 0, 0 ;hold
  DB 0, 0, 2, 2, 2, 2, 2, 2 ;ready
  DB 2, 2, 2, 2, 2, 2, 2, 2 ;ready
  DB 4, 5, 5, 5, 5, 5, 5, 5 ;swing

IntroBattingXSeq:
  DB  1,  1,  0,  0,  1,  1,  0,  0 ;waggle
  DB  0,  0,  0,  0,  0,  0,  0,  0 ;hold
  DB  1,  1,  0,  0,  1,  1,  0,  0 ;waggle
  DB  0,  0,  0,  0,  0,  0,  0,  0 ;hold
  DB  0,  1,  2,  3,  4,  5,  5,  5 ;ready
  DB  5,  5,  5,  5,  3,  3,  3,  3 ;ready
  DB  2,  2,  2,  2,  2,  2,  1,  1 ;watch
  DB  1,  1,  0,  0,  1,  1,  0,  0 ;waggle
  DB  0,  0,  0,  0,  0,  0,  0,  0 ;hold
  DB  1,  1,  0,  0,  1,  1,  0,  0 ;waggle
  DB  0,  0,  0,  0,  0,  0,  0,  0 ;hold
  DB  0,  1,  2,  3,  4,  5,  5,  5 ;ready
  DB  5,  5,  5,  5,  5,  5,  5,  5 ;ready
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
  DB 1, 1, 1, 1, 1, 1, 2, 2 ;pitch
  DB 2, 2, 2, 2, 2, 2, 2, 2 ;pitch
  DB 2, 2, 2, 2, 2, 2, 2, 2 ;watch
  DB 0, 0, 0, 0, 0, 0, 0, 0 ;hold
  DB 0, 0, 0, 0, 0, 0, 0, 0 ;hold
  DB 0, 0, 0, 0, 0, 0, 0, 0 ;hold
  DB 0, 0, 0, 0, 0, 0, 0, 0 ;hold
  DB 1, 1, 1, 1, 1, 1, 2, 2 ;pitch
  DB 2, 2, 2, 2, 2, 2, 2, 2 ;pitch
  DB 2, 2, 2, 2, 2, 2, 2, 2 ;watch

IntroPitchingXSeq:
  DB 0, 0, 0, 0, 0, 0, 0, 0 ;hold
  DB 0, 0, 0, 0, 0, 0, 0, 0 ;hold
  DB 0, 0, 0, 0, 0, 0, 0, 0 ;hold
  DB 0, 0, 0, 0, 0, 0, 0, 0 ;hold
  DB 4, 5, 6, 7, 8, 9,10,11 ;ready
  DB 8, 7, 6, 5, 4, 3, 2, 1 ;pitch
  DB 0, 0, 0, 0, 0, 0, 0, 0 ;hold
  DB 0, 0, 0, 0, 0, 0, 0, 0 ;hold
  DB 0, 0, 0, 0, 0, 0, 0, 0 ;hold
  DB 0, 0, 0, 0, 0, 0, 0, 0 ;hold
  DB 0, 0, 0, 0, 0, 0, 0, 0 ;hold
  DB 4, 5, 6, 7, 8, 9,10,11 ;ready
  DB 8, 7, 6, 5, 4, 3, 2, 1 ;pitch
  DB 0, 0, 0, 0, 0, 0, 0, 0 ;hold

BallXSeq: 
  DB 0, 0, 0, 0, 0, 0, 0, 0
  DB 0, 0, 0, 0, 0, 0, 0, 0
  DB 0, 0, 0, 0, 0, 0, 0, 0
  DB 0, 0, 0, 0, 0, 0, 0, 0
  DB 0, 0, 0, 0, 0, 0, 106,108;release
  DB 110,108,106,104,100,96,92,88;land
  DB 0, 0, 0, 0, 0, 0, 0, 0
  DB 0, 0, 0, 0, 0, 0, 0, 0
  DB 0, 0, 0, 0, 0, 0, 0, 0
  DB 0, 0, 0, 0, 0, 0, 0, 0
  DB 0, 0, 0, 0, 0, 0, 0, 0
  DB 0, 0, 0, 0, 0, 0, 106,108;release
  DB 110,108,106,104,100,96,92,88;land
  DB 28,24,20,16,12,8,4,0

BallYSeq:
  DB 0, 0, 0, 0, 0, 0, 0, 0
  DB 0, 0, 0, 0, 0, 0, 0, 0
  DB 0, 0, 0, 0, 0, 0, 0, 0
  DB 0, 0, 0, 0, 0, 0, 0, 0
  DB 0, 0, 0, 0, 0, 0, 70,62;release
  DB 60,58,60,62,70,75,90,105;land
  DB 0, 0, 0, 0, 0, 0, 0, 0
  DB 0, 0, 0, 0, 0, 0, 0, 0
  DB 0, 0, 0, 0, 0, 0, 0, 0
  DB 0, 0, 0, 0, 0, 0, 0, 0
  DB 0, 0, 0, 0, 0, 0, 0, 0
  DB 0, 0, 0, 0, 0, 0, 70,62;release
  DB 60,58,60,62,70,75,90,105;land
  DB 56,52,48,44,40,36,32,26

UpdateIntroSparks:
  xor a
  ld hl, tile_buffer
  ld bc, 24
  call mem_Set

  ld hl, tile_buffer+24
  ld a, 24
.loop
    push af
    push hl
    call gbdk_Random
    ld a, d
    or a, OAMF_PRI
    pop hl
    ld [hli], a
    pop af
    dec a
    jr nz, .loop

  ld hl, tile_buffer
  ld de, tile_buffer+24
  ld b, 1
  ld c, 24
  call SetSpriteTilesProps

  ld b, 56;x
  ld c, 106;y
  ld h, 8;w
  ld l, 3;h
  ld a, 1
  call MoveSprites

  ret

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
  ;TODO: set intro SGB border here

  DISPLAY_OFF

  ld hl, StartPalSet
  call SetPalettesIndirect
  ld hl, SGBStartLightsAttrBlk
  call sgb_PacketTransfer

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

  PLAY_SONG intro_lights_data, 0

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
    call UpdateIntroSparks
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
  ld [_c], a
.sparksAfterHitLoop
    call UpdateIntroSparks
    UPDATE_INPUT_AND_JUMP_TO_IF_BUTTONS .pitchSequence, (PADF_START | PADF_A)
    call gbdk_WaitVBL
    ld a, [_c]
    dec a
    ld [_c], a
    jr nz, .sparksAfterHitLoop

  HIDE_ALL_SPRITES
  EXITABLE_DELAY .fadeOutAndExit, (PADF_START | PADF_A), 60

.pitchSequence
  ld hl, SGBStartBattleSlideAttrBlk
  call sgb_PacketTransfer
  ld [_breakpoint], a

  HIDE_ALL_SPRITES
  PLAY_SONG charge_fanfare_data, 0
  ld d, 0 ; x
  ld e, 0 ; y
  ld h, _INTRO_PITCH_COLUMNS ; w
  ld l, _INTRO_PITCH_ROWS ; h
  ld bc, _IntroPitchTileMap
  call gbdk_SetBkgTiles

  ld hl, tile_buffer
  ld bc, 32*10
  ld a, 1
  call mem_Set
  ld d, 0;x
  ld e, 4;y
  ld h, 32;w
  ld l, 10;h
  ld bc, tile_buffer
  call SetBkgPaletteMap

  ld hl, rBGP
  ld [hl], DMG_PAL_BDLW

  xor a
  ld [_k], a
.slidePlayersLoop
    UPDATE_INPUT_AND_JUMP_TO_IF_BUTTONS .fadeOutAndExit, (PADF_START | PADF_A)
    ld a, [_k]
    ld b, a
    add a, 33
    ld [rSCX], a

    push af
.setPalette
    ld b, a
    and a, %00000111
    jr nz, .skipPalette
    ld a, 168
    sub a, b
    srl a
    srl a
    srl a
    ld d, a
    ld e, 7
    ld h, _INTRO_PITCH0_COLUMNS-1
    ld l, _INTRO_PITCH0_ROWS+1
    ld b, 1
    ld c, 2
    call sgb_SetBlock
.skipPalette
    pop af
    
    sub a, 65
    ld b, a
    ld c, 80
    ld a, _INTRO_STANCE0_COLUMNS
    ld h, a
    ld a, _INTRO_STANCE0_ROWS
    ld l, a
    ld de, _IntroStance0TileMap
    ld a, OAMF_PRI | 2;palette
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

  ld hl, SGBStartBattleAnimAttrBlk
  call sgb_PacketTransfer
  EXITABLE_DELAY .fadeOutAndExit, (PADF_START | PADF_A), 60

.battingSequence

  xor a
  ld b, a
  ld c, a
.battingSequenceLoop

.getBatterSpriteTiles
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

.moveBatterTiles
    pop bc;index
    push bc

    ld hl, IntroBattingXSeq
    add hl, bc
    ld a, [hl]
    add a, 96

    ld b, a
    ld c, 80
    ld h, _INTRO_WATCH1_COLUMNS
    ld l, _INTRO_WATCH1_ROWS

    ld a, OAMF_PRI | 2;palette
    ld [sprite_props], a
    ld a, SPRITE_FLAGS_SKIP | SPRITE_FLAGS_CLEAR_END
    ld [sprite_flags], a
    xor a;skip tile 0
    ld [sprite_skip_id], a
    ld a, _INTRO_SPRITES_TILE_COUNT
    call SetSpriteTilesXY ;bc = xy in screen space, hl = wh in tiles, de = tilemap, a = offset

.moveBall
    pop bc;index
    push bc

    ld hl, BallXSeq
    add hl, bc
    ld a, [hl]
    ld d, a
    ld hl, BallYSeq
    add hl, bc
    ld a, [hl]
    ld hl, oam_buffer
    ld [hli], a;y
    ld a, d
    ld [hli], a;x
    xor a
    ld [hli], a;tile
    ld a, OAMF_PRI | OAMF_PAL1
    ld [hl], a;props
    
.slidePitcher
    pop bc;index
    push bc

    ld hl, IntroPitchingXSeq
    add hl, bc
    ld a, [hl]
    add a, 160
    ld [rSCX], a

.updatePitchingTiles
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
    jp .battingSequenceLoop

.fadeOutAndExit
  ld hl, SGBFadeOutAttrBlk
  call sgb_PacketTransfer
  FADE_OUT
  ret
