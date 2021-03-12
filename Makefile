VERSION = DEMO#DEMO AWAY HOME
GAME_NAME = BEISBOL_$(VERSION)
ROM_NAME = $(GAME_NAME).gbc
ROM_FILE = $(DIST_DIR)/$(ROM_NAME)
SYM_FILE = $(DIST_DIR)/$(GAME_NAME).sym

SRC_DIR =   ./src
DATA_DIR =  ./data
MUSIC_DIR = ./music
DIST_DIR =  ./bin
OBJ_DIR =   ./build

all:
	@mkdir -p $(OBJ_DIR)
	@mkdir -p $(DIST_DIR)
	
	rgbasm -D _$(VERSION) -o $(OBJ_DIR)/main.o $(SRC_DIR)/main.asm
	rgblink -m $(OBJ_DIR)/main.map -n $(SYM_FILE) -o $(ROM_FILE) $(OBJ_DIR)/main.o
	rgbfix -jvcs -k 01 -l 0x33 -m 0x1B -p 255 -t $(GAME_NAME) $(ROM_FILE)

ifeq ($(OS), Windows_NT)
	start "$(ROM_FILE)"
else
	open $(ROM_FILE)
endif
	

clean:
	# @rm -rf $(DIST_DIR)
	@rm -rf $(OBJ_DIR)
