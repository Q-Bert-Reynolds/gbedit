
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
  call ShowItems
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
    call ShowItems
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

ShowItems::
  CLEAR_WIN_AREA 6,3,13,9,0
  ld a, [_s]
  and a
  cp 1
  jr c, .numTooLow
  cp MAX_ITEMS
  jr nc, .numTooHigh
  jr .draw
.numTooLow
  ld a, 1
  ld [_s], a
  jr .draw
.numTooHigh
  ld a, MAX_ITEMS
  ld [_s], a
.draw
  ld de, $0603
  ld c, 4
.loop
    push bc;count
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

DrawItemListEntry::;a = num, de = xy
  push de;xy

  dec a
  ld hl, items
  ld b, 0
  ld c, a
  add hl, bc
  add hl, bc
  ld a, [hli];get item id
  dec a
  ld c, a

  ld hl, ItemNames 
  call str_FromArray

  ld de, str_buffer
  call str_Copy

  ld hl, str_buffer
  call str_Length

  ld h, e
  ld l, 1
  pop de;xy
  inc e
  ld bc, str_buffer
  ld a, DRAW_FLAGS_WIN | DRAW_FLAGS_PAD_TOP
  call SetTiles
  ret

UseSelectedItem::
  ld a, -1
  ret