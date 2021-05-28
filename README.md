# About:

This is text editor for GameBoy that supports PS/2 and USB keyboards via link port. It is a fork of [Béisbol](https://bitbucket.org/q_bert_reynolds/beisbolgb).

# Compiling:
    gcc -o bin/mod2gbt mod2gbt.c
    python3 mod2gbt.py
    python3 img2rgbds.py
    make clean
    make

# Cart:
MCB5, 2M ROM (128 banks), 32K SRAM (4 banks)