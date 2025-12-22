%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

typedef struct yy_buffer_state *YY_BUFFER_STATE;

extern int yyparse(void);
extern YY_BUFFER_STATE yy_scan_string(const char *str);
extern void yy_delete_buffer(YY_BUFFER_STATE buffer);

#define MAX_ARGS 64

typedef struct ArgList {
    float *data;
    int count;
} ArgList;

ArgList* make_args(float first);
ArgList* add_arg(ArgList* list, float value);
float call_function(char* name, ArgList* args);

void yyerror(const char *msg);
int yylex();
%}

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
      expr { printf("Result = %f\n", $1); }
    ;

expr:
      expr PLUS expr    { $$ = $1 + $3; }
    | expr MINUS expr   { $$ = $1 - $3; }
    | expr MUL expr     { $$ = $1 * $3; }
    | expr DIV expr     { $$ = $1 / $3; }
    | NUMBER            { $$ = $1; }
    | IDENT LPAREN args RPAREN {
            $$ = call_function($1, $3);
            free($3->data);
            free($3);
            free($1);
      }
    | LPAREN expr RPAREN { $$ = $2; }
    ;

args:
      expr { $$ = make_args($1); }
    | args COMMA expr { $$ = add_arg($1, $3); }
    ;

%%

ArgList* make_args(float first)
{
    ArgList* al = malloc(sizeof(ArgList));
    al->data = malloc(sizeof(float) * MAX_ARGS);
    al->count = 0;
    al->data[al->count++] = first;
    return al;
}

ArgList* add_arg(ArgList* list, float value)
{
    list->data[list->count++] = value;
    return list;
}

float call_function(char* name, ArgList* args)
{
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

    return 0;
}

void yyerror(const char *msg)
{
    fprintf(stderr, "%s\n", msg);
}

int main(void)
{
    int choice;
    char input[1024];
    int count = 0;

    printf("Choose input mode:\n1) Manual\n2) From entries.txt\nChoice: ");
    scanf("%d", &choice);
    getchar();

    if (choice == 1) {
        fgets(input, sizeof(input), stdin);
        YY_BUFFER_STATE buffer = yy_scan_string(input);
        yyparse();
        yy_delete_buffer(buffer);
        count = 1;
    } else if (choice == 2) {
        FILE *f = fopen("entries.txt", "r");
        if (!f) return 1;
        while (fgets(input, sizeof(input), f)) {
            if (input[0] == '\n') continue;
            YY_BUFFER_STATE buffer = yy_scan_string(input);
            yyparse();
            yy_delete_buffer(buffer);
            count++;
        }
        fclose(f);
    }

    printf("Total expressions evaluated: %d\n", count);
    return 0;
}

