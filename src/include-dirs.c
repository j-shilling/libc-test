#include <include-dirs.h>

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

include_directories_t *include_directories = NULL;

static void
free_include_directories (void)
{
  while (include_directories)
    {
      include_directories_t *next = include_directories->next;
      free (include_directories->path);
      free (include_directories);
      include_directories = next;
    }
}

void
include_directories_add (char *path)
{
  if (NULL == path)
    return;

  include_directories_t *node =
    (include_directories_t *) malloc (sizeof (include_directories));
  if (NULL == node)
    {
      perror ("\nError: ");
      exit (EXIT_FAILURE);
    }

  size_t str_len = strlen (path);
  if (0 == str_len)
    {
      free (node);
      return;
    }

  node->path = (char *) malloc (str_len + 1);
  if (NULL == node)
    {
      free (node);
      perror ("\nError: ");
      exit (EXIT_FAILURE);
    }
  strcpy (node->path, path);

  if (NULL == include_directories)
    {
      atexit (free_include_directories);
      node->next = NULL;
    }
  else
    {
      node->next = include_directories;
    }

  include_directories = node;
}
