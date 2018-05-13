#ifndef __INCLUDE_DIRS_H__
#define __INCLUDE_DIRS_H__

#include <cdefs.h>

__BEGIN_DECLS

typedef struct _include_directories
{
  char *path;
  struct _include_directories *next;
} include_directories_t;

void include_directories_add (char *path);

extern include_directories_t *include_directories;

__END_DECLS

#endif /* __INCLUDE_DIRS_H__ */
