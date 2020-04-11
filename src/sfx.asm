SECTION "SFX", ROMX, BANK[SFX_BANK]

SelectSound::
  DB 3;steps
  DB %0001 ;disable mask

  DB 2, %1110, SFX_CH_1 ;ticks, mask, channel
  DB 0, $FF, $FF        ;sweep, duty/len, volume
  DW E5                 ;frequency

  DB 4, %1110, SFX_CH_1
  DB 0, $FF, $FF
  DW C6

  DB 2, %1110, SFX_CH_1
  DB 0, $FF, $FF
  DW A6

TitleDropInSound::
  DB 2;steps
  DB %1000 ;disable mask

  DB 2, %0111, SFX_CH_4 ;ticks, mask, channel
  DB $00, $3A, $F8       ;sweep, duty/len, volume
  DB $62, $80            ;frequency, control

  DB 8, %0111, SFX_CH_4
  DB $00, $3A, $A8 
  DB $72, $80      

VersionSlideInSound::
  DB 3;steps
  DB %0001 ;disable mask
  
  DB 20, %1111, SFX_CH_1
  DB 0, 0, 0
  DW 0

  DB 20, %1110, SFX_CH_1
  DB %01000111, $FF, $FF
  DW A4

  DB 4, %1110, SFX_CH_1
  DB 0, $FF, $FF
  DW C6