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

/* Preprocessor directives */
%token		TOK_DEFINE
%token		TOK_ELIF
%token		TOK_ELSE
%token		TOK_ENDIF
%token		TOK_ERROR
%token          TOK_INCLUDE
%token		TOK_IF
%token		TOK_IFDEF
%token		TOK_IFNDEF
%token		TOK_LINE
%token		TOK_PRAGMA
%token		TOK_UNDEF

/* Preprocessor keywords */
%token		TOK_DEFINED

/* Preprocessor Values */
%token <string>	TOK_IDENTIFIER
%token <integer>TOK_INTEGER

%%

input:
     %empty
;

%%

void
yyerror (char const * s)
{
  fprintf (stderr, "Error: %s\n", s);
}
