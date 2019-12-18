#ifndef BEISBOL_TYPES
#define BEISBOL_TYPES

typedef struct {
    char *name;
    unsigned char pp, type, effect, accuracy, power;
} Move;

typedef struct {
    char *name;
    char *description;
    unsigned char num, type1, type2;
    unsigned char evolves_to, evolve_type;
    unsigned char hp, bat, field, speed, throw;
    unsigned char lineup_body, lineup_head, lineup_hat;
} Roledex;

typedef struct {
    char *nickname;
    unsigned char num;
    unsigned char move_ids[4];
    unsigned char move_pp[4];
    unsigned char level, hp, position, batting_order;
    unsigned int hits, at_bats;//, plate_appearances, walks;
    unsigned int outs_recorded, runs_allowed;//, walks_allowed, strikeouts;
} Player;

#endif
