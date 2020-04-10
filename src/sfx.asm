SECTION "SFX", ROMX, BANK[SFX_BANK]

SelectSound:
  DB 3;steps
  ;  ticks, sweep, duty/len, volume
  DB 2,     0,     $FF,     $FF
  DW E5 ;frequency
  DB 4,     0,     $FF,     $FF
  DW C6
  DB 2,     0,     $FF,     $FF
  DW A6