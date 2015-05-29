#ifndef H_TABLE_SYMBOLES
#define H_TABLE_SYMBOLES

#define MAX_ID 32
#define MAX_TABLE 1024
#define MAX_ARG 64
#define VOID_ 0
#define CONSTENT 1
#define CONSTCAR 2
#define ENT 3
#define CARAC 4

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

typedef struct{
  TS ts;
  Symbole symb;
  int nb_args;
  char args_id[MAX_ARG][MAX_ID];
  int args_type[MAX_ARG];
  int args_adr[MAX_ARG];
}Fonction;

typedef struct{
  Fonction fonc[MAX_TABLE];
  int index;
}TSfonc;

void init(TS *ts);

void insert(TS *ts, int type, int adresse, char id[MAX_ID]);

void setSize(TS *ts, int taille, int index);

int contains(TS *ts, char id[MAX_ID]);

void insertFonc(TSfonc *ts, int type, int adresse, char id[MAX_ID], int nb_args, char args_id[MAX_ARG][MAX_ID], int args_type[MAX_ARG]);

int containsFonc(TSfonc *ts, char id[MAX_ID]);

#endif
