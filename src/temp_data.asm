INCLUDE "src/beisbol.inc"

SECTION "Temp Data", ROMX, BANK[TEMP_BANK]
TempItems:
  DB BASEBALL_ITEM,    10
  DB TM01_ITEM,        1
  DB STEROIDS_ITEM,    99
  DB TOWN_MAP_ITEM,    0
  DB DREAM_SCOPE_ITEM, 0
  DB HARMONICA_ITEM,   0
  DB EXP_ALL_ITEM,     0
  DB POTION_ITEM,      32
  DB BICYCLE_ITEM,     0
  DS MAX_ITEMS*2 - 18;18=num bytes above

MyBubbiData:
  DB 001                                ; .number
  DB 5                                  ; .age
  DB SHORTSTOP                          ; .position
  DB TOSS_MOVE                          ; .moves
  DB SWING_MOVE, 0, 0
  DB 20, 40, 0, 0                       ; .pp
  DB THROW_LEFT | BAT_RIGHT | BAT_LEFT  ; .hand
  DB NONE                               ; .status
  DW 45                                 ; .hp
  DW 45                                 ; .max_hp 
  DW 49                                 ; .bat
  DW 49                                 ; .field
  DW 45                                 ; .speed
  DW 65                                 ; .throw
  NICKNAME "Buttercup"                  ; .nickname
  DB $FF,$FF,$FF                        ; .xp
  DB $0F,$0F,$FF                        ; .pay
  DW 42                                 ; .strikeouts
  DW 1                                  ; .sacrifices
  DW 100                                ; .batted_outs
  DW 8                                  ; .fielders_choice   
  DW 420                                ; .singles           
  DW 50                                 ; .doubles           
  DW 8                                  ; .tripples          
  DW 20                                 ; .homeruns          
  DW 123                                ; .runs              
  DW 200                                ; .runs_batted_in    
  DW 80                                 ; .walks             
  DW 10                                 ; .reached_on_error  
  DW 5                                  ; .hit_by_pitch      
  DW 42                                 ; .stolen_bases      
  DW 10                                 ; .caught_stealing   
  DW 200                                ; .batters_faced     
  DW 501                                ; .outs_recorded     
  DW 109                                ; .walks_allowed     
  DW 200                                ; .hits_allowed      
  DW 23                                 ; .runs_allowed
  DW 100                                ; .strikeouts_thrown 
  DW 12                                 ; .wild_pitches      
  DW 8                                  ; .hit_batters       
MyBubbiDataEnd:

MyZaphData:
  DB 145                                ; .number
  DB 89                                 ; .age
  DB RIGHT_FIELDER                      ; .position
  DB ELEC_SLIDER_MOVE                   ; .moves
  DB THUNDERSTICK_MOVE
  DB RISER_MOVE
  DB PSYCH_OUT_MOVE
  DB 10, 10, 10, 10                     ; .pp
  DB THROW_RIGHT | BAT_RIGHT            ; .hand
  DB NONE                               ; .status
  DW 47                                 ; .hp
  DW 48                                 ; .max_hp 
  DW 49                                 ; .bat
  DW 49                                 ; .field
  DW 45                                 ; .speed
  DW 65                                 ; .throw
  NICKNAME "Zaphod"                     ; .nickname
  DB $00,$01,$FF                        ; .xp
  DB $0F,$0F,$FF                        ; .pay
  DW 42                                 ; .strikeouts
  DW 1                                  ; .sacrifices 
  DW 100                                ; .batted_outs  
  DW 8                                  ; .fielders_choice
  DW 420                                ; .singles        
  DW 50                                 ; .doubles        
  DW 8                                  ; .tripples       
  DW 20                                 ; .homeruns       
  DW 123                                ; .runs           
  DW 200                                ; .runs_batted_in 
  DW 80                                 ; .walks          
  DW 10                                 ; .reached_on_error
  DW 5                                  ; .hit_by_pitch   
  DW 42                                 ; .stolen_bases   
  DW 10                                 ; .caught_stealing
  DW 200                                ; .batters_faced  
  DW 501                                ; .outs_recorded  
  DW 109                                ; .walks_allowed  
  DW 200                                ; .hits_allowed   
  DW 23                                 ; .runs_allowed
  DW 100                                ; .strikeouts_thrown
  DW 12                                 ; .wild_pitches   
  DW 8                                  ; .hit_batters    
MyZaphDataEnd:

MyGioData:
  DB 17                                 ; .number
  DB 18                                 ; .age
  DB LEFT_FIELDER                       ; .position
  DB RISER_MOVE                         ; .moves
  DB SWING_MOVE
  DB CUTTER_MOVE, 0
  DB 20, 40, 20, 0                      ; .pp
  DB THROW_RIGHT | BAT_RIGHT            ; .hand
  DB NONE                               ; .status
  DW 32                                 ; .hp
  DW 45                                 ; .max_hp 
  DW 49                                 ; .bat
  DW 49                                 ; .field
  DW 45                                 ; .speed
  DW 65                                 ; .throw
  NICKNAME ""                           ; .nickname
  DB $00,$01,$FF                        ; .xp
  DB $0F,$0F,$FF                        ; .pay
  DW 42                                 ; .strikeouts
  DW 1                                  ; .sacrifices 
  DW 100                                ; .batted_outs  
  DW 8                                  ; .fielders_choice
  DW 420                                ; .singles        
  DW 50                                 ; .doubles        
  DW 8                                  ; .tripples       
  DW 20                                 ; .homeruns       
  DW 123                                ; .runs           
  DW 200                                ; .runs_batted_in 
  DW 80                                 ; .walks          
  DW 10                                 ; .reached_on_error
  DW 5                                  ; .hit_by_pitch   
  DW 42                                 ; .stolen_bases   
  DW 10                                 ; .caught_stealing
  DW 200                                ; .batters_faced  
  DW 501                                ; .outs_recorded  
  DW 109                                ; .walks_allowed  
  DW 200                                ; .hits_allowed   
  DW 23                                 ; .runs_allowed
  DW 100                                ; .strikeouts_thrown
  DW 12                                 ; .wild_pitches   
  DW 8                                  ; .hit_batters    
MyGioDataEnd:

MyBearData:
  DB 143                                ; .number
  DB 50                                 ; .age
  DB FIRST_BASEMAN                      ; .position
  DB THUNDERBALL_MOVE                   ; .moves
  DB SWING_MOVE
  DB SMASH_MOVE
  DB ROCK_MOVE
  DB 20, 40, 15, 10                     ; .pp
  DB THROW_RIGHT | BAT_RIGHT            ; .hand
  DB NONE                               ; .status
  DW 32                                 ; .hp
  DW 45                                 ; .max_hp 
  DW 49                                 ; .bat
  DW 49                                 ; .field
  DW 45                                 ; .speed
  DW 65                                 ; .throw
  DS NICKNAME_LENGTH                    ; .nickname
  DB $00,$01,$FF                        ; .xp
  DB $0F,$0F,$FF                        ; .pay
  DW 42                                 ; .strikeouts
  DW 1                                  ; .sacrifices
  DW 100                                ; .batted_outs
  DW 8                                  ; .fielders_choice   
  DW 420                                ; .singles           
  DW 50                                 ; .doubles           
  DW 8                                  ; .tripples          
  DW 20                                 ; .homeruns          
  DW 123                                ; .runs              
  DW 200                                ; .runs_batted_in    
  DW 80                                 ; .walks             
  DW 10                                 ; .reached_on_error  
  DW 5                                  ; .hit_by_pitch      
  DW 42                                 ; .stolen_bases      
  DW 10                                 ; .caught_stealing   
  DW 200                                ; .batters_faced     
  DW 501                                ; .outs_recorded     
  DW 109                                ; .walks_allowed     
  DW 200                                ; .hits_allowed      
  DW 23                                 ; .runs_allowed
  DW 100                                ; .strikeouts_thrown 
  DW 12                                 ; .wild_pitches      
  DW 8                                  ; .hit_batters       
MyBearDataEnd:

MyStarchildData:
  DB 120                                ; .number
  DB 12                                 ; .age
  DB THIRD_BASEMAN                      ; .position
  DB BUBBLEBALL_MOVE                    ; .moves
  DB SHELL_MOVE, 0, 0
  DB 20, 40, 0, 0                       ; .pp
  DB THROW_RIGHT | BAT_RIGHT            ; .hand
  DB NONE                               ; .status
  DW 32                                 ; .hp
  DW 45                                 ; .max_hp 
  DW 49                                 ; .bat
  DW 49                                 ; .field
  DW 45                                 ; .speed
  DW 65                                 ; .throw
  DS NICKNAME_LENGTH                    ; .nickname
  DB $00,$01,$FF                        ; .xp
  DB $0F,$0F,$FF                        ; .pay
  DW 42                                 ; .strikeouts
  DW 1                                  ; .sacrifices
  DW 100                                ; .batted_outs
  DW 8                                  ; .fielders_choice   
  DW 420                                ; .singles           
  DW 50                                 ; .doubles           
  DW 8                                  ; .tripples          
  DW 20                                 ; .homeruns          
  DW 123                                ; .runs              
  DW 200                                ; .runs_batted_in    
  DW 80                                 ; .walks             
  DW 10                                 ; .reached_on_error  
  DW 5                                  ; .hit_by_pitch      
  DW 42                                 ; .stolen_bases      
  DW 10                                 ; .caught_stealing   
  DW 200                                ; .batters_faced     
  DW 501                                ; .outs_recorded     
  DW 109                                ; .walks_allowed     
  DW 200                                ; .hits_allowed      
  DW 23                                 ; .runs_allowed
  DW 100                                ; .strikeouts_thrown 
  DW 12                                 ; .wild_pitches      
  DW 8                                  ; .hit_batters       
MyStarchildDataEnd:

MyMetaData:
  DB 11                                 ; .number
  DB 4                                  ; .age
  DB SECOND_BASEMAN                     ; .position
  DB HARDEN_MOVE                        ; .moves
  DB SILKY_SWING_MOVE
  DB SWING_MOVE, 0
  DB 20, 40, 15, 0                      ; .pp
  DB THROW_RIGHT | BAT_RIGHT            ; .hand
  DB NONE                               ; .status
  DW 15                                 ; .hp
  DW 45                                 ; .max_hp 
  DW 49                                 ; .bat
  DW 49                                 ; .field
  DW 45                                 ; .speed
  DW 65                                 ; .throw
  DS NICKNAME_LENGTH                    ; .nickname
  DB $00,$01,$FF                        ; .xp
  DB $0F,$0F,$FF                        ; .pay
  DW 42                                 ; .strikeouts
  DW 1                                  ; .sacrifices
  DW 100                                ; .batted_outs
  DW 8                                  ; .fielders_choice   
  DW 420                                ; .singles           
  DW 50                                 ; .doubles           
  DW 8                                  ; .tripples          
  DW 20                                 ; .homeruns          
  DW 123                                ; .runs              
  DW 200                                ; .runs_batted_in    
  DW 80                                 ; .walks             
  DW 10                                 ; .reached_on_error  
  DW 5                                  ; .hit_by_pitch      
  DW 42                                 ; .stolen_bases      
  DW 10                                 ; .caught_stealing   
  DW 200                                ; .batters_faced     
  DW 501                                ; .outs_recorded     
  DW 109                                ; .walks_allowed     
  DW 200                                ; .hits_allowed      
  DW 23                                 ; .runs_allowed
  DW 100                                ; .strikeouts_thrown 
  DW 12                                 ; .wild_pitches      
  DW 8                                  ; .hit_batters       
MyMetaDataEnd:

MyChuData:
  DB 25                                 ; .number
  DB 23                                 ; .age
  DB CENTER_FIELDER                     ; .position
  DB LIGHTNINBOLT_MOVE                  ; .moves
  DB SWING_MOVE
  DB CIRCLECHANGE_MOVE
  DB CURVEBALL_MOVE
  DB 20, 40, 30, 20                     ; .pp
  DB THROW_RIGHT | BAT_RIGHT            ; .hand
  DB NONE                               ; .status
  DW 5                                  ; .hp
  DW 49                                 ; .max_hp 
  DW 49                                 ; .bat
  DW 55                                 ; .field
  DW 60                                 ; .speed
  DW 30                                 ; .throw
  DS NICKNAME_LENGTH                    ; .nickname
  DB $00,$01,$FF                        ; .xp
  DB $0F,$0F,$FF                        ; .pay
  DW 42                                 ; .strikeouts
  DW 1                                  ; .sacrifices
  DW 100                                ; .batted_outs
  DW 8                                  ; .fielders_choice   
  DW 420                                ; .singles           
  DW 50                                 ; .doubles           
  DW 8                                  ; .tripples          
  DW 20                                 ; .homeruns          
  DW 123                                ; .runs              
  DW 200                                ; .runs_batted_in    
  DW 80                                 ; .walks             
  DW 10                                 ; .reached_on_error  
  DW 5                                  ; .hit_by_pitch      
  DW 42                                 ; .stolen_bases      
  DW 10                                 ; .caught_stealing   
  DW 200                                ; .batters_faced     
  DW 501                                ; .outs_recorded     
  DW 109                                ; .walks_allowed     
  DW 200                                ; .hits_allowed      
  DW 23                                 ; .runs_allowed
  DW 100                                ; .strikeouts_thrown 
  DW 12                                 ; .wild_pitches      
  DW 8                                  ; .hit_batters       
MyChuDataEnd:

MyYogiData:
  DB 9                                  ; .number
  DB 69                                 ; .age
  DB CATCHER                            ; .position
  DB HYDRO_CANNON_MOVE                  ; .moves
  DB SHELL_MOVE
  DB SPITBALL_MOVE
  DB SMASH_MOVE
  DB 5, 5, 10, 20                       ; .pp
  DB THROW_RIGHT | BAT_RIGHT            ; .hand
  DB NONE                               ; .status
  DW 32                                 ; .hp
  DW 45                                 ; .max_hp 
  DW 49                                 ; .bat
  DW 49                                 ; .field
  DW 45                                 ; .speed
  DW 65                                 ; .throw
  DS NICKNAME_LENGTH                    ; .nickname
  DB $00,$01,$FF                        ; .xp
  DB $0F,$0F,$FF                        ; .pay
  DW 42                                 ; .strikeouts        
  DW 1                                  ; .sacrifices        
  DW 100                                ; .batted_outs       
  DW 8                                  ; .fielders_choice   
  DW 420                                ; .singles           
  DW 50                                 ; .doubles           
  DW 8                                  ; .tripples          
  DW 20                                 ; .homeruns          
  DW 123                                ; .runs              
  DW 200                                ; .runs_batted_in    
  DW 80                                 ; .walks             
  DW 10                                 ; .reached_on_error  
  DW 5                                  ; .hit_by_pitch      
  DW 42                                 ; .stolen_bases      
  DW 10                                 ; .caught_stealing   
  DW 200                                ; .batters_faced     
  DW 501                                ; .outs_recorded     
  DW 109                                ; .walks_allowed     
  DW 200                                ; .hits_allowed      
  DW 23                                 ; .runs_allowed
  DW 100                                ; .strikeouts_thrown 
  DW 12                                 ; .wild_pitches      
  DW 8                                  ; .hit_batters       
MyYogiDataEnd:

MyBigRedData:
  DB 6                                  ; .number
  DB 38                                 ; .age
  DB PITCHER                            ; .position
  DB HIGH_HEAT_MOVE                     ; .moves
  DB SWING_MOVE
  DB HEATER_MOVE
  DB CURVEBALL_MOVE
  DB 5, 40, 15, 20                      ; .pp
  DB THROW_LEFT | BAT_RIGHT             ; .hand
  DB NONE                               ; .status
  DW 69                                 ; .hp
  DW 101                                ; .max_hp 
  DW 109                                ; .bat
  DW 111                                ; .field
  DW 99                                 ; .speed
  DW 130                                ; .throw
  NICKNAME "Ruby"                       ; .nickname
  DB $00,$01,$FF                        ; .xp
  DB $0F,$0F,$FF                        ; .pay
  DW 42                                 ; .strikeouts
  DW 1                                  ; .sacrifices
  DW 100                                ; .batted_outs
  DW 8                                  ; .fielders_choice   
  DW 420                                ; .singles           
  DW 50                                 ; .doubles           
  DW 8                                  ; .tripples          
  DW 20                                 ; .homeruns          
  DW 123                                ; .runs              
  DW 200                                ; .runs_batted_in    
  DW 80                                 ; .walks             
  DW 10                                 ; .reached_on_error  
  DW 5                                  ; .hit_by_pitch      
  DW 42                                 ; .stolen_bases      
  DW 10                                 ; .caught_stealing   
  DW 200                                ; .batters_faced     
  DW 501                                ; .outs_recorded     
  DW 109                                ; .walks_allowed     
  DW 200                                ; .hits_allowed      
  DW 23                                 ; .runs_allowed
  DW 100                                ; .strikeouts_thrown 
  DW 12                                 ; .wild_pitches      
  DW 8                                  ; .hit_batters       
MyBigRedDataEnd:

OpponentBigRedData:
  DB 006                                ; .number
  DB 42                                 ; .age
  DB PITCHER                            ; .position
  DB HIGH_HEAT_MOVE                     ; .moves
  DB SWING_MOVE
  DB HEATER_MOVE
  DB CURVEBALL_MOVE
  DB 5, 40, 15, 20                      ; .pp
  DB THROW_LEFT | BAT_RIGHT             ; .hand
  DB NONE                               ; .status
  DW 32                                 ; .hp
  DW 45                                 ; .max_hp 
  DW 49                                 ; .bat
  DW 49                                 ; .field
  DW 45                                 ; .speed
  DW 65                                 ; .throw
  DW 100                                ; .hits
  DW 2000                               ; .at_bats
  DW 44                                 ; .runs_allowed
  DW 300                                ; .outs_recorded
OpponentBigRedDataEnd:

OpponentBubbiData:
  DB 001                                ; .number
  DB 42                                 ; .age
  DB SHORTSTOP                          ; .position
  DB TOSS_MOVE                          ; .moves
  DB SWING_MOVE, 0, 0
  DB 20, 40, 0, 0                       ; .pp
  DB THROW_RIGHT | BAT_LEFT             ; .hand
  DB NONE                               ; .status
  DW 32                                 ; .hp
  DW 45                                 ; .max_hp 
  DW 49                                 ; .bat
  DW 49                                 ; .field
  DW 45                                 ; .speed
  DW 65                                 ; .throw
  DW 100                                ; .hits
  DW 2000                               ; .at_bats
  DW 44                                 ; .runs_allowed
  DW 300                                ; .outs_recorded
OpponentBubbiDataEnd:

OpponentBearData:
  DB 143                                ; .number
  DB 42                                 ; .age
  DB FIRST_BASEMAN                      ; .position
  DB TOSS_MOVE                          ; .moves
  DB SWING_MOVE, 0, 0
  DB 20, 40, 0, 0                       ; .pp
  DB THROW_RIGHT | BAT_RIGHT            ; .hand
  DB NONE                               ; .status
  DW 32                                 ; .hp
  DW 45                                 ; .max_hp 
  DW 49                                 ; .bat
  DW 49                                 ; .field
  DW 45                                 ; .speed
  DW 65                                 ; .throw
  DW 100                                ; .hits
  DW 2000                               ; .at_bats
  DW 44                                 ; .runs_allowed
  DW 300                                ; .outs_recorded
OpponentBearDataEnd:

Seed::
.userLineup
  ld hl, MyYogiData
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

  ld hl, MyBubbiData
  ld de, UserLineupPlayer8
  ld bc, MyBubbiDataEnd - MyBubbiData
  call mem_Copy

  ld hl, MyBigRedData
  ld de, UserLineupPlayer9
  ld bc, MyBubbiDataEnd - MyBubbiData
  call mem_Copy

.opposingLineup
  ld hl, OpponentBubbiData
  ld de, OpponentLineupPlayer1
  ld bc, OpponentBubbiDataEnd - OpponentBubbiData
  call mem_Copy

  ld hl, OpponentBigRedData
  ld de, OpponentLineupPlayer2
  ld bc, OpponentBigRedDataEnd - OpponentBigRedData
  call mem_Copy

  ld hl, OpponentBubbiData
  ld de, OpponentLineupPlayer3
  ld bc, OpponentBubbiDataEnd - OpponentBubbiData
  call mem_Copy

  ld hl, OpponentBearData
  ld de, OpponentLineupPlayer4
  ld bc, OpponentBubbiDataEnd - OpponentBubbiData
  call mem_Copy

  ld hl, OpponentBubbiData
  ld de, OpponentLineupPlayer5
  ld bc, OpponentBubbiDataEnd - OpponentBubbiData
  call mem_Copy

  ld hl, OpponentBearData
  ld de, OpponentLineupPlayer6
  ld bc, OpponentBubbiDataEnd - OpponentBubbiData
  call mem_Copy

  ld hl, OpponentBubbiData
  ld de, OpponentLineupPlayer7
  ld bc, OpponentBubbiDataEnd - OpponentBubbiData
  call mem_Copy

  ld hl, OpponentBearData
  ld de, OpponentLineupPlayer8
  ld bc, OpponentBubbiDataEnd - OpponentBubbiData
  call mem_Copy

  ld hl, OpponentBubbiData
  ld de, OpponentLineupPlayer9
  ld bc, OpponentBubbiDataEnd - OpponentBubbiData
  call mem_Copy

  ld hl, 2020
  call gbdk_Seed
  ld hl, players_seen
  ld de, players_sign
  ld c, 151/8
.loop
    push de;signed
    push hl;seen
    call gbdk_Random
    ld a, e
    pop hl;seen
    ld [hli], a
    and a, d
    pop de;signed
    ld [de], a
    inc de

    dec c
    jr nz, .loop

  push de;signed
  push hl;seen
  call gbdk_Random
  ld a, e
  and a, $FE
  pop hl;seen
  ld [hl], a
  and a, d
  and a, $FE
  pop de;signed
  ld [de], a

  ld hl, players_seen
  ld a, %11000011
  ld [hli], a
  ld a, %01111111
  ld [hl], a
  
  ld hl, players_sign
  ld a, %00000011
  ld [hli], a
  ld a, %01111000
  ld [hl], a

  ld hl, TempItems
  ld de, items
  ld bc, MAX_ITEMS*2
  call mem_Copy

  ld a, [items+2]

  ret