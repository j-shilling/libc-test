%{
#include <string.h>
#include <include-dirs.h>

#include "cpp.yacc.h"

#if YYDEBUG
#  define __return(x)		do { fprintf (stderr, "--returning " #x "\n"); return x; } while (0)
#  define __begin(x)		do { fprintf (stderr, "--start-condition " #x "\n"); BEGIN(x); } while (0)
#  define __set_string(x)	do { fprintf (stderr, "--semantic yylval.string=\"%s\"\n", x); yylval.string = x; } while (0)
#  define __set_char(x)		do { fprintf (stderr, "--semantic yylval.character=\"%c\"\n", x); yylval.character = x; } while (0)
#else
#  define __return(x)		do { return x; } while (0)
#  define __begin(x)		do { BEGIN(x); } while (0)
#  define __set_string(x) 	do { yylval.string = x; } while (0)
#  define __set_char(x) 	do { yylval.character = x; } while (0)
#endif

#if FLEX
#  define __set_debug()		yy_flex_debug = YYDEBUG
#else
#  define __set_debug()
#endif
%}

%option noyywrap

%x preprocessor
%%
	__set_debug();

	/* Trigraphs */
<*>"??="			unput ('#');
<*>"??/"			unput ('\\');
<*>"??'"			unput ('^');
<*>"??("			unput ('[');
<*>"??)"			unput (']');
<*>"??!"			unput ('|');
<*>"??<"			unput ('{');
<*>"??>"			unput ('}');
<*>"??-"			unput ('~');

	/* linebreaks */
<*>"\\\n"			/* Ignore newline after \n */

	/* whitespace */
<*>[ \t]+			/* Always ignore tabs and spaces */
\n				/* Ignore newlines in INITIAL */

	/* comments */
<*>"//".*			/* Ignore inline comments */
<*>"/*"([^\*]|\*[^\/])*"*/"	/* Ignore c comments */

	/* The preprocessor */
"#"				{ __begin (preprocessor); }
<preprocessor>\n		{ __begin (INITIAL); }

<preprocessor>define		{ __return (TOK_DEFINE); }
<preprocessor>elif		{ __return (TOK_ELIF); }
<preprocessor>else		{ __return (TOK_ELSE); }
<preprocessor>endif		{ __return (TOK_ENDIF); }
<preprocessor>error		{ __return (TOK_ERROR); }
<preprocessor>include		{ __return (TOK_INCLUDE); }
<preprocessor>if		{ __return (TOK_IF); }
<preprocessor>ifdef		{ __return (TOK_IFDEF); }
<preprocessor>ifndef		{ __return (TOK_IFNDEF); }
<preprocessor>line		{ __return (TOK_LINE); }
<preprocessor>pragma		{ __return (TOK_PRAGMA); }
<preprocessor>undef		{ __return (TOK_UNDEF); }

<preprocessor>defined		{ __return (TOK_DEFINED); }

	/* Identifiers */
<*>[a-zA-Z_]+[a-zA-Z0-9_]	{
				  size_t size = strlen (yytext);
				  char *text = (char *) malloc (size + 1);
				  if (NULL == text)
				    {
				      perror ("Error");
				      exit (EXIT_FAILURE);
				    }
				 strcpy (text, yytext);
				 __set_string (text);
				 __return (TOK_IDENTIFIER);
			       }

	/* Integer literals */
<*>[+|-]?[1-9]+[0-9]*[u|U|l|L]		{  /* Decimal */
					}
<*>[+|-]?0[x|X][0-9a-fA-F]+[u|U|l|L]	{  /* Hex */
					}
<*>[+|-]?0[0-7]+[u|U|l|L]		{  /* Octal */
					}
%%
