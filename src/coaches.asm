INCLUDE "src/beisbol.inc"
;constants
COACH_CALVIN      EQU 0
COACH_DOC_HICKORY EQU 1
COACH_NOLAN0      EQU 2
COACH_NOLAN1      EQU 3
COACH_NOLAN2      EQU 4
COACHES_COUNT     EQU 5

SECTION "Coach Data", ROMX, BANK[COACHES_BANK]

INCLUDE "img/coaches/calvin.asm"
INCLUDE "img/coaches/doc_hickory.asm"
INCLUDE "img/coaches/nolan0.asm"
INCLUDE "img/coaches/nolan1.asm"
INCLUDE "img/coaches/nolan2.asm"

CoachTiles:
  DW _CalvinTiles 
  DW _DocHickoryTiles 
  DW _Nolan0Tiles 
  DW _Nolan1Tiles 
  DW _Nolan2Tiles 

CoachTileCounts:
  DB _CALVIN_TILE_COUNT
  DB _DOC_HICKORY_TILE_COUNT
  DB _NOLAN0_TILE_COUNT
  DB _NOLAN1_TILE_COUNT
  DB _NOLAN2_TILE_COUNT

CoachTileMaps:
  DW _CalvinTileMap
  DW _DocHickoryTileMap
  DW _Nolan0TileMap
  DW _Nolan1TileMap
  DW _Nolan2TileMap

CoachColorCounts:
  DB _CALVIN_COLOR_COUNT
  DB _DOC_HICKORY_COLOR_COUNT
  DB _NOLAN0_COLOR_COUNT
  DB 0
  DB 0

CoachPaletteMaps:
  DW _CalvinPaletteMap
  DW _DocHickoryPaletteMap
  DW _Nolan0PaletteMap
  DW 0
  DW 0

CoachColors:
  DW _CalvinColors
  DW _DocHickoryColors
  DW _Nolan0Colors
  DW 0
  DW 0

CoachNames:
  DB "Calvin", 0
  DB "Doc", 0
  DB "Nolan", 0
  DB "Nolan", 0
  DB "Nolan", 0
  
BankedLoadCoachTiles:: ;a = coach id, de = vram address
  push de;vram address
  push af;id
  ld b, 0
  ld c, a
  ld hl, CoachTileCounts
  add hl, bc
  ld a, [hl]
  ld de, 16
  call math_Multiply
  ld b, h
  ld c, l

  pop af;id
  add a, a
  ld d, 0
  ld e, a
  ld hl, CoachTiles
  add hl, de
  ld a, [hli]
  ld d, a
  ld a, [hl]
  ld h, a
  ld l, d

  pop de;vram address
  call mem_CopyVRAM
  ret

BankedLoadCoachPalettes:: ;a = coach id, h = offset
  ld b, a;coach
  ld a, [sys_info]
  and a, SYS_INFO_GBC | SYS_INFO_SGB
  ret z;exit early if not GBC
  push bc;coach id
  sla h;offset*2
  sla h;offset*4(colors per palette)
  sla h;offset*8(bytes per color)
  ld a, %10000000;auto increment
  or a, h;offset
  ldh [rBCPS], a
  pop af;coach id
  push af;coach id
  add a, a
  ld b, 0
  ld c, a
  ld hl, CoachColors
  add hl, bc
  ld a, [hli]
  ld c, a
  ld a, [hl]
  ld h, a 
  ld l, c;hl = colors
  pop af;coach id
  push hl;colors
  ld b, 0
  ld c, a
  ld hl, CoachColorCounts
  add hl, bc
  ld a, [hl];color count
  add a, a;num color * 2B / color 
  ld c, a
  pop hl;colors
.loop
    ld a, [hli]
    ldh [rBCPD], a
    dec c
    jr nz, .loop
  ret

BankedSetCoachTiles:: ;a = coach, de=xy, h=offset
  push hl;offset

  add a, a
  ld b, 0
  ld c, a
  ld hl, CoachTileMaps
  add hl, bc
  ld a, [hli]
  ld c, a
  ld a, [hl]
  ld b, a ;bc = tiles

  pop hl;offset
  ld a, h; a = offset

  ld hl, $0707
  call SetBkgTilesWithOffset
  ret

BankedSetCoachPalettes:: ;a = coach, de=xy, h=offset
  ld b, a;coach
  ld a, [sys_info]
  and a, SYS_INFO_GBC | SYS_INFO_SGB
  ret z;exit early if not GBC
  ld a, b;coach

  push hl;offset
  add a, a
  ld b, 0
  ld c, a
  ld hl, CoachPaletteMaps
  add hl, bc
  ld a, [hli]
  ld c, a
  ld a, [hl]
  ld b, a ;bc = tiles

  ld a, 1
  ld [rVBK], a
  pop hl;offset
  ld a, h; a = offset

  ld hl, $0707
  call SetBkgTilesWithOffset
  xor a
  ld [rVBK], a
  ret

BankedGetCoachsName:: ;a = coach, returns name in name_buffer
  ld c, a;number
  ld hl, CoachNames
  cp COACHES_COUNT
  jr nc, .copy ;name outside of range, return Calvin
  ld b, 0
  call str_FromArray
.copy
  ld de, name_buffer
  call str_Copy
  ret

SECTION "Coach Code", ROM0

LoadCoachTiles:: ;a = coach id, de = vram address
  push af
  ld a, [loaded_bank]
  ld b, a;bank
  ld a, COACHES_BANK
  call SetBank

  pop af
  push bc;bank
  call BankedLoadCoachTiles

  pop af;bank
  call SetBank
  ret

LoadCoachPalettes:: ;a = coach id, h = offset
  push af
  ld a, [loaded_bank]
  ld b, a;bank
  ld a, COACHES_BANK
  call SetBank

  pop af
  push bc;bank
  call BankedLoadCoachPalettes

  pop af;bank
  call SetBank
  ret

SetCoachTiles:: ;a = coach, de=xy, h=offset
  push af
  ld a, [loaded_bank]
  ld b, a;bank
  ld a, COACHES_BANK
  call SetBank

  pop af
  push bc;bank
  call BankedSetCoachTiles

  pop af;bank
  call SetBank
  ret

SetCoachPalettes:: ;a = coach, de=xy, h=offset
  push af
  ld a, [loaded_bank]
  ld b, a;bank
  ld a, COACHES_BANK
  call SetBank

  pop af
  push bc;bank
  call BankedSetCoachPalettes

  pop af;bank
  call SetBank
  ret

GetCoachesName:: ;a = coach, returns name in name_buffer
  push af
  ld a, [loaded_bank]
  ld b, a;bank
  ld a, COACHES_BANK
  call SetBank

  pop af
  push bc;bank
  call BankedGetCoachsName

  pop af;bank
  call SetBank
  ret