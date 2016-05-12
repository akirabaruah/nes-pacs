#ifndef _NES_H
#define _NES_H

#include <linux/ioctl.h>

typedef struct {
  unsigned char d_in;
  unsigned char d_out;
  unsigned short addr; 
} nes_arg_t;

#define NES_MAGIC 'q'

/* ioctls and their arguments */
#define NES_WRITE _IOW(NES_MAGIC, 1, nes_arg_t *)
#define NES_READ _IOWR(NES_MAGIC, 2, nes_arg_t *)

#endif
