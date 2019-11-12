ROM_NAME = beisbol.gbc

# Directories
SRC_DIR = ./src
DIST_DIR = ./bin
OBJ_DIR = ./build

# Binaries
CC	= lcc

# Files
ROM_FILE = $(DIST_DIR)/$(ROM_NAME)
OBJ_FILES = $(OBJ_DIR)/main.o

all: $(ROM_FILE)
	open $(ROM_FILE)

$(ROM_FILE): $(OBJ_FILES)
	@mkdir -p $(DIST_DIR)
	$(CC) -Wl-m -Wl-yp0x143=0x80 -o $@ $^

$(OBJ_DIR)/%.o : $(SRC_DIR)/%.c
	@mkdir -p $(OBJ_DIR)
	$(CC) -Wa-l -c -o $@ $<


build: 	$(ROM_FILE)

clean:
	@rm -rf $(DIST_DIR)
	@rm -rf $(OBJ_DIR)
