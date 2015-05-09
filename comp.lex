%{
#include "comp.h"
%}

%%
[ \t\n]+ ;
[0-9]+ {sscanf(yytext,"%d",&yylval.val); return NUM;}
[+-] {sscanf(yytext,"%c",&yylval.signeope); return ADDSUB;}
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
. return yytext[0];
%%
