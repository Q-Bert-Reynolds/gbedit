INCLUDE "src/beisbol.inc"
INCLUDE "src/gbt_player/gbt_player.inc"

IF !DEF(AUDIO_ASM)
AUDIO_ASM SET 1

INCLUDE "src/gbt_player/gbt_player.asm"
INCLUDE "src/gbt_player/gbt_player_bank1.asm"

PLAY_SONG: MACRO ;\1 load address
  di
  ld a, BANK(\1)
  ld hl, \1
  call PlaySong
  ei
ENDM

INCLUDE "music/intro_lights.asm"
INCLUDE "music/charge_fanfare.asm"
INCLUDE "music/take_me_out_to_the_ballgame.asm"
INCLUDE "music/hurrah_for_our_national_game.asm"
INCLUDE "music/tessie.asm"

SECTION "Audio", ROM0
UpdateAudio::
  ld a, [loaded_bank]
  ld [vblank_bank], a
  
  call gbt_update
  
  ld a, [vblank_bank]
  call SetBank
  ret

PlaySong:: ; a = bank, hl = song address
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
