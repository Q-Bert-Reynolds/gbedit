INCLUDE "src/beisbol.inc"

SECTION "Temp Data", ROMX, BANK[TEMP_BANK]

MyBubbiData:
  DB 001                   ; .number
  DB 5                     ; .level
  DB 6                     ; .position
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

MyZaphData:
  DB 145                   ; .number
  DB 89                    ; .level
  DB 9                     ; .position
  DB ELECTRIC_SLIDER_MOVE  ; .moves
  DB THUNDER_STICK_MOVE
  DB RISER_MOVE
  DB PSYCH_OUT_MOVE
  DB 10, 10, 10, 10        ; .pp
  DB NONE                  ; .status
  DW 32                    ; .hp
  DW 45                    ; .max_hp 
  DW 49                    ; .bat
  DW 49                    ; .field
  DW 45                    ; .speed
  DW 65                    ; .throw
  DS 12                    ; .nickname
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
MyZaphDataEnd:

MyGioData:
  DB 17                    ; .number
  DB 18                    ; .level
  DB 7                     ; .position
  DB RISER_MOVE            ; .moves
  DB SWING_MOVE
  DB CUTTER_MOVE, 0
  DB 20, 40, 20, 0          ; .pp
  DB NONE                  ; .status
  DW 32                    ; .hp
  DW 45                    ; .max_hp 
  DW 49                    ; .bat
  DW 49                    ; .field
  DW 45                    ; .speed
  DW 65                    ; .throw
  DS 12                    ; .nickname
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
MyGioDataEnd:

MyBearData:
  DB 143                   ; .number
  DB 50                    ; .level
  DB 3                     ; .position
  DB THUNDERBALL_MOVE      ; .moves
  DB SWING_MOVE
  DB SMASH_MOVE
  DB ROCK_MOVE
  DB 20, 40, 15, 10        ; .pp
  DB NONE                  ; .status
  DW 32                    ; .hp
  DW 45                    ; .max_hp 
  DW 49                    ; .bat
  DW 49                    ; .field
  DW 45                    ; .speed
  DW 65                    ; .throw
  DS 12                    ; .nickname
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
MyBearDataEnd:

MyStarchildData:
  DB 120                   ; .number
  DB 12                    ; .level
  DB 5                     ; .position
  DB BUBBLEBALL_MOVE       ; .moves
  DB SHELL_MOVE, 0, 0
  DB 20, 40, 0, 0          ; .pp
  DB NONE                  ; .status
  DW 32                    ; .hp
  DW 45                    ; .max_hp 
  DW 49                    ; .bat
  DW 49                    ; .field
  DW 45                    ; .speed
  DW 65                    ; .throw
  DS 12                    ; .nickname
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
MyStarchildDataEnd:

MyMetaData:
  DB 11                    ; .number
  DB 4                     ; .level
  DB 4                     ; .position
  DB HARDEN_MOVE           ; .moves
  DB SILKY_SWING_MOVE
  DB SWING_MOVE, 0
  DB 20, 40, 15, 0          ; .pp
  DB NONE                  ; .status
  DW 32                    ; .hp
  DW 45                    ; .max_hp 
  DW 49                    ; .bat
  DW 49                    ; .field
  DW 45                    ; .speed
  DW 65                    ; .throw
  DS 12                    ; .nickname
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
MyMetaDataEnd:

MyChuData:
  DB 25                    ; .number
  DB 23                    ; .level
  DB 8                     ; .position
  DB LIGHTNING_BOLT_MOVE   ; .moves
  DB SWING_MOVE
  DB CIRCLE_CHANGE_MOVE
  DB CURVEBALL_MOVE
  DB 20, 40, 30, 20        ; .pp
  DB NONE                  ; .status
  DW 32                    ; .hp
  DW 49                    ; .max_hp 
  DW 49                    ; .bat
  DW 55                    ; .field
  DW 60                    ; .speed
  DW 30                    ; .throw
  DS 12                    ; .nickname
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
MyChuDataEnd:

MyYogiData:
  DB 9                     ; .number
  DB 69                    ; .level
  DB 2                     ; .position
  DB HYDRO_CANNON_MOVE     ; .moves
  DB SHELL_MOVE
  DB SPITBALL_MOVE
  DB SMASH_MOVE
  DB 5, 5, 10, 20          ; .pp
  DB NONE                  ; .status
  DW 32                    ; .hp
  DW 45                    ; .max_hp 
  DW 49                    ; .bat
  DW 49                    ; .field
  DW 45                    ; .speed
  DW 65                    ; .throw
  DS 12                    ; .nickname
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
MyYogiDataEnd:

MyFrecklesData:
  DB 5                     ; .number
  DB 18                    ; .level
  DB 1                     ; .position
  DB HIGH_HEAT_MOVE        ; .moves
  DB SWING_MOVE
  DB HEATER_MOVE
  DB CURVEBALL_MOVE
  DB 5, 40, 15, 20         ; .pp
  DB NONE                  ; .status
  DW 69                    ; .hp
  DW 101                   ; .max_hp 
  DW 109                   ; .bat
  DW 111                   ; .field
  DW 99                    ; .speed
  DW 130                   ; .throw
  DS 12                    ; .nickname
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
MyFrecklesDataEnd:

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

  ld hl, MyZaphData
  ld de, UserLineupPlayer2
  ld bc, MyBubbiDataEnd - MyBubbiData
  call mem_Copy

  ld hl, MyGioData
  ld de, UserLineupPlayer3
  ld bc, MyBubbiDataEnd - MyBubbiData
  call mem_Copy

  ld hl, MyBearData
  ld de, UserLineupPlayer4
  ld bc, MyBubbiDataEnd - MyBubbiData
  call mem_Copy

  ld hl, MyStarchildData
  ld de, UserLineupPlayer5
  ld bc, MyBubbiDataEnd - MyBubbiData
  call mem_Copy

  ld hl, MyMetaData
  ld de, UserLineupPlayer6
  ld bc, MyBubbiDataEnd - MyBubbiData
  call mem_Copy

  ld hl, MyChuData
  ld de, UserLineupPlayer7
  ld bc, MyBubbiDataEnd - MyBubbiData
  call mem_Copy

  ld hl, MyYogiData
  ld de, UserLineupPlayer8
  ld bc, MyBubbiDataEnd - MyBubbiData
  call mem_Copy

  ld hl, MyFrecklesData
  ld de, UserLineupPlayer9
  ld bc, MyBubbiDataEnd - MyBubbiData
  call mem_Copy


  ld hl, OpponentSquirtData
  ld de, OpponentLineupPlayer1
  ld bc, OpponentSquirtDataEnd - OpponentSquirtData
  call mem_Copy
  ret