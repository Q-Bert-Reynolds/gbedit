Priority

- items button should open a list on both pause menu and play ball
  - use select to swap items in list
  - use items
- show user data when name selected from pause menu
- results from hitting to the field
- set contact power from move, player, and barrel

General

- link cable support!
- move all strings to separate (generated) file
- give math subroutines more appropriate names
- big list of "real names" to use in place of ID and OT

Optimization

- remove use of temp_bank in rolédex to free up RAM
- move_data.id could be stored in upper 7 bits (since there are < 128 moves), move_data.use in LSB
- overworld map and player image data need to be compressed to fit more
- math_Divide24 and str_Number24 are both really similar to their 16 bit counterparts, perhaps they can be reduced in to a smaller number of instructions, or we could only use the 24 bit versions
- SetSpriteTiles, SetSpriteTilesProps, and SetSpriteTilesXY can likely be merged
- Load/Set User/Opposing PlayerBkgTiles subroutines share a ton of code

Python scripts

- generate GBC palette maps from images
- SGB borders should (optionally?) use PNG palettes directly
- duplicate functionality (like the PascalCase function) should be moved to library file
- avatar directional maps should be organized into arrays
- only update .asm file when PNG, GIF, TMX, or MOD files change
- handle 1bpp and rle images
- roledex description parser should print warning when more than 6 lines

Intro

- home version batter has too many tiles
- make ball movement smooth
- randomize players

New Game

- load bedroom map

Play Ball

- if opposing pitcher is ahead - throw more balls, behind - throw more strikes
- pitches in the dirt should bounce
- hide strikezone after pitcher sets
- players should disappear immediately after plate appearance or end of inning
- reduce pitching frames to 3, batting to 2, make trail fx a sprite
- ball should go behind lefty user batter, righty opposing batter
- ball should fly off screen after contact
- more pitching/batting animations
- change color of move info based on type
- bunting

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
  - show pitch or bat icon next to move PP
- show appropriate stat (ie. BA, ERA) below age

Overworld

- pause menu should remember last selection
- replace map system, should be sparse objects in 32x32 tile regions
  - different building sizes
  - patches of trees, grass, water
  - paths, fences, 
  - 
- random encounters should only happen on fields, batting cages, bullpens, etc
- make legs go behind things
- collisions
- animated tiles
- load black tiles outside of map bounds
- fix move left/up bug where boundary tiles don't load sometimes (if the map system doesn't change) 
- enter/exit buildings
- read signs

Rolédex

- finish player descriptions (some show placeholder pokemon text)
- fix player descriptions that are longer than 6 lines
- if player descriptions only span 1 page, garbage text is drawn on the next
- create tileset specific to dex
- show player home towns / recruitment locations

Audio

- fix title screen SFX and music switching
- pitch, hit, wiff, catch SFX
- utilize SGB sound capabilities

Super GameBoy

- use second controller 
- use color palette data
- use additional sprites
- borders for each city when walking
- borders for different fields
- crowd SFX
- extra music voices
- fix LCD interrupt flickering when sending packets

Design Notes

- play against Doc Hicory (the Billet Town team that neither you nor your rival picked) anytime you want to
- pitch speed should be a relative speed so that pitches appear faster when the pitcher's Throw stat is higher than the batter's Bat stat
- after becoming the world champions, the northern pass opens... encounter Mike at top of weather research tower
- trash cans at your rival's house "look like they've taken a beating"
- each town should have an age limits for their league, you should be able to replay home teams as many times as you want
- teammates in their 20s and 30s have a small chance of producing a child
- players should have an age peak, after which speed and throw stats begin to decline (bat and field don't)
- players should have a retirement age