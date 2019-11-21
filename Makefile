VERSION = AWAY
ROM_NAME = BEISBOL_$(VERSION).gbc

# Directories
SRC_DIR = ./src
DIST_DIR = ./bin
OBJ_DIR = ./build

# Binaries
CC	= lcc -D$(VERSION)=def

# Files
ROM_FILE = $(DIST_DIR)/$(ROM_NAME)
OBJ_FILES = $(OBJ_DIR)/main.o

all: 
	@mkdir -p $(OBJ_DIR)
	$(CC) -Wa-l -Wf-bo1 -c -o $(OBJ_DIR)/start.o $(SRC_DIR)/start.c
	$(CC) -Wa-l -Wf-bo2 -c -o $(OBJ_DIR)/title.o $(SRC_DIR)/title.c
	$(CC) -Wa-l -Wf-bo3 -c -o $(OBJ_DIR)/new_game.o $(SRC_DIR)/new_game.c
	$(CC) -Wa-l -c -o $(OBJ_DIR)/main.o $(SRC_DIR)/main.c
	@mkdir -p $(DIST_DIR)
	$(CC) -Wl-m -Wl-yp0x143=0x80 -Wl-yt0x01 -Wl-yo0x04 -o $(ROM_FILE) $(OBJ_DIR)/*.o
	open $(ROM_FILE)

clean:
	@rm -rf $(DIST_DIR)
	@rm -rf $(OBJ_DIR)
