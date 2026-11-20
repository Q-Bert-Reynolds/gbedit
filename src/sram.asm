;text buffer, see src/editor/text_buffer.asm
SECTION "Text Buffer 0", SRAM, BANK[0]
sram_text_buffer: DS $2000
SECTION "Text Buffer 1", SRAM, BANK[1]
  DS $2000
SECTION "Text Buffer 2", SRAM, BANK[2]
  DS $2000

SECTION "Text Buffer Signature", SRAM, BANK[MAIN_SRAM_BANK]
sram_tb_signature:: DS 4
