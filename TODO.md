Current

- fix user pitching tile scaling - more than 30 tiles crashes
- user pitching mechanics
- random opponent batting
- advancing bases / scoring
- semi-random contact results (announcer mode)

General

- remove direct use of save file (so it doesn't immediately overwrite old save)
- track time played
- link cable support!
- move all strings to separate (generated) file
- give math subroutines more appropriate names
- big list of "real names" to use in place of ID and OT

Optimization

- overworld map and player image data need to be compressed to fit more
- math_Divide24 and str_Number24 are both really similar to their 16 bit counterparts, perhaps they can be reduced in to a smaller number of instructions, or we could only use the 24 bit versions
- SetSpriteTiles, SetSpriteTilesProps, and SetSpriteTilesXY can likely be merged

Python scripts

- SGB borders should (optionally?) use PNG palettes directly
- duplicate functionality (like the PascalCase function) should be moved to library file
- avatar directional maps should be organized into arrays
- only update .asm file when PNG, GIF, TMX, or MOD files change
- handle 1bpp and rle images
- roledex description parser should print warning when more than 6 lines

Intro

- make ball movement smooth
- pitch/bat anim for home version
- randomize players

New Game

- transition to overworld without turning off display
- load bedroom map

Play Ball

- reduce pitching frames to 3, batting to 2, make trail fx a sprite
- ball should fly off screen after contact
- handle different moves
- hide / disable selection of pitches when batting / swings when pitching
- more pitching/batting animations

Simulation

- initial velocity should be calculated from ball speed, spray angle, and launch angle
- ball should bounce off fences
- running
- catching throwing
- implement basic rules
- iterative landing spot calc slightly off, direct method often way off
- field should probably be bigger than 32x32

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

Audio

- fix title screen SFX and music switching
- pitch, hit, wiff, catch SFX
- utilize SGB sound capabilities

GameBoy Color

- generate palette maps from images

Super GameBoy

- use second controller 
- use color palette data
- use additional sprites
- borders for each city when walking
- borders for different fields
- crowd SFX
- extra music voices
- fix LCD interrupt flickering when sending packets