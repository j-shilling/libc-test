#include <stdio.h>

int
trigraphs_parse (FILE *in, FILE *out)
{
  int c = fgetc (in);
  int status = c;
  while (EOF != c && EOF != status)
    {
      if ('?' == c)
        {
          c = fgetc (in);
	  if ('?' == c)
            {
              c = fgetc (in);    
	      switch (c)
              {
              case '=':  status = fputc ('#', out); break;
              case '/':  status = fputc ('\\', out); break;
              case '\'': status = fputc ('^', out); break;
              case '(':  status = fputc ('[', out); break;
              case ')':  status = fputc (']', out); break;
              case '!':  status = fputc ('|', out); break;
              case '<':  status = fputc ('{', out); break;
              case '>':  status = fputc ('}', out); break;
              case '-':  status = fputc ('~', out); break;
              case EOF:  break;
              default:   status = fputc ('?', out);
                         if (EOF != status)
                           status = fputc ('?', out);
                         if (EOF != status)
                           status = fputc (c, out);
                         break;
              }
            }
	  else
            {
	      status = fputc ('?', out);
              if (EOF != status)
                status = fputc (c, out);
	    }
        }
      else
        {
          status = fputc (c, out);
        }
      c = fgetc (in);
    }

  return ferror (in) || ferror (out);
}
