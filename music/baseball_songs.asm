INCLUDE "src/beisbol.inc"
INCLUDE "src/audio.asm"

SECTION "Baseball Songs", ROMX, BANK[SONG_BANK]

OrganWaveTable:
  DB $01, $23, $45, $67, $89, $AB, $CD, $EF, $02, $46, $8A, $CE, $02, $46, $8A, $CE

;tone struct:
; DB pitch_sweep;     // ch1 only, rate (bits 654, 0=off), direction (bit 3, 1=down, 0=up), right shift (bits 210, 0=off)
; DB wave_duty;       // wave pattern duty (bits 76), length counter load register (bits 543210)
; DB volume_envelope; // channel volume (bits 7654), direction (bit 3, 0=down, 1=up), step len (bits 210, 0=off)

OrganTone:
  DB %00011000, %11111111, %11111111

DrumTone:
  DB %00111010, %11000100, %11110001

TakeMeOutToTheBallGamePhraseA:
  DW G3,   HOLD, G4
  DW E4,   D4,   B3
  DW D4,   HOLD, HOLD
  DW A3,   HOLD, HOLD
  DW G3,   HOLD, G4
  DW E4,   D4,   B3
  DW D4,   HOLD, HOLD
  DW HOLD, HOLD, HOLD
TakeMeOutToTheBallGamePhraseB:
  DW E4,   Eb4,  E4
  DW B3,   C4,   D4
  DW E4,   HOLD, C4
  DW A3,   HOLD, HOLD
  DW E4,   HOLD, E4
  DW E4,   Gb4,  G4
  DW A4,   Gb4,  E4
  DW D4,   B3,   A3
TakeMeOutToTheBallGamePhraseC:
  DW G3,   HOLD, G4
  DW E4,   D4,   B3
  DW D4,   HOLD, HOLD
  DW A3,   HOLD, A3
  DW G3,   HOLD, A3
  DW B3,   C4,   D4
  DW E4,   HOLD, HOLD
  DW REST, E4,   Gb4
TakeMeOutToTheBallGamePhraseD:
  DW G4,   HOLD, HOLD
  DW G4,   HOLD, HOLD
  DW G4,   Gb4,  E4
  DW D4,   Db4,  D4
  DW E4,   HOLD, HOLD
  DW Gb4,  HOLD, HOLD
  DW G4,   HOLD, HOLD
  DW HOLD, HOLD, HOLD 

TakeMeOutToTheBallGameSong::
  ld a, [music_phrase_num]
  and a
  jr nz, .partB
.partA
  PLAY_NOTE TakeMeOutToTheBallGamePhraseA, OrganTone, 1
  jr .drums
.partB
  cp 1
  jr nz, .partC
  PLAY_NOTE TakeMeOutToTheBallGamePhraseB, OrganTone, 1
  jr .drums
.partC
  cp 2
  jr nz, .partD
  PLAY_NOTE TakeMeOutToTheBallGamePhraseC, OrganTone, 1
  jr .drums
.partD
  PLAY_NOTE TakeMeOutToTheBallGamePhraseD, OrganTone, 1
.drums
  jp FinishMusicUpdate

LoadTakeMeOutToTheBallGame::
  ld a, BANK(TakeMeOutToTheBallGameSong)
  ld [current_song_bank], a
  ld hl, TakeMeOutToTheBallGameSong
  ld a, h
  ld [rCurrentSong], a
  ld a, l
  ld [rCurrentSong+1], a

  xor a
  ld [music_timer], a
  ld [music_beat_num], a
  ld [music_phrase_num], a

  ld a, 4 ;phrases
  ld [music_phrases], a
  ld a, 20 ;more like inverse of tempo
  ld [music_tempo], a
  ld a, 24 ;8 measures * 3 beats/measure
  ld [music_beats], a

  ld hl, OrganWaveTable
  ld de, _AUD3WAVERAM
  ld bc, 16
  call mem_Copy

  jp DoneLoadingSong

ChargePhraseA:
  DW Bb4,  F4,   G4,   A4
  DW Bb4,  F4,   G4,   A4
  DW B4,   Gb4,  Ab4,  Bb4
  DW B4,   Gb4,  Ab4,  Bb4
  DW C4,   G4,   A4,   B4
  DW C4,   G4,   A4,   B4
  DW C4,   HOLD, HOLD, HOLD
  DW C3,   E3,   G3,   C4
  DW G3,   C4,   HOLD, HOLD
  DW C5,   HOLD, HOLD, HOLD  

ChargeSong:
  PLAY_NOTE ChargePhraseA, OrganTone, 1
  jp FinishMusicUpdate

LoadChargeSong::
  ld a, BANK(ChargeSong)
  ld [current_song_bank], a
  ld hl, ChargeSong
  ld a, h
  ld [rCurrentSong], a
  ld a, l
  ld [rCurrentSong+1], a

  xor a
  ld [music_timer], a
  ld [music_beat_num], a
  ld [music_phrase_num], a

  ld a, 1
  ld [music_phrases], a
  ld a, 20
  ld [music_tempo], a
  ld a, 40 ;10 measures * 4 beats/measure
  ld [music_beats], a

  jp DoneLoadingSong