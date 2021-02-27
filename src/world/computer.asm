;Until you meet Bill James, it says "SOMEONE's PC"
TurnedOnComputerText:          DB "%s turned on\nthe PC.", 0
AccessedSomeonesPCText:        DB "Accessed someone's\nPC.", 0
AccessedBillsPCText:           DB "Accessed BILL's\nPC.", 0
AccessedPlayerFarmSystemText:  DB "Accessed PLAYER\nstorage system.",0
WhatText:                      DB "What?",0
PlayerFarmSystemMenuText:      DB "CALL UP\nRELEASE\nCHANGE FARM\nSEE YA!",0
FarmTexts:                     DB "AAAA\nAAA\nAA\nHigh A\nLow A\nRookie\nClass B\nClass C",0
AccessedMyComputerText:        DB "Accessed my PC.", 0
AccessedItemStorageSystemText: DB "Accessed Item\nStorage System.", 0
WhatDoYouWantToDoText:         DB "What do you want\nto do?", 0
ItemStorageSystemMenuText:     DB "WITHDRAW ITEM\nDEPOSIT ITEM\nTOSS ITEM\nLOG OFF", 0
WhatDoYouWantToWithdrawText:   DB "What do you want\nto withdraw?", 0
WithdrewItemText:              DB "Withdrew\n%s", 0
WhatDoYouWantToDepositText:    DB "What do you want\nto deposit?", 0
ItemWasStoredText:             DB "%s was\nstored via PC.", 0
SomeonesPCText:                DB "SOMEONE's PC\n",0
BillsPCText:                   DB "BILL's PC\n",0
UserPCText:                    DB "%s's PC\n",0
DocsPCText:                    DB "DOC's PC\n",0
LeaguePCText:                  DB "LEAGUE\n",0
LogOffText:                    DB "LOG OFF",0

UsePublicComputer:
  ld a, [last_map_button_state]
  and a, PADF_UP
  ret z
  call ShowTurnedOnComputerText

  xor a
  ld [list_selection], a
.showOptions
    call CopyBkgToWin
    ld a, 7
    ld [rWX], a
    xor a
    ld [rWY], a
    HIDE_ALL_SPRITES
    SHOW_WIN

    call GetPCOptions
    push af;options count
    add a, a
    add a, 2
    ld e, a;height
    xor a
    ld [name_buffer], a
    ld bc, 0
    ld d, 16
    ld a, DRAW_FLAGS_PAD_TOP | DRAW_FLAGS_WIN
    call ShowListMenu
    pop bc;options count in b
    cp a, 0
    jr z, .logOut
    cp a, b
    jr z, .logOut

  .checkBillsPC
    cp a, 1
    jr nz, .checkMyPC
    call AccessPlayerStorageSystem
    xor a
    ld [list_selection], a
    jp .showOptions

  .checkMyPC
    cp a, 2
    jr nz, .checkDocsPC
    call AccessItemStorageSystem
    ld a, 1
    ld [list_selection], a
    jr .showOptions

  .checkDocsPC
    cp a, 3
    jr nz, .checkLeaguePC
    call AccessPlayerRatingSystem
    ld a, 2
    ld [list_selection], a
    jr .showOptions

  .checkLeaguePC
    cp a, 4
    jr nz, .showOptions
    call AcccessLeagueStatsSystem
    ld a, 3
    ld [list_selection], a
    jp .showOptions

.logOut
  HIDE_WIN
  call ShowPlayerAvatar
  WAITPAD_UP
  ret

GetPCOptions:;returns options in str_buffer, option count in a
.checkMetBill
  ld hl, BillsPCText
  ld a, [pc_flags]
  and a, PC_FLAG_MET_BILL
  jr nz, .copyStoragePCText
  ld hl, SomeonesPCText
.copyStoragePCText
  ld de, str_buffer
  call str_Copy
.appendUserPCText
  ld hl, UserPCText
  ld de, name_buffer
  ld bc, user_name
  call str_Replace
  ld hl, name_buffer
  ld de, str_buffer
  call str_Append
  ld a, 3;Bill's PC, user's PC, and LOG OFF
  push af;options count
.checkGotRoledex
  ld a, [pc_flags]
  and a, PC_FLAG_GOT_ROLEDEX
  jr z, .finish;assumes you haven't beaten the league if you don't have a Rolédex
  pop af;options count
  inc a
  push af;options count
  ld hl, DocsPCText
  ld de, str_buffer
  call str_Append
.checkBeatLeague
  ld a, [pc_flags]
  and a, PC_FLAG_BEAT_LEAGUE
  jr z, .finish
  pop af;options count
  inc a
  push af;options count
  ld hl, LeaguePCText
  ld de, str_buffer
  call str_Append
.finish
  ld hl, LogOffText
  ld de, str_buffer
  call str_Append
  pop af;options count
  ret

UseMyComputer:
  ld a, [last_map_button_state]
  and a, PADF_UP
  ret z
  call ShowTurnedOnComputerText
  call AccessItemStorageSystem
  HIDE_WIN
  WAITPAD_UP
  call ShowPlayerAvatar
  ret

ShowTurnedOnComputerText:
  ld hl, TurnedOnComputerText
  ld bc, user_name
  ld de, str_buffer
  call str_Replace
  ld hl, str_buffer
  call RevealTextAndWait
  HIDE_WIN
  ret

AccessPlayerStorageSystem:
  ld hl, AccessedSomeonesPCText
  ld a, [pc_flags]
  and a, PC_FLAG_MET_BILL
  jr z, .showAccessedPCText
  ld hl, AccessedBillsPCText
.showAccessedPCText
  ld a, DRAW_FLAGS_PAD_TOP | DRAW_FLAGS_WIN
  ld de, 12
  call RevealText
  ld de, $1210
  ld a, DRAW_FLAGS_PAD_TOP | DRAW_FLAGS_WIN
  call FlashNextArrow
  ld hl, AccessedPlayerFarmSystemText
.showAccessedFarmText
  ld de, 12
  call RevealText
  ld de, $1210
  ld a, DRAW_FLAGS_PAD_TOP | DRAW_FLAGS_WIN
  call FlashNextArrow
.showFarmName 
  ld bc, 12
  ld hl, WhatText
  ld a, DRAW_FLAGS_PAD_TOP | DRAW_FLAGS_WIN
  call DisplayTextAtPos
.
  ld hl, PlayerFarmSystemMenuText
  ld de, str_buffer
  call str_Copy
  xor a
  ld [name_buffer], a
  ld bc, 0
  ld de, $100A
  ld a, DRAW_FLAGS_PAD_TOP | DRAW_FLAGS_WIN
  call ShowListMenu

; "What?" [FARM AAA]
;  CALL UP 
;     "Who's getting the call?"
;     "Who's getting sent down?"
;     "PLAYER added to the lineup."
;  RELEASE
;  CHANGE FARM
;  SEE YA!
  ret

AccessItemStorageSystem:
  ld a, 7
  ld [rWX], a
  xor a
  ld [rWY], a
  SHOW_WIN
  HIDE_ALL_SPRITES
  xor a
  ld [list_selection], a
.showItemStorageSystemMenu
    call CopyBkgToWin
    
    ld bc, 12
    ld hl, WhatDoYouWantToDoText
    ld a, DRAW_FLAGS_PAD_TOP | DRAW_FLAGS_WIN
    call DisplayTextAtPos

    ld hl, ItemStorageSystemMenuText
    ld de, str_buffer
    call str_Copy
    xor a
    ld [name_buffer], a
    ld bc, 0
    ld de, $100A
    ld a, DRAW_FLAGS_PAD_TOP | DRAW_FLAGS_WIN
    call ShowListMenu

    cp a, 0
    ret z
    cp a, 4
    ret z

  .withdraw
    cp a, 1
    jr nz, .deposit
    ld a, INVENTORY_MODE_WITHDRAW
    ld [inventory_mode], a
    call ShowInventory
    jp .showItemStorageSystemMenu

  .deposit
    cp a, 2
    jr nz, .toss
    ld a, INVENTORY_MODE_DEPOSIT
    ld [inventory_mode], a
    call ShowInventory
    jp .showItemStorageSystemMenu

  .toss
    cp a, 3
    jp nz, .showItemStorageSystemMenu
    ld a, INVENTORY_MODE_TOSS
    ld [inventory_mode], a
    call ShowInventory
    jp .showItemStorageSystemMenu

AccessPlayerRatingSystem:
;DOC's PC
; "Accessed DOC's PC."
; "Accessed player rating system."
; "Want to get your ROLéDEX rated?"
; "Closed link to DOC's PC."
  ret

AcccessLeagueStatsSystem:
; LEAGUE
; "Accessed HALL OF FAME List."
  ret