%{
#include <stdio.h>
#include <stdlib.h>
#include <include-dirs.h>

int yylex (void);
void yyerror (char const *);
%}

%union
{
  char *string;
  int   integer;
}
%destructor { free ($$); } <string>
%printer { fprintf (yyoutput, "%s", $$); } <string>
%printer { fprintf (yyoutput, "%d", $$); } <integer>

%token          TOK_INCLUDE
%token <string> TOK_LOCAL_FILE
%token <string> TOK_GLOBAL_FILE

%token		TOK_IF
%token		TOK_ENDIF

%type  <integer>expr
%token <integer>TOK_INTEGER
%left		TOK_ADD TOK_SUB
%left		TOK_MUL TOK_DIV

%%

input:
     %empty
   | input stmt
;

stmt:
    	include
|	if
;

include:
       TOK_INCLUDE TOK_LOCAL_FILE		{ include_queue_push ($2, 0); }
     | TOK_INCLUDE TOK_GLOBAL_FILE		{ include_queue_push ($2, 1); }
     ;

expr:
    	TOK_INTEGER				{ $$ = $1; }
|	expr TOK_ADD expr			{ $$ = $1 + $3; }
|	expr TOK_SUB expr			{ $$ = $1 - $3; }
|	expr TOK_MUL expr			{ $$ = $1 * $3; }
|	expr TOK_DIV expr			{ $$ = $1 / $3; }
|	'(' expr ')'				{ $$ = $2; }
;

if:
	TOK_IF expr
;

%%

void
yyerror (char const * s)
{
  ;
}
