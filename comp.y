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
 TS ts;
 void inst(const char *);
 void instarg(const char *, int);
 void comment(const char *);
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
%type <val> NUM Exp
%type <car> CARACTERE
%type <val> Jumpif Jumpelse Wlabel Jumpwhile
%type <id> LValue


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

ListVar : ListVar VRG Ident
	| Ident
	;

Ident : IDENT Tab{
		insert(&ts, cur_type, $1);
	};

Tab : Tab LSQB ENTIER RSQB
	| /* rien*/ 
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

Corps : LACC DeclConst DeclVar SuiteInstr RACC;

DeclVar : DeclVar TYPE ListVar PV{
		cur_type = $2;
	}
	| /* rien */
	;

SuiteInstr : SuiteInstr Instr
	| /* rien */
	;

InstrComp : LACC SuiteInstr RACC;

Instr : LValue EGAL Exp PV{
		Valeur val;
		if(isalpha($3)){
			val.caractere = $3;
		}
		else{
			val.entier = $3;
		}
		setID(&ts, $1, val);
	}
	| IF LPAR Exp RPAR Jumpif Instr %prec NOELSE {instarg("LABEL", $5);}
	| IF LPAR Exp RPAR Jumpif Instr ELSE Jumpelse {instarg("LABEL", $5);} Instr {instarg("LABEL", $8);}
	| WHILE Wlabel {instarg("LABEL", $2);} LPAR Exp Jumpwhile RPAR Instr {instarg("JUMP", $2); instarg("LABEL", $6);} 
	| RETURN Exp PV
	| RETURN PV
	| IDENT LPAR Arguments RPAR PV
	| READ LPAR IDENT RPAR PV
	| READCH LPAR IDENT RPAR PV
	| PRINT LPAR Exp RPAR PV{
		instarg("SET", $3);
		if(isalpha($3)){
			inst("WRITECH");
		}
		else{
			inst("WRITE");
		}
	}
	| PV
	| InstrComp
	;

Jumpif : {
		comment("---Deb Jumpif");
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
		comment("---Deb Wlabel");
		$$ = jump_label++;
		comment("---Fin Wlabel");
	}
	;

Jumpwhile : {
		comment("---Deb Jumpwhile");
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
		if($2 == '+') $$ = $1 + $3;
		else if($2 == '-') $$ = $1 - $3;
		instarg("SET", $$);
	}
	| Exp DIVSTAR Exp {
		if($2 == '*') $$ = $1 * $3;
		else if($2 == '/') $$ = $1 / $3;
		instarg("SET", $$);
	}
	| Exp COMP Exp{
		if(0 == strcmp($2, "<")){
			$$ =  $1 < $3;
			instarg("SET", $$);
			inst("PUSH");
		}
		else if(0 == strcmp($2, ">")){
			$$ = $1 > $3;
			instarg("SET", $$);
		}
		else if(0 == strcmp($2, "<=")){
			$$ =  $1 <= $3;
			instarg("SET", $$);
		}
		else if(0 == strcmp($2, ">=")){
			$$ =  $1 >= $3;
			instarg("SET", $$);
		}
		else if(0 == strcmp($2, "==")){
			$$ =  $1 == $3;
			instarg("SET", $$);
		}
		else if(0 == strcmp($2, "!=")){
			$$ =  $1 != $3;
			instarg("SET", $$);
		}
	}
	| ADDSUB Exp{

	}
	| Exp BOPE Exp{
		if(0 == strcmp($2, "&&")){
			$$ = $1 && $3;
			instarg("SET", $$);
		}
		else if(0 == strcmp($2, "||")){
			$$ = $1 || $3;
			instarg("SET", $$);
		}
	}
	| NEGATION Exp {
		if(0 == $2) $$ = 1;
		else $$ = 0;
		instarg("SET", $$);
	}
	| LPAR Exp RPAR {
		$$ = $2;
		instarg("SET", $$);
	}
	| LValue{
		Valeur val;
		int type;
		type = getVal(&ts, $1, &val);
		switch(type){
		case 0:
			$$ = val.entier;
			break;
		case 1:
			$$ = val.caractere;
			break;	
		}
		instarg("SET", $$);
	}
	| NUM {
		$$ = $1;
		instarg("SET", $1);
	}
	| CARACTERE {
		$$ = $1;
		instarg("SET", $1);
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

