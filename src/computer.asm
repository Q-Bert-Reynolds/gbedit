TurnedOnComputerText: DB "%s turned on\nthe PC.", 0

;Bedroom computer only shows items.
;Until you meet Bill James, it says "SOMEONE's PC"

;ITEMS:
; WITHDRAW ITEM
; DEPOSIT ITEM
; TOSS ITEM
; LOG OFF

;BILL's PC
; "Accessed BILL's PC."
; "Accessed PLAYER storage system."
; "What?" [FARM AAA]
;  CALL UP 
;     "Who's getting the call?"
;     "Who's getting sent down?"
;     "PLAYER added to the lineup."
;  RELEASE
;  CHANGE FARM
;  SEE YA!

;DOC's PC
; "Accessed DOC's PC."
; "Accessed player rating system."
; "Want to get your ROLéDEX rated?"
; "Closed link to DOC's PC."

; LEAGUE
; "Accessed HALL OF FAME List."

UseComputer:
  ld hl, TurnedOnComputerText
  ld bc, user_name
  ld de, str_buffer
  call str_Replace
  ld hl, str_buffer
  call RevealTextAndWait
  HIDE_WIN
  WAITPAD_UP
  ret
