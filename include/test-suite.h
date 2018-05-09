#ifndef __TEST_SUITE_H__
#define __TEST_SUITE_H__

#include <test-func.h>

/* Test suite information */
typedef struct test_suite
{
  const char *name; /* Name of the test suite */
  const int std; /* Lowest standard in the suite */
  function_test_t const *tests[]; /* NULL-terminated array of tests */
} test_suite_t;

/* pointer to a null terminated list of available test suites */
extern struct test_suite const *const tests[];

#endif /* __TEST_SUITE_H__ */
