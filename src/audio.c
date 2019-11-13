#include "beisbol.h"

#ifndef AUDIO
#define AUDIO

#define MEASURES 12
#define BEATS MEASURES*4
#define PLAYBACK_SPEED 12
#define LOOPS 12

UWORD beat = -1;
UBYTE music_timer = 0;
UBYTE loop_num = 0;

typedef enum {
    C3, Cd3, D3, Dd3, E3, F3, Fd3, G3, Gd3, A3, Ad3, B3,
    C4, Cd4, D4, Dd4, E4, F4, Fd4, G4, Gd4, A4, Ad4, B4,
    C5, Cd5, D5, Dd5, E5, F5, Fd5, G5, Gd5, A5, Ad5, B5,
    C6, Cd6, D6, Dd6, E6, F6, Fd6, G6, Gd6, A6, Ad6, B6,
    C7, Cd7, D7, Dd7, E7, F7, Fd7, G7, Gd7, A7, Ad7, B7,
    C8, Cd8, D8, Dd8, E8, F8, Fd8, G8, Gd8, A8, Ad8, B8,
    SILENCE
} Pitch;

const UWORD freq[] = {
    44,   156,  262,  363,  457,  547,  631,  710,  786,  854,  923,  986,
    1046, 1102, 1155, 1205, 1253, 1297, 1339, 1379, 1417, 1452, 1486, 1517,
    1546, 1575, 1602, 1627, 1650, 1673, 1694, 1714, 1732, 1750, 1767, 1783,
    1798, 1812, 1825, 1837, 1849, 1860, 1871, 1881, 1890, 1899, 1907, 1915,
    1923, 1930, 1936, 1943, 1949, 1954, 1959, 1964, 1969, 1974, 1978, 1982,
    1985, 1988, 1992, 1995, 1998, 2001, 2004, 2006, 2009, 2011, 2013, 2015,
    0
};

const UBYTE noise_freq[] = {
    236,   235,  223,  222,  221,  220,  219,  207,  206,  205,  204,  203,
    191,   190,  189,  188,  187,  175,  174,  173,  172,  171,  159,  158,
    157,   156,  155,  143,  142,  141,  140,  139,  127,  126,  125,  124,
    123,   111,  110,  109,  108,  107,   95,   94,   93,   92,   91,   79,
    78,     77,   76,   75,   63,   62,   61,   60,   59,   47,   46,   45,
    44,     43,   31,   30,   29,   28,   27,   15,   14,   13,   12,   11,
    0
};

typedef struct {
    Pitch pitch;
    UBYTE volume_envelope; // channel volume (bits 7654), direction (bit 3, 0=down, 1=up), step len (bits 210, 0=off)
    UBYTE wave_duty;       // wave pattern duty (bits 76), length counter load register (bits 543210)
    UBYTE pitch_sweep;     // ch1 only, rate (bits 654, 0=off), direction (bit 3, 1=down, 0=up), right shift (bits 210, 0=off)
} note;

const note bass_notes [] = {
    {SILENCE, 0,     0,     0},
    {E3,      0xFFU, 0x3FU, 0},
    {G3,      0xFFU, 0x3FU, 0},
    {Gd3,     0xFFU, 0xFFU, 0},
    {A3,      0xFFU, 0x3FU, 0},
    {B3,      0xFFU, 0x3FU, 0},
    {Cd4,     0xFFU, 0x3FU, 0},
    {D4,      0xFFU, 0x3FU, 0},
    {E4,      0xFFU, 0x3FU, 0},
};

const BYTE bass_loop[] = {
    1,0,0,0,
    8,0,0,4,
    5,8,5,0,
    8,0,0,0,
    7,6,5,2,
    0,1,2,0,
    1,0,4,5,
    8,0,0,4,
    5,8,5,0,
    8,0,0,0,
    7,6,5,2,
    0,1,2,0,
};

const note strings_notes[] = {
    {SILENCE, 0,     0,     0},
    {E5,      0xFFU, 0xFFU, 0},
    {G5,      0xFFU, 0xFFU, 0},
    {Gd5,     0xFFU, 0xFFU, 0},
    {A5,      0xFFU, 0xFFU, 0},
    {B5,      0xFFU, 0xFFU, 0},
    {Cd6,     0xFFU, 0xFFU, 0},
    {D6,      0xFFU, 0xFFU, 0},
    {E6,      0xFFU, 0xFFU, 0},
};

const BYTE strings_loop[] = {
    1,0,0,0,
    3,0,0,0,
    0,0,0,0,
    5,0,0,0,
    4,0,0,0,
    0,0,0,0,
    1,0,0,0,
    3,0,0,0,
    0,0,0,0,
    5,0,0,0,
    4,0,0,0,
    0,0,0,0,
};

const note chime_notes[] = {
    {SILENCE, 0,     0,     0},
    {E6,      0xF6U, 0xC6U, 0},
    {G6,      0xF6U, 0xC6U, 0},
    {Gd6,     0xF6U, 0xC6U, 0},
    {A6,      0xF6U, 0xC6U, 0},
    {B6,      0xF6U, 0xC6U, 0},
    {Cd7,     0xF6U, 0xC6U, 0},
    {D7,      0xF6U, 0xC6U, 0},
    {E7,      0xF6U, 0xC6U, 0},
};

const BYTE chime_loop[] = {
    1,0,3,1,
    3,0,0,1,
    3,1,3,0,
    0,1,3,4,
    3,4,5,0,
    0,3,4,5,
    1,0,3,1,
    3,0,0,1,
    3,1,3,0,
    0,1,3,4,
    3,4,5,0,
    0,3,4,8
};

const note drum_notes[] = {
    {SILENCE, 0,     0,     0},
    {E5,      0xE1U, 0xCFU, 0},
    {A6,      0xF0U, 0xCFU, 0},
};

const BYTE drum_loop1[] = {
    0,0,0,0,
    0,0,0,0,
    0,0,0,0,
    0,0,0,0,
    0,0,0,0,
    0,0,0,0,
    0,0,0,0,
    2,0,1,0,
    1,0,1,0,
    2,0,1,0,
    1,0,1,0,
    2,0,1,0,
};

const BYTE drum_loop2[] = {
    1,0,1,0,
    2,0,1,0,
    1,0,1,0,
    2,0,1,0,
    1,0,1,0,
    2,0,1,0,
    1,0,1,0,
    2,0,1,0,
    1,0,1,0,
    2,0,1,0,
    1,0,1,0,
    2,0,1,0,
};

const BYTE drum_loop3[] = {
    1,2,1,1,
    2,1,2,2,
    1,2,1,1,
    2,1,2,2,
    1,2,1,1,
    2,1,2,2,
    1,2,1,1,
    2,1,2,2,
    1,2,1,1,
    2,1,2,2,
    1,2,1,1,
    2,1,2,2,
};

void set_note(int channel, note *n){
    if ((*n).pitch == SILENCE) return;

    switch(channel){
        case 1:
            NR10_REG = (*n).pitch_sweep;
            NR11_REG = (*n).wave_duty;
            NR12_REG = (*n).volume_envelope;
            NR13_REG = (UBYTE)freq[(*n).pitch]; // low bits
            NR14_REG = 0x80U | ((UWORD)freq[(*n).pitch]>>8); // high bits
            break;
        case 2:
            NR21_REG = (*n).wave_duty;
            NR22_REG = (*n).volume_envelope;
            NR23_REG = (UBYTE)freq[(*n).pitch];
            NR24_REG = 0x80U | ((UWORD)freq[(*n).pitch]>>8);
            break;
        case 3:
            NR31_REG = (*n).wave_duty;
            NR32_REG = (*n).volume_envelope;
            NR33_REG = (UBYTE)freq[(*n).pitch];
            NR34_REG = 0x80U | ((UWORD)freq[(*n).pitch]>>8);
            break;
        case 4:
            NR41_REG = (*n).wave_duty;
            NR42_REG = (*n).volume_envelope;
            NR43_REG = noise_freq[(*n).pitch];
            NR44_REG = 0xC0U;
            NR51_REG |= 0x88;
            break;
    }
}

void play_music() {
    switch (loop_num) {
        case 6:
        case 0:
            set_note(1, &bass_notes[bass_loop[beat]]);
            set_note(4, &drum_notes[drum_loop1[beat]]);
            break;
        case 1:
            set_note(1, &bass_notes[bass_loop[beat]]);
            set_note(4, &drum_notes[drum_loop2[beat]]);
            set_note(2, &chime_notes[chime_loop[beat]]);
            break;
        case 7:
        case 2:
            set_note(1, &bass_notes[bass_loop[beat]]);
            set_note(4, &drum_notes[drum_loop2[beat]]);
            break;
        case 3:
            set_note(1, &bass_notes[bass_loop[beat]]);
            set_note(2, &strings_notes[strings_loop[beat]]);
            set_note(4, &drum_notes[drum_loop2[beat]]);
            break;
        case 5:
            set_note(1, &bass_notes[bass_loop[beat]]);
            set_note(2, &chime_notes[chime_loop[beat]]);
            set_note(4, &drum_notes[drum_loop3[beat]]);
            break;
        case 8:
            set_note(2, &chime_notes[chime_loop[beat]]);
            set_note(1, &strings_notes[chime_loop[beat]]);
            break;
        case 9:
            set_note(2, &chime_notes[chime_loop[beat]]);
            set_note(1, &bass_notes[strings_loop[beat]]);
            break;
        default:
            set_note(1, &bass_notes[bass_loop[beat]]);
            set_note(2, &chime_notes[chime_loop[beat]]);
            set_note(4, &drum_notes[drum_loop2[beat]]);
            break;
    }
    
    NR51_REG |= 0x11U;
}

void setup_audio () {
    NR52_REG = 0xFFU;
    NR51_REG = 0x00U;
    NR50_REG = 0x77U;
}

void update_audio () {
    if (music_timer == 0) {
        play_music();
        beat++;
        if (beat == BEATS) {
            beat = 0;
            loop_num++;
            if (loop_num == LOOPS) loop_num = 0;
        }
    }
    music_timer++;
    if (music_timer == PLAYBACK_SPEED) music_timer = 0;
}
#endif
