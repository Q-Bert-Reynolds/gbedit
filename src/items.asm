
INCLUDE "data/item_data.asm"
INCLUDE "data/item_strings.asm"

SECTION "Item Bank 0", ROM0
ShowItemListFromWorld::
  ld a, ITEM_BANK
  call SetBank

  call ShowItemList

  ld a, OVERWORLD_BANK
  call SetBank
  ret

SECTION "Item Bank X", ROMX, BANK[ITEM_BANK]
ShowItemList::
  ld bc, $0402
  ld de, $100B
  ld a, DRAW_FLAGS_WIN | DRAW_FLAGS_PAD_TOP
  call DrawUIBox
  HIDE_SPRITES

  xor a
  ld [_j], a
  ld a, 1
  ld [_s], a
  ld a, 3
  ld [_c], a
  ld de, $0503
  ld a, DRAW_FLAGS_WIN | DRAW_FLAGS_PAD_TOP
  call DrawListMenuArrow
  call DrawItems
  WAITPAD_UP_OR_FRAMES 20
.loop
    call UpdateInput
    ld de, $0503
    ld a, [_j]
    ld c, a
    push bc;old _j in c
    ld a, DRAW_FLAGS_WIN | DRAW_FLAGS_PAD_TOP
    call MoveListMenuArrow
    pop bc;old _j in c
    ld b, a;store dir
    ld a, [_j]
    sub a, c;change in _j
    cp b;check if change is same as expected
    jr z, .checkA
.scrollItems
    ld a, [_s]
    add a, b
    ld [_s], a
    call DrawItems
.checkA
    ld a, [button_state]
    and a, PADF_A
    jr z, .checkB
    call UseSelectedItem
    cp a, -1
    jr z, .exit
.checkB
    ld b, 0
    ld a, [button_state]
    and a, PADF_B
    jr nz, .exit
    call gbdk_WaitVBL
    jp .loop
.exit
  SHOW_SPRITES
  ret

DrawItems::
  CLEAR_WIN_AREA 6,3,13,9,0
  call GetItemListLength;list len in b
  ld a, [_s]
  and a
  cp 1
  jr c, .numTooLow
  cp b
  jr nc, .numTooHigh
  jr .draw
.numTooLow
  ld a, 1
  ld [_s], a
  jr .draw
.numTooHigh
  ld a, b
  ld [_s], a
.draw
  ld de, $0603
  ld c, 4
.loop
    push bc;list len, draw count
    push af;num
    push de;xy
    call DrawItemListEntry
    pop de;xy
    inc e
    inc e;y+=2
    pop af;num
    inc a;num++
    pop bc;count
    dec c
    jr nz, .loop
  ret

GetItemListLength::;puts item list len in b
  ld b, 0
  ld hl, items
.loop
    inc b
    ld a, [hli]
    inc hl
    and a
    ret z
    jr .loop

DrawItemListEntry::;a = num, de = xy, bc = list len, draw count
  inc e;y++
  push de;xy
  cp a, b;is num last?
  jr c, .drawItem
  jr z, .drawCancel
  pop de;xy
  ret
.drawCancel
  ld hl, CancelString
  jr .draw

.drawItem
  dec a
  ld hl, items
  ld b, 0
  ld c, a
  add hl, bc
  add hl, bc
  ld a, [hli];get item id
  dec a
  ld c, a
  ld a, [hl];get item count
  and a
  jr z, .getItemName

.drawItemCount
  ld h, 0
  ld l, a;item count
  push bc;item index
  push de;xy
  ld de, name_buffer
  call str_Number

  ld hl, name_buffer
  call str_Length

  ld h, e
  ld l, 1
  pop de;xy
  inc e
  push de;xy
  ld a, 17
  sub a, h
  ld d, a
  ld bc, name_buffer
  ld a, DRAW_FLAGS_WIN | DRAW_FLAGS_PAD_TOP
  call SetTiles

  pop de
  ld d, 14
  ld bc, name_buffer
  ld a, "x"
  ld [bc], a
  ld hl, $0101
  ld a, DRAW_FLAGS_WIN | DRAW_FLAGS_PAD_TOP
  call SetTiles

  pop bc;item index

.getItemName
  ld hl, ItemNames 
  call str_FromArray;item index in bc

.draw
  ld de, str_buffer
  call str_Copy

  ld hl, str_buffer
  call str_Length

  ld h, e
  ld l, 1
  pop de;xy
  ld bc, str_buffer
  ld a, DRAW_FLAGS_WIN | DRAW_FLAGS_PAD_TOP
  call SetTiles
  ret

UseSelectedItem::
  ld a, -1
  ret