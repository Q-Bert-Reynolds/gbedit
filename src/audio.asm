INCLUDE "src/beisbol.inc"
INCLUDE "src/gbt_player/gbt_player.inc"

IF !DEF(AUDIO_ASM)
AUDIO_ASM SET 1

INCLUDE "src/gbt_player/gbt_player.asm"
INCLUDE "src/gbt_player/gbt_player_bank1.asm"

LOAD_SONG: MACRO ;\1 load address
  di
  ld a, BANK(\1)
  ld hl, \1
  call LoadSong
  ei
ENDM

INCLUDE "music/intro_lights.asm"
INCLUDE "music/charge_fanfare.asm"
INCLUDE "music/take_me_out_to_the_ballgame.asm"

SECTION "Audio", ROM0
PlayNote: ;a = channel, de = tone, hl = note
  push af;channel
  push hl;note
  ld a, [hli] ;second byte of pitch
  and a
  jr nz, .checkPulseChannel1
  ld a, [hl] ;first byte of pitch
  and a
  jr nz, .checkPulseChannel1 
  pop hl;note
  pop af;channel
  ret;if ((*n).pitch == SILENCE) return;
.checkPulseChannel1; switch(channel){
  pop hl;note
  pop af;channel
  cp 1
  jr nz, .checkPulseChannel2
  ld a, [de] ;ch1 only, rate (bits 654, 0=off), direction (bit 3, 1=down, 0=up), right shift (bits 210, 0=off)
  ld [rAUD1SWEEP], a
  inc de
  ld a, [de] ;wave pattern duty (bits 76), length counter load register (bits 543210)
  ld [rAUD1LEN], a
  inc de
  ld a, [de] ;channel volume (bits 7654), direction (bit 3, 0=down, 1=up), step len (bits 210, 0=off)
  ld [rAUD1ENV], a
  ld a, [hli] ;lower byte of pitch
  ld [rAUD1LOW], a
  ld a, [hli] ;upper byte of pitch
  or AUDHIGH_RESTART ;| AUDHIGH_LENGTH_ON
  ld [rAUD1HIGH], a
  ret
.checkPulseChannel2
  cp 2
  jr nz, .checkWaveChannel
  inc de ;no sweep
  ld a, [de] ;wave pattern duty (bits 76), length counter load register (bits 543210)
  ld [rAUD2LEN], a
  inc de
  ld a, [de] ;channel volume (bits 7654), direction (bit 3, 0=down, 1=up), step len (bits 210, 0=off)
  ld [rAUD2ENV], a
  ld a, [hli] ;lower byte of pitch
  ld [rAUD2LOW], a
  ld a, [hli] ;upper byte of pitch
  or AUDHIGH_RESTART ;| AUDHIGH_LENGTH_ON
  ld [rAUD2HIGH], a
  ret
.checkWaveChannel
  cp 3
  jr nz, .checkNoiseChannel
  ld a, AUDENA_ON ;enable channel 3
  inc de ;no sweep
  ld [rAUD3ENA], a
  ld a, [de] ;Sound length = (256-t1)*(1/2) seconds
  ld [rAUD3LEN], a
  inc de
  ld a, [de] ;volume envelope
  ld [rAUD3LEVEL], a
  ld a, [hli] ;lower byte of pitch
  ld [rAUD3LOW], a
  ld a, [hli] ;upper byte of pitch
  or AUDHIGH_RESTART ;| AUDHIGH_LENGTH_ON
  ld [rAUD3HIGH], a
  ret
.checkNoiseChannel
  cp 4
  ret nz
  inc de ;no sweep
  ld a, [de] ;Bit 5-0 - Sound length data (<64)
  ld [rAUD4LEN], a
  inc de
  ld a, [de] ;channel volume (bits 7654), direction (bit 3, 0=down, 1=up), step len (bits 210, 0=off)
  ld [rAUD4ENV], a
  ld a, [hli] ;shift clock (bits 7654), step (bit 3, 0=15, 1=7), dividing ratio 1.048576/(n+1) (bits 210)
  ld [rAUD4POLY], a
  ld a, [hli] ; reset sound (bit 7), Counter/consecutive selection (bit 6)
  or AUDHIGH_RESTART ;| AUDHIGH_LENGTH_ON
  ld [rAUD4GO], a
  ret

UpdateAudio::
  ld a, [loaded_bank]
  ld [vblank_bank], a
  
  call gbt_update
  
  ld a, [vblank_bank]
  call SetBank
  ret

LoadSong:: ; a = bank, hl = song address
  ld d, h
  ld e, l ;de = pointer to song data
  ld b, 0
  ld c, a ;data bank

  ld a, [loaded_bank]
  ld [temp_bank], a ;store current bank

  ld a, 1 ;song speed
  call gbt_play

  ld a, [temp_bank]
  call SetBank
  ret 

ENDC ;AUDIO_ASM
