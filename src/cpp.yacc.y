%{
int yylex (void);
void yyerror (char const *);
%}

%%

input:
     %empty
     ;

%%

void
yyerror (char const * s)
{
  ;
}
