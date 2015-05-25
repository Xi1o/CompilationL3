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
  int adresse;
}Symbole;

typedef struct{
  Symbole table[MAX_TABLE];
  int index; /*index 1ere case vide*/
}TS;

void init(TS *ts);

void insert(TS *ts, int type, int adresse, char id[MAX_ID]);

void setSize(TS *ts, int taille, int index);

int contains(TS *ts, char id[MAX_ID]);

#endif
