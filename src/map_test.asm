INCLUDE "src/beisbol.inc"

SECTION "Map Test", ROMX, BANK[OVERWORLD_BANK]

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
  ld hl, InfieldChunk
  call SetCurrentMapChunk
  call DrawMapToScreen
  DISPLAY_ON

.loop
    call UpdateInput
    ld a, [button_state]
    ld b, a;buttons
  .testUp
    and a, PADF_UP
    jr z, .testDown
    call MoveMapUp
    jp .testStartA
  .testDown
    ld a, b
    and a, PADF_DOWN
    jr z, .testLeft
    call MoveMapDown
    jp .testStartA
  .testLeft
    ld a, b
    and a, PADF_LEFT
    jr z, .testRight
    call MoveMapLeft
    jp .testStartA
  .testRight
    ld a, b
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
