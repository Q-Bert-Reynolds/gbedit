# Compiling:
    `python3 png2gbdk.py`
    `make clean`
    `make`

# TODO:
    get_bkg_data function broken
        doesn't store tiles in array
        often causes "Wrote XX to XXXX (RAM Mirror)" error
    player images:
        batting/pitching -> front/back -> ready/action (8 each)
    python script
        handle 1bpp and rle
        only update .c file when png changes
        identify animations - same size, numbered names (name0, name1, etc)
    Main
        move UI functions to separate script
    Intro
        sfx
        sparks after ball hits light
        pitch/bat anim
        bounce title
        delay version slide
        randomize players
    New Game
        shrink Calvin image, transition to bedroom
    Battle
        doubled back & player front images should be different batting/pitching images
        hit the ball
        handle different moves
        batting             
        opponent batting / user pitching
            animation
            move ball
    Team Menu
    Walking
    Roledex

# Cart
MCB5, 2M ROM (128 banks), 32K SRAM (4 banks)

ROM Banks:
2 -c -o $(OBJ_DIR)/ui.o           $(SRC_DIR)/ui.c	
3 -c -o $(OBJ_DIR)/start.o        $(SRC_DIR)/start.c
4 -c -o $(OBJ_DIR)/title.o        $(SRC_DIR)/title.c
5 -c -o $(OBJ_DIR)/new_game.o     $(SRC_DIR)/new_game.c
6 -c -o $(OBJ_DIR)/play_ball.o    $(SRC_DIR)/play_ball.c

    main.c         ( bank0 ) - movement/collisions, bank switching
    ui.c           ( bank2 ) - font, non-realtime UI functions, options
    start.c        ( bank3 ) - copyrights & intro
    title.c        ( bank4 ) - title, new game/continue menu
    new_game.c     ( bank5 ) - prologue, name entry
    play_ball.c    ( bank6 ) - baseball
    roledex.c      ( bank7 ) - rolédex descriptions
    lineup.c       ( bank8 ) - change batting order & positions
    players_imgX.c ( bank1X) - player images

RAM Banks
    save0.c (bank0) - main save file