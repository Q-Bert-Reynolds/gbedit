SECTION "Text File", SRAM, BANK[MAIN_SRAM_BANK]
sram_text_file:DS 8192
sram_text_file_end::
SECTION "Save/Load Code", ROM0
LoadLine::;loads line number bc into line_buffer, address in line_address
  di
  ENABLE_RAM_MBC5

  ;load user and rival names
  SWITCH_RAM_MBC5 MAIN_SRAM_BANK
  ; ld hl, sram_user_name
  ; ld de, user_name
  ; ld bc, sram_main_save_end - sram_user_name
  ; call mem_Copy

  DISABLE_RAM_MBC5
  reti
  
SaveLine::;saves line_buffer to SRAM at line_bank:line_address
  ;overwrites old line at that address
  ;shifts all subsequent lines (even across banks)
  di
  ENABLE_RAM_MBC5


  ld a, [line_address]
  ld d, a
  ld a, [line_address+1]
  ld e, a
  ld a, [line_bank]
  ld [rRAMB], a
  push af;line bank

  ld hl, AliceText
  ld bc, AliceTextEnd - AliceText
  ld de, sram_text_file
  call mem_Copy;save text file to SRAM
  
  pop af;line bank
.bankLoop
    ; push af;bank
    ; ld [rRAMB], a

  ; .addressLoop ;copy until de == 8192 or "\n" found
      ld a, 26;End of File character
      ld [de], a
      ; inc de
      ; ld a, d
      ; cp a, $20
      ; jp nz, .addressLoop

    ; ld de, sram_text_file
    ; pop af;bank
    ; inc a 
    ; cp a, MAX_RAM_BANKS+1
    ; jr nz, .bankLoop

  DISABLE_RAM_MBC5
  reti