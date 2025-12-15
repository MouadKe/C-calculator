/* calc.y */
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#define MAX_ARGS 64

/* Arg list structure so each function call gets its own list */
typedef struct ArgList {
    float *data;
    int count;
} ArgList;

/* function prototypes */
ArgList* make_args(float first);
ArgList* add_arg(ArgList* list, float value);
float call_function(char* name, ArgList* args);

void yyerror(const char *msg);
int yylex();
%}

/* semantic value union */
%union {
    float fval;
    char* sval;
    ArgList* plist;
}

%token <fval> NUMBER
%token <sval> IDENT
%token PLUS MINUS MUL DIV
%token LPAREN RPAREN COMMA UNKNOWN

%type <fval> expr
%type <plist> args

%left PLUS MINUS
%left MUL DIV

%%

input:
      expr  { printf("Result = %f\n", $1); }
    ;

expr:
      expr PLUS expr    { $$ = $1 + $3; }
    | expr MINUS expr   { $$ = $1 - $3; }
    | expr MUL expr     { $$ = $1 * $3; }
    | expr DIV expr     { $$ = $1 / $3; }

    | NUMBER            { $$ = $1; }

    /* function call: IDENT '(' args ')' */
    | IDENT LPAREN args RPAREN {
            /* call function with that call's ArgList ($3) */
            $$ = call_function($1, $3);

            /* free memory for args list and identifier strdup */
            free($3->data);
            free($3);
            free($1);
      }

    | LPAREN expr RPAREN  { $$ = $2; }
    ;

args:
      expr {
            /* make a new ArgList containing the single expr value */
            ArgList* al = make_args($1);
            $$ = al;
      }
    | args COMMA expr {
            /* append to the existing ArgList */
            $$ = add_arg($1, $3);
      }
    ;

%%

/* create a new ArgList with one element */
ArgList* make_args(float first)
{
    ArgList* al = (ArgList*) malloc(sizeof(ArgList));
    if (!al) { fprintf(stderr, "Out of memory\n"); exit(1); }
    al->data = (float*) malloc(sizeof(float) * MAX_ARGS);
    if (!al->data) { fprintf(stderr, "Out of memory\n"); exit(1); }
    al->count = 0;
    al->data[al->count++] = first;
    return al;
}

/* add element to existing ArgList; returns the same list pointer */
ArgList* add_arg(ArgList* list, float value)
{
    if (list->count >= MAX_ARGS) {
        fprintf(stderr, "Too many arguments (max %d)\n", MAX_ARGS);
        return list;
    }
    list->data[list->count++] = value;
    return list;
}

/* call a named function with the provided ArgList */
float call_function(char* name, ArgList* args)
{
    printf("DEBUG %s: args_count=%d : ", name, args->count);
    for (int i = 0; i < args->count; i++) printf("%f ", args->data[i]);
    printf("\n");

    if (strcmp(name, "somme") == 0) {
        float s = 0;
        for (int i = 0; i < args->count; i++) s += args->data[i];
        return s;
    }

    if (strcmp(name, "produit") == 0) {
        float p = 1;
        for (int i = 0; i < args->count; i++) p *= args->data[i];
        return p;
    }

    if (strcmp(name, "moyenne") == 0) {
        float s = 0;
        for (int i = 0; i < args->count; i++) s += args->data[i];
        return s / args->count;
    }

    if (strcmp(name, "variance") == 0) {
        float mean = 0;
        for (int i = 0; i < args->count; i++) mean += args->data[i];
        mean /= args->count;

        float v = 0;
        for (int i = 0; i < args->count; i++)
            v += (args->data[i] - mean) * (args->data[i] - mean);

        return v / args->count;
    }

    if (strcmp(name, "ecart_type") == 0) {
        float mean = 0;
        for (int i = 0; i < args->count; i++) mean += args->data[i];
        mean /= args->count;

        float v = 0;
        for (int i = 0; i < args->count; i++)
            v += (args->data[i] - mean) * (args->data[i] - mean);

        return sqrt(v / args->count);
    }

    printf("Unknown function: %s\n", name);
    return 0;
}

void yyerror(const char *msg)
{
    fprintf(stderr, "%s\n", msg);
}

int main() {
    yyparse();
    return 0;
}

