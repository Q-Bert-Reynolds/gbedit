INCLUDE "src/beisbol.inc"

SECTION "Lineup", ROMX, BANK[LINEUP_BANK]

ShowLineup::; a = playing_game?

  ret