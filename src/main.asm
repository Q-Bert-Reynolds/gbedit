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
  di
  ld sp, $ffff
  DISPLAY_OFF
  CGB_COMPATIBILITY
  call gbdk_CPUFast
  DISABLE_LCD_INTERRUPT

  ; audio  
  ld hl, rAUDENA
  ld [hl], AUDENA_ON
  xor a
  ld [rAUDTERM], a
  ld hl, rAUDVOL
  ld [hl], $FF
  
  ; drawing
  SPRITES_8x8
  ld hl, rBGP
  ld [hl], BG_PALETTE
  ld hl, rOBP0
  ld [hl], SPR_PALETTE_0
  ld hl, rOBP1
  ld [hl], SPR_PALETTE_1
  
  SHOW_SPRITES
  SHOW_BKG
  
  SWITCH_RAM_MBC5 0
  SWITCH_ROM_MBC5 START_BANK
  call Start

  SWITCH_ROM_MBC5 TITLE_BANK
  call Title
  ; if (!title()) {
  ;     SWITCH_ROM_MBC5 NEW_GAME_BANK
  ;     new_game();
  ; }

  ; SWITCH_ROM_MBC5 PLAY_BALL_BANK
  ; start_game();

  SWITCH_ROM_MBC5 0
  jp Main

UpdateInput::
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
  ret

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

LoadFontTiles::
  PUSH_BANK
  SWITCH_ROM_MBC5 UI_BANK
  call UILoadFontTiles
  POP_BANK
  ret

RevealText:: ;hl = text
  ld de, str_buff
  call mem_CopyString
  PUSH_BANK
  SWITCH_ROM_MBC5 UI_BANK
  ld hl, str_buff
  call UIRevealText
  POP_BANK
  ret

DrawUIBox: ;de = wh
; for (j = 0; j < h; ++j) {
;   for (i = 0; i < w; ++i) {
;     k = 0;
;     if (j == 0) {
;       if (i == 0) k = BOX_UPPER_LEFT;
;       else if (i == w-1) k = BOX_UPPER_RIGHT;
;       else k = BOX_HORIZONTAL;
;     else if (j == h-1) {
;       if (i == 0) k = BOX_LOWER_LEFT;
;       else if (i == w-1) k = BOX_LOWER_RIGHT;
;       else k = BOX_HORIZONTAL;
;     else if (i == 0 || i == w-1) k = BOX_VERTICAL;
;     tiles[j*w+i] = k;
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
; draw_win_ui_box(0,0,20,6);
; l = strlen(text);
; w = 0;
; y = 0;
; for (i = 0; i < l; ++i) {
;   if (text[i] == '\n') {
;     memcpy(str_buff,text+w,i-w);
;     set_win_tiles(1, 2+y*2, i-w, 1, str_buff);
;     ++y;
;     w = i+1;
; memcpy(str_buff,text+w,i-w);
; set_win_tiles(1, 2+y*2, i-w, 1, str_buff);
; move_win(7,96);
; SHOW_WIN;
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

MoveSprites:: ;bc = xy, hl = wh, a = offset
  ld [_a], a
  xor a
  ld [_j], a
.loopRows\@ ;for (j = 0; j < h; j++)
  xor a
  ld [_i], a
.loopColumns\@ ;for (i = 0; i < w; i++)
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
  jr nz, .loopColumns\@

  ld a, [_j]
  inc a
  ld [_j], a
  sub a, l
  jr nz, .loopRows\@

  ret