#include "table_symboles.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

void init(TS *ts){
  ts->index = 0;
}

void insert(TS *ts, int type, char id[MAX_ID]){
  if(-1 != contains(ts, id)){
    fprintf(stderr, "Erreur : ID %s déjà existant.\n", id);
    exit(EXIT_FAILURE);
  }

  ts->table[ts->index].type = type;
  strncpy(ts->table[ts->index].id, id, MAX_ID);
  ts->table[ts->index].type = type;
  ts->index++;
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

int getVal(TS *ts, char id[MAX_ID], Valeur *val){
  int i;

  if(-1 == (i = contains(ts, id))){
    fprintf(stderr, "Erreur : get ID '%s' inconnu.\n", id);
    exit(EXIT_FAILURE);
  }
  switch(ts->table[i].type){
  case ENT:
    val->entier = ts->table[i].valeur.entier;
    break;
  case CARAC:
    break;
  default:
    fprintf(stderr, "Erreur : type inconnu.");
    exit(EXIT_FAILURE);
  }
  return ts->table[i].type;
}

int setID(TS *ts, char id[MAX_ID], Valeur newval){
  int i;
  
  if(-1 == (i = contains(ts, id))){
    fprintf(stderr, "Erreur : set ID '%s' inconnu.\n", id);
    return 0;
  }
  switch(ts->table[i].type){
  case ENT:
    ts->table[i].valeur.entier = newval.entier;
    break;
  case CARAC:
    break;
  default:
    fprintf(stderr, "Erreur : type inconnu.");
    exit(EXIT_FAILURE);
  }
  return 1;
}
