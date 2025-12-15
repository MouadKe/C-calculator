
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* 1. Define ArgList and prototypes first, before including y.tab.h */
#define MAX_ARGS 64
typedef struct ArgList {
    float *data;
    int count;
} ArgList;

/* prototypes needed by parser */
ArgList* make_args(float first);
ArgList* add_arg(ArgList* list, float value);
float call_function(char* name, ArgList* args);

/* 2. Now include Bison-generated tokens and types */
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

[ \t\r\n]+             ;   /* ignore whitespace */

. {
      printf("Unknown character: %s\n", yytext);
      return UNKNOWN;
}

%%

