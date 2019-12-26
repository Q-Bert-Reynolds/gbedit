VERSION = AWAY
GAME_NAME = BEISBOL_$(VERSION)
ROM_NAME = $(GAME_NAME).gbc
ROM_FILE = $(DIST_DIR)/$(ROM_NAME)

SRC_DIR =   ./src
DATA_DIR =  ./data
MUSIC_DIR = ./music
DIST_DIR =  ./bin
OBJ_DIR =   ./build

all:
	@mkdir -p $(OBJ_DIR)
	@mkdir -p $(DIST_DIR)
	
	rgbasm -D $(VERSION) -o $(OBJ_DIR)/main.o $(SRC_DIR)/main.asm
	rgblink -o $(ROM_FILE) $(OBJ_DIR)/main.o
	rgbfix -vcs -l 0x33 -p 0 -t $(GAME_NAME) $(ROM_FILE)

	open $(ROM_FILE)

clean:
	# @rm -rf $(DIST_DIR)
	@rm -rf $(OBJ_DIR)
	# find . \( -iname '*.1bpp' -o -iname '*.2bpp' -o -iname '*.pic' \) -exec rm {} +
