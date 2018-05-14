%{
#include <string.h>
#include <include-dirs.h>

#include "cpp.yacc.h"

#if YYDEBUG
#  define __return(x)		do { fprintf (stderr, "--returning " #x "\n"); return x; } while (0)
#  define __begin(x)		do { fprintf (stderr, "--start-condition " #x "\n"); BEGIN(x); } while (0)
#  define __set_string(x)	do { fprintf (stderr, "--semantic yylval.string=\"%s\"\n", x); yylval.string = x; } while (0)
#else
#  define __return(x)		do { return x; } while (0)
#  define __begin(x)		do { BEGIN(x); } while (0)
#  define __set_string(x) 	do { yylval.string = x; } while (0)
#endif

#if FLEX
#  define __set_debug()		yy_flex_debug = YYDEBUG
#else
#  define __set_debug()
#endif
%}

%x include
%%
	__set_debug();

<*>[ \t\n]+			/* Ignore whitespace */
<*>"//".*			/* Ignore inline comments */
<*>"/*"([^\*]|\*[^\/])*"*/"	/* Ignore c comments */

"#include"		{
			  __begin (include);
			  __return (TOK_INCLUDE);
			}
<include>\"[^\"]*\"	{
			  size_t len = strlen (yytext) - 2; /* remove initial and final " */
			  char *file  = (char *) malloc (len + 1);
			  if (NULL == file)
			    {
			      perror ("Error: ");
			      exit (EXIT_FAILURE);
			    }

			  strncpy (file, yytext + 1, len);
			  file[len + 1] = '\0';

			  __set_string (file);
			  __begin (INITIAL);
			  __return (TOK_LOCAL_FILE);
			}
<include>"<"[^">"]*">"	{
			  size_t len = strlen (yytext) - 2; /* remove initial < and final > */
			  char *file  = (char *) malloc (len + 1);
			  if (NULL == file)
			    {
			      perror ("Error: ");
			      exit (EXIT_FAILURE);
			    }

			  strncpy (file, yytext + 1, len);
			  file[len + 1] = '\0';

			  __set_string (file);
			  __begin (INITIAL);
			  __return (TOK_GLOBAL_FILE);
			}
%%

int
yywrap (void)
{
  return include_queue_pop ();
}
