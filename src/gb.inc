IF !DEF(GB_INC)
GB_INC SET 1

INCLUDE "src/hardware.inc"
INCLUDE "src/memory1.asm"
INCLUDE "src/strings.asm"
INCLUDE "src/gbdk.asm"
INCLUDE "src/keyboard/keyboard.asm"
INCLUDE "src/math.asm"
INCLUDE "src/charmap.asm"
INCLUDE "src/constants.asm"
INCLUDE "src/macros.asm"
INCLUDE "src/color.asm"
INCLUDE "src/sgb.asm"
INCLUDE "src/audio.asm"
INCLUDE "src/ui.asm"
INCLUDE "src/core.asm"
INCLUDE "src/fade.asm"
INCLUDE "src/wram.asm"
INCLUDE "src/sram.asm"

ENDC ; GB_INC
