General

- move all strings to separate (generated) file
- link cable support!
- give math subroutines more appropriate names
- math_Divide24 and str_Number24 are both really similar to their 16 bit counterparts, perhaps they can be reduced in to a smaller number of instructions, or we could only use the 24 bit versions
- SetSpriteTiles and SetSpriteTilesProps can likely be merged
- big list of "real names" to use in place of ID and OT

Python scripts

- duplicate functionality (like the PascalCase function) should be moved to library file
- avatar directional maps should be organized into arrays
- only update .asm file when PNG or TMX files change
- handle 1bpp and rle images
- identify animations - same size, numbered names (name0, name1, etc)
- roledex description parser should print warning when more than 6 lines

Intro

- sfx
- sparks after ball hits light
- pitch/bat anim
- randomize players

New Game

- remove direct use of save file (so it doesn't immediately overwrite old save)
- shrink Calvin image, transition to bedroom

Battle

- images for batting/pitching -> front/back -> ready/action (8 each * 151)
- hit the ball
- handle different moves
- show X next to pitches when batting / swings when pitching 
- opponent batting / user pitching
    - animation
    - move ball

Team Menu

- stat page
  - missing moves in move list should show "-"
  - should be accessible from PC as well
- show appropriate stat (ie. BA, ERA) below level
- animate player when highlighted

Overworld

- random encounters should only happen on fields, batting cages, bullpens, etc
- make legs go behind things
- collisions
- animated tiles
- load black tiles outside of map bounds
- fix move left/up bug where boundary tiles don't load sometimes
- enter/exit buildings
- read signs

Rolédex

- hold button to scroll fast
- finish player descriptions (some show placeholder pokemon text)
- fix player descriptions that are longer than 6 lines
- create tileset specific to dex
- show player home towns / recruitment locations
  
Music:

- Charge (intro anim)
- Billet Town
- play ball

SFX:

- pitch
- hit
- wiff
- catch
- select
- confirm
- cancel
