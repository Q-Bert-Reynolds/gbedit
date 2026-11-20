ROM_NAME  = TEXT_EDITOR
BIN_DIR   = bin
BUILD_DIR = build
ROM_FILE  = $(BIN_DIR)/$(ROM_NAME).gbc
SYM_FILE  = $(BIN_DIR)/$(ROM_NAME).sym

PYTHON   ?= python3
EMULATOR ?= gearboy

ASM_SOURCES = $(shell find src -type f \( -name '*.asm' -o -name '*.inc' \))
C_HEADERS   = src/editor/editor.h src/constants.h
ASSETS      = img/ui_font.tiles img/default_sgb_border.asm

.PHONY: all code assemble assets run clean

all: assemble

code: assemble run

src/constants.h: src/constants.asm build.py
	$(PYTHON) build.py

src/editor/_editor.asm: src/editor/editor.c $(C_HEADERS) peephole.def
	sdcc $< -msm83 --asm=rgbds --opt-code-size --no-peep --peep-file peephole.def --disable-warning 218 -S -o $@

img/ui_font.tiles: img/ui_font.png img2rgbds.py
	$(PYTHON) img2rgbds.py

img/default_sgb_border.asm: img/default_sgb_border.png sgb_border.py utils.py
	$(PYTHON) sgb_border.py $< $@

assets: src/constants.h $(ASSETS)

$(BUILD_DIR) $(BIN_DIR):
	mkdir -p $@

$(BUILD_DIR)/main.o: $(ASM_SOURCES) src/editor/_editor.asm $(ASSETS) | $(BUILD_DIR)
	rgbasm -o $@ src/main.asm

$(ROM_FILE): $(BUILD_DIR)/main.o | $(BIN_DIR)
	rgblink -m $(BUILD_DIR)/main.map -n $(SYM_FILE) -o $@ $<
	rgbfix -jvcs -k 01 -l 0x33 -m 0x1B -p 255 $@

assemble: $(ROM_FILE)

run: assemble
	$(EMULATOR) $(ROM_FILE)

clean:
	rm -rf $(BUILD_DIR)
	rm -f $(ROM_FILE) $(SYM_FILE) src/editor/_editor.asm src/constants.h
