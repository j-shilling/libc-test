AC_PREREQ([2.69])
AC_INIT([libc-test], [0.1], [shilling.jake@gmail.com])
AM_INIT_AUTOMAKE([-Wall -Werror subdir-objects])

CFLAGS="$CFLAGS -I`pwd`/include"

AC_ARG_ENABLE([debug],
	      AS_HELP_STRING([--enable-debug], [build with GDB debugging support]),
	      [case "${enable_debug}" in
	         yes) debug=true ;;
		 no)  debug=false ;;
		 *)   AC_MSG_ERROR([bad value ${enable_debug} for --enable-debug]) ;;
	       esac],[debug=false])
AM_CONDITIONAL([DEBUG], [test x$debug = xtrue])

if test "x$debug" = "xtrue"; then
	CFLAGS="$CFLAGS -O0 -ggdb -DYYDEBUG=1"
else
	CFLAGS="$CFLAGS -O2 -DYYDEBUG=0"
fi

# Checks for programs.
AC_PROG_CC
AM_PROG_AR
AC_PROG_RANLIB

AC_PROG_YACC
if test "x$YACC" = "xyacc"; then
	AC_CHECK_PROG([HAVE_YACC], [yacc], [true], [false])
	if test "x$HAVE_YACC" = "xfalse"; then
		AC_MSG_ERROR([yacc compatible program required])
	fi
fi
AM_PROG_LEX
if test "x$LEX" = "xflex"; then
	CFLAGS="$CFLAGS -DFLEX=1"
else
	CFLAGS="$CFLAGS -DFLEX=0"
fi

if test "x$LEX" = "x:"; then
	AC_MSG_ERROR([lex compatible program requried])
fi

# Checks for libraries.
AC_CHECK_LIB([dl], [dlopen], [],
	     [AC_MSG_ERROR([Cannot link with dl])])

# Checks for header files.
AC_CHECK_HEADERS([stddef.h stdlib.h string.h unistd.h], [],
		 [AC_MSG_ERROR([Missing required headers])])

# Checks for library functions.
AC_CHECK_FUNC([asprintf], [CFLAGS="$CFLAGS -D__HAVE_ASPRINTF"])
AC_CHECK_FUNC([strdup],   [CFLAGS="$CFLAGS -D__HAVE_STRDUP"])

AC_CONFIG_FILES([Makefile
                 src/Makefile
                 src/assert/Makefile
                 src/complex/Makefile
                 src/ctype/Makefile
                 src/errno/Makefile
                 src/fenv/Makefile
                 src/float/Makefile
                 src/inttypes/Makefile
                 src/iso646/Makefile
                 src/limits/Makefile
                 src/locale/Makefile
                 src/math/Makefile
                 src/setjmp/Makefile
                 src/signal/Makefile
                 src/stdalign/Makefile
                 src/stdarg/Makefile
                 src/stdatomic/Makefile
                 src/stdbool/Makefile
                 src/stddef/Makefile
                 src/stdint/Makefile
                 src/stdio/Makefile
                 src/stdlib/Makefile
                 src/stdnoreturn/Makefile
                 src/string/Makefile
                 src/tgmath/Makefile
                 src/threads/Makefile
                 src/time/Makefile
                 src/uchar/Makefile
                 src/wchar/Makefile
                 src/wctype/Makefile])
AC_OUTPUT
