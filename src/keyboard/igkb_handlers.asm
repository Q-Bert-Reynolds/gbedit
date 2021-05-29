IGKBHandleCode::;a = scan code
.handleSpace
  cp a, 137
  jr nz, .handlePeriod
  ld a, " "
  jp DrawCharacter
.handlePeriod
  cp a, 148
  jr nz, .handleApostrophe
  ld a, "."
  jp DrawCharacter
.handleApostrophe
  cp a, 145
  jr nz, .handleComma
  ld a, "'"
  jp DrawCharacter
.handleComma
  cp a, 147
  jr nz, .handleEnter
  ld a, ","
  jp DrawCharacter
.handleEnter
  cp a, 133
  jr nz, .handleBackspace
  jp KBHandleEnter
.handleBackspace
  cp a, 135
  jr nz, .handleZero
  jp KBHandleBackspace
.handleZero
  cp a, 132
  jr nz, .handleNumber
  ld a, "0"
  call DrawCharacter
.handleNumber
  cp a, 123
  jr c, .handleCharacter
  cp a, 133
  jr nc, .handleCharacter
  sub a, 74
.handleCharacter
  call DrawCharacter
  ret