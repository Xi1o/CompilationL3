#ifndef H_TABLE_SYMBOLES
#define H_TABLE_SYMBOLES

#define MAX_ID 32
#define MAX_TABLE 1024
#define ENT 0
#define CARAC 1 
#define CONSTENT 2
#define CONSTCAR 3

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

void initTables(TS **ts);

void freeTables(TS **ts);

void addTable(TS **ts, int newlen);

void removeTable(TS **ts, int newlen);

void insert(TS *ts, int type, int adresse, char id[MAX_ID]);

void setSize(TS *ts, int taille, int index);

int contains(TS *ts, char id[MAX_ID]);

#endif
