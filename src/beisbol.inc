IF !DEF(BEISBOL_INC)
BEISBOL_INC SET 1

INCLUDE "src/hardware.inc"
INCLUDE "src/memory1.asm"
INCLUDE "src/strings.asm"
INCLUDE "src/gbdk.asm"
INCLUDE "src/math.asm"

INCLUDE "src/charmap.asm"
INCLUDE "src/constants.asm"
INCLUDE "src/macros.asm"
INCLUDE "src/audio.asm"

INCLUDE "src/roledex/roledex.asm"
INCLUDE "src/core.asm"
INCLUDE "src/players.asm"
INCLUDE "src/map_loader.asm"
INCLUDE "src/ui.asm"

;TODO: Remove temp data
INCLUDE "src/temp_data.asm"

INCLUDE "src/start.asm"
INCLUDE "src/title.asm"
INCLUDE "src/new_game.asm"
INCLUDE "src/overworld.asm"
INCLUDE "src/baseball/play_ball.asm"
INCLUDE "src/lineup/lineup.asm"
INCLUDE "src/roledex/roledex_ui.asm"
INCLUDE "src/baseball/simulation.asm"

INCLUDE "src/wram.asm"
INCLUDE "src/sram.asm"

ENDC ; BEISBOL_INC
