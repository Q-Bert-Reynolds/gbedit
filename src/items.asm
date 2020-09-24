INCLUDE "src/beisbol.inc"

INCLUDE "data/item_data.asm"
INCLUDE "data/item_strings.asm"

SECTION "Item Bank 0", ROM0
ShowInventory::
  ld a, [game_state]
  and a, GAME_STATE_PLAY_BALL
  jr z, .show
    call CopyBkgToWin
    ld a, 7
    ld [rWX], a
    xor a
    ld [rWY], a
    SHOW_WIN

.show
  ld a, [loaded_bank]
  push af
  ld a, ITEM_BANK
  call SetBank
  call _ShowInventory

  ld a, [game_state]
  and a, GAME_STATE_PLAY_BALL
  jr z, .exit
    HIDE_WIN

.exit
  pop af
  call SetBank
  ret

GetInventoryItemID::; a = index of item in list, returns item id in a, item count in [hl]
  push bc
  ld hl, inventory
  ld b, 0
  ld c, a
  add hl, bc
  add hl, bc
  ld a, [hli];get item id
  pop bc
  ret 

GetItemData::;a = item id, returns [item data]
  push de
  push bc
  ld b, a;item id
  ld a, [loaded_bank]
  push af;bank
  ld a, ITEM_BANK
  call SetBank
  ld a, b;item id
  dec a
  ld hl, ItemList
  ld b, 0
  ld c, a
  add hl, bc
  add hl, bc
  ld a, [hli]
  ld b, a
  ld a, [hli]
  ld h, a
  ld l, b
  ld de, item_data
  ld bc, item_data.end - item_data
  call mem_Copy
  pop af;bank
  call SetBank
  pop bc
  pop de
  ret

GetItemName::;a = item id, returns item name in [name_buffer]
  dec a
  ld b, 0
  ld c, a

  ld a, [loaded_bank]
  push af;bank
  ld a, ITEM_BANK
  call SetBank

  ld hl, ItemNames
  call str_FromArray
  ld de, name_buffer
  call str_Copy

  pop af;bank
  call SetBank
  ret 

SECTION "Item Bank X", ROMX, BANK[ITEM_BANK]

UseTossText:               DB "USE\nTOSS",0
TooImportantText:          DB "That's too impor-\ntant to toss!",0
NoCyclingText:             DB "No cycling\nallowed here.",0
IsItOkToTossItemText:      DB "Is it OK to toss\n%s?",0
ThrewAwayItemText:         DB "Threw away\n%s.",0
NowIsNotTheTimeText:       DB "Doc: %s!\nThis isn't the\ntime to use that!",0
BootedUpTMText:            DB "Booted up a TM!",0
ItContainedMoveText:       DB "It contained\n%s!",0
TeachMoveText:             DB "Teach %s\nto a PLAYER?",0
WriteAnOfferToPlayerText:  DB "Write an offer\nto %s.",0
BaseOfferText:             DB "$000000/game"
OfferPlayerMoneyText:      DB "Offer %s\n$%s/game?",0
PlayerRejectsOfferText:    DB "%s is\nnot interested.",0
PlayerAcceptsOfferText:    DB "%s\naccepts!",0
GivePlayerANicknameText:   DB "Give %s\na nickname?",0


_ShowInventory:
  ld bc, $0402
  ld de, $100B
  ld a, DRAW_FLAGS_WIN | DRAW_FLAGS_PAD_TOP
  call DrawUIBox
  HIDE_SPRITES

  call GetInventoryLength;number of items in b
  ld a, b
  ld [_b], a;number of items
  xor a
  ld [_j], a;index
  ld a, 1
  ld [_s], a;current page
  ld a, 3
  ld [_c], a;number of places the list menu arrow can be
  ld de, $0503
  ld a, DRAW_FLAGS_WIN | DRAW_FLAGS_PAD_TOP
  call DrawListMenuArrow
  call DrawItems
  WAITPAD_UP_OR_FRAMES 20
.loop
    call gbdk_WaitVBL
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
    jr z, .flashDownArrow
.scrollItems
    ld a, [_s]
    add a, b
    ld [_s], a
    call DrawItems
.flashDownArrow
    ld a, [vbl_timer]
    cp a, 30
    ld a, 0
    jr c, .drawDown
.drawDownArrow
    ld a, ARROW_DOWN
.drawDown
    ld d, 18
    ld e, 11
    ld bc, name_buffer
    ld [bc], a
    ld hl, $0101
    ld a, DRAW_FLAGS_WIN | DRAW_FLAGS_PAD_TOP
    call SetTiles
.checkA
    ld a, [button_state]
    and a, PADF_A
    jr z, .checkB
    ld de, 0
    ld hl, $1412
    ld bc, bkg_buffer
    call gbdk_GetWinTiles

    call SelectItem
    cp a, -1
    jr z, .exit
    
    ld de, 0
    ld hl, $1412
    ld bc, bkg_buffer
    call gbdk_SetWinTiles
    call DrawItems
    WAITPAD_UP
    jp .loop
    
.checkB
    ld b, 0
    ld a, [button_state]
    and a, PADF_B
    jr nz, .exit
    jp .loop
.exit
  WAITPAD_UP
  ret

DrawItems::
  CLEAR_WIN_AREA 6,3,13,9,0
  ld a, [_b]
  ld b, a
  dec b
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
  ld a, [_s]
  dec a
  ld [_s], a
.draw
  inc b
  ld de, $0603
  ld c, 4
.loop
    push bc;list len, draw count
    push af;num
    push de;xy
    call DrawInventoryEntry
    pop de;xy
    inc e
    inc e;y+=2
    pop af;num
    inc a;num++
    pop bc;count
    dec c
    jr nz, .loop
  ret

GetInventoryLength::;puts item list len in b
  ld b, 0
  ld hl, inventory
.loop
    inc b
    ld a, [hli]
    inc hl
    and a
    ret z
    jr .loop

DrawInventoryEntry::;a = num, de = xy, bc = list len, draw count
  inc e;y++
  push de;xy
  cp a, b;is num last?
  jr c, .drawItem
  jr z, .drawCancel
  pop de;xy
  ret
.drawCancel
  ld hl, CancelString
  jp .draw

.drawItem
  dec a
  ld hl, inventory
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

  pop de;xy
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

SelectItem::;returns exit code in a (-1 = close inventory, 0 = back to inventory)
  PLAY_SFX SelectSound
  ld a, [_j];index
  ld b, a
  ld a, [_c];number of places the list menu arrow can be
  ld c, a
  push bc;index/places
  ld a, [_b];num items
  ld b, a
  ld a, [_s];page
  ld c, a
  push bc;num items,page
  ld a, [_j]
  add a, c
  cp a, b
  jr z, .closeInventory
.getItem
  dec a;index
  ld b, a;index
  call GetInventoryItemID;item id in a
.checkBike
  cp BICYCLE_ITEM
  jr nz, .notBike

  ;TODO: check if cycling allowed
  ld hl, NoCyclingText
  jr .displayText

.notBike
  push bc;index in b
  call GetItemData;returns [item_data]

  ld hl, UseTossText
  ld de, str_buffer
  call str_Copy
  xor a
  ld [name_buffer], a
  ld [list_selection], a
  ld a, DRAW_FLAGS_WIN
  ld b, 13
  ld c, 10
  ld d, 7
  ld e, 5
  call ShowListMenu
  pop bc;index in b
  and a
  jp z, .backToItemList
  cp a, 1
  jr z, .useItem
.tossItem
  ld a, [item_data.type]
  cp ITEM_TYPE_SPECIAL
  jr z, .tooImportant
  ld a, b;item index
  call TossItem
  jr .exit

.tooImportant
  ld hl, TooImportantText
  jr .displayText

.useItem
  ld a, b;item index
  call UseItem
  jr .exit
  
.displayText
  call RevealItemTextAndWait

.backToItemList
  ld a, 1
  jr .exit

.closeInventory
  ld a, -1

.exit;a = exit code (-1 = exit inventory, 0 = decrement item count)
  ld d, a;exit code
  pop bc;num items,page
  and a
  jr nz, .skip
  dec b
.skip
  ld a, b
  ld [_b], a;num items
  ld a, c
  ld [_s], a;page
  pop bc;index/places
  ld a, b
  ld [_j], a;index
  ld a, c
  ld [_c], a;number of places the list menu arrow can be
  ld a, d;exit code
  ret

IncDecDigit: ;a = dir
  push af;dir
  ld a, [_x]
  ld hl, str_buffer+1
  ld b, 0
  ld c, a
  add hl, bc
  ld a, [hl]
  ld b, a
  pop af;dir
  add a, b
  ld [hl], a
  cp a, "0"
  jr c, .under
  cp a, "9"+1
  jr z, .over
  ret
.under
  ld a, "9"
  ld [hl], a
  ret
.over
  ld a, "0"
  ld [hl], a
  ret

UpdateOffer:
  ld bc, $0607
  ld de, $0e05
  ld a, DRAW_FLAGS_WIN | DRAW_FLAGS_PAD_TOP
  call DrawUIBox

  ld de, $0709
  ld hl, $0c01
  ld bc, str_buffer
  call gbdk_SetWinTiles

  ld a, ARROW_UP
  ld [name_buffer], a
  ld a, [_x]
  add a, 8
  ld d, a
  ld e, 8
  ld bc, name_buffer
  ld hl, $0101
  call gbdk_SetWinTiles

  ld a, ARROW_DOWN
  ld [name_buffer], a
  ld a, [_x]
  add a, 8
  ld d, a
  ld e, 10
  ld bc, name_buffer
  ld hl, $0101
  call gbdk_SetWinTiles

  ret

TensTable:
  D24 100000
  D24 10000
  D24 1000
  D24 100
  D24 10
  D24 1 

GetPowerOfTen:; digit in a, returns 10^(5-a) in bcd, won't change ehl
  push hl
  push de
  ld hl, TensTable
  ld b, 0
  ld c, a
  add a, a
  add a, c
  ld c, a
  add hl, bc
  ld a, [hli]
  ld b, a
  ld a, [hli]
  ld c, a
  pop de
  ld a, [hl]
  ld d, a
  pop hl
  ret

GetOfferFromText:;"$000000/week" in str_buffer, returns number in ehl
  PUSH_VAR _i
  PUSH_VAR _j
  xor a
  ld [_i], a
  ld de, 0
  ld hl, 0
  ld bc, str_buffer+1
.loopDigits
    ld a, [bc]
    inc bc
    sub a, "0"
    jr z, .skip
    ld [_j], a
    push bc;character
    ld a, [_i]
    call GetPowerOfTen
  .loopPowersOfTen
      call math_Add24
      ld a, [_j]
      dec a
      ld [_j], a
      jr nz, .loopPowersOfTen
    pop bc
  .skip
    ld a, [_i]
    inc a
    ld [_i], a
    cp a, 6
    jr nz, .loopDigits
  POP_VAR _j
  POP_VAR _i
  ret

MakeOffer:;returns z if offer cancelled, result of offer in a (1 = accepted), exit code in b (-1 = exit inventory)
  TRAMPOLINE GetCurrentOpponentPlayer
  ld a, [hl]
  call GetPlayerName
  ld bc, name_buffer
  ld hl, WriteAnOfferToPlayerText
  ld de, str_buffer
  call str_Replace

  ld hl, str_buffer
  ld a, DRAW_FLAGS_WIN | DRAW_FLAGS_PAD_TOP
  ld bc, 12
  call DisplayTextAtPos

  ld hl, BaseOfferText
  ld de, str_buffer
  ld bc, 12
  call mem_Copy

  ld a, 5
  ld [_x], a
  call UpdateOffer
.loop
    WAITPAD_UP_OR_FRAMES 20
    call gbdk_WaitVBL
    call UpdateInput
    ld a, [button_state]
    cp a, PADF_B
    jp z, .cancel
    and a, PADF_A | PADF_START
    jr nz, .makeOffer

  .checkLeft
    ld a, [button_state]
    cp a, PADF_LEFT
    jr nz, .checkRight
    ld a, [_x]
    cp a, 0
    jr z, .loop
    dec a
    ld [_x], a
    call UpdateOffer
    jr .loop

  .checkRight
    ld a, [button_state]
    cp a, PADF_RIGHT
    jr nz, .checkUp
    ld a, [_x]
    cp a, 5
    jr z, .loop
    inc a
    ld [_x], a
    call UpdateOffer
    jr .loop

  .checkUp
    ld a, [button_state]
    cp a, PADF_UP
    jr nz, .checkDown
    ld a, 1
    call IncDecDigit
    call UpdateOffer
    jr .loop

  .checkDown
    ld a, [button_state]
    cp a, PADF_DOWN
    jr nz, .loop
    ld a, -1
    call IncDecDigit
    call UpdateOffer
    jp .loop

.makeOffer
  call GetOfferFromText
  push de;offer num
  push hl

  TRAMPOLINE GetCurrentOpponentPlayer
  ld a, [hl]
  call GetPlayerName
  ld bc, name_buffer
  ld hl, OfferPlayerMoneyText
  ld de, str_buffer
  call str_Replace

  pop hl;offer num
  pop de;
  ld bc, name_buffer
  call str_Number24
  ld bc, name_buffer
  ld hl, str_buffer
  ld de, tile_buffer
  call str_Replace

  ld hl, tile_buffer
  ld a, DRAW_FLAGS_WIN | DRAW_FLAGS_PAD_TOP
  ld de, 12
  call RevealText

  WAITPAD_UP
  ld b, 14
  ld c, 7
  ld a, DRAW_FLAGS_WIN
  call AskYesNo

  cp a, 1
  jr nz, .cancel

.confirmOffer
  TRAMPOLINE GetCurrentOpponentPlayer
  ld a, [hl]
  call GetPlayerName

  call gbdk_Random 
  ld a, e
  cp a, d
  ld de, str_buffer
  ld bc, name_buffer
  jr c, .offerRejected

.offerAccepted
  ld hl, PlayerAcceptsOfferText
  call str_Replace
  ld hl, str_buffer
  call RevealTextAndWait
  ld a, 1;nz=used item, a==1 means accepted
  or a
  ld b, -1
  ret

.offerRejected
  ld hl, PlayerRejectsOfferText
  call str_Replace
  ld hl, str_buffer
  call RevealTextAndWait
  ld a, 2;nz=used item, a!=1 means rejected
  or a
  ld b, -1
  ret
  
.cancel
  xor a
  ret

UseItem:;[item_data], a = index, returns exit code in a (-1 = close inventory)
  push af;index
  ld a, [game_state]
  and a, GAME_STATE_PLAY_BALL
  push af;play ball flag
  ld a, [item_data.type]
.checkBaseballItem
  cp ITEM_TYPE_BASEBALL
  jr nz, .checkGameItem
  pop af;play ball flag
  jr z, .notTheTime
  ld a, [game_state]
  and a , GAME_STATE_UNSIGNED_PLAYER
  jr z, .notTheTime;TODO: handle making offers to signed players
  call MakeOffer
  jp nz, .used
  jp .exit
    
.checkGameItem
  cp ITEM_TYPE_GAME
  jr nz, .checkMoveItem
  pop af;play ball flag
  jr z, .notTheTime

.checkMoveItem
  cp ITEM_TYPE_MOVE
  jr nz, .checkSpecialItem
  pop af;play ball flag
  jr nz, .notTheTime
  call TeachMove
  ld a, c
  and 1
  jr nz, .used
  jr .exit
  
.checkSpecialItem
  cp ITEM_TYPE_SPECIAL
  jr nz, .checkStatsItem
  pop af;play ball flag
  call UseSpecialItem
  jr z, .notTheTime
  ld b, 0
  jr .exit

.checkStatsItem
  cp ITEM_TYPE_STATS
  jr nz, .checkSellItem
  pop af;play ball flag, not used here
  ld a, [item_data.id] 
  ld b, a
  call ShowLineup
  ld b, -1
  ld a, c
  and 1
  jr nz, .used
  jr .exit

.checkSellItem
  cp ITEM_TYPE_SELL
  jr nz, .checkWorldItem
  pop af;play ball flag
  jr nz, .notTheTime
  ld b, 0
  jr .exit

.checkWorldItem
  cp ITEM_TYPE_WORLD
  jr nz, .exit
  pop af;play ball flag
  jr z, .notTheTime
  ld b, 0
  jr .exit

.notTheTime
  ld hl, NowIsNotTheTimeText
  ld de, str_buffer
  ld bc, user_name
  call str_Replace
  ld hl, str_buffer
  call RevealItemTextAndWait
  ld b, 0
  jr .exit

.used;TODO: this logic can be combined with the TossItem logic
  pop af;index
  ld d, 0
  ld e, a
  ld hl, inventory
  add hl, de
  add hl, de 
  inc hl
  ld a, [hl]
  dec a
  jr z, .removeItemCompletely
  ld [hl], a
  ld a, b;exit code
  ret

.removeItemCompletely
  push bc;exit code in b
  inc hl
  ld d, h
  ld e, l
  dec de
  dec de
  ld a, MAX_ITEMS*BYTES_PER_ITEM
  sub a, b
  sub a, b
  ld b, 0
  ld c, a;items to move down
  call mem_Copy;copies hl to hl-2
  pop bc;exit code in b
  ld a, b
  ret

.exit
  pop af;index
  ld a, b;exit code
  ret

UseSpecialItem:;[item_data], f = playball flag, returns z if can't use now
  ld a, [item_data.id]
  jr nz, .playingBaseball
.walkingAround
  cp TOWN_MAP_ITEM
  jr z, .useTownMap
  cp HARMONICA_ITEM
  jr z, .playMusic
  cp OLD_ROD_ITEM
  jr z, .goFish
  cp GOOD_ROD_ITEM
  jr z, .goFish
  cp SUPER_ROD_ITEM
  jr z, .goFish
  cp TOKEN_CASE_ITEM
  jr z, .showTokens
  jr .anywhere
.playingBaseball
  cp HARMONICA_ITEM
  jr z, .wakePlayer
  cp TOWN_MAP_ITEM
  ret z
  cp OLD_ROD_ITEM
  ret z
  cp GOOD_ROD_ITEM
  ret z
  cp SUPER_ROD_ITEM
  ret z
  cp TOKEN_CASE_ITEM
  ret z
.anywhere
  cp HELIX_JERSEY_ITEM
  ret z
  cp DOME_HELMET_ITEM
  ret z
  cp OLD_HAT_ITEM
  ret z
  cp GOLD_TEETH_ITEM
  ret z
  cp SS_TICKET_ITEM
  ret z
  cp DREAM_SCOPE_ITEM
  ret z
  cp EXP_ALL_ITEM
  ret z
  xor a
  ret
.goFish
  jr .exit
.showTokens
  jr .exit
.useTownMap
  call ShowTownMap
  jr .exit
.playMusic
  jr .exit
.wakePlayer
.exit
  ld a, 1
  or a
  ret

ShowTownMap:
  HIDE_WIN
  call DrawStateMap
.loop
  UPDATE_INPUT_AND_JUMP_TO_IF_BUTTONS .exit, PADF_A | PADF_B | PADF_START
  jr .loop
.exit
  SHOW_WIN
  ret

TeachMove:;[item_data], returns exit code in b (-1 = exit inventory), item used in c (0 = not used, 1 = used)
  ld hl, item_data
  ld bc, 4
  add hl, bc
  ld a, [hl]
  call GetMoveName

  ld hl, BootedUpTMText
  call RevealItemTextAndWait

  ld hl, ItContainedMoveText
  ld de, str_buffer
  ld bc, name_buffer
  call str_Replace
  ld hl, str_buffer
  call RevealItemTextAndWait

  ld hl, TeachMoveText
  ld de, str_buffer
  ld bc, name_buffer
  call str_Replace
  ld hl, str_buffer
  ld de, $000C
  ld a, DRAW_FLAGS_PAD_TOP | DRAW_FLAGS_WIN
  call RevealText

  ld b, 14
  ld c, 7
  ld a, DRAW_FLAGS_WIN
  call AskYesNo
  cp a, 1
  ld b, 0
  ld c, 0
  ret nz
  
  ld a, [item_data.id] 
  ld b, a
  call ShowLineup
  ld b, -1
  ret 

TossItem:;[item_data], a = index, returns exit code in a (0 = item removed completely)
.showTossCount
  push af;index
  call GetInventoryItemID
  ld a, [hl];item count

  ld h, a;item count
  ld a, DRAW_FLAGS_WIN
  ld b, 15;x
  ld c, 9;y
  ld d, 5;w
  ld e, 3;h
  call ShowNumberPicker
  and a
  jr nz, .askSure
  pop bc;b = item index
  ld a, 1
  ret
  
.askSure
  pop bc;item index
  ld c, a;count
  push bc;index/count
  ld a, [item_data.id]
  sub a, 2;why 2 instead of one?
  ld b, 0
  ld c, a
  ld hl, ItemNames 
  call str_FromArray;item index in bc
  push hl;item name
  ld de, name_buffer
  call str_Copy

  ld hl, IsItOkToTossItemText
  ld de, str_buffer
  ld bc, name_buffer
  call str_Replace

  ld hl, str_buffer
  ld de, $000C
  ld a, DRAW_FLAGS_PAD_TOP | DRAW_FLAGS_WIN
  call RevealText
  
  ld b, 14
  ld c, 7
  ld a, DRAW_FLAGS_WIN
  call AskYesNo
  pop hl;item name
  pop bc;index/count
  cp a, 1
  jr z, .tossItems
  ld a, 1;return code
  ret

.tossItems
  push hl;item name
  ld d, 0
  ld e, b
  ld hl, inventory
  add hl, de
  add hl, de 
  inc hl
  ld a, [hl]
  sub a, c;item count - toss count
  jr z, .removeItemCompletely
  ld [hl], a
  ld a, 1;exit code
  jr .showText
.removeItemCompletely
  inc hl
  ld d, h
  ld e, l
  dec de
  dec de
  ld a, MAX_ITEMS*BYTES_PER_ITEM
  sub a, b
  sub a, b
  ld b, 0
  ld c, a;items to move down
  call mem_Copy;copies hl to hl-2
  xor a;exit code
.showText
  pop hl;item name
  push af;exit code
  ld de, name_buffer
  call str_Copy

  ld hl, ThrewAwayItemText
  ld de, str_buffer
  ld bc, name_buffer
  call str_Replace

  ld hl, str_buffer
  call RevealItemTextAndWait

  pop af;exit code (-1 = item removed completely)
  ret

RevealItemTextAndWait:;hl = text
  ld de, $000C
  ld a, DRAW_FLAGS_PAD_TOP | DRAW_FLAGS_WIN
  call RevealText
  
  ld de, $1210
  ld a, DRAW_FLAGS_PAD_TOP | DRAW_FLAGS_WIN
  call FlashNextArrow
  ret