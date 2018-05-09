#include <test-suite.h>
#include <stddef.h>

extern test_suite_t assert_h;
extern test_suite_t complex_h;
extern test_suite_t ctype_h;
extern test_suite_t errno_h;
extern test_suite_t fenv_h;
extern test_suite_t inttypes_h;
extern test_suite_t iso646_h;
extern test_suite_t limits_h;
extern test_suite_t locale_h;
extern test_suite_t math_h;
extern test_suite_t setjmp_h;
extern test_suite_t signal_h;
extern test_suite_t stdalign_h;
extern test_suite_t stdarg_h;
extern test_suite_t stdatomic_h;
extern test_suite_t stdbool_h;
extern test_suite_t stddef_h;
extern test_suite_t stdint_h;
extern test_suite_t stdio_h;
extern test_suite_t stdlib_h;
extern test_suite_t stdnoreturn_h;
extern test_suite_t string_h;
extern test_suite_t tgmath_h;
extern test_suite_t threads_h;
extern test_suite_t time_h;
extern test_suite_t uchar_h;
extern test_suite_t wchar_h;
extern test_suite_t wctype_h;

struct test_suite const *const tests[] =
{
  &assert_h,
  &complex_h,
  &ctype_h,
  &errno_h,
  &fenv_h,
  &inttypes_h,
  &iso646_h,
  &limits_h,
  &locale_h,
  &math_h,
  &setjmp_h,
  &signal_h,
  &stdalign_h,
  &stdarg_h,
  &stdatomic_h,
  &stdbool_h,
  &stddef_h,
  &stdint_h,
  &stdio_h,
  &stdlib_h,
  &stdnoreturn_h,
  &string_h,
  &tgmath_h,
  &threads_h,
  &time_h,
  &uchar_h,
  &wchar_h,
  &wctype_h,
  NULL
};
