#include <stdio.h>

int
line_splice (FILE *in, FILE *out)
{
  int c = fgetc (in);
  int status = c;
  while (EOF != c && EOF != status)
    {
      if ('\\' == c)
        {
          c = fgetc (in);
	  if ('\n' == c)
            {
              /* Ignore \ and the newline */
            }
          else
            {
              status = fputc ('\\', out);
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
