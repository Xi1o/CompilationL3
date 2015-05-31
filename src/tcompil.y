/* PROJET COMPILATION L3 Informatique
	Auteurs :
		Raphaël CHENEAU <rcheneau@etud.u-pem.fr>
		Bryan LEE <blee@etud.u-pem.fr>
*/

%{
	#include <stdlib.h>
	#include <stdio.h>
	#include <unistd.h>
	#include <string.h>
	#include <ctype.h>
	#include <unistd.h>
	#include "table_symboles.h"

	void yyerror(char*);
	void inst(const char *);
	void instarg(const char *, int);
	void comment(const char *);
	void setIndexFonction(char id[MAX_ID]);
	void callFonction(char id[MAX_ID]);
	void setFonction(int nb_args);

	int setID(TS *ts, char id[MAX_ID]);
	int getVal(TS *ts, char id[MAX_ID]);
	int getDimSize(int *dimensions, int from, int n);

	FILE* yyin;
	FILE* output_stream; /* OPTION : fichier d'exportation du code machine */

	TS ts[2]; /*Tables des symboles global + main.*/
	TS *cur_ts; /*Pointeur table des symboles actuelle.*/
	TSfonc ts_fonc; /*Table des symboles de fonctions.*/

	int yylex();
	int yylineno;
	int jump_label = 1; /*Valeur premier label.*/
	int var_size; /*taille de la variable actuelle.*/
	int is_tab; /*1 si tableau 0 sinon.*/
	int tab; /*sauvegarde si is_tab a été mis à 1.*/
	int cur_type; /*Type de la variable actuelle.*/
	int last_free_adr = 0; /*Adresse pile libre disponible.*/
	int cur_fonc; /*Indice de la fonction actuelle*/
	int fst_fonc = 1; /*1 si c'est la 1ère fonction déclarée, 0 sinon*/
	int decl_fonc = 1; /*1 si entrain de déclarer des fonctions, 0 sinon*/
	int args_type[MAX_ARG]; /*Tableau contenant les types des arguments.*/
	int has_returned; /*0 si une fonction de type non void n'a pas return, 1 sinon.*/
	int opt; /* OPTION : reconnaissance d'options */
	int opt_o_used = 0 ; /* OPTION : 0 si l'option -o n'a pas été utilisée, 1 sinon */ 

	char args_id[MAX_ARG][MAX_ID]; /*Tableau contenant les identifiants des arguments.*/
	char opt_o_filename[500] = ""; /* OPTION : buffer to receive the exported .vm file */

%}

%locations

%code requires {
	#define MAXID 32
	#define GLOB 0
}

%union {
	int val;
	char car;
	char signeope;
	char comp[2];
	int type;
	char id[MAXID];
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
%type <val> DeclConst ListConst DeclVar ListVar ListTypVar Parametres ListExp 
%type <val> Jumpif Jumpelse Wlabel Jumpwhile EnTeteFonct Type Tab Ident
%type <id> LValue
%type <type> Exp Litteral

%%
Prog : DeclConst DeclVarPuisFonct DeclMain;

DeclConst : DeclConst CONST ListConst PV{
		$$ += $3;
	}
	| /* rien */ {$$ = 0;};

ListConst : ListConst VRG IDENT EGAL {instarg("ALLOC", 1);} Litteral{
		$$ = $1 + 1;
		insert(cur_ts, $6, last_free_adr, $3);
		setID(cur_ts, $3);
		last_free_adr += 1;
	}
	| IDENT EGAL {instarg("ALLOC", 1);} Litteral{
		$$ = 1;	
		insert(cur_ts, $4, last_free_adr, $1);
		setID(cur_ts, $1);
		last_free_adr += 1;
	};

Litteral : NombreSigne{
		$$ = CONSTENT;
	}
	| CARACTERE {
		$$ = CONSTCAR;
		instarg("SET", $1);
		inst("PUSH");
	};

NombreSigne : NUM {
		instarg("SET", $1);
		inst("PUSH");
	}
	| ADDSUB NUM {
		if('-' == $1){
			instarg("SET", -$2);
		}
		else{
			instarg("SET", $2);
		}
		inst("PUSH");
	};

DeclVarPuisFonct : Type ListVar {instarg("ALLOC", $2);} PV DeclVarPuisFonct
	| DeclFonct
	| /*rien*/;

ListVar : ListVar VRG Ident{
		$$ += $3;
	}
	| Ident{
		$$ = $1;
	};

Ident : IDENT {insert(cur_ts, cur_type, last_free_adr, $1);is_tab = 0;} Tab {
		$$ = $3;
		last_free_adr += $$;
		setDimension(cur_ts, is_tab, cur_ts->index-1);
	};

Tab : Tab LSQB NUM RSQB{
		setSizeDimension(cur_ts, $3, is_tab, cur_ts->index-1);
		var_size = $3;
		is_tab += 1;
		$$ *= $3;
	}
	| /*rien*/ {	
		setSize(cur_ts, 1, cur_ts->index-1);
		$$ = 1;
	};

DeclMain : EnTeteMain {instarg("LABEL", 0);} Corps{
	
	};

EnTeteMain : MAIN LPAR RPAR{
		decl_fonc = 0;
		cur_ts = &ts[1];
	};

DeclFonct : DeclFonct DeclUneFonct
	| DeclUneFonct;

DeclUneFonct : EnTeteFonct {if(1 == fst_fonc){instarg("JUMP", 0);fst_fonc = 0;}comment("---DeclUneFonct");instarg("LABEL", jump_label++);last_free_adr = 0;setFonction($1);} Corps {
		if(0 == has_returned) yyerror("Retour manquant.");
		inst("RETURN");
	};

EnTeteFonct : Type IDENT LPAR Parametres RPAR{
		if(MAX_ARG == $4){
			yyerror("Max argument dépassé.");
		}
		insertFonc(&ts_fonc, $1, jump_label, $2, $4, args_id, args_type);
		$$ = $4;
		has_returned = 0;
	}
	| VOID IDENT LPAR Parametres RPAR{
		if(MAX_ARG == $4){
			yyerror("Max argument dépassé.");
		}
		
		insertFonc(&ts_fonc, VOID_, jump_label, $2, $4, args_id, args_type);
		$$ = $4;
		/*La fonction peut se passer du return.*/
		has_returned = 1;
	};

Parametres : VOID{
		$$ = 0;
	}
	| ListTypVar{
		$$ = $1;
	};

ListTypVar : ListTypVar VRG Type IDENT {
		args_type[$$] = $3;
		strncpy(args_id[$$], $4, MAX_ID);
		$$ += 1;
	}
	| Type IDENT {
		args_type[0] = $1;
		strncpy(args_id[0], $2, MAX_ID);
		$$ = 1;
	};

Corps : LACC DeclConst DeclVar {instarg("ALLOC", $3);} SuiteInstr RACC {
		last_free_adr = 0;
	};

DeclVar : DeclVar Type ListVar PV {	
		$$ += $3;
	}
	| /* rien */ {$$ = 0;};

SuiteInstr : SuiteInstr Instr
	| /* rien */;

InstrComp : LACC SuiteInstr RACC;

Type : TYPE {cur_type = $1; $$=$1;};

Instr : LValue {tab=0;if(1==is_tab){tab=1;}} EGAL Exp PV {
		int type;
		if(1 == tab) is_tab = 1;
		type = setID(cur_ts, $1);
		if(CONSTENT == type || CONSTCAR == type){
			yyerror("Les constantes ne peuvent être modifiées.");
		} 
		if(type != $4){
			yyerror("Type incorrecte.");
		}
	}
	| IF LPAR Exp RPAR Jumpif Instr %prec NOELSE {instarg("LABEL", $5);
	if(ENT != $3){yyerror("Condition avec entier seulement.");}}
	| IF LPAR Exp RPAR Jumpif Instr ELSE Jumpelse {instarg("LABEL", $5);} Instr {instarg("LABEL", $8);
	if(ENT != $3){yyerror("Condition avec entier seulement.");}}
	| WHILE Wlabel {instarg("LABEL", $2);} LPAR Exp RPAR Jumpwhile Instr {instarg("JUMP", $2); instarg("LABEL", $7);
	if(ENT != $5){yyerror("Condition avec entier seulement.");}}
	| RETURN Exp PV {
		comment("---RETURN Exp");
		if($2 != ts_fonc.fonc[cur_fonc].symb.type){
			yyerror("Retour fonction, type incorrecte.");
		}
		has_returned = 1;
		inst("POP");
		inst("RETURN");
	}
	| RETURN PV {
		comment("---RETURN");
		if(VOID_ != ts_fonc.fonc[cur_fonc].symb.type){
			yyerror("Valeur de retour manquante.");
		}
		inst("RETURN");
	}
	| IDENT LPAR {setIndexFonction($1);} Arguments RPAR PV {
		callFonction($1);
	}
	| READ LPAR IDENT RPAR PV {
		comment("---READ");
		inst("READ");
		inst("PUSH");
		setID(cur_ts, $3);
	}
	| READCH LPAR IDENT RPAR PV {
		comment("---READCH");
		inst("READCH");
		inst("PUSH");
		setID(cur_ts, $3);
	}
	| PRINT LPAR Exp RPAR PV{
		comment("---PRINT");
		inst("POP");
		if(ENT == $3){
			inst("WRITE");
		}
		else if(CARAC == $3){
			inst("WRITECH");
		}
		inst("PUSH");
	}
	| PV
	| InstrComp;

Jumpif : {
		comment("---Jumpif");
		inst("POP");
		instarg("JUMPF", $$ = jump_label++);
	};

Jumpelse : {
		comment("---Jumpelse");
		instarg("JUMP", $$ = jump_label++);
	};

Wlabel : {
		$$ = jump_label++;
	};

Jumpwhile : {
		comment("---Jumpwhile");
		inst("POP");
		instarg("JUMPF", $$ = jump_label++);
	};

Arguments : ListExp{
		if($1 < ts_fonc.fonc[cur_fonc].nb_args){
			yyerror("Fonction pas assez d'arguments.");
		}
	}
	| /* rien */{
		if(0 < ts_fonc.fonc[cur_fonc].nb_args){
			yyerror("Fonction pas assez d'arguments.");
		}
	};

LValue : IDENT {is_tab = 0;} TabExp {
		strncpy($$, $1, MAX_ID);
	};

TabExp : TabExp LSQB Exp RSQB {is_tab = 1;}
	| /*rien*/;

ListExp : ListExp VRG Exp{
		if($$ > ts_fonc.fonc[cur_fonc].nb_args){
			yyerror("Fonction trop d'arguments.");
		}
		if($3 != ts_fonc.fonc[cur_fonc].args_type[$$]){
			yyerror("Fonction argument type incorrecte.");
		}
		$$ += 1;
	}
	| Exp{
		if(0 == ts_fonc.fonc[cur_fonc].nb_args){
			yyerror("Fonction trop d'arguments.");
		}
		if($1 != ts_fonc.fonc[cur_fonc].args_type[0]){
			yyerror("Fonction argument type incorrecte.");
		}
		$$ = 1;
	};

Exp : Exp ADDSUB Exp {
		comment("---ADDSUB");
		if(ENT != $1 || ENT != $3){
			yyerror("Addition / soustraction avec entiers seulement.");
		}
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
		comment("---DIVSTAR");
		if(ENT != $1 || ENT != $3){
			yyerror("Multiplication / division avec entiers seulement.");
		}
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
		comment("---COMP");
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
		$$ = ENT;
	}
	| ADDSUB Exp{
		comment("---ADDSUB unaire");
		if(ENT != $1){
			yyerror("+/- avec entiers seulement.");
		}
		if('-' == $1){
			inst("POP");
			inst("NEG");
			inst("PUSH");
		}
	}
	| Exp BOPE Exp{
		comment("---BOPE");
		if(ENT != $1 || ENT != $3){
			yyerror("Booléens avec entiers seulement.");
		}
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
		comment("---NEGATION");
		if(ENT != $2){
			yyerror("Négation avec entier seulement.");
		}
		inst("POP");
		inst("SWAP");
		inst("SET 1");
		inst("SUB");
		inst("PUSH");
	}
	| LPAR Exp RPAR {$$ = $2;}
	| LValue {
		$$ = getVal(cur_ts, $1);
		/*Si de type CONST renvoie juste type de base pour les rendre compatibles.*/
		if(CONSTENT  == $$) $$ = ENT;
		else if(CONSTCAR == $$) $$ = CARAC;
	}
	| NUM {
		comment("---NUM");
		instarg("SET", $1);
		inst("PUSH");
		$$ = ENT;
	}
	| CARACTERE {
		comment("---CARACTERE");
		instarg("SET", $1);
		inst("PUSH");
		$$ = CARAC;
	}
	| IDENT LPAR {setIndexFonction($1);} Arguments RPAR{
		$$ = 3;
		callFonction($1);
		inst("PUSH");
	};

%%

void yyerror(char* s) {
	fprintf(stderr, "Erreur : %s\n", s);
	exit(EXIT_FAILURE);
}

void endProgram() {
	fprintf(output_stream, "HALT\n");
}

void inst(const char *s){
	fprintf(output_stream, "%s\n",s);
}

void instarg(const char *s,int n){
		fprintf(output_stream, "%s\t%d\n",s,n);
}

void comment(const char *s){
		fprintf(output_stream, "#%s\n",s);
}

int getDimSize(int *dimensions, int from, int n){
	int i, res;
	
	for(i = from, res = 1; i < n; i++){
		res *= dimensions[i];
	}
	return res;
}

/*
 * Place sur la pile l'adresse de l'indice i du tableau.
 * mode 0 = setID
 * mode 1 = getVal
*/
void setArrIndex(TS *ts, int i, int mode){
	int j, n;

	n = ts->table[i].tab;
	for(j = 0; j < n-1; j++){
		if(0 == mode) /*setID 1 élément en + sur la pile.*/
			instarg("SET", n+1);
		else /*getVal 1 élément en - sur la pile.*/
			instarg("SET", n);
		inst("SWAP");
		inst("TOPST");
		inst("SUB");
		inst("LOAD");
		inst("SWAP");
		instarg("SET", getDimSize(ts->table[i].dimensions, j+1, n));
		inst("MUL");
		inst("PUSH");		
	}
	if(0 == mode)
		instarg("SET", 2*(n+1)-(n+1));
	else
		instarg("SET", 2*(n+1)-(n+2));
	inst("SWAP");
	inst("TOPST");
	inst("SUB");
	inst("LOAD");
	inst("SWAP");
	for(j = 0; j < n-1; j++){
		inst("POP");
		inst("ADD");
		inst("SWAP");
	}
	instarg("SET", ts->table[i].adresse);
	inst("ADD");
}

int setID(TS *ts_locale, char id[MAX_ID]){
	int i, adr, in_glob;
	TS *ts_selec;

	comment("---setID");
	if(-1 == (i = contains(ts_locale, id))){
		if(-1 == (i = contains(&ts[GLOB], id))){
			fprintf(stderr, "Erreur : set ID <%s> inconnu.\n", id);
			exit(EXIT_FAILURE);
		}
		else{
			ts_selec = &ts[GLOB];
			in_glob = 1;
		}
	}
	else{
		ts_selec = ts_locale;
		in_glob = 0;
	}
	adr = ts_selec->table[i].adresse;
	if(0 == is_tab){
		instarg("SET", adr);
	}
	else{
		setArrIndex(ts_selec, i, 0);
	}
	inst("SWAP");
	inst("POP");
	
	/*Dans le main/globales.*/
	if(0 == decl_fonc || 1 == in_glob){
		inst("SAVE");
	}
	/*Dans une fonction.*/
	else{
		inst("SAVER");
	}
	return ts_selec->table[i].type;
}

int getVal(TS *ts_locale, char id[MAX_ID]){
	int i, adr, in_glob;
	TS *ts_selec;

	comment("---getVal");
	if(-1 == (i = contains(ts_locale, id))){
		if(-1 == ((i = contains(&ts[GLOB], id)))){
			fprintf(stderr, "Erreur : get ID <%s> inconnu.\n", id);
			exit(EXIT_FAILURE);
		}
		else{
			ts_selec = &ts[GLOB];
			in_glob = 1;
		}
	}
	else{
		ts_selec = ts_locale;
		in_glob = 0;
	}
	adr = ts_selec->table[i].adresse;
	instarg("SET", adr);
	if(is_tab){
		setArrIndex(ts_selec, i, 1);
	}
	/*Dans le main.*/
	if(0 == decl_fonc || 1 == in_glob){
		inst("LOAD");
	}
	/*Dans une fonction*/
	else{
		inst("LOADR");
	}
	inst("PUSH");
	return ts_selec->table[i].type;
}

void setIndexFonction(char id[MAX_ID]){
	if(-1 == (cur_fonc = containsFonc(&ts_fonc, id))){
		fprintf(stderr, "Erreur : fonction id <%s> inconnu.\n", id);
		exit(EXIT_FAILURE);
	}
}

void callFonction(char id[MAX_ID]){
	int adr;

	comment("---callFonction");
	adr = ts_fonc.fonc[cur_fonc].symb.adresse;
	instarg("CALL", adr);
}

void setFonction(int nb_args){
	int i, type;
	char *id_arg;

	comment("---setFonction");
	cur_ts = &ts_fonc.fonc[ts_fonc.index-1].ts;
	instarg("ALLOC", nb_args);
	for(i = 0; i < nb_args; i++){
		type = ts_fonc.fonc[ts_fonc.index-1].args_type[i];
		id_arg = ts_fonc.fonc[ts_fonc.index-1].args_id[i];
		insert(&ts_fonc.fonc[ts_fonc.index-1].ts, type, last_free_adr, id_arg);
		last_free_adr += 1;
		instarg("SET", -2 - nb_args + i);
		inst("LOADR");
		inst("PUSH");
		instarg("SET", i); 
		inst("SWAP");
		inst("POP");
		inst("SAVER");
	}
}

int main(int argc, char** argv) {

	while( (opt = getopt(argc, argv, "o")) != -1 ) {
		switch( opt ) {
			case 'o':
				opt_o_used = 1; /* -o utilisée, change la manière dont on print les instr */
				break;
			case '?':	return 1; /* stop après affichage auto de l'erreur "option inconnue" */
		}
	}

	/* rappel : après boucle getopt, optind contient l'index du 1er arg indépendant s'il existe */
	if ( optind == argc ) { /* s'il n'y a pas d'argument indépendant */
		fprintf(stderr, "usage: %s [-o] [FILE]\n", argv[0]);
		fprintf(stderr, "  -o : Exporte le résultat de la compilation dans un fichier .vm\n");
		return 1;		
	}
	else { /* sinon, y a un argument indépendant, ça devrait être le nom du fichier src */
		yyin = fopen(argv[optind], "r"); /* tenter de l'ouvrir */
		if ( !yyin ) {
			fprintf(stderr, "Erreur : Echec ouverture du fichier \"%s\".\n", argv[optind]);
			return 1;
		}
		/* ici, fichier ouvert avec succès */
		if ( opt_o_used ) { /* si l'option -o a été utilisée */
			strncpy(opt_o_filename, argv[optind], strlen(argv[optind])); /* opt_o_filename = nomFichierSource */
			strncat(opt_o_filename, ".vm", 3); /* opt_o_filename = nomFichierSource.vm */
			output_stream = fopen(opt_o_filename, "w"); /* open pour ecriture */
			if ( !output_stream ) {
				fprintf(stderr, "Erreur : Echec ouverture du fichier \"%s\".\n", opt_o_filename);
				fprintf(stderr, "         Le résultat sera affiché sur la sortie standard.\n");
				output_stream = stdout; /* On ne quitte pas, on utilise stdout comme sortie */
			}
		}
		/* sinon, on assigne stdout à output_stream */
		/* Astuce : dans ttes les fonctions qui print des instructions, on utilise fprintf(output_stream, ...) */
		else output_stream = stdout;
	}

	init(&ts[0]);
	init(&ts[1]);
	cur_ts = &ts[GLOB];
	yyparse();
	endProgram();

	return 0;
}
