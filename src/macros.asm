MACRO GAME_NAME
  DB "TEXT EDITOR",0,0,0,0
ENDM

MACRO SET_BANK
  ldh [loaded_bank], a
  ld [rROMB0], a
ENDM

MACRO TRAMPOLINE ;\1 = jump address
  ld b, BANK(\1)
  ld hl, \1
  call Trampoline
ENDM

MACRO PUSH_ALL
  push af
  push bc
  push de
  push hl
ENDM

MACRO POP_ALL
  pop hl
  pop de
  pop bc
  pop af
ENDM

MACRO LOAD_TILES ;\1 = tile address, \2 = vram address, \3 = index, \4 = count
  ld hl, \1
  ld de, \2 + \3*16
  ld bc, \4*16
IF (\2 + \3*16 + \4*16) > $9800
  call mem_CopyToTileData
ELSE
  call mem_CopyVRAM
ENDC
ENDM

MACRO CLEAR_SCREEN ;\1 = tile
  ld a, \1;tile
  call ClearScreen
ENDM
