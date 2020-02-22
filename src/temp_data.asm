INCLUDE "src/beisbol.inc"

SECTION "Temp Data", ROMX, BANK[TEMP_BANK]

MyBubbiData:
  DB 001                   ; .number
  DB 5                     ; .level
  DB 1                     ; .position
  DB TOSS_MOVE             ; .moves
  DB SWING_MOVE, 0, 0
  DB 20, 40, 0, 0          ; .pp
  DB NONE                  ; .status
  DW 32                    ; .hp
  DW 45                    ; .max_hp 
  DW 49                    ; .bat
  DW 49                    ; .field
  DW 45                    ; .speed
  DW 65                    ; .throw
  DS 12;DB "Buttercup", 0, 0, 0  ; .nickname
  DB $00,$01,$FF           ; .xp
  DB $00,$00,$FF           ; .pay
  DW 42                    ; .strikeouts        DW ;both looking and swinging
  DW 1                     ; .sacrifices        DW ;both sac flies and sac bunts
  DW 100                   ; .batted_outs       DW ;groundout, lineout, flyout, popout, GIDP, etc
  DW 8                     ; .fielders_choice   DW
  DW 420                   ; .singles           DW
  DW 50                    ; .doubles           DW
  DW 8                     ; .tripples          DW
  DW 20                    ; .homeruns          DW
  DW 123                   ; .runs              DW
  DW 200                   ; .runs_batted_in    DW
  DW 80                    ; .walks             DW
  DW 10                    ; .reached_on_error  DW
  DW 5                     ; .hit_by_pitch      DW
  DW 42                    ; .stolen_bases      DW
  DW 10                    ; .caught_stealing   DW
  DW 200                   ; .batters_faced     DW
  DW 501                   ; .outs_recorded     DW
  DW 109                   ; .walks_allowed     DW
  DW 200                   ; .hits_allowed      DW
  DW 23                    ; .runs_allowed      DW ;earned only
  DW 100                   ; .strikeouts_thrown DW
  DW 12                    ; .wild_pitches      DW
  DW 8                     ; .hit_batters       DW
MyBubbiDataEnd:

MyMickData:
  DB 151                   ; .number
  DB 10                    ; .level
  DB 2                     ; .position
  DB BRAIN_MELTER_MOVE     ; .moves
  DB PREDICT_MOVE
  DB SWING_MOVE, 0
  DB 20, 40, 0, 0          ; .pp
  DB NONE                  ; .status
  DW 32                    ; .hp
  DW 45                    ; .max_hp 
  DW 49                    ; .bat
  DW 49                    ; .field
  DW 45                    ; .speed
  DW 65                    ; .throw
  DB "Lil Mack", 0, 0, 0   ; .nickname
  DB $00,$01,$FF           ; .xp
  DB $FF,$FF,$FF           ; .pay
  DW 42                    ; .strikeouts        DW ;both looking and swinging
  DW 1                     ; .sacrifices        DW ;both sac flies and sac bunts
  DW 100                   ; .batted_outs       DW ;groundout, lineout, flyout, popout, GIDP, etc
  DW 8                     ; .fielders_choice   DW
  DW 420                   ; .singles           DW
  DW 50                    ; .doubles           DW
  DW 8                     ; .tripples          DW
  DW 20                    ; .homeruns          DW
  DW 123                   ; .runs              DW
  DW 200                   ; .runs_batted_in    DW
  DW 80                    ; .walks             DW
  DW 10                    ; .reached_on_error  DW
  DW 5                     ; .hit_by_pitch      DW
  DW 42                    ; .stolen_bases      DW
  DW 10                    ; .caught_stealing   DW
  DW 200                   ; .batters_faced     DW
  DW 501                   ; .outs_recorded     DW
  DW 109                   ; .walks_allowed     DW
  DW 200                   ; .hits_allowed      DW
  DW 23                    ; .runs_allowed      DW ;earned only
  DW 100                   ; .strikeouts_thrown DW
  DW 12                    ; .wild_pitches      DW
  DW 8                     ; .hit_batters       DW
MyMickDataEnd:

OpponentSquirtData:
  DB 007                   ; .number
  DB 42                    ; .level
  DB 1                     ; .position
  DB TOSS_MOVE             ; .moves
  DB SWING_MOVE, 0, 0
  DB 20, 40, 0, 0          ; .pp
  DB NONE                  ; .status
  DW 32                    ; .hp
  DW 45                    ; .max_hp 
  DW 49                    ; .bat
  DW 49                    ; .field
  DW 45                    ; .speed
  DW 65                    ; .throw
  DW 100                   ; .hits
  DW 2000                  ; .at_bats
  DW 44                    ; .runs_allowed
  DW 300                   ; .outs_recorded
OpponentSquirtDataEnd:

Seed::
  ld hl, MyBubbiData
  ld de, UserLineupPlayer1
  ld bc, MyBubbiDataEnd - MyBubbiData
  call mem_Copy

  ld hl, MyMickData
  ld de, UserLineupPlayer2
  ld bc, MyMickDataEnd - MyMickData
  call mem_Copy

  ld hl, OpponentSquirtData
  ld de, OpponentLineupPlayer1
  ld bc, OpponentSquirtDataEnd - OpponentSquirtData
  call mem_Copy
  ret