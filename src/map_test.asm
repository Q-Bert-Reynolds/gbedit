INCLUDE "src/beisbol.inc"

SECTION "Map Test", ROMX, BANK[WORLD_BANK]

TestMap::
  DISPLAY_OFF
  PLAY_SONG tessie_data, 1
  SET_DEFAULT_PALETTE
  call LoadFontTiles
  ld a, MAP_OVERWORLD
  ld [map], a
  call SetMapTiles
  call SetMapPalettes
  ld a, 20
  ld [map_x], a
  ld [map_y], a
  ld a, MAP_OVERWORLD
  call SetCurrentMap
  ld a, MAP_OVERWORLD_CHUNK_BILLETTOWNNE
  ld [map_chunk], a
  call DrawMapToScreen
  DISPLAY_ON

  ld a, 4
  ld [map_scroll_speed], a

.loop
    call UpdateInput
  .testUp
    ld a, [button_state]
    and a, PADF_UP
    jr z, .testDown
    call MoveMapUp
    jp .testLeft
  .testDown
    ld a, [button_state]
    and a, PADF_DOWN
    jr z, .testLeft
    call MoveMapDown
  .testLeft
    ld a, [button_state]
    and a, PADF_LEFT
    jr z, .testRight
    call MoveMapLeft
    jp .testStartA
  .testRight
    ld a, [button_state]
    and a, PADF_RIGHT
    jr z, .testStartA
    call MoveMapRight
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
