#include <include-dirs.h>

extern int yyparse (void);

#if YYDEBUG
extern int yydebug;
#endif

void
cpp_parse_header (const char *header)
{
#if YYDEBUG
  yydebug = 1;
#endif 

  include_queue_push (header, 1);
  include_queue_pop();
  yyparse();
}
