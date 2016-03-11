# 1 "vd.cudafe1.gpu"
# 212 "/usr/local/lib/gcc/x86_64-unknown-linux-gnu/4.9.2/include/stddef.h" 3
typedef unsigned long size_t;
#include "crt/host_runtime.h"
void *memcpy(void*, const void*, size_t); void *memset(void*, int, size_t);

#include "vd.cudafe2.stub.c"
