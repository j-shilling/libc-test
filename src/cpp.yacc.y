%{
#include <stdio.h>
#include <include-dirs.h>

int yylex (void);
void yyerror (char const *);
%}

%define parse.trace
%union { char *string; }
%code requires { #include <stdlib.h> }
%destructor { free ($$); } <string>
%printer { fprintf (yyoutput, "%s", $$); } <string>

%token          TOK_INCLUDE
%token <string> TOK_LOCAL_FILE
%token <string> TOK_GLOBAL_FILE

%%

input:
     %empty
   | input stmt
;

stmt:
    include
;

include:
       TOK_INCLUDE TOK_LOCAL_FILE		{ include_queue_push ($2, 0); }
     | TOK_INCLUDE TOK_GLOBAL_FILE		{ include_queue_push ($2, 1); }
     ;

%%

void
yyerror (char const * s)
{
  ;
}
