#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <dlfcn.h>
#include <time.h>
#include <stddef.h>

#include <test-suite.h>

#define N_TEST_SUITES		29

#ifdef __HAVE_ASPRINTF
extern int asprintf (char **strp, const char *fmt, ...);
#else
static int asprintf (char **strp, const char *fmt, ...);
#endif 

#ifdef __HAVE_STRDUP
extern char *strdup (const char *s);
#else
static char *strdup (const char *s);
#endif

static inline char *time_str (double time);
static inline char *heap_str (ptrdiff_t change);

int
main (int argc, char *argv[])
{
  /* Storage for user options */
  char *lib_path = NULL; /* path to libc */
  char *inc_path = NULL; /* path to include dir with C headers */
  int std = 2011;        /* version of C to test */

  /* Null terminated array of test suites to run */
  char *requested_tests[N_TEST_SUITES];
  memset (requested_tests, 0, sizeof (requested_tests));

  /* Parse arguments */
  int c;
  while ((c = getopt (argc, argv, "+c:l:I:?")) != -1)
  {
    switch (c)
    {
    case 'c':
      if (0 == strcmp ("11", optarg))
        std = 2011;
      else if (0 == strcmp ("99", optarg))
        std = 1999;
      else if (0 == strcmp ("89", optarg))
        std = 1989;
      else
        {
          fprintf (stderr, "c%s is not supported\n", optarg);
          goto print_help;
        }
      break;

    case 'l':
      lib_path = optarg;
      break;

    case 'I':
      inc_path = optarg;
      break;

    case '?':
    print_help:
      printf ("Usage: %s [OPTIONS]... [TESTS]...\n", argv[0]);
      printf ("Test a given libc or libc-headers according to a given standard.\n");
      printf ("\n");
      printf (" == OPTIONS == \n");
      printf ("   Available standards:\n");
      printf ("-c11                             Test C11 compatability [default]\n");
      printf ("-c99                             Test C99 compatability\n");
      printf ("-c89                             Test C89 compatability\n");
      printf ("\n");
      printf ("  Test Configurations:\n");
      printf ("-l /path/to/libc                 Specify the path to the libc file. If this is\n");
      printf ("                                 not specified, then all function tests will be\n");
      printf ("                                 disabled.\n");
      printf ("-I /path/to/headers              Specify the directory containing the libc header\n");
      printf ("                                 files. If this is not specified then all header\n");
      printf ("                                 tests will be disabled.\n");
      printf ("\n");
      exit (EXIT_SUCCESS);
      break;

    default:
      fprintf (stderr, "An unkown error occurred!\n");
      exit (EXIT_FAILURE);
    }
  }

  /* All additional arguments are read as test suite names */
  int i;
  for (i = optind; (i < argc) && ((i - optind) < N_TEST_SUITES); i++)
    requested_tests[i - optind] = argv[i];

  /* We cannot do anything without an include dir or libc */
  if (!lib_path && !inc_path)
    {
      printf ("Please specify the path to libc or include directory.\n");
      exit (EXIT_SUCCESS);
    }

  if (inc_path)
    {
      printf ("Header tests are currently unsupported!\n");
      inc_path = NULL;
    }  

  /* load libc */
  void *libc = dlopen (lib_path, RTLD_LAZY);
  if (!libc)
    {
      char *msg = dlerror();
      fprintf (stderr, "Could not open libc. %s\n",
		      (NULL != msg) ? msg : "unkown error");
      exit (EXIT_FAILURE);
    }

  /* Main loop to iterate tests */
  int failed_test_count = 0;
  test_suite_t const *const *cur_suite;
  for (cur_suite = tests; NULL != (*cur_suite); cur_suite ++)
    {
      /* Check if this suite applies to the current standard */
      if ((*cur_suite)->std > std)
        continue;

      /* Check whether user has provided a list of tests */
      if (NULL != requested_tests[0])
        {
          char **req;
	  int found = 0;
	  for (req = requested_tests; NULL != (*req); req++)
            {
              if (0 == strcmp ((*cur_suite)->name, (*req)))
                {
                  found = 1;
		  break;
		}
	    }
	  /* Skip tests not specified */
	  if (!found)
            continue;
        }

      printf ("\n\t== %s ==\n\n", (*cur_suite)->name);

      /* iterate tests in suite */
      function_test_t const *const *cur_test;
      for (cur_test = (*cur_suite)->tests; NULL != (*cur_test); cur_test ++)
        {
          /* Exclude tests for new versions of C */
          if ((*cur_test)->std > std)
            continue;

	  printf ("%s: %s\n", (*cur_test)->name, (*cur_test)->desc);

	  /* Get function to test */
	  void *symb = dlsym (libc, (*cur_test)->symb);
	  if (!symb)
            {
              printf ("Warning: could not load function %s. %s\n",
			      (*cur_test)->symb, dlerror());
	      printf ("FAILURE: %s() not implemented\n\n", (*cur_test)->symb);
	      failed_test_count ++;
	      continue;
	    }

	  /* Execute test */
	  void *heap_start = sbrk(0);
	  clock_t t = clock();
	  int result = (*cur_test)->test (symb);
	  t = clock() - t;
	  void *heap_end = sbrk(0);

	  ptrdiff_t heap_change = heap_end - heap_start;
	  double exec_time = ((double)t) / CLOCKS_PER_SEC;

	  if (EXIT_SUCCESS == result)
	    {
              char *time = time_str (exec_time);
	      char *heap = heap_str (heap_change);

	      printf ("PASS: %10s %10s\n\n",
			      time, heap);

	      free (time);
	      free (heap);
	    }
	  else
	    {
	      printf ("FAILURE\n\n");
	      failed_test_count ++;
	    }
        }
    }

  /* cleanup */
  dlclose (libc);

  return (failed_test_count == 0) ? EXIT_SUCCESS : EXIT_FAILURE;
}

static inline char *
time_str (double time)
{
  char *ret = NULL;

  if (time >= 60)
    {
      asprintf (&ret, "%.2f min", time / 60);
    }
  else if (time >= 1)
    {
      asprintf (&ret, "%.2f sec", time);
    }
  else if (time >= .001)
    {
      asprintf (&ret, "%.2f ms", time * 1000);
    }
  else if (time >= .0000000001)
    {
      asprintf (&ret, "%.2f ns", time * 1000000000);
    }

  if (!ret)
    ret = strdup ("?");

  return ret;
}

static inline char *
heap_str (ptrdiff_t change)
{
  ptrdiff_t abs_value = (change < 0) ? (change * -1) : (change);
  char *ret = NULL;

  if (abs_value > (1024 * 1024))
    asprintf (&ret, "%jd Mi", abs_value / (1024 * 1024));
  else if (abs_value > (1024))
    asprintf (&ret, "%jd Ki", abs_value / (1024));
  else 
    asprintf (&ret, "%jd B", abs_value);

  if (!ret)
    ret = strdup ("?");

  return ret;
}

#ifndef __HAVE_ASPRINTF

#include <stdarg.h>

static int
asprintf (char **strp, const char *fmt, ...)
{
  va_list ap, ap_copy;
  va_start (ap, fmt);
  va_copy (ap_copy, ap);

  int size = vsnprintf (NULL, 0, fmt, ap_copy);
  if (size >= 0)
    {
      char *buf = (char *) malloc (size + 1);
      if (NULL == buf)
        return -1;

      vsprintf (buf, fmt, ap);

      (*strp) = buf;
    }

  return size;
}

#endif 

#ifndef __HAVE_STRDUP

static char *
strdup (const char *s)
{
  if (NULL == s)
    return NULL;

  size_t size = strlen (s);
  if (size == 0)
    return NULL;

  char *buf = (char *) malloc (size + 1);
  if (NULL == buf)
    return NULL;

  strcpy (buf, s);
  return buf;
}

#endif
