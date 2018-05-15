SUBDIRS = assert \
	  complex \
	  ctype \
	  errno \
	  fenv \
	  float \
	  inttypes \
	  iso646 \
	  limits \
	  locale \
	  math \
	  setjmp \
	  signal \
	  stdalign \
	  stdarg \
	  stdatomic \
	  stdbool \
	  stddef \
	  stdint \
	  stdio \
	  stdlib \
	  stdnoreturn \
	  string \
	  tgmath \
	  threads \
	  time \
	  uchar \
	  wchar \
	  wctype

AM_YFLAGS = -d
if DEBUG
AM_LFLAGS = -d
else
AM_LFLAGS =
endif

bin_PROGRAMS = libc-test

BUILT_SOURCES = cpp.yacc.h
CLEANFILES = cpp.yacc.c \
	     cpp.yacc.h \
	     cpp.lex.c

libc_test_SOURCES = main.c \
		    tests.c \
		    include-dirs.c \
		    cpp.yacc.y \
		    cpp.lex.l


libc_test_CFLAGS = $(CFLAGS) -I$(top_srcdir)/include
libc_test_LDADD = \
    assert/lib.a \
    complex/lib.a \
    ctype/lib.a \
    errno/lib.a \
    fenv/lib.a \
    inttypes/lib.a \
    iso646/lib.a \
    limits/lib.a \
    locale/lib.a \
    math/lib.a \
    setjmp/lib.a \
    signal/lib.a \
    stdalign/lib.a \
    stdarg/lib.a \
    stdatomic/lib.a \
    stdbool/lib.a \
    stddef/lib.a \
    stdint/lib.a \
    stdio/lib.a \
    stdlib/lib.a \
    stdnoreturn/lib.a \
    string/lib.a \
    tgmath/lib.a \
    threads/lib.a \
    time/lib.a \
    uchar/lib.a \
    wchar/lib.a \
    wctype/lib.a

