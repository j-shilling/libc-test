%{
#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <sys/stat.h>

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

#define __copy_yytext()                       \
do                                            \
  {                                           \
    size_t size = strlen (yytext);            \
    char *text = (char *) malloc (size + 1);  \
                                              \
    if (NULL == text)                         \
      perror (""), exit(EXIT_FAILURE);        \
    else                                      \
      strcpy (text, yytext);                  \
                                              \
    __set_string (text);                      \
  }                                           \
while (0)

/* Include Stack */
typedef struct __buffer_state_node
{
  include_directories_t *cur_dir;
  YY_BUFFER_STATE buffer_state;
  struct __buffer_state_node *next;
} buffer_state_node_t;

include_directories_t *cur_dir = NULL;
static buffer_state_node_t *include_stack = NULL;

static void buffer_state_push (YY_BUFFER_STATE buffer_state);
static YY_BUFFER_STATE buffer_state_pop (void);
static void __include_file (include_directories_t *cur, const char *filename);
%}

%option noyywrap

%x preprocessor
%x include
%%
	yy_flex_debug = YYDEBUG;

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
<preprocessor>\n		{ __begin (INITIAL); __return ('\n'); }

<preprocessor>define		{ __return (TOK_DEFINE); }
<preprocessor>elif		{ __return (TOK_ELIF); }
<preprocessor>else		{ __return (TOK_ELSE); }
<preprocessor>endif		{ __return (TOK_ENDIF); }
<preprocessor>error		{ __return (TOK_ERROR); }

<preprocessor>include		{ __begin (include); }
<include><[^\n>]+>		{ yytext[strlen (yytext) - 1] = '\0'; __include_file (NULL, yytext + 1); __begin (INITIAL); }
<include>\"[^\n>]+\"		{ yytext[strlen (yytext) - 1] = '\0'; __include_file (cur_dir, yytext + 1); __begin (INITIAL); }

<preprocessor>if		{ __return (TOK_IF); }
<preprocessor>ifdef		{ __return (TOK_IFDEF); }
<preprocessor>ifndef		{ __return (TOK_IFNDEF); }
<preprocessor>line		{ __return (TOK_LINE); }
<preprocessor>pragma		{ __return (TOK_PRAGMA); }
<preprocessor>undef		{ __return (TOK_UNDEF); }

<preprocessor>defined		{ __return (TOK_DEFINED); }

	/* Integer literals */
<*>[+|-]?[1-9]+[0-9]*[u|U|l|L]		{  /* Decimal */
					}
<*>[+|-]?0[x|X][0-9a-fA-F]+[u|U|l|L]	{  /* Hex */
					}
<*>[+|-]?0[0-7]+[u|U|l|L]		{  /* Octal */
					}

<<EOF>>					{
					  if (NULL == include_stack)
					    yyterminate();
					  yy_delete_buffer (YY_CURRENT_BUFFER);
					  yy_switch_to_buffer (
					    include_stack->buffer_state);
					  cur_dir = include_stack->cur_dir;
					  buffer_state_node_t *node = include_stack;
					  include_stack = node->next;
					  free (node);
					  __begin (INITIAL);
					}
%%

static void
__include_file (include_directories_t *cur, const char *filename)
{
  char *file = NULL;
  {
  include_directories_t *node = 
    (NULL != cur) ? cur : include_directories;

  /* Search for filename. Will search only cur if cur != NULL
   * otherwise will iterate over include_directories.
   */
  do
    {
      size_t dir_size = strlen (node->path);
      size_t file_size = strlen (filename);
      file = (char *) malloc (dir_size + file_size + 2);
      if (NULL == file)
        {
          perror ("");
          exit (EXIT_FAILURE);
        }

      sprintf (file, "%s/%s", node->path, filename);

      struct stat file_stat;
      if (stat (file, &file_stat))
        {
          if (ENOENT != errno || NULL != cur || NULL == node->next)
            {
              perror (file);
              exit (EXIT_FAILURE);
            }
          free (file);
          file = NULL;
       }

      node = node->next;
    }
  while (NULL == cur && NULL == file && NULL != node);
  }

  /* Push YY_CURRENT_BUFFER onto the include_stack */
  {
  buffer_state_node_t *node = (buffer_state_node_t *)
    malloc (sizeof (buffer_state_node_t));
  if (NULL == node)
    {
      perror ("");
      exit (EXIT_FAILURE);
    }

  node->buffer_state = YY_CURRENT_BUFFER;
  node->cur_dir = cur_dir;
  node->next = include_stack;

  include_stack = node;
  }

  /* Switch to include file */
  yyin = fopen (file, "r");
  free (file);
  if (NULL == yyin)
    {
      perror (file);
      exit (EXIT_FAILURE);
    }

  yy_switch_to_buffer (
    yy_create_buffer (yyin, YY_BUF_SIZE));
}
