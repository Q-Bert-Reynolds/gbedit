SECTION "Options Save", SRAM, BANK[MAIN_SRAM_BANK]
sram_text_speed: DB
sram_animation_style: DB
sram_coaching_style: DB

SECTION "Main Save", SRAM, BANK[MAIN_SRAM_BANK]
sram_user_name: DS NAME_LENGTH
sram_rival_name: DS NAME_LENGTH
sram_hours: DW
sram_minutes: DB
sram_seconds: DB
sram_inventory: DS MAX_ITEMS*BYTES_PER_ITEM
sram_pc_items: DS MAX_PC_ITEMS*BYTES_PER_ITEM
sram_money: DS 3
sram_players_seen: DS 151/8+1
sram_players_sign: DS 151/8+1
sram_map: DB
sram_map_chunk: DB
sram_map_x: DB
sram_map_y: DB
sram_pc_flags: DB
sram_main_save_end:

SECTION "Team Save", SRAM, BANK[TEAM_SRAM_BANK]
sram_UserLineup: DS LINEUP_SIZE

SECTION "Farm Save 1", SRAM, BANK[FARM_SRAM_BANK]
sram_FarmAAAA: DS FARM_SIZE
sram_FarmAAA: DS FARM_SIZE
sram_FarmAA: DS FARM_SIZE
sram_FarmHighA: DS FARM_SIZE

SECTION "Farm Save 2", SRAM, BANK[FARM_SRAM_BANK+1]
sram_FarmLowA: DS FARM_SIZE
sram_FarmRookie: DS FARM_SIZE
sram_FarmClassB: DS FARM_SIZE
sram_FarmClassC: DS FARM_SIZE

SECTION "Save/Load Code", ROM0
LoadOptions::
  di
  SWITCH_RAM_MBC5 MAIN_SRAM_BANK
  ENABLE_RAM_MBC5
  ld hl, sram_text_speed
  ld de, text_speed
  ld bc, 3;text_speed, animation_style and coaching_style
  call mem_Copy
  DISABLE_RAM_MBC5
  reti
  
SaveOptions::
  di
  SWITCH_RAM_MBC5 MAIN_SRAM_BANK
  ENABLE_RAM_MBC5
  ld hl, text_speed
  ld de, sram_text_speed
  ld bc, 3;text_speed, animation_style and coaching_style
  call mem_Copy
  DISABLE_RAM_MBC5
  reti

LoadGame::
  di
  ENABLE_RAM_MBC5

  ;load user and rival names
  SWITCH_RAM_MBC5 MAIN_SRAM_BANK
  ld hl, sram_user_name
  ld de, user_name
  ld bc, sram_main_save_end - sram_user_name
  call mem_Copy

  ;load user's lineup
  SWITCH_RAM_MBC5 TEAM_SRAM_BANK
  ld hl, sram_UserLineup
  ld de, UserLineup
  ld bc, UserLineupEnd - UserLineup
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

  ;save user and rival names
  SWITCH_RAM_MBC5 MAIN_SRAM_BANK
  ld hl, user_name
  ld de, sram_user_name
  ld bc, sram_main_save_end - sram_user_name
  call mem_Copy

  ;save user's lineup
  SWITCH_RAM_MBC5 TEAM_SRAM_BANK
  ld hl, UserLineup
  ld de, sram_UserLineup
  ld bc, UserLineupEnd - UserLineup
  call mem_Copy

  DISABLE_RAM_MBC5
  reti