%{

/* PROJET COMPILATION L3 Informatique
	Auteurs :
		Raphaël CHENEAU <rcheneau@etud.u-pem.fr>
		Bryan LEE <blee@etud.u-pem.fr>
*/



#include "tcompil.h"

void lyyerror(YYLTYPE *locp, const char *str){
	fprintf(stderr, "Erreur\n");
	exit(EXIT_FAILURE);
}
%}

%%
[ \t\n]+ ;
"'\\n'" {yylval.car = '\n'; return CARACTERE;}
"'\\t'" {yylval.car = '\t'; return CARACTERE;}
 "/*".*"*/" ;

[0-9]+ {sscanf(yytext, "%d", &yylval.val); return NUM;}
"'"."'" {yylval.car = yytext[1]; return CARACTERE;}
[+-] {sscanf(yytext, "%c", &yylval.signeope); return ADDSUB;}
[*/] {sscanf(yytext, "%c", &yylval.signeope); return DIVSTAR;}
[<>]|"=="|"!="|"<="|">=" {sscanf(yytext, "%2s", yylval.comp); return COMP;}
"&&"|"||" {sscanf(yytext, "%2s", yylval.comp); return BOPE;}
"!" {return NEGATION;}
"main" {return MAIN;}
"print" {return PRINT;}
"const" {return CONST;}
"void" {return VOID;}
"return" {return RETURN;}
";" {return PV;}
"(" {return LPAR;}
")" {return RPAR;}
"{" {return LACC;}
"}" {return RACC;}
"[" {return LSQB;}
"]" {return RSQB;}
"read" {return READ;}
"readch" {return READCH;}
"if" {return IF;}
"else" {return ELSE;}
"while" {return WHILE;}
"entier" {yylval.type = 3; return TYPE;}
"caractere" {yylval.type = 4; return TYPE;}
[a-zA-Z][a-zA-Z0-9_]* {sscanf(yytext, "%32s", yylval.id); return IDENT;}
"=" {return EGAL;}
"," {return VRG;}
. return yytext[0];
%%
