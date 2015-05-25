#include "table_symboles.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

void init(TS *ts){
  ts->index = 0;
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
