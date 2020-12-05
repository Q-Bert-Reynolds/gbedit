SECTION "Play Ball Intro", ROMX, BANK[PLAY_BALL_INTRO_BANK]

INCLUDE "src/baseball/scale_tile_data_2x.asm"
INCLUDE "img/coaches/calvin_back_2x.asm"
INCLUDE "src/baseball/interrupts.asm"

;strings
UnsignedPlayerAppearedText::  DB "Unsigned %s\nappeared!",0
TeamChallengeText::           DB " wants to \nplay %s innings.",0
PlayBallText::                DB "Play ball!",0

ShowPlayBallWindow:
  ld bc, 0
  ld d, 20
  ld e, 6
  ld a, DRAW_FLAGS_WIN
  call DrawUIBox

  ld a, 7
  ld [rWX], a
  ld a, 96
  ld [rWY], a
  SHOW_WIN
  ret 

SGBPlayBallIntroAttrBlk:
  ATTR_BLK 2
  ATTR_BLK_PACKET %001, 0,0,0, 0,12, 20,6 ;bottom UI
  ATTR_BLK_PACKET %001, 1,1,1, 0,0, 20,12 ;upper Dark

PlayBallIntro: ;[_a] = player num or coach id
  ld hl, SGBPlayBallIntroAttrBlk
  call sgb_PacketTransfer

  call LoadFontTiles
  call ShowPlayBallWindow

  ld a, 1
  ld hl, tile_buffer
  ld bc, 240
  call mem_Set

  ld d, 0
  ld e, 0
  ld h, 20
  ld l, 12
  ld bc, tile_buffer
  call GBCSetBkgPaletteMap

  ld de, $8800;_VRAM+$1000+_UI_FONT_TILE_COUNT*16
  ld bc, _CALVIN_BACK_2X_TILE_COUNT
  ld hl, _CalvinBack2xTiles
  call SetBkgDataDoubled

  ld a, [game_state]
  and a, GAME_STATE_UNSIGNED_PLAYER
  jr z, .loadOpposingCoach

.loadUnsignedPlayer
  ld a, [_a];player num
  ld de, _UI_FONT_TILE_COUNT+64
  call LoadPlayerBkgData
  jr .showCalvinHatSprites

.loadOpposingCoach
  ld a, COACH_NOLAN1 ;TODO: load opposing team coach
  ld de, $8800 + 64*16
  call LoadCoachTiles

.showCalvinHatSprites
  xor a
  ld [_j], a
  ld bc, 0
.rowLoop; for (j = 0; j < 3; ++j)
    xor a
    ld [_i], a
.columnLoop; for (i = 0; i < _CALVIN_BACK_2X_COLUMNS-1; ++i)

      ld de, _CALVIN_BACK_2X_COLUMNS-1
      ld a, [_j]
      call math_Multiply
      ld b, 0
      ld a, [_i]
      ld c, a
      add hl, bc;j*(_CALVIN_BACK_2X_COLUMNS-1)+i
      ld c, l

      ld d, 0
      ld a, [_j]
      ld e, a
      add hl, de;j*_CALVIN_BACK_2X_COLUMNS+i
      ld de, _CalvinBack2xTileMap
      add hl, de;_calvin_back_map[j*_CALVIN_BACK_2X_COLUMNS+i]
      ld a, [hl]
      add a, _UI_FONT_TILE_COUNT;_calvin_back_map[j*_CALVIN_BACK_2X_COLUMNS+i]+_UI_FONT_TILE_COUNT
      ld d, a
      ld e, c
      call gbdk_SetSpriteTile
      ld c, e
      ld d, 1;palette
      call gbdk_SetSpriteProp
      
      ld a, [_i]
      inc a
      ld [_i], a
      cp _CALVIN_BACK_2X_COLUMNS-1
      jr nz, .columnLoop

    ld a, [_j]
    inc a
    ld [_j], a
    cp 3
    jr nz, .rowLoop

  ld d, 1
  ld e, 16-_CALVIN_BACK_2X_ROWS
  ld h, _CALVIN_BACK_2X_COLUMNS
  ld l, _CALVIN_BACK_2X_ROWS-4
  ld bc, _CalvinBack2xTileMap + 3*_CALVIN_BACK_2X_COLUMNS
  ld a, _UI_FONT_TILE_COUNT
  call SetBkgTilesWithOffset

  ld a, [game_state]
  and a, GAME_STATE_UNSIGNED_PLAYER
  jr z, .showOpposingCoach

.showUnsignedPlayer
  ld a, [_a];player num
  push af;player num
  call GetPlayerImgColumns
  ld c, a

  ld a, 19
  sub a, c
  ld b, a;x
  ld a, 7
  sub a, c
  ld c, a;y
  ld de, _UI_FONT_TILE_COUNT+64
  
  pop af;player num
  call SetPlayerBkgTiles
  jr .setupSlideInLoop

.showOpposingCoach
  ld d, 12
  ld e, 0
  ld a, COACH_NOLAN1
  ld h, _UI_FONT_TILE_COUNT+64
  call SetCoachTiles

.setupSlideInLoop
  ld a, 160
  ld [rSCX], a
  xor a
  ld [rSCY], a
  ld [rVBK], a

  xor a
  ld [rLYC], a
  SET_LCD_INTERRUPT SlideInLCDInterrupt
  DISPLAY_ON

  ld a, 160
  ld [_x], a
.slideInLoop; for (x = 160; x >= 0; x-=2)
    call gbdk_WaitVBL
    ld a, [_x]
    sub a, 2
    ld [_x], a
    and a
    jr nz, .slideInLoop
  call gbdk_WaitVBL
  xor a
  ld [_x], a
  call gbdk_WaitVBL
  DISABLE_LCD_INTERRUPT

  TRAMPOLINE SetPlayerColors

  ld a, 2
  ld hl, tile_buffer
  ld bc, 56
  call mem_Set

  ld d, 0
  ld e, 5
  ld h, 8
  ld l, 7
  ld bc, tile_buffer
  call GBCSetBkgPaletteMap

  ld c, 21
.setCalvinSpriteColorsLoop
    dec c
    ld d, 2
    push bc
    call gbdk_SetSpriteProp
    pop bc
    xor a
    cp c
    jr nz, .setCalvinSpriteColorsLoop

  ld a, [game_state]
  and a, GAME_STATE_UNSIGNED_PLAYER
  jr z, .showTeamText

.showUnsignedText
  ld a, [_a];player num
  push af;num

  call LoadPlayerBaseData
  ld hl, player_base.sgb_pal
  ld a, [hli]
  ld e, a
  ld a, [hli]
  ld d, a
  ld bc, PaletteCalvin
  ld a, [sgb_Pal23]
  call SetPalettesDirect

  pop af;num
  call GetPlayerName
  ld hl, UnsignedPlayerAppearedText
  ld de, str_buffer
  ld bc, name_buffer
  call str_Replace
  jr .revealText

.showTeamText
  ld bc, PaletteCalvin
  ld de, PaletteNolan
  ld a, [sgb_Pal23]
  call SetPalettesDirect

  ld a, COACH_CALVIN;TODO: replace with actual opponent name
  call GetCoachesName;coach name in name_buffer
  ld hl, name_buffer
  ld de, str_buffer
  call str_Copy;coach name in str_buffer
  ld hl, TeamChallengeText
  ld de, str_buffer
  call str_Append;coach name + "wants to play %s innings." in str_buffer
  ld hl, 3
  ld de, name_buffer
  call str_Number;puts number of innings in name_buffer
  ld hl, str_buffer
  ld bc, name_buffer
  ld de, str_buffer
  call str_Replace

.revealText
  ld hl, str_buffer
  call RevealTextAndWait ;reveal_text(str_buff, PLAY_BALL_BANK);

  SET_LCD_INTERRUPT SlideOutLCDInterrupt

  xor a
  ld [_x], a
.slideOutLoop; for (x = 0; x > -80; x-=2)
    call gbdk_WaitVBL
    ld a, [_x]
    sub a, 2
    ld [_x], a
    cp -80
    jr nz, .slideOutLoop

  CLEAR_BKG_AREA 1, 16-_CALVIN_BACK_2X_ROWS, _CALVIN_BACK_2X_COLUMNS, _CALVIN_BACK_2X_ROWS-4, " "
  DISABLE_LCD_INTERRUPT

  HIDE_ALL_SPRITES
  call gbdk_WaitVBL
  xor a
  ld [rSCX], a
  ld [rSCY], a

  ld hl, PlayBallText
  call RevealTextAndWait
  HIDE_WIN
  ret
