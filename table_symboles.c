#include "table_symboles.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

void init(TS *ts){
  ts->index = 0;
}

void insert(TS *ts, int type, char id[MAX_ID], int valeur){
  if(-1 != contains(ts, id)){
    fprintf(stderr, "Erreur : ID %s déjà existant.\n", id);
    exit(EXIT_FAILURE);
  }
  switch(type){
  case ENT:
    ts->table[ts->index].valeur = valeur;
    break;
  case CARAC:
    break;
  default:
    fprintf(stderr, "Unknown type.\n");
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

int getVal(TS *ts, char id[MAX_ID], int *val){
  int i;

  if(-1 == (i = contains(ts, id))){
    fprintf(stderr, "Erreur : ID %s inconnu.\n", id);
    return 0;
  }
  *val = ts->table[i].valeur;
  return 1;
}

int setID(TS *ts, char id[MAX_ID], int newval){
  int i;
  
  if(-1 == (i = contains(ts, id))){
    fprintf(stderr, "Erreur : ID %s inconnu.\n", id);
    return 0;
  }
  ts->table[i].valeur = newval;
  return 1;
}
