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
  DB %1010 ;disable mask

  DB 1, %1101, SFX_CH_2
  DB %11110111, $FF, $FF
  DW A3

  DB 80, %0101, SFX_CH_4              ;ticks, mask, channel
  DB $00, $FF, $FF                   ;sweep, duty/len, volume
  DB NOISE_DIV_2K | NOISE_EARTHQUAKE, $80 ;frequency, control

VersionSlideInSound::
  DB 5;steps
  DB %1001 ;disable mask
  
  DB 16, %1111, SFX_CH_1
  DB 0, 0, 0
  DW 0

  DB 1, %1110, SFX_CH_1
  DB %11110111, $FF, $FF
  DW A3

  DB 8, %0110, SFX_CH_4
  DB $00, $FF, $F0
  DB NOISE_DIV_128 | NOISE_STATIC, $80

  DB 8, %0110, SFX_CH_4
  DB $00, $FF, $F8
  DB NOISE_DIV_64 | NOISE_STATIC, $80

  DB 8, %0110, SFX_CH_4
  DB $00, $FF, $FF
  DB NOISE_DIV_32 | NOISE_STATIC, $80