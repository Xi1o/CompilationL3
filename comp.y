%{
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>
int yyerror(char*);
int yylex();
 FILE* yyin; 
 int jump_label = 0;
 void inst(const char *);
 void instarg(const char *,int);
 void comment(const char *);
%}


%union {
	int val;
	char signeope;
}

%left BOPE
%left COMP
%left ADDSUB
%left DIVSTAR
%left NEGATION

%token NUM BOPE CARACTERE COMP CONST DIVSTAR LACC RACC LPAR RPAR LSQB RSQB ENTIER IDENT MAIN NEGATION PRINT PV READ READCH RETURN TYPE VOID VRG EGAL IF ELSE WHILE
%type <val> NUM
%token <signeope> ADDSUB

%%
Prog : DeclConst DeclVarPuisFonct DeclMain;

DeclConst : DeclConst CONST ListConst PV
	| /* rien */
	;

ListConst : ListConst VRG IDENT EGAL Litteral
	| IDENT EGAL Litteral
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

Ident : IDENT Tab;

Tab : Tab LSQB ENTIER RSQB
	| /* rien */
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

DeclVar : DeclVar TYPE ListVar PV
	| /* rien */
	;

SuiteInstr : SuiteInstr Instr
	| /* rien */
	;

InstrComp : LACC SuiteInstr RACC;

Instr : LValue EGAL Exp PV
	/*| IF LPAR Exp RPAR Instr NOELSE */
	| IF LPAR Exp RPAR Instr ELSE Instr
	| WHILE LPAR Exp RPAR Instr
	| RETURN Exp PV
	| RETURN PV
	| IDENT LPAR Arguments RPAR PV
	| READ LPAR IDENT RPAR PV
	| READCH LPAR IDENT RPAR PV
	| PRINT LPAR Exp RPAR PV{
		inst("POP");
		inst("WRITE");
	}
	| PV
	| InstrComp
	;

Arguments :ListExp
	| /* rien */
	;

LValue : IDENT TabExp;

TabExp : TabExp LSQB Exp RSQB;

ListExp : ListExp VRG Exp
	| Exp
	;

Exp : Exp ADDSUB Exp {
			inst("POP");
			inst("SWAP");
			inst("POP");
			if ( $2 == '+' ) inst("ADD");
			else if ( $2 == '-' ) inst("SUB");
			inst("PUSH");
	}
	| Exp DIVSTAR Exp
	| Exp COMP Exp
	| ADDSUB Exp
	| Exp BOPE Exp
	| NEGATION Exp
	| LPAR Exp RPAR
	| LValue
	| NUM { 
		instarg("SET", $1);
		inst("PUSH");
	}
	| CARACTERE
	| IDENT LPAR Arguments RPAR
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
  yyparse();
  endProgram();
  return 0;
}

