%{
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <ctype.h>
#include "table_symboles.h"

int yyerror(char*);
int yylex();
 FILE* yyin;
 int jump_label = 0;
 int cur_type;
 int last_free_adr = 0;
 TS ts;
 void inst(const char *);
 void instarg(const char *, int);
 void comment(const char *);
 void setID(TS *ts, char id[32]);
 int getVal(TS *ts, char id[32]);
%}

%union {
	int val;
	char car;
	char signeope;
	char comp[2];
	int type;
	char id[32];
}

%left BOPE
%left COMP
%left ADDSUB
%left DIVSTAR
%left NEGATION
%left NOELSE
%left ELSE

%token NUM CARACTERE
%token <id> IDENT
%token <type> TYPE 
%token <comp> COMP
%token <signeope> ADDSUB DIVSTAR
%token <comp> BOPE
%token NEGATION
%token EGAL PV VRG LPAR RPAR LACC RACC LSQB RSQB
%token IF ELSE NOELSE WHILE
%token PRINT READ READCH
%token CONST ENTIER 
%token MAIN RETURN VOID
%type <val> NUM ENTIER
%type <car> CARACTERE
%type <val> DeclVar ListVar
%type <val> Jumpif Jumpelse Wlabel Jumpwhile
%type <id> LValue
%type <type> Exp


%%
Prog : DeclConst DeclVarPuisFonct DeclMain;

DeclConst : DeclConst CONST ListConst PV
	| /* rien */
	;

ListConst : ListConst VRG IDENT EGAL Litteral
	| IDENT EGAL Litteral{
		
	}
	;

Litteral : NombreSigne
	| CARACTERE
	;

NombreSigne : NUM
	| ADDSUB NUM
	;

DeclVarPuisFonct : TYPE ListVar PV DeclVarPuisFonct
	| DeclFonct
	| /* rien */
	;

ListVar : ListVar VRG Ident{
		$$ = $1 + 1;
		last_free_adr += 1;
	}
	| Ident{
		$$ = 1;
		last_free_adr += 1;
	}
	;

Ident : IDENT Tab{
		insert(&ts, cur_type, last_free_adr, $1);
	}
	;

Tab : Tab LSQB ENTIER RSQB{
	}
	| /*rien*/ {
		setSize(&ts, 1, ts.index-1);
	} 
	;

DeclMain : EnTeteMain Corps;

EnTeteMain : MAIN LPAR RPAR;

DeclFonct : DeclFonct DeclUneFonct
	| DeclUneFonct
	;

DeclUneFonct : EnTeteFonct Corps;

EnTeteFonct : TYPE IDENT LPAR Parametres RPAR
	| VOID IDENT LPAR Parametres RPAR
	;

Parametres : VOID
	| ListTypVar
	;

ListTypVar : ListTypVar VRG TYPE IDENT
	| TYPE IDENT
	;

Corps : LACC DeclConst DeclVar {instarg("ALLOC", $3);} SuiteInstr RACC
	;

DeclVar : DeclVar TYPE {cur_type = $2;} ListVar PV{
		
		$$ += $4;
	}
	| /* rien */ {}
	;

SuiteInstr : SuiteInstr Instr
	| /* rien */
	;

InstrComp : LACC SuiteInstr RACC;

Instr : LValue EGAL Exp PV{
		setID(&ts, $1);
	}
	| IF LPAR Exp RPAR Jumpif Instr %prec NOELSE {instarg("LABEL", $5);}
	| IF LPAR Exp RPAR Jumpif Instr ELSE Jumpelse {instarg("LABEL", $5);} Instr {instarg("LABEL", $8);}
	| WHILE Wlabel {instarg("LABEL", $2);} LPAR Exp RPAR Jumpwhile Instr {instarg("JUMP", $2); instarg("LABEL", $7);} 
	| RETURN Exp PV
	| RETURN PV
	| IDENT LPAR Arguments RPAR PV
	| READ LPAR IDENT RPAR PV
	| READCH LPAR IDENT RPAR PV
	| PRINT LPAR Exp RPAR PV{
		inst("POP");
		if(0 == $3){
			inst("WRITE");
		}
		else if(1 == $3){
			inst("WRITECH");
		}
	}
	| PV
	| InstrComp
	;

Jumpif : {
		comment("---Deb Jumpif");
		inst("POP");
		instarg("JUMPF", $$ = jump_label++);
		comment("---Fin Jumpif");
	}
	;

Jumpelse : {
		comment("---Deb Jumpelse");
		instarg("JUMP", $$ = jump_label++);
		comment("---Fin Jumpelse");
	}
	;

Wlabel : {
		$$ = jump_label++;
	}
	;

Jumpwhile : {
		comment("---Deb Jumpwhile");
		inst("POP");
		instarg("JUMPF", $$ = jump_label++);
		comment("---Fin Jumpwhile");
	}
	;

Arguments : ListExp
	| /* rien */
	;

LValue : IDENT TabExp{
		strncpy($$, $1, 32);
	}
	;

TabExp : TabExp LSQB Exp RSQB
	| /*rien*/
	;

ListExp : ListExp VRG Exp
	| Exp
	;

Exp : Exp ADDSUB Exp {
		inst("POP");
		inst("SWAP");
		inst("POP");
		if('+' == $2){
			inst("ADD");
		}
		else if('-' == $2){
			inst("SUB");
		}
		inst("PUSH");
	}
	| Exp DIVSTAR Exp {
		inst("POP");
		inst("SWAP");
		inst("POP");
		if('*' == $2){
			inst("MUL");
		}
		else if('/' == $2){
			inst("DIV");
		}
		inst("PUSH");
	}
	| Exp COMP Exp{
		if(0 == strcmp($2, "<")){
			inst("POP"); 
			inst("SWAP"); 
			inst("POP");
			inst("LESS");
			inst("PUSH");
		}
		else if(0 == strcmp($2, ">")){
			inst("POP");
			inst("SWAP");
			inst("POP");
			inst("GREATER");
			inst("PUSH");
		}
		else if(0 == strcmp($2, "<=")){
			inst("POP");
			inst("SWAP");
			inst("POP");
			inst("LEQ");
			inst("PUSH");
		}
		else if(0 == strcmp($2, ">=")){
			inst("POP");
			inst("SWAP");
			inst("POP");
			inst("GEQ");
			inst("PUSH");
		}
		else if(0 == strcmp($2, "==")){
			inst("POP");
			inst("SWAP");
			inst("POP");
			inst("EQUAL");
			inst("PUSH");
		}
		else if(0 == strcmp($2, "!=")){
			inst("POP");
			inst("SWAP");
			inst("POP");
			inst("NOTEQ");
			inst("PUSH");
		}
	}
	| ADDSUB Exp{

	}
	| Exp BOPE Exp{
		if(0 == strcmp($2, "&&")){
			inst("POP");
			inst("SWAP");
			inst("POP");
			inst("ADD");
			inst("SWAP");
			inst("SET 2");
			inst("EQUAL");
			inst("PUSH");
		}
		else if(0 == strcmp($2, "||")){
			inst("POP");
			inst("SWAP");
			inst("POP");
			inst("ADD");
			inst("SWAP");
			inst("SET 1");
			inst("LEQ");
			inst("PUSH");
		}
	}
	| NEGATION Exp {
		inst("POP");
		inst("SWAP");
		inst("SET 1");
		inst("SUB");
		inst("PUSH");
	}
	| LPAR Exp RPAR {

	}
	| LValue{
		$$ = getVal(&ts, $1);
	}
	| NUM {
		instarg("SET", $1);
		inst("PUSH");
		$$ = 0;
	}
	| CARACTERE {
		instarg("SET", $1);
		inst("PUSH");
		$$ = 1;
	}
	| IDENT LPAR Arguments RPAR{

	}
	;

%%

int yyerror(char* s) {
	fprintf(stderr,"%s\n",s);
	return 0;
}

void endProgram() {
	printf("HALT\n");
}

void inst(const char *s){
	printf("%s\n",s);
}

void instarg(const char *s,int n){
	printf("%s\t%d\n",s,n);
}

void comment(const char *s){
	printf("#%s\n",s);
}

void setID(TS *ts, char id[32]){
	int i, adr;

	comment("---DEB setID");
	if(-1 == (i = contains(ts, id))){
		fprintf(stderr, "Erreur : set ID %s inconnu.\n", id);
		exit(EXIT_FAILURE);
	}
	adr = ts->table[i].adresse;
	instarg("SET", adr);
	inst("SWAP");
	inst("POP");
	inst("SAVE");
	comment("---FIN setID");
}

int getVal(TS *ts, char id[32]){
	int i, adr;

	comment("---DEB getVal");
	if(-1 == (i = contains(ts, id))){
		fprintf(stderr, "Erreur : get ID %s inconnu.\n", id);
		exit(EXIT_FAILURE);
	}
	adr = ts->table[i].adresse;
	instarg("SET", adr);
	inst("LOAD");
	inst("PUSH");
	comment("---FIN getVal");
	return ts->table[i].type;
}

int main(int argc, char** argv) {
	if(argc==2){
		yyin = fopen(argv[1],"r");
	}

	else if(argc==1){
		yyin = stdin;
	}

	else{
		fprintf(stderr,"usage: %s [src]\n",argv[0]);
		return 1;
	}

	init(&ts);
	yyparse();
	endProgram();
	return 0;
}

