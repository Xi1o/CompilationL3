/* PROJET COMPILATION L3 Informatique
	Auteurs :
		Raphaël CHENEAU <rcheneau@etud.u-pem.fr>
		Bryan LEE <blee@etud.u-pem.fr>
*/

#include "table_symboles.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <assert.h>

/*
 * Met l'index de la table des symboles à 0.
 **/
void init(TS *ts){
  ts->index = 0;
}

void insert(TS *ts, int type, int adresse, char id[MAX_ID]){
  if(-1 != contains(ts, id)){
    fprintf(stderr, "Erreur : ID <%s> déjà existant.\n", id);
    exit(EXIT_FAILURE);
  }

  ts->table[ts->index].type = type;
  strncpy(ts->table[ts->index].id, id, MAX_ID);
  ts->table[ts->index].id[MAX_ID-1] = '\0';
  ts->table[ts->index].type = type;
  ts->table[ts->index].adresse = adresse;
  ts->index++;
}

void setSize(TS *ts, int taille, int index, int is_tab){
  ts->table[index].taille = taille;
  ts->table[index].tab = is_tab;
}

int contains(TS *ts, char id[MAX_ID]){
  int i;

  for(i = 0; i < ts->index; i++){
    if(0 == strncmp(id, ts->table[i].id, MAX_ID)){
      return i;
    }
  } 
  return -1;
}

void insertFonc(TSfonc *ts, int type, int adresse, char id[MAX_ID], int nb_args, char args_id[MAX_ARG][MAX_ID], int args_type[MAX_ARG]){
  int i;
  if(-1 != containsFonc(ts, id)){
    fprintf(stderr, "Erreur : ID %s déjà existant.\n", id);
    exit(EXIT_FAILURE);
  }

  ts->fonc[ts->index].symb.type = type;
  strncpy(ts->fonc[ts->index].symb.id, id, MAX_ID);
  ts->fonc[ts->index].symb.id[MAX_ID-1] = '\0';
  ts->fonc[ts->index].symb.adresse = adresse;
  ts->fonc[ts->index].symb.taille = 1;
  
  ts->fonc[ts->index].nb_args = nb_args;
  for(i = 0 ; i < nb_args; i++){
    strncpy(ts->fonc[ts->index].args_id[i], args_id[i], MAX_ID);
    ts->fonc[ts->index].args_id[i][MAX_ID-1] = '\0';
    ts->fonc[ts->index].args_type[i] = args_type[i];
    ts->fonc[ts->index].args_adr[i] = i;
  }
  
  ts->index++;
}

int containsFonc(TSfonc *ts, char id[MAX_ID]){
  int i;

  for(i = 0; i < ts->index; i++){
    if(0 == strncmp(id, ts->fonc[i].symb.id, MAX_ID)){
      return i;
    }
  } 
  return -1;
}
