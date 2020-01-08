INCLUDE "src/beisbol.inc"

SECTION "UI", ROMX, BANK[UI_BANK]
INCLUDE "img/ui_font.asm"

UILoadFontTiles::
  ld hl, _UiFontTiles
  ld de, _VRAM+$1000
  ld bc, _UI_FONT_TILE_COUNT*16
  call mem_CopyVRAM ;doesn't loop so mem_CopyToTileData is unnecessary
  ret

FlashNextArrow: ;de = xy
;     while (1) {
;         tiles[0] = ARROW_DOWN;
;         set_win_tiles(x, y, 1, 1, tiles);
;         update_waitpadup();
;         for (a = 0; a < 20; ++a) {
;             if (joypad() & J_A) return;
;             update_delay(10);
;         tiles[0] = 0;
;         set_win_tiles(x, y, 1, 1, tiles);
;         for (a = 0; a < 20; ++a) {
;             if (joypad() & J_A) return;
;             update_delay(10);
  ret

UIRevealText:: ; hl = text
; draw_win_ui_box(0,0,20,6);
; move_win(7,96);
; SHOW_WIN;
; x = 0;
; y = 0;
; l = strlen(text);
; w = 0;
; for (i = 0; i < l; ++i) {
;   if (text[i] == '\n') {
;     ++y;
;     memcpy(str_buff,"                 ",17);
;     memcpy(str_buff,text+w,i-w);
;     if (y == 2) {
;       y = 1;
;       flash_next_arrow(18,4);
;       set_win_tiles(1, 2, 17, 1, str_buff);
;       set_win_tiles(1, 4, 17, 1, "                 ");
;     x = 0;
;     w = i+1;
;   else {
;     set_win_tiles(x+1,y*2+2,1,1,text+i);
;     x++;
;   update_delay(10);
; flash_next_arrow(18,4);
  ret

MoveOptionsArrow: ; e = y
; tiles[0] = 0;
; tiles[1] = ARROW_RIGHT;
; tiles[2] = ARROW_RIGHT_BLANK;
; set_bkg_tiles(1,3,1,1,tiles + (a==0 ? 2 : 0) - (y==0 ? 1 : 0));
; set_bkg_tiles(7,3,1,1,tiles + (a==1 ? 2 : 0) - (y==0 ? 1 : 0));
; set_bkg_tiles(14,3,1,1,tiles + (a==2 ? 2 : 0) - (y==0 ? 1 : 0));
; set_bkg_tiles(1,8,1,1,tiles + (b==0 ? 2 : 0) - (y==1 ? 1 : 0));
; set_bkg_tiles(10,8,1,1,tiles + (b==1 ? 2 : 0) - (y==1 ? 1 : 0));
; set_bkg_tiles(1,13,1,1,tiles + (c==0 ? 2 : 0) - (y==2 ? 1 : 0));
; set_bkg_tiles(10,13,1,1,tiles + (c==1 ? 2 : 0) - (y==2 ? 1 : 0));
; set_bkg_tiles(1,16,1,1,tiles + (y==3 ? 1 : 2));
  ret

UIShowOptions::
; DISPLAY_OFF;
; disable_interrupts();
; ENABLE_RAM_MBC5;
; a = text_speed;
; b = animation_style;
; c = coaching_style;
; DISABLE_RAM_MBC5;
; enable_interrupts();
; if (a > 2) a = 0;
; if (b > 1) b = 0;
; if (c > 1) c = 0;
  call DrawBKGUIBox; bc = xy, de = wh ; draw_bkg_ui_box(0,0,20,5);
; set_bkg_tiles(1,1,18,3,
;   "TEXT SPEED        "
;   "                  "
;   " FAST  MEDIUM SLOW"
  call DrawBKGUIBox; bc = xy, de = wh ; draw_bkg_ui_box(0,5,20,5);
; set_bkg_tiles(1,6,18,3,
;   "AT-BAT ANIMATIONS "
;   "                  "
;   " ON       OFF     "
  call DrawBKGUIBox; bc = xy, de = wh ; draw_bkg_ui_box(0,10,20,5);
; set_bkg_tiles(1,11,18,3,
;   "COACHING STYLE    "
;   "                  "
;   " SHIFT    SET     "
; set_bkg_tiles(2,16,6,1,
;   "CANCEL"
; DISPLAY_ON;
; update_waitpadup();
; y = 0;
; move_options_arrow(y);
; while (1) {
;   k = joypad();
;   if (k & J_UP && y > 0) {
;     update_vbl(); 
;     move_options_arrow(--y);
;     update_waitpadup();
;   else if (k & J_DOWN && y < 3) {
;     update_vbl(); 
;     move_options_arrow(++y);
;     update_waitpadup();
;   else if (k & J_LEFT && y < 3) {
;     update_vbl(); 
;     if (y == 0 && a > 0) --a;
;     else if (y == 1 && b > 0) --b;
;     else if (y == 2 && c > 0) --c;
;     move_options_arrow(y);
;     update_waitpadup();
;   else if (k & J_RIGHT && y < 3) {
;     update_vbl(); 
;     if (y == 0 && a < 2) ++a;
;     else if (y == 1 && b < 1) ++b;
;     else if (y == 2 && c < 1) ++c;
;     move_options_arrow(y);
;     update_waitpadup();
;   if (k & (J_START | J_A) && y == 3) break;
;   else if (k & J_B) break;
;   update_vbl(); 
; disable_interrupts();
; ENABLE_RAM_MBC5;
; text_speed = a;
; animation_style = b;
; coaching_style = c;
; DISABLE_RAM_MBC5;
; enable_interrupts();

MoveTextEntryArrow: ; bc = from xy, de = to xy
; update_vbl();
; tiles[0] = 0;
; if (from_y == 5) {
;   set_win_tiles(1,15,1,1,tiles);
; else {
;   set_win_tiles(from_x*2+1,from_y*2+5,1,1,tiles);
; tiles[0] = ARROW_RIGHT;
; if (to_y == 5) {
;   set_win_tiles(1,15,1,1,tiles);
; else {
;   set_win_tiles(to_x*2+1,to_y*2+5,1,1,tiles);
; update_waitpadup();

UpdateTextEntryDisplay: ; hl = str, d = max_len
; w = strlen(str);
; for (i = 0; i < max_len; ++i) {
;   tiles[i] = ' ';
;   if (i != w) tiles[i+max_len] = '-';
;   else tiles[i+max_len] = '^';
; set_win_tiles(10,2,max_len,2,tiles);
; if (w > 0) set_win_tiles(10,2,w,1,str);

LowerCase:
  db "abcdefghijklmnopqrstuvwxyz *():;[]#%-?!*+/.,é"
UpperCase:
  db "ABCDEFGHIJKLMNOPQRSTUVWXYZ *():;[]#%-?!*+/.,é"
UIShowTextEntry:: ; de = title, hl = str, c = max_len
; DISPLAY_OFF;
; for (i = 0; i != max_len; ++i) str[i] = 0;
; CLEAR_WIN_AREA(0,0,20,4,' ');
; move_win(7,0);
; l = strlen(title);
; if (l > 0) set_win_tiles(0,1,l,1,title);
; update_text_entry_display(str, max_len);
; draw_win_ui_box(0,4,20,11);
; DISPLAY_ON;
; x = 0;
; y = 0;
; c = 0;
; l = 0;
; while (1) {
;   if (c == 0) {
;     memcpy(str_buff, upper_case, 46);
;     set_win_tiles(2,15,10,1,"lower case");
;   else {
;     memcpy(str_buff, lower_case, 46);
;     set_win_tiles(2,15,10,1,"UPPER CASE");

;   for (j = 0; j < 5; ++j) {
;     for (i = 0; i < 9; ++i) {
;       tiles[j*2*18+i*2]   = (x==i && y==j) ? ARROW_RIGHT : 0;
;       tiles[j*2*18+i*2+1] = str_buff[j*9+i];
;     for (i = 0; i < 9; ++i) {
;       tiles[(j*2+1)*18+i*2]   = 0;
;       tiles[(j*2+1)*18+i*2+1] = 0;
;   set_win_tiles(1,5,18,9,tiles);
;   update_waitpadup();
;   while (1) {
;     k = joypad();
;     if (k & J_UP && y > 0) {
;       move_text_entry_arrow(x,y,x,y-1);
;       --y;
;     else if (k & J_DOWN && y < 5) {
;       move_text_entry_arrow(x,y,x,y+1);
;       ++y;
;     else if (k & J_LEFT && x > 0 && y < 5) {
;       move_text_entry_arrow(x,y,x-1,y);
;       --x;
;     else if (k & J_RIGHT && x < 8 && y < 5) {
;       move_text_entry_arrow(x,y,x+1,y);
;       ++x;

;     if (k & (J_START | J_A)) {
;       if (y == 5) {
;         c = 1-c;
;         break;
;       else if (str_buff[y*9+x] == '\x1E') {
;         if (l > 0) return;
;       else if (l < max_len) {
;         str[l++] = str_buff[y*9+x];
;         set_win_tiles(10,3,max_len,1,str);
;         update_text_entry_display(str, max_len);
;         update_waitpadup();
;     else if (k & J_B && l > 0) {
;       str[--l] = '\0';
;       update_text_entry_display(str, max_len);
;       update_waitpadup();
;     update_vbl(); 
  ret

MoveMenuArrow: ; e = y
; for (i = 0; i < c; ++i) {
;   tiles[i*2] = 0;
;   if (i == y) tiles[i*2+1] = ARROW_RIGHT;
;   else tiles[i*2+1] = 0;
; set_bkg_tiles(1,1,1,c*2,tiles);
  ret

UIShowListMenu::  ; bc = xy, de = wh, hl = text, title = sp
  push bc
  push de
  call DrawBKGUIBox; draw_bkg_ui_box(x,y,w,h);
  pop de
  pop bc

  xor a
  ld [_l], a
  ld [_c], a
  ld a, c
  add a, 2
  ld [_j], a ;j = y+2;
.placeCharactersLoop ;while (1) {
  ld a, "\n"
  cp a, [hl] ;if (text[k] == '\n') {
  jr nz, .testEndOfString

  push bc
  push de
  push hl
  ld a, b
  add a, 2
  ld d, a ; x
  ld a, [_j]
  ld e, a ; y
  ld a, [_l]
  ld h, a ; w
  ld a, 1
  ld l, a ; h
  ld bc, tile_buffer
  call gbdk_SetBKGTiles ;set_bkg_tiles(x+2,j,l,1,tiles);
  pop hl
  pop de
  pop bc

  xor a
  ld [_l], a
  ld a, [_j]
  add a, 2
  ld [_j], a
  ld a, [_c]
  inc a
  ld [_c], a
  jr .nextChar
.testEndOfString
  xor a
  cp a, [hl] ;else if (text[k] == '\0') {
  jr nz, .setChar

  push bc
  push de
  push hl
  ld a, b
  add a, 2
  ld d, a ; x
  ld a, [_j]
  ld e, a ; y
  ld a, [_l]
  ld h, a ; w
  ld a, 1
  ld l, a ; h
  ld bc, tile_buffer
  call gbdk_SetBKGTiles ;set_bkg_tiles(x+2,j,l,1,tiles);
  pop hl
  pop de
  pop bc

  ld a, [_c]
  inc a
  ld [_c], a ;++c;
  jr .exitLoop ;break;
.setChar;   else {
  push bc
  push de
  push hl
  ld a, [hl];text[k]
  ld d, a
  ld hl, tile_buffer
  xor a
  ld b, a
  ld a, [_l]
  ld c, a
  add hl, bc ;tiles[l]
  ld [hl], d ;tiles[l] = text[k];
  inc c
  ld a, c
  ld [_l], a;++l;
  pop hl
  pop de
  pop bc
.nextChar
  inc hl
  jr .placeCharactersLoop
.exitLoop

  pop hl ;title
; tiles[0] = ARROW_RIGHT;
; set_bkg_tiles(x+1,y+2,1,1,tiles);
  ; l = strlen(title);
; if (l > 0) {
;   i = (w-l)/2;
;   set_bkg_tiles(x+i,y,l,1,title);
; update_waitpadup();
; j = 0;
; while (1) {
;   k = joypad();
;   if (k & J_UP && j > 0) {
;     update_vbl(); 
;     move_menu_arrow(--j);
;     update_waitpadup();
;   else if (k & J_DOWN && j < c-1) {
;     update_vbl(); 
;     move_menu_arrow(++j);
;     update_waitpadup();
;   if (k & (J_START | J_A)) return j+1;
;   else if (k & J_B) return 0;
;   update_vbl(); 
; return 0;
  ret