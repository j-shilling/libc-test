%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <sys/stat.h>

#include <include-dirs.h>

int yylex (void);
void yyerror (char const *, char const *);

extern include_directories_t *cur_dir;
extern FILE *yyin;
%}

%union
{
  char *string;
  int   integer;
}

%define parse.error verbose

%parse-param { char const *file_name };
%initial-action
{
  for (cur_dir = include_directories; cur_dir; cur_dir = cur_dir->next)
    {
      size_t dir_size = strlen (cur_dir->path);
      size_t file_size = strlen (file_name);
      char *file = (char *) malloc (dir_size + file_size + 2);
      if (!file)
        {
          yyerror (NULL, "Out of memory");
          return 2;
        }
      sprintf (file, "%s/%s", cur_dir->path, file_name);
      
      struct stat file_stat;
      if (stat (file, &file_stat))
        {
          yyerror (NULL, strerror (errno));
          return 1;
        }

      yyin = fopen (file, "r");
      if (NULL == yyin)
        {
          yyerror (NULL, strerror (errno));
          return 1;
        }
    }
};

%destructor { free ($$); } <string>
%printer { fprintf (yyoutput, "%s", $$); } <string>
%printer { fprintf (yyoutput, "%d", $$); } <integer>

/* Preprocessor directives */
%token		TOK_DEFINE
%token		TOK_ELIF
%token		TOK_ELSE
%token		TOK_ENDIF
%token		TOK_ERROR
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
yyerror (char const *file_name, char const * s)
{
  fprintf (stderr, "Error: %s\n", s);
}
