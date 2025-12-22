
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_ARGS 64
typedef struct ArgList {
    float *data;
    int count;
} ArgList;

ArgList* make_args(float first);
ArgList* add_arg(ArgList* list, float value);
float call_function(char* name, ArgList* args);

#include "y.tab.h"

int yywrap() { return 1; }
%}

%%

[0-9]+(\.[0-9]+)?      { yylval.fval = atof(yytext); return NUMBER; }
[a-zA-Z_][a-zA-Z0-9_]* { yylval.sval = strdup(yytext); return IDENT; }

"+"                    { return PLUS; }
"-"                    { return MINUS; }
"*"                    { return MUL; }
"/"                    { return DIV; }
"("                    { return LPAREN; }
")"                    { return RPAREN; }
","                    { return COMMA; }

[ \t\r\n]+             ;

. { return UNKNOWN; }

%%

