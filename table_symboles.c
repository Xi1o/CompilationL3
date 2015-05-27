#include "table_symboles.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

/*
 * Met l'index de la table des symboles à 0.
 **/
static void init(TS *ts){
  ts->index = 0;
}

/*
 * Réalloue la table des symboles à la taille newlen.
 */
static int editTable(TS **ts, int newlen){
  TS *new_ts;

  new_ts = (TS*) realloc(*ts, sizeof(TS)*newlen);
  if(!new_ts){
    return -1;
  }
  *ts = new_ts;
  return 0;
}

void initTables(TS **ts){
  /*Alloue 2 tables des symboles (globale et main).*/
  *ts = (TS*) malloc(sizeof(TS)*2);
  if(!*ts){
    fprintf(stderr, "Erreur allocations tables.\n");
    exit(EXIT_FAILURE);
  }
  /*Initialise la table des globales.*/
  init(*ts);
  /*Initialise la table du main.*/
  init(*ts+1);
}

void freeTables(TS **ts){
  free(*ts);
}

void addTable(TS **ts, int newlen){
  if(-1 == editTable(ts, newlen)){
    fprintf(stderr, "Erreur ajout table.\n");
    exit(EXIT_FAILURE);
  }
  /*Initialise la nouvelle table.*/
  init(*ts+newlen-1);
}

void removeTable(TS **ts, int newlen){
  if(-1 == editTable(ts, newlen)){
    fprintf(stderr, "Erreur suppression table.\n");
    exit(EXIT_FAILURE);
  }
}

void insert(TS *ts, int type, int adresse, char id[MAX_ID]){
  if(-1 != contains(ts, id)){
    fprintf(stderr, "Erreur : ID %s déjà existant.\n", id);
    exit(EXIT_FAILURE);
  }

  ts->table[ts->index].type = type;
  strncpy(ts->table[ts->index].id, id, MAX_ID);
  ts->table[ts->index].type = type;
  ts->table[ts->index].adresse = adresse;
  ts->index++;
}

void setSize(TS *ts, int taille, int index){
  ts->table[index].taille = taille;
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
