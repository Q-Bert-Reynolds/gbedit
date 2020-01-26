Multiply:: ; hl = de * a
  ld hl, 0
  and a
  ret z
.loop
  add hl, de
  dec a
  jr nz, .loop
  ret

Modulo:: ; a = a % b
  cp b
  jr c, .found
.loop
  sub a, b
  jr nc, .loop  
.found
  ret