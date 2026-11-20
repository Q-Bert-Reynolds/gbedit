SECTION "Core HRAM", HRAM
loaded_bank:: DB
temp_a_reg:: DB

SECTION "Core ROM0", ROM0

Trampoline:: ;b = bank, hl = address, can use a, de, and RAM for args, can return in any register
  ldh [temp_a_reg], a
  ldh a, [loaded_bank]
  push af;old bank
  ld a, b;new bank
  SET_BANK
  ldh a, [temp_a_reg]
  ld bc, .bounceBack
  push bc ;put return addres on stack before jumping
  jp hl
.bounceBack
  ldh [temp_a_reg], a
  pop af;old bank
  SET_BANK
  ldh a, [temp_a_reg]
  ret

ClearTiles:: ;a = tile, display should be off
  ld bc, 32*32+20*18
  ld hl, _SCRN0
  jp mem_SetVRAM

ClearScreen:: ;a = tile, display should be off
  call ClearTiles
  ld a, 166
  ldh [rWX], a
  ld a, 143
  ldh [rWY], a
  call HideAllSprites
.checkGBC
  ldh a, [sys_info]
  and a, SYS_INFO_GBC
  ret z
.clearColors
  ld a, 1
  ldh [rVBK], a
  xor a
  call ClearTiles
  ldh [rVBK], a
  ret 

HideAllSprites::
  xor a
  ld b, OAM_COUNT
  ld hl, oam_buffer
.loop
    ld [hli], a
    ld [hli], a
    inc hl
    inc hl
    dec b
    jr nz, .loop
  call gbdk_DMATransfer
  ret
