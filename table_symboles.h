#ifndef H_TABLE_SYMBOLES
#define H_TABLE_SYMBOLES

#define MAX_ID 32
#define MAX_TABLE 1024
#define ENT 0
#define CARAC 1

typedef struct{
  char id[MAX_ID];
  int type;
  int taille;
  int valeur;
}Symbole;

typedef struct{
  Symbole table[MAX_TABLE];
  int index; /*index 1ere case vide*/
}TS;

void init(TS *ts);

void insert(TS *ts, int type, char id[MAX_ID], int valeur);

int contains(TS *ts, char id[MAX_ID]);

int getVal(TS *ts, char id[MAX_ID], int *val);

int setID(TS *ts, char id[MAX_ID], int newval);

#endif
