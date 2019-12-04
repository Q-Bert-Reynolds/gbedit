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
    main.c         ( bank0 ) - movement/collisions, font, UI, bank switching
    start.c        ( bank2 ) - copyrights & intro
    title.c        ( bank3 ) - title, new game/continue menu
    new_game.c     ( bank4 ) - prologue, name entry
    play_ball.c    ( bank5 ) - baseball
    roledex.c      ( bank6 ) - rolédex descriptions
    lineup.c       ( bank7 ) - change batting order & positions
    players_imgX.c ( bank1X) - player images

RAM Banks
    save0.c (bank0) - main save file