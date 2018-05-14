#include <include-dirs.h>

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <libgen.h>
#include <sys/stat.h>

char *cur_dir = NULL;
include_queue_t *queue = NULL;

extern FILE *yyin;

void
include_queue_push (char *path, int global)
{
  /* Sanity check */
  if (NULL == path)
    return;

  size_t path_size = strlen (path);
  char *file = NULL;
  struct stat info;
  size_t dir_size;
  /* Search current directory */
  if (NULL != cur_dir)
    {
      dir_size  = strlen (cur_dir);
      file = (char *) malloc (dir_size + path_size + 2);
      if (!file)
	{
	  perror ("Error: ");
	  exit (EXIT_FAILURE);
	}

      sprintf (file, "%s/%s", cur_dir, path);

      if (stat (file, &info))
	{
	  if (ENOENT != errno || !global)
	    {
	      free (file);
	      perror ("Warning: ");
	      return;
	    }
	  else
	    {
	      free (file);
	      file = NULL;
	    }
	}
    }

  /* Search other include directories */
  if (NULL == file && global)
    {
      include_directories_t *cur;
      for (cur = include_directories; cur; cur = cur->next)
	{
	  dir_size  = strlen (cur->path);
	  file = (char *) malloc (dir_size + path_size + 2);
	  if (!file)
	    {
	      perror ("Error: ");
	      exit (EXIT_FAILURE);
	    }

	  sprintf (file, "%s/%s", cur->path, path);

	  if (stat (file, &info))
	    {
	      if (ENOENT != errno)
		{
		  free (file);
		  perror ("Warning: ");
		  return;
		}
	      else
		{
		  free (file);
		  file = NULL;
		}
	    }
	  else
	    {
	      break;
	    }
	}
    }

  if (file)
    {
      if (S_ISDIR (info.st_mode))
	{
	  fprintf (stderr, "Warning: %s is a directory\n", file);
	  free (file);
	  return;
	}

      include_queue_t *node =
	(include_queue_t *) malloc (sizeof (include_queue_t));
      node->path = file;
      node->next = queue;
      queue = node;
    }
  else
    {
      fprintf (stderr, "Warning: could not find %s\n", path);
    }
}

int
include_queue_pop  (void)
{
  if (NULL != queue)
    {
      char *path = queue->path;

      /* Pop node from queue */
      include_queue_t *next = queue->next;
      free (queue);
      queue = next;

      yyin = fopen (path, "r");
      if (NULL == yyin)
	{
	  perror ("Warning: ");
	  free (path);
	  return 1;
	}

      char *dir = dirname (path);
      if (cur_dir)
	free (cur_dir);

      cur_dir = (char *) malloc (strlen (dir) + 1);
      if (NULL == cur_dir)
	{
	  perror ("Error: ");
	  exit (EXIT_FAILURE);
	}

      strcpy (cur_dir, dir);
      free (path);

      return 0;
    }

  return 1;
}
