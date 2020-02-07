INCLUDE "src/beisbol.inc"
INCLUDE "src/audio.asm"

SECTION "Test Song", ROMX, BANK[SONG_BANK]

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

TestSong::
  ld a, [loop_num]; switch (loop_num) {
.part1
  cp 6
  jr z, .skip
  cp 0
  jr nz, .part2
.skip
  PLAY_NOTE BassLoop, BassNotes, 1
  PLAY_NOTE DrumLoop1, DrumNotes, 4
  ret
.part2
  cp 1
  jr nz, .part3
  PLAY_NOTE BassLoop, BassNotes, 1
  PLAY_NOTE DrumLoop2, DrumNotes, 4
  PLAY_NOTE ChimeLoop, ChimeNotes, 2
  ret
.part3
  cp 7
  jr z, .skip2
  cp 2
  jr nz, .part4
.skip2
  PLAY_NOTE BassLoop, BassNotes, 1
  PLAY_NOTE DrumLoop2, DrumNotes, 4
  ret
.part4
  cp 3
  jr nz, .part5
  PLAY_NOTE BassLoop, BassNotes, 1
  PLAY_NOTE StringsLoop, StringsNotes, 2
  PLAY_NOTE DrumLoop2, DrumNotes, 4
  ret
.part5
  cp 5
  jr nz, .part6
  PLAY_NOTE BassLoop, BassNotes, 1
  PLAY_NOTE ChimeLoop, ChimeNotes, 2
  PLAY_NOTE DrumLoop3, DrumNotes, 4
  ret
.part6
  cp 8
  jr nz, .part7
  PLAY_NOTE ChimeLoop, ChimeNotes, 2
  PLAY_NOTE StringsLoop, StringsNotes, 1
  ret
.part7
  cp 9
  jr nz, .defaultPart
  PLAY_NOTE ChimeLoop, ChimeNotes, 2
  PLAY_NOTE StringsLoop, BassNotes, 1
  ret
.defaultPart
  PLAY_NOTE BassLoop, BassNotes, 1
  PLAY_NOTE ChimeLoop, ChimeNotes, 2
  PLAY_NOTE DrumLoop2, DrumNotes, 4
  ret