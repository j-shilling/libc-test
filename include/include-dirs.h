#ifndef __INCLUDE_DIRS_H__
#define __INCLUDE_DIRS_H__

#include <cdefs.h>
#include <stdio.h>

__BEGIN_DECLS

struct _path_list
{
  char *path;
  struct _path_list *next;
};

typedef struct _path_list include_directories_t;
typedef struct _path_list include_queue_t;

void include_queue_push (char *path, int global);
int  include_queue_pop  (void);

void include_directories_add (char *path);

extern include_directories_t *include_directories;

__END_DECLS

#endif /* __INCLUDE_DIRS_H__ */
