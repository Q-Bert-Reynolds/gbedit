SECTION "Main Save", SRAM, BANK[MAIN_SRAM_BANK]
sram_user_name:: DS NAME_LENGTH
sram_text_speed: DB
sram_hours: DW
sram_minutes: DB
sram_seconds: DB
sram_main_save_end:

SECTION "Save/Load Code", ROM0
LoadGame::
  di
  ENABLE_RAM_MBC5

  ;load user and rival names
  SWITCH_RAM_MBC5 MAIN_SRAM_BANK
  ld hl, sram_user_name
  ld de, user_name
  ld bc, sram_main_save_end - sram_user_name
  call mem_Copy

  DISABLE_RAM_MBC5
  reti

CheckSave::;returns z if no save
  ENABLE_RAM_MBC5
  SWITCH_RAM_MBC5 MAIN_SRAM_BANK
  ld hl, sram_user_name
  ld de, name_buffer
  ld bc, NAME_LENGTH
  call mem_Copy
  DISABLE_RAM_MBC5

.checkLength
  ld hl, name_buffer
  call str_Length
  ld a, d
  and a
  jp nz, .noSaveFile
  ld a, e
  and a
  jp z, .noSaveFile

  ld hl, name_buffer
  ld b, NAME_LENGTH
.testLettersLoop
    ld a, [hli]
    cp a, 128
    jr nc, .noSaveFile
    and a
    jr z, .saveExists
    dec b
    jr nz, .testLettersLoop

.saveExists
  ld a, 1
  or a
  ret
.noSaveFile
  xor a
  ret
  
SaveGame::
  di
  ENABLE_RAM_MBC5

  SWITCH_RAM_MBC5 MAIN_SRAM_BANK
  ld hl, user_name
  ld de, sram_user_name
  ld bc, sram_main_save_end - sram_user_name
  call mem_Copy

  DISABLE_RAM_MBC5
  reti