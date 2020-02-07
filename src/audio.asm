INCLUDE "src/beisbol.inc"

IF !DEF(AUDIO_ASM)
AUDIO_ASM SET 1

MEASURES        EQU 12
BEATS           EQU MEASURES*4
PLAYBACK_SPEED  EQU 12
LOOPS           EQU 12

C3      SET 44
Cb3     SET 156
D3      SET 262
Db3     SET 363
E3      SET 457
F3      SET 547
Fb3     SET 631
G3      SET 710
Gb3     SET 786
A3      SET 854
Ab3     SET 923
B3      SET 986
C4      SET 1046
Cb4     SET 1102
D4      SET 1155
Db4     SET 1205
E4      SET 1253
F4      SET 1297
Fb4     SET 1339
G4      SET 1379
Gb4     SET 1417
A4      SET 1452
Ab4     SET 1486
B4      SET 1517
C5      SET 1546
Cb5     SET 1575
D5      SET 1602
Db5     SET 1627
E5      SET 1650
F5      SET 1673
Fb5     SET 1694
G5      SET 1714
Gb5     SET 1732
A5      SET 1750
Ab5     SET 1767
B5      SET 1783
C6      SET 1798
Cb6     SET 1812
D6      SET 1825
Db6     SET 1837
E6      SET 1849
F6      SET 1860
Fb6     SET 1871
G6      SET 1881
Gb6     SET 1890
A6      SET 1899
Ab6     SET 1907
B6      SET 1915
C7      SET 1923
Cb7     SET 1930
D7      SET 1936
Db7     SET 1943
E7      SET 1949
F7      SET 1954
Fb7     SET 1959
G7      SET 1964
Gb7     SET 1969
A7      SET 1974
Ab7     SET 1978
B7      SET 1982
C8      SET 1985
Cb8     SET 1988
D8      SET 1992
Db8     SET 1995
E8      SET 1998
F8      SET 2001
Fb8     SET 2004
G8      SET 2006
Gb8     SET 2009
A8      SET 2011
Ab8     SET 2013
B8      SET 2015
SILENCE SET 0

WaveTable:
  DB 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
  DB 15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0

;note struct:
; DB pitch_sweep;     // ch1 only, rate (bits 654, 0=off), direction (bit 3, 1=down, 0=up), right shift (bits 210, 0=off)
; DB wave_duty;       // wave pattern duty (bits 76), length counter load register (bits 543210)
; DB volume_envelope; // channel volume (bits 7654), direction (bit 3, 0=down, 1=up), step len (bits 210, 0=off)
; DW pitch;

BassNotes:
  DB %00000000, %00000000, %00000000
  DW SILENCE
  DB %00000000, %00111111, %11111111
  DW E3
  DB %00000000, %00111111, %11111111
  DW G3
  DB %00000000, %00111111, %11111111
  DW Gb3
  DB %00000000, %00111111, %11111111
  DW A3
  DB %00000000, %00111111, %11111111
  DW B3
  DB %00000000, %00111111, %11111111
  DW Cb4
  DB %00000000, %00111111, %11111111
  DW D4
  DB %00000000, %00111111, %11111111
  DW E4

BassLoop:
  DB 1,0,0,0
  DB 8,0,0,4
  DB 5,8,5,0
  DB 8,0,0,0
  DB 7,6,5,2
  DB 0,1,2,0
  DB 1,0,4,5
  DB 8,0,0,4
  DB 5,8,5,0
  DB 8,0,0,0
  DB 7,6,5,2
  DB 0,1,2,0

StringsNotes:
  DB %00000000, %00000000, %00000000
  DW SILENCE
  DB %00111010, %11000100, %11110001
  DW E5
  DB %00111010, %11000100, %11110001
  DW G5
  DB %00111010, %11000100, %11110001
  DW Gb5
  DB %00111010, %11000100, %11110001
  DW A5
  DB %00111010, %11000100, %11110001
  DW B5
  DB %00111010, %11000100, %11110001
  DW Cb6
  DB %00111010, %11000100, %11110001
  DW D6
  DB %00111010, %11000100, %11110001
  DW E6

StringsLoop:
  DB 1,0,0,0
  DB 3,0,0,0
  DB 0,0,0,0
  DB 5,0,0,0
  DB 4,0,0,0
  DB 0,0,0,0
  DB 1,0,0,0
  DB 3,0,0,0
  DB 0,0,0,0
  DB 5,0,0,0
  DB 4,0,0,0
  DB 0,0,0,0

ChimeNotes:
  DB %00000000, %00000000, %00000000
  DW SILENCE
  DB %00111010, %11000100, %11110001
  DW E6
  DB %00111010, %11000100, %11110001
  DW G6
  DB %00111010, %11000100, %11110001
  DW Gb6
  DB %00111010, %11000100, %11110001
  DW A6
  DB %00111010, %11000100, %11110001
  DW B6
  DB %00111010, %11000100, %11110001
  DW Cb7
  DB %00111010, %11000100, %11110001
  DW D7
  DB %00111010, %11000100, %11110001
  DW E7

ChimeLoop:
  DB 1,0,3,1
  DB 3,0,0,1
  DB 3,1,3,0
  DB 0,1,3,4
  DB 3,4,5,0
  DB 0,3,4,5
  DB 1,0,3,1
  DB 3,0,0,1
  DB 3,1,3,0
  DB 0,1,3,4
  DB 3,4,5,0
  DB 0,3,4,8

DrumNotes:
  DB %00000000, %00000000, %00000000
  DW SILENCE
  DB %00111010, %11000100, %11110001
  DW E5
  DB %00111010, %11000100, %11110001
  DW A6

DrumLoop1:
  DB 0,0,0,0
  DB 0,0,0,0
  DB 0,0,0,0
  DB 0,0,0,0
  DB 0,0,0,0
  DB 0,0,0,0
  DB 0,0,0,0
  DB 2,0,1,0
  DB 1,0,1,0
  DB 2,0,1,0
  DB 1,0,1,0
  DB 2,0,1,0

DrumLoop2:
  DB 1,0,1,0
  DB 2,0,1,0
  DB 1,0,1,0
  DB 2,0,1,0
  DB 1,0,1,0
  DB 2,0,1,0
  DB 1,0,1,0
  DB 2,0,1,0
  DB 1,0,1,0
  DB 2,0,1,0
  DB 1,0,1,0
  DB 2,0,1,0

DrumLoop3:
  DB 1,2,1,1
  DB 2,1,2,2
  DB 1,2,1,1
  DB 2,1,2,2
  DB 1,2,1,1
  DB 2,1,2,2
  DB 1,2,1,1
  DB 2,1,2,2
  DB 1,2,1,1
  DB 2,1,2,2
  DB 1,2,1,1
  DB 2,1,2,2

SetNote: ;a = channel, hl = note
  push af;channel
  push hl;note
  ld a, [hli] ;first byte of pitch
  and a
  jr nz, .checkPulseChannel1
  ld a, [hl] ;second byte of pitch
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
  ld a, [hli] ;ch1 only, rate (bits 654, 0=off), direction (bit 3, 1=down, 0=up), right shift (bits 210, 0=off)
  ld [rAUD1SWEEP], a
  ld a, [hli] ;wave pattern duty (bits 76), length counter load register (bits 543210)
  ld [rAUD1LEN], a
  ld a, [hli] ;channel volume (bits 7654), direction (bit 3, 0=down, 1=up), step len (bits 210, 0=off)
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
  inc hl ;no sweep
  ld a, [hli] ;wave pattern duty (bits 76), length counter load register (bits 543210)
  ld [rAUD2LEN], a
  ld a, [hli] ;channel volume (bits 7654), direction (bit 3, 0=down, 1=up), step len (bits 210, 0=off)
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
  inc hl ;no sweep
  ld [rAUD3ENA], a
  ld a, [hli] ;Sound length = (256-t1)*(1/2) seconds
  ld [rAUD3LEN], a
  ld a, [hli] ;volume envelope
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
  inc hl ;no sweep
  ld a, [hli] ;Bit 5-0 - Sound length data (<64)
  ld [rAUD4LEN], a
  ld a, [hli] ;channel volume (bits 7654), direction (bit 3, 0=down, 1=up), step len (bits 210, 0=off)
  ld [rAUD4ENV], a
  ld a, [hli] ;shift clock (bits 7654), step (bit 3, 0=15, 1=7), dividing ratio 1.048576/(n+1) (bits 210)
  ld [rAUD4POLY], a
  ld a, [hli] ; reset sound (bit 7), Counter/consecutive selection (bit 6)
  or AUDHIGH_RESTART ;| AUDHIGH_LENGTH_ON
  ld [rAUD4GO], a
  ret

SET_NOTE: macro

ENDM

PlayMusic:
  ; ld a, 1
  ; ld hl, ChimeNotes+5
  ; call SetNote

  ld d, 0
  ld a, [beat]
  ld e, a ;beat in de
  
  ld hl, BassLoop
  add hl, de;note index
  ld a, [hl];bass note

  ld d, 0
  ld e, a  
  ld a, 5 ;len of note struct
  call math_Multiply ;hl = beat * len(note)

  ld bc, BassNotes
  add hl, bc;note

  ld a, 1;channel
  call SetNote

; switch (loop_num) {
;   case 6:
;   case 0:
;       set_note(1, &bass_notes[bass_loop[beat]]);
;       set_note(4, &drum_notes[drum_loop1[beat]]);
;       break;
;   case 1:
;       set_note(1, &bass_notes[bass_loop[beat]]);
;       set_note(4, &drum_notes[drum_loop2[beat]]);
;       set_note(2, &chime_notes[chime_loop[beat]]);
;       break;
;   case 7:
;   case 2:
;       set_note(1, &bass_notes[bass_loop[beat]]);
;       set_note(4, &drum_notes[drum_loop2[beat]]);
;       break;
;   case 3:
;       set_note(1, &bass_notes[bass_loop[beat]]);
;       set_note(2, &strings_notes[strings_loop[beat]]);
;       set_note(4, &drum_notes[drum_loop2[beat]]);
;       break;
;   case 5:
;       set_note(1, &bass_notes[bass_loop[beat]]);
;       set_note(2, &chime_notes[chime_loop[beat]]);
;       set_note(4, &drum_notes[drum_loop3[beat]]);
;       break;
;   case 8:
;       set_note(2, &chime_notes[chime_loop[beat]]);
;       set_note(1, &strings_notes[chime_loop[beat]]);
;       break;
;   case 9:
;       set_note(2, &chime_notes[chime_loop[beat]]);
;       set_note(1, &bass_notes[strings_loop[beat]]);
;       break;
;   default:
;       set_note(1, &bass_notes[bass_loop[beat]]);
;       set_note(2, &chime_notes[chime_loop[beat]]);
;       set_note(4, &drum_notes[drum_loop2[beat]]);
;       break;

  ret

UpdateAudio::
  ld a, [music_timer]
  and a
  jr nz, .incrementTimer ;if (music_timer == 0) {
    call PlayMusic ;play_music();
    ld a, [beat]
    inc a ;beat++;
    ld [beat], a
    cp BEATS ;TODO: should be variable
    jr nz, .incrementTimer ;if (beat == BEATS) {
      xor a ;beat = 0;
      ld [beat], a
      ld a, [loop_num]
      inc a ;loop_num++;
      ld [loop_num], a
      cp LOOPS
      jr nz, .incrementTimer;if (loop_num == LOOPS) 
        xor a
        ld [loop_num], a;loop_num = 0;
.incrementTimer
  ld a, [music_timer]
  inc a ; music_timer++;
  ld [music_timer], a
  cp PLAYBACK_SPEED ;TODO: should be variable
  ret nz;if (music_timer == PLAYBACK_SPEED)
  xor a
  ld [music_timer], a ;music_timer = 0;
  ret


ENDC ;AUDIO_ASM
