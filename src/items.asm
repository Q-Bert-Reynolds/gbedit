
INCLUDE "data/item_data.asm"
INCLUDE "data/item_strings.asm"

SECTION "Item Bank 0", ROM0
ShowItemListFromWorld::
  ld a, ITEM_BANK
  call SetBank

  ld a, DRAW_FLAGS_WIN | DRAW_FLAGS_PAD_TOP
  call ShowItemList

  ld a, OVERWORLD_BANK
  call SetBank
  ret

SECTION "Item Bank X", ROMX, BANK[ITEM_BANK]
ShowItemList::; a = draw flags
  push af;draw flags
  ld bc, $0402
  ld de, $100B
  call DrawUIBox
  HIDE_SPRITES

  xor a
  ld [_s], a
  ld [_j], a
  ld a, 3
  ld [_c], a
  pop af;draw flags
  push af;draw flags
  ld de, $0503
  call DrawListMenuArrow
  WAITPAD_UP_OR_FRAMES 20
.loop
    call UpdateInput
    ld de, $0503
    ld a, [_j]
    ld c, a
    pop af;draw flags
    push af;draw flags
    push bc;old _j in c
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
  pop af;draw flags
  SHOW_SPRITES
  ret

ShowItems::
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

DrawItemListEntry

UseSelectedItem::
  ld a, -1
  ret