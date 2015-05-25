%{
#include "comp.h"
int jump_lab = 0;
%}

%%
[ \t\n]+ ;
[0-9]+ {sscanf(yytext, "%d", &yylval.val); return NUM;}
[+-] {sscanf(yytext, "%c", &yylval.signeope); return ADDSUB;}
[*/] {sscanf(yytext, "%c", &yylval.signeope); return DIVSTAR;}
[<>]|"=="|"!="|"<="|">=" {sscanf(yytext, "%2s", yylval.comp); return COMP;}
"&&"|"||" {sscanf(yytext, "%2s", yylval.comp); return BOPE;}
"!" {return NEGATION;}
"main" {return MAIN;}
"print" {return PRINT;}
";" {return PV;}
"(" {return LPAR;}
")" {return RPAR;}
"{" {return LACC;}
"}" {return RACC;}
"if" {return IF;}
"print" {return PRINT;}
"else" {return ELSE;}
"entier" {yylval.type = 0; return TYPE;}
"caractere" {yylval.type = 1; return TYPE;}
[a-zA-Z][a-zA-Z0-9_]* {sscanf(yytext, "%32s", yylval.id); return IDENT;}
"=" {return EGAL;}
"," {return VRG;}
. return yytext[0];
%%
