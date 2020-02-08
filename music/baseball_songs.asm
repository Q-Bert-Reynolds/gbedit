INCLUDE "src/beisbol.inc"
INCLUDE "src/audio.asm"

SECTION "Baseball Songs", ROMX, BANK[SONG_BANK]

WaveTable:
  DB 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
  DB 15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0

;tone struct:
; DB pitch_sweep;     // ch1 only, rate (bits 654, 0=off), direction (bit 3, 1=down, 0=up), right shift (bits 210, 0=off)
; DB wave_duty;       // wave pattern duty (bits 76), length counter load register (bits 543210)
; DB volume_envelope; // channel volume (bits 7654), direction (bit 3, 0=down, 1=up), step len (bits 210, 0=off)

OrganTone:
  DB %00000000, %00111111, %11111111

DrumTone:
  DB %00111010, %11000100, %11110001

TakeMeOutToTheBallGameA:
  DW G3,   HOLD, G4
  DW E4,   D4,   B4
  DW D4,   HOLD, HOLD
  DW A4,   HOLD, HOLD
  DW G3,   HOLD, G4
  DW E4,   D4,   B4
  DW D4,   HOLD, HOLD
  DW HOLD, HOLD, HOLD
TakeMeOutToTheBallGameB:
  DW E4,   Eb4,  E4
  DW B4,   C4,   D4
  DW E4,   HOLD, C4
  DW A4,   HOLD, HOLD
  DW E4,   HOLD, E4
  DW E4,   Gb4,  G4
  DW A5,   Gb4,  E4
  DW D4,   B4,   A4
TakeMeOutToTheBallGameC:
  DW G3,   HOLD, G4
  DW E4,   D4,   B4
  DW D4,   HOLD, HOLD
  DW A4,   HOLD, A4
  DW G3,   HOLD, A4
  DW B4,   C4,   D4
  DW E4,   HOLD, HOLD
  DW REST, E4,   Gb4
TakeMeOutToTheBallGameD:
  DW G4,   HOLD, HOLD
  DW G4,   HOLD, HOLD
  DW G4,   Gb4,  E4
  DW D4,   Bb4,  D4
  DW E4,   HOLD, HOLD
  DW Gb4,  HOLD, HOLD
  DW G4,   HOLD, HOLD
  DW HOLD, HOLD, HOLD 

DrumLoop:
  DW C3, B8, B8
  DW C3, B8, B8
  DW C3, B8, B8
  DW C3, B8, B8
  DW C3, B8, B8
  DW C3, B8, B8
  DW C3, B8, B8
  DW C3, B8, B8
  
TakeMeOutToTheBallGameSong::
  ld a, [loop_num]
  and a
  jr nz, .partB
.partA
  PLAY_NOTE TakeMeOutToTheBallGameA, OrganTone, 3
  jr .drums
.partB
  cp 1
  jr nz, .partC
  PLAY_NOTE TakeMeOutToTheBallGameB, OrganTone, 3
  jr .drums
.partC
  cp 2
  jr nz, .partD
  PLAY_NOTE TakeMeOutToTheBallGameC, OrganTone, 3
  jr .drums
.partD
  PLAY_NOTE TakeMeOutToTheBallGameD, OrganTone, 3
.drums
  ; PLAY_NOTE DrumLoop, DrumTone, 4
  ret