/* PROJET COMPILATION L3 Informatique
	Auteurs :
		Raphaël CHENEAU <rcheneau@etud.u-pem.fr>
		Bryan LEE <blee@etud.u-pem.fr>
*/

#ifndef H_TABLE_SYMBOLES
#define H_TABLE_SYMBOLES

#define MAX_ID 32
#define MAX_TABLE 1024
#define MAX_ARG 64
#define MAX_DIM 8
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
  int tab; /*0 ou nb dimension si est un tableau*/
  int dimensions[MAX_DIM];
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

/**
 * Initialisation d'une table des symboles.
 * Initialise l'index à 0.
*/
void init(TS *ts);

/**
 * Insertion d'un nouveau symbole dans la table.
 * Incrémente l'index de 1.
 */
void insert(TS *ts, int type, int adresse, char id[MAX_ID]);

/**
 * Met à la dimension d'indice i sa taille (tableaux).
 */
void setSizeDimension(TS *ts, int size, int i, int index);

/**
 * Sauvegarde le nombre de dimension que possède le tableau.
 */
void setDimension(TS *ts, int nb, int index);

/**
 * Sauvegarde la taille d'un élément dans la table des symboles à l'indice index.
 */
void setSize(TS *ts, int taille, int index);

/**
 * Retourne 1 si la table des symboles possède l'indentifiant id, 0 sinon.
 */
int contains(TS *ts, char id[MAX_ID]);

/**
 * Similaire à insert mais ici rempli une table des symboles pour les fonctions.
 */
void insertFonc(TSfonc *ts, int type, int adresse, char id[MAX_ID], int nb_args, char args_id[MAX_ARG][MAX_ID], int args_type[MAX_ARG]);

/**
 * Similaire à contains mais pour les fonctions, retourn 1 si contient la fonction id, 0 sinon.
 */
int containsFonc(TSfonc *ts, char id[MAX_ID]);

#endif
