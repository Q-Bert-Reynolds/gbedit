INCLUDE "src/beisbol.inc"

SECTION "Map Test", ROMX, BANK[OVERWORLD_BANK]

INCLUDE "maps/unity_test_map.gbmap"

TestMap::
  DISPLAY_OFF
  PLAY_SONG tessie_data, 1
  SET_DEFAULT_PALETTE
  call LoadFontTiles
  call LoadOverworldTiles
  ld hl, MapPalettes
  call SetupMapPalettes
  ld a, 21
  ld [map_x], a
  ld [map_y], a
  ld d, a
  ld e, a
  sla a
  sla a
  sla a
  ld [rSCX], a
  ld [rSCY], a
  ld hl, BilletTownNE
  call SetCurrentMapChunk
  call DrawMapToScreen
  DISPLAY_ON

.loop
    ld c, MAP_SCROLL_SPEED
    call UpdateInput
    ld a, [button_state]
    ld b, a;buttons
  .testUp
    and a, PADF_UP
    jr z, .testDown
    ld a, [rSCY]
    sub a, c;pos -= speed
    push af
    ld e, a
    jr nc, .noChunkChangeNorth
    ld a, MAP_NORTH
    call GetCurrentMapChunkNeighbor
    call SetCurrentMapChunk
  .noChunkChangeNorth
    srl e
    srl e
    srl e
    ld a, [map_y]
    cp a, e
    jp z, .moveY;if y == map_y, no draw
    ld a, e
    ld [map_y], a
    call DrawMapTopEdge
    jp .moveY
  .testDown
    ld a, b
    and a, PADF_DOWN
    jr z, .testLeft
    ld a, [rSCY]    
    add a, c;pos += speed
    push af
    ld e, a
    jr nc, .noChunkChangeSouth
    ld a, MAP_SOUTH
    call GetCurrentMapChunkNeighbor
    call SetCurrentMapChunk
  .noChunkChangeSouth
    srl e
    srl e
    srl e
    ld a, [map_y]
    cp a, e
    jp z, .moveY;if y == map_y, no draw
    ld a, e
    ld [map_y], a
    call DrawMapBottomEdge
    jp .moveY
  .testLeft
    ld a, b
    and a, PADF_LEFT
    jr z, .testRight
    ld a, [rSCX]
    sub a, c;pos -= speed
    push af
    ld d, a
    jr nc, .noChunkChangeWest
    ld a, MAP_WEST
    call GetCurrentMapChunkNeighbor
    call SetCurrentMapChunk
  .noChunkChangeWest
    srl d
    srl d
    srl d
    ld a, [map_x]
    cp a, d
    jp z, .moveX;if x == map_x, no draw
    ld a, d
    ld [map_x], a
    call DrawMapLeftEdge
    jp .moveX
  .testRight
    ld a, b
    and a, PADF_RIGHT
    jr z, .testStartA
    ld a, [rSCX]
    add a, c;pos += speed
    push af
    ld d, a
    jr nc, .noChunkChangeEast
    ld a, MAP_EAST
    call GetCurrentMapChunkNeighbor
    call SetCurrentMapChunk
  .noChunkChangeEast
    srl d
    srl d
    srl d
    ld a, [map_x]
    cp a, d
    jp z, .moveX;if x == map_x, no draw
    ld a, d
    ld [map_x], a
    call DrawMapRightEdge
    ;fall through to move right
  .moveX
    pop af
    ld [rSCX], a
    jr .testStartA
  .moveY
    pop af
    ld [rSCY], a
  .testStartA
    ld a, [last_button_state]
    and a, PADF_A | PADF_START
    jr nz, .wait
    ld a, [button_state]
    and a, PADF_A | PADF_START
    jr nz, .exit
  .wait
    call gbdk_WaitVBL
    jp .loop
.exit
  ret
