INCLUDE "src/beisbol.inc"
INCLUDE "src/ui.asm"
INCLUDE "src/start.asm"
INCLUDE "src/title.asm"

SECTION "Gloval Vars", WRAM0
rLCDInterrupt: DW
last_button_state: DB
button_state: DB
_a: DB
_b: DB
_c: DB
_d: DB
_i: DB
_j: DB
_k: DB
_l: DB
_w: DW
_x: DW
_y: DW
_z: DW
tmp: DB
tile_buffer: DS 512
str_buff: DS 64
name_buff: DS 16

SECTION "Header", ROM0[$100]
Entry:
  nop
  jp Main
  NINTENDO_LOGO
IF DEF(_HOME)
  DB "BEISBOL HOME",0,0,0  ;Cart name - 15bytes
ELSE
  DB "BEISBOL AWAY",0,0,0  ;Cart name - 15bytes
ENDC
  DB 0                     ;$143
  DB 0,0                   ;$144 - Licensee code (not important)
  DB 0                     ;$146 - SGB Support indicator
  DB CART_ROM_MBC5_RAM_BAT ;$147 - Cart type
  DB CART_ROM_2M           ;$148 - ROM Size
  DB CART_RAM_256K         ;$149 - RAM Size
  DB 1                     ;$14a - Destination code
  DB $33                   ;$14b - Old licensee code
  DB 0                     ;$14c - Mask ROM version
  DB 0                     ;$14d - Complement check (important)
  DW 0                     ;$14e - Checksum (not important)

SECTION "VBlank", ROM0[$0040]
  reti
SECTION "LCDC", ROM0[$0048]
  call LCDInterrupt
SECTION "TimerOverflow", ROM0[$0050]
  reti
SECTION "Serial", ROM0[$0058]
  reti
SECTION "p1thru4", ROM0[$0060]
  reti

SECTION "Main", ROM0
Main::
.setup
  di
  ld sp, $ffff
  DISPLAY_OFF
  CGB_COMPATIBILITY
  call gbdk_CPUFast
  DISABLE_LCD_INTERRUPT
  
.setupAudio
  ld hl, rAUDENA
  ld [hl], AUDENA_ON
  xor a
  ld [rAUDTERM], a
  ld hl, rAUDVOL
  ld [hl], $FF
  
.setupDrawing
  SPRITES_8x8
  ld hl, rBGP
  ld [hl], BG_PALETTE
  ld hl, rOBP0
  ld [hl], SPR_PALETTE_0
  ld hl, rOBP1
  ld [hl], SPR_PALETTE_1
  SHOW_SPRITES
  SHOW_BKG
  
.start ;show intro credits, batting animation
  SWITCH_RAM_MBC5 0
  SWITCH_ROM_MBC5 START_BANK
  call Start
.title ;show title drop, version slide, cycle of players, new game/continue screen
  SWITCH_ROM_MBC5 TITLE_BANK
  call Title ;should set a to 0 if new game pressed
  jr nz, .startGame
.newGame
  SWITCH_ROM_MBC5 NEW_GAME_BANK
  ; call NewGame
.startGame
  SWITCH_ROM_MBC5 PLAY_BALL_BANK
  ; call StartGame
  SWITCH_ROM_MBC5 0
  jp Main ;restart the game

LCDInterrupt::
  ld hl, rLCDInterrupt
  ld a, [hli]
  ld b, a
  ld a, [hl]
  ld h, b
  ld l, a
  jp hl
NoInterrupt::
  reti

UpdateInput::
  push hl

  ;copy button_state to last_button_state
  ld hl, button_state
  ld a, [hl]
  ld hl, last_button_state
  ld [hl], a

  ;read DPad
  ld hl, rP1
  ld a, P1F_5
  ld [hl], a ;switch to P15
  ld a, [hl] ;load DPad
  and %00001111 ;discard upper nibble
  swap a ;move low nibble to high nibble
  ld b, a ;store DPad in b

  ;read A,B,Select,Start
  ld hl, rP1
  ld a, P1F_4
  ld [hl], a ;switch to P14
  ld a, [hl] ;load buttons
  and %00001111 ;discard upper nibble
  or b ;combine DPad with other buttons
  cpl ;flip bits so 1 means pressed
  ld hl, button_state
  ld [hl], a

  pop hl
  ret

LoadFontTiles::
  PUSH_BANK
  SWITCH_ROM_MBC5 UI_BANK
  call UILoadFontTiles
  POP_BANK
  ret

RevealText:: ;hl = text
  ld de, str_buff
  call str_Copy
  PUSH_BANK
  SWITCH_ROM_MBC5 UI_BANK
  ld hl, str_buff
  call UIRevealText
  POP_BANK
  ret

DrawUIBox: ;Entry: de = wh, Affects: hl
  ld hl, tile_buffer
  xor a
  ld [_j], a
.rowLoop ;for (j = 0; j < h; ++j) {
  xor a
  ld [_i], a
.columnLoop ;for (i = 0; i < w; ++i) {
.testTop ;if (j == 0) {
  ld a, [_j] 
  and a
  jr nz, .testBottom
.testUpperLeft ;if (i == 0) k = BOX_UPPER_LEFT;
  ld a, [_i]
  and a
  jr nz, .testUpperRight
  ld a, BOX_UPPER_LEFT
  jp .setTile
.testUpperRight ;else if (i == w-1) k = BOX_UPPER_RIGHT;
  ld a, [_i]
  sub a, d
  inc a
  jr nz, .setHorizontal
  ld a, BOX_UPPER_RIGHT
  jp .setTile
.testBottom ;else if (j == h-1) {
  ld a, [_j] 
  sub e
  inc a
  jr nz, .testSides
.testLowerLeft ;if (i == 0) k = BOX_LOWER_LEFT;
  ld a, [_i]
  and a
  jr nz, .testLowerRight
  ld a, BOX_LOWER_LEFT
  jp .setTile
.testLowerRight ;else if (i == w-1) k = BOX_LOWER_RIGHT;
  ld a, [_i]
  sub a, d
  inc a
  jr nz, .setHorizontal
  ld a, BOX_LOWER_RIGHT
  jp .setTile
.testSides ;else if (i == 0 || i == w-1) k = BOX_VERTICAL;
  ld a, [_i]
  and a
  jr z, .setVertical
  sub d
  inc a
  jr z, .setVertical
.setNone
  xor a
  jr .setTile
.setVertical
  ld a, BOX_VERTICAL
  jr .setTile
.setHorizontal
  ld a, BOX_HORIZONTAL
.setTile
  ld [hli], a ;tiles[j*w+i] = k;

  ld a, [_i]
  inc a
  ld [_i], a
  sub a, h
  jr nz, .columnLoop

  ld a, [_j]
  inc a
  ld [_j], a
  sub a, l
  jr nz, .rowLoop
  ret

DrawBKGUIBox:: ; bc = xy, de = wh
  push bc ;xy
  push de ;wh
  call DrawUIBox
  pop hl ;wh
  pop de ;xy
  ld bc, tile_buffer
  call gbdk_SetBKGTiles
  ret

DrawWinUIBox:: ; bc = xy, de = wh
  push bc ;xy
  push de ;wh
  call DrawUIBox
  pop hl ;wh
  pop de ;xy
  ld bc, tile_buffer
  call gbdk_SetWinTiles
  ret

DisplayText:: ;hl = text
  push hl
  xor a ; draw_win_ui_box(0,0,20,6);
  ld b, a
  ld c, a
  ld a, 20
  ld d, a
  ld a, 6
  ld e, a
  call DrawWinUIBox
  pop hl
  push hl
  call str_Length
  ld a, e ; assumes that de is less than a byte
  ld [_l], a ; l = strlen(text);
  pop hl
  xor a
  ld [_w], a
  ld [_y], a
  ld [_i], a
.loopString; for (i = 0; i < l; ++i) {
  push hl
  xor a
  ld b, a
  ld a, [_i]
  ld c, a
  add hl, bc
  ld a, [hl]
  sub a, "\n"
  jr nz, .skip ;if (text[i] == '\n') {
  pop hl
  push hl
  xor a
  ld b, a
  ld a, [_w]
  ld c, a
  add hl, bc ;text+w
  ld de, str_buff
  ld a, [_i]
  sub a, c
  ld c, a ;i-w
  call mem_Copy ;memcpy(str_buff,text+w,i-w);
  ld a, 1
  ld d, a ;x
  ld l, a ;height
  ld a, [_y]
  add a ;*2
  add a, 2 ;2+y*2
  ld e, a ;y
  ld h, c ;i-w still in c
  ld bc, str_buff
  call gbdk_SetWinTiles ;set_win_tiles(1, 2+y*2, i-w, 1, str_buff);
  ld a, [_y]
  inc a
  ld [_y], a ;++y
  ld a, [_i]
  inc a
  ld [_w], a ;w = i+1;
.skip
  pop hl
  push hl
  ld a, [_i]
  inc a
  ld [_i], a
  ld b, a
  ld a, [_l]
  sub a, b
  jr nz, .loopString
  pop hl
  xor a
  ld b, a
  ld a, [_w]
  ld c, a
  add hl, bc ;text+w
  ld de, str_buff
  ld a, [_i]
  sub a, c
  ld c, a ;i-w
  call mem_Copy ; memcpy(str_buff,text+w,i-w);
  ld a, 1
  ld d, a ;x
  ld l, a ;height
  ld a, [_y]
  add a ;*2
  add a, 2 ;2+y*2
  ld e, a ;y
  ld h, c ;i-w still in c
  ld bc, str_buff
  call gbdk_SetWinTiles ;set_win_tiles(1, 2+y*2, i-w, 1, str_buff);
  ld a, 96
  ld hl, rWY
  ld [hli], a
  ld a, 7
  ld [hl], a ; move_win(7,96);
  SHOW_WIN
  ret

ShowListMenu:: ; bc = xy, de = wh, hl = text, title = sp
; strcpy(str_buff, text);
; strcpy(name_buff, title);
  PUSH_BANK
  SWITCH_ROM_MBC5 UI_BANK
  call UIShowListMenu ;a = ui_show_list_menu(x,y,w,h,name_buff,str_buff);
  POP_BANK
; return a;
  ret

ShowTextEntry:: ;bc = title, de = str, l = max_len
; strcpy(str_buff, title);
; strcpy(name_buff, str);
  PUSH_BANK
  SWITCH_ROM_MBC5 UI_BANK
  call UIShowTextEntry ;ui_show_text_entry(str_buff, name_buff, max_len);
  POP_BANK
; strcpy(title, str_buff);
; strcpy(str, name_buff);
  ret

ShowOptions::
  PUSH_BANK
  SWITCH_ROM_MBC5 UI_BANK
  call UIShowOptions
  POP_BANK
  ret

;; moves a grid of sprite tiles
MoveSprites:: ;bc = xy in screen space, hl = wh in tiles, a = first sprite index
  ld [_a], a
  xor a
  ld [_j], a
.rowLoop ;for (j = 0; j < h; j++)
  xor a
  ld [_i], a
.columnLoop ;for (i = 0; i < w; i++)
  ld a, [_i]
  add a ;i*2
  add a ;i*4
  add a ;i*8
  add a, b ;i*8+x
  ld d, a

  ld a, [_j]
  add a; j*2
  add a; j*4
  add a; j*8
  add a, c ;j*8+y
  ld e, a

  push bc
  ld a, [_a]
  ld c, a
  inc a
  ld [_a], a

  push hl
  call gbdk_MoveSprite;move_sprite(a++, i*8+x, j*8+y);
  pop hl
  pop bc

  ld a, [_i]
  inc a
  ld [_i], a
  sub a, h
  jr nz, .columnLoop

  ld a, [_j]
  inc a
  ld [_j], a
  sub a, l
  jr nz, .rowLoop

  ret