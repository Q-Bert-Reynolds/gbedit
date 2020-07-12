SECTION "Main Save", SRAM, BANK[MAIN_SRAM_BANK]
sram_text_speed: DB
sram_animation_style: DB
sram_coaching_style: DB
sram_user_name: DS NAME_LENGTH
sram_rival_name: DS NAME_LENGTH

SECTION "Team Save", SRAM, BANK[TEAM_SRAM_BANK]
sram_UserLineup:

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
  ld bc, NAME_LENGTH * 2
  call mem_Copy

  ;load user's lineup
  SWITCH_RAM_MBC5 TEAM_SRAM_BANK
  ld hl, sram_UserLineup
  ld de, UserLineup
  ld bc, UserLineupEnd - UserLineup
  call mem_Copy

  DISABLE_RAM_MBC5
  reti

  
SaveGame::
  di
  ENABLE_RAM_MBC5

  ;save user and rival names
  SWITCH_RAM_MBC5 MAIN_SRAM_BANK
  ld hl, user_name
  ld de, sram_user_name
  ld bc, NAME_LENGTH * 2
  call mem_Copy

  ;save user's lineup
  SWITCH_RAM_MBC5 TEAM_SRAM_BANK
  ld hl, UserLineup
  ld de, sram_UserLineup
  ld bc, UserLineupEnd - UserLineup
  call mem_Copy

  DISABLE_RAM_MBC5
  reti