INCLUDE "src/beisbol.inc"

IF !DEF(AUDIO_ASM)
AUDIO_ASM SET 1


C3      SET 44
Db3     SET 156
D3      SET 262
Eb3     SET 363
E3      SET 457
F3      SET 547
Gb3     SET 631
G3      SET 710
Ab3     SET 786
A3      SET 854
Bb3     SET 923
B3      SET 986
C4      SET 1046
Db4     SET 1102
D4      SET 1155
Eb4     SET 1205
E4      SET 1253
F4      SET 1297
Gb4     SET 1339
G4      SET 1379
Ab4     SET 1417
A4      SET 1452
Bb4     SET 1486
B4      SET 1517
C5      SET 1546
Db5     SET 1575
D5      SET 1602
Eb5     SET 1627
E5      SET 1650
F5      SET 1673
Gb5     SET 1694
G5      SET 1714
Ab5     SET 1732
A5      SET 1750
Bb5     SET 1767
B5      SET 1783
C6      SET 1798
Db6     SET 1812
D6      SET 1825
Eb6     SET 1837
E6      SET 1849
F6      SET 1860
Gb6     SET 1871
G6      SET 1881
Ab6     SET 1890
A6      SET 1899
Bb6     SET 1907
B6      SET 1915
C7      SET 1923
Db7     SET 1930
D7      SET 1936
Eb7     SET 1943
E7      SET 1949
F7      SET 1954
Gb7     SET 1959
G7      SET 1964
Ab7     SET 1969
A7      SET 1974
Bb7     SET 1978
B7      SET 1982
C8      SET 1985
Db8     SET 1988
D8      SET 1992
Eb8     SET 1995
E8      SET 1998
F8      SET 2001
Gb8     SET 2004
G8      SET 2006
Ab8     SET 2009
A8      SET 2011
Bb8     SET 2013
B8      SET 2015
HOLD    SET 0
REST    SET 1

PLAY_NOTE: MACRO ;LoopArray, Tone, Channel
  ld d, 0
  ld a, [music_beat_num]
  ld e, a ;music_beat_num in de
  
  ld hl, \1
  add hl, de;note index
  add hl, de;because notes are 2 bytes

  ld de, \2;tone

  ld a, \3;channel
  call PlayNote
ENDM

INCLUDE "music/baseball_songs.asm"

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

PlayMusic:
  ld a, [loaded_bank]
  ld [vblank_bank], a
  ld a, [current_song_bank]
  call SetBank

  ld hl, rCurrentSong
  ld a, [hli]
  ld b, a
  ld a, [hl]
  ld h, b
  ld l, a
  jp hl
EndPlayMusic:: ;song must jump back here
  ld a, [vblank_bank]
  call SetBank
  ret

UpdateAudio::
  ld a, [music_timer]
  and a
  jr nz, .incrementTimer ;if (music_timer == 0) {
    call PlayMusic ;play_music();
    ld a, [music_beat_num]
    inc a ;music_beat_num++;
    ld [music_beat_num], a
    ld b, a
    ld a, [music_beats]
    cp b
    jr nz, .incrementTimer ;if (music_beat_num == BEATS) {
      xor a ;music_beat_num = 0;
      ld [music_beat_num], a
      ld a, [music_loop_num]
      inc a ;music_loop_num++;
      ld [music_loop_num], a
      ld b, a
      ld a, [music_loops]
      cp b
      jr nz, .incrementTimer;if (music_loop_num == LOOPS) 
        xor a
        ld [music_loop_num], a;music_loop_num = 0;
.incrementTimer
  ld a, [music_timer]
  inc a ; music_timer++;
  ld [music_timer], a
  ld b, a
  ld a, [music_tempo]
  cp b
  ret nz;if (music_timer == PLAYBACK_SPEED)
  xor a
  ld [music_timer], a ;music_timer = 0;
  ret


ENDC ;AUDIO_ASM
