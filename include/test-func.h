#ifndef __TEST_FUNC_H__
#define __TEST_FUNC_H__

typedef void (*func)(void);
typedef int (*test_func) (func);

typedef struct
{
  const char *name;
  const char *desc;
  const char *symb;
  const int std;
  const test_func test;
} function_test_t;

#endif /* __TEST_FUNC_H__ */
