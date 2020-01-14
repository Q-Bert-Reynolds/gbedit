Multiply:: ; hl = de * a
  ld hl, 0
  and a
  ret z
.loop
  add hl, de
  dec a
  jr nz, .loop
  ret