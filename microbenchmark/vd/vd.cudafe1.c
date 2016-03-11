# 1 "vd.cu"
# 35 "/usr/local/include/c++/4.9.2/exception" 3
#pragma GCC visibility push ( default )
# 159 "/usr/local/include/c++/4.9.2/exception" 3
#pragma GCC visibility pop
# 42 "/usr/local/include/c++/4.9.2/new" 3
#pragma GCC visibility push ( default )
# 157 "/usr/local/include/c++/4.9.2/new" 3
#pragma GCC visibility pop
# 1424 "/usr/local/cuda/bin/../targets/x86_64-linux/include/driver_types.h"
struct CUstream_st;
# 206 "/usr/include/libio.h" 3
enum __codecvt_result {

__codecvt_ok,
__codecvt_partial,
__codecvt_error,
__codecvt_noconv};
# 199 "/usr/include/math.h" 3
enum _ZUt_ {
FP_NAN,

FP_INFINITE,

FP_ZERO,

FP_SUBNORMAL,

FP_NORMAL};
# 292 "/usr/include/math.h" 3
enum _LIB_VERSION_TYPE {
_IEEE_ = (-1),
_SVID_,
_XOPEN_,
_POSIX_,
_ISOC_};
# 128 "/usr/local/include/c++/4.9.2/bits/cpp_type_traits.h" 3
enum _ZNSt9__is_voidIvEUt_E { _ZNSt9__is_voidIvE7__valueE = 1};
# 148 "/usr/local/include/c++/4.9.2/bits/cpp_type_traits.h" 3
enum _ZNSt12__is_integerIbEUt_E { _ZNSt12__is_integerIbE7__valueE = 1};
# 155 "/usr/local/include/c++/4.9.2/bits/cpp_type_traits.h" 3
enum _ZNSt12__is_integerIcEUt_E { _ZNSt12__is_integerIcE7__valueE = 1};
# 162 "/usr/local/include/c++/4.9.2/bits/cpp_type_traits.h" 3
enum _ZNSt12__is_integerIaEUt_E { _ZNSt12__is_integerIaE7__valueE = 1};
# 169 "/usr/local/include/c++/4.9.2/bits/cpp_type_traits.h" 3
enum _ZNSt12__is_integerIhEUt_E { _ZNSt12__is_integerIhE7__valueE = 1};
# 177 "/usr/local/include/c++/4.9.2/bits/cpp_type_traits.h" 3
enum _ZNSt12__is_integerIwEUt_E { _ZNSt12__is_integerIwE7__valueE = 1};
# 201 "/usr/local/include/c++/4.9.2/bits/cpp_type_traits.h" 3
enum _ZNSt12__is_integerIsEUt_E { _ZNSt12__is_integerIsE7__valueE = 1};
# 208 "/usr/local/include/c++/4.9.2/bits/cpp_type_traits.h" 3
enum _ZNSt12__is_integerItEUt_E { _ZNSt12__is_integerItE7__valueE = 1};
# 215 "/usr/local/include/c++/4.9.2/bits/cpp_type_traits.h" 3
enum _ZNSt12__is_integerIiEUt_E { _ZNSt12__is_integerIiE7__valueE = 1};
# 222 "/usr/local/include/c++/4.9.2/bits/cpp_type_traits.h" 3
enum _ZNSt12__is_integerIjEUt_E { _ZNSt12__is_integerIjE7__valueE = 1};
# 229 "/usr/local/include/c++/4.9.2/bits/cpp_type_traits.h" 3
enum _ZNSt12__is_integerIlEUt_E { _ZNSt12__is_integerIlE7__valueE = 1};
# 236 "/usr/local/include/c++/4.9.2/bits/cpp_type_traits.h" 3
enum _ZNSt12__is_integerImEUt_E { _ZNSt12__is_integerImE7__valueE = 1};
# 243 "/usr/local/include/c++/4.9.2/bits/cpp_type_traits.h" 3
enum _ZNSt12__is_integerIxEUt_E { _ZNSt12__is_integerIxE7__valueE = 1};
# 250 "/usr/local/include/c++/4.9.2/bits/cpp_type_traits.h" 3
enum _ZNSt12__is_integerIyEUt_E { _ZNSt12__is_integerIyE7__valueE = 1};
# 268 "/usr/local/include/c++/4.9.2/bits/cpp_type_traits.h" 3
enum _ZNSt13__is_floatingIfEUt_E { _ZNSt13__is_floatingIfE7__valueE = 1};
# 275 "/usr/local/include/c++/4.9.2/bits/cpp_type_traits.h" 3
enum _ZNSt13__is_floatingIdEUt_E { _ZNSt13__is_floatingIdE7__valueE = 1};
# 282 "/usr/local/include/c++/4.9.2/bits/cpp_type_traits.h" 3
enum _ZNSt13__is_floatingIeEUt_E { _ZNSt13__is_floatingIeE7__valueE = 1};
# 350 "/usr/local/include/c++/4.9.2/bits/cpp_type_traits.h" 3
enum _ZNSt9__is_charIcEUt_E { _ZNSt9__is_charIcE7__valueE = 1};
# 358 "/usr/local/include/c++/4.9.2/bits/cpp_type_traits.h" 3
enum _ZNSt9__is_charIwEUt_E { _ZNSt9__is_charIwE7__valueE = 1};
# 373 "/usr/local/include/c++/4.9.2/bits/cpp_type_traits.h" 3
enum _ZNSt9__is_byteIcEUt_E { _ZNSt9__is_byteIcE7__valueE = 1};
# 380 "/usr/local/include/c++/4.9.2/bits/cpp_type_traits.h" 3
enum _ZNSt9__is_byteIaEUt_E { _ZNSt9__is_byteIaE7__valueE = 1};
# 387 "/usr/local/include/c++/4.9.2/bits/cpp_type_traits.h" 3
enum _ZNSt9__is_byteIhEUt_E { _ZNSt9__is_byteIhE7__valueE = 1};
# 138 "/usr/local/include/c++/4.9.2/bits/cpp_type_traits.h" 3
enum _ZNSt12__is_integerIeEUt_E { _ZNSt12__is_integerIeE7__valueE}; enum _ZNSt12__is_integerIdEUt_E { _ZNSt12__is_integerIdE7__valueE}; enum _ZNSt12__is_integerIfEUt_E { _ZNSt12__is_integerIfE7__valueE};
# 43 "/usr/local/include/c++/4.9.2/ext/type_traits.h" 3
struct _ZN9__gnu_cxx11__enable_ifILb1EdEE;
# 212 "/usr/local/lib/gcc/x86_64-unknown-linux-gnu/4.9.2/include/stddef.h" 3
typedef unsigned long size_t;
#include "crt/host_runtime.h"
# 48 "/usr/local/include/c++/4.9.2/ext/type_traits.h" 3
typedef double _ZN9__gnu_cxx11__enable_ifILb1EdE6__typeE;
# 43 "/usr/local/include/c++/4.9.2/ext/type_traits.h" 3
struct _ZN9__gnu_cxx11__enable_ifILb1EdEE {char __nv_no_debug_dummy_end_padding_0;};
void *memcpy(void*, const void*, size_t); void *memset(void*, int, size_t);
# 2776 "/usr/local/cuda/bin/../targets/x86_64-linux/include/cuda_runtime_api.h"
extern enum cudaError cudaConfigureCall(struct dim3, struct dim3, size_t, struct CUstream_st *);
# 2957 "/usr/local/cuda/bin/../targets/x86_64-linux/include/cuda_runtime_api.h"
extern enum cudaError cudaMalloc(void **, size_t);
# 3094 "/usr/local/cuda/bin/../targets/x86_64-linux/include/cuda_runtime_api.h"
extern enum cudaError cudaFree(void *);
# 3987 "/usr/local/cuda/bin/../targets/x86_64-linux/include/cuda_runtime_api.h"
extern enum cudaError cudaMemcpy(void *, const void *, size_t, enum cudaMemcpyKind);
# 16 "vd.cu"
extern int main(int, char **);
# 490 "/usr/local/cuda/bin/../targets/x86_64-linux/include/cuda_runtime.h"
static __inline__ enum cudaError _Z10cudaMallocIfE9cudaErrorPPT_m(float **, size_t);
extern int __cudaSetupArgSimple();
extern int __cudaLaunch();
# 456 "/usr/local/include/c++/4.9.2/cmath" 3
extern  __attribute__((__weak__)) /* COMDAT group: _ZSt3sinIiEN9__gnu_cxx11__enable_ifIXsr3std12__is_integerIT_EE7__valueEdE6__typeES2_ */ __inline__ _ZN9__gnu_cxx11__enable_ifILb1EdE6__typeE _ZSt3sinIiEN9__gnu_cxx11__enable_ifIXsr3std12__is_integerIT_EE7__valueEdE6__typeES2_(int);
# 215 "/usr/local/include/c++/4.9.2/cmath" 3
extern  __attribute__((__weak__)) /* COMDAT group: _ZSt3cosIiEN9__gnu_cxx11__enable_ifIXsr3std12__is_integerIT_EE7__valueEdE6__typeES2_ */ __inline__ _ZN9__gnu_cxx11__enable_ifILb1EdE6__typeE _ZSt3cosIiEN9__gnu_cxx11__enable_ifIXsr3std12__is_integerIT_EE7__valueEdE6__typeES2_(int);
extern void __nv_dummy_param_ref();
extern void __nv_save_fatbinhandle_for_managed_rt();
extern int __cudaRegisterEntry();
extern int __cudaRegisterBinary();
static void __sti___10_vd_cpp1_ii_a311767b(void) __attribute__((__constructor__));
# 16 "vd.cu"
int main( int argc,  char **argv)
{  float __T20;
 struct dim3 __T21;
 unsigned __T22;
 struct dim3 __T23;
 unsigned __T24;
 float *__cuda_local_var_41747_12_non_const_h_a;
 float *__cuda_local_var_41748_12_non_const_h_b;

 float *__cuda_local_var_41750_12_non_const_h_c;


 float *__cuda_local_var_41753_12_non_const_d_a;
 float *__cuda_local_var_41754_12_non_const_d_b;

 float *__cuda_local_var_41756_12_non_const_d_c;


 size_t __cuda_local_var_41759_12_non_const_bytes;
# 45 "vd.cu"
 int __cuda_local_var_41770_9_non_const_i;
# 56 "vd.cu"
 int __cuda_local_var_41781_9_non_const_blockSize;
# 56 "vd.cu"
 int __cuda_local_var_41781_20_non_const_gridSize;
# 71 "vd.cu"
 float __cuda_local_var_41796_11_non_const_sum;
# 34 "vd.cu"
__cuda_local_var_41759_12_non_const_bytes = 20480UL;


__cuda_local_var_41747_12_non_const_h_a = ((float *)(malloc(__cuda_local_var_41759_12_non_const_bytes)));
__cuda_local_var_41748_12_non_const_h_b = ((float *)(malloc(__cuda_local_var_41759_12_non_const_bytes)));
__cuda_local_var_41750_12_non_const_h_c = ((float *)(malloc(__cuda_local_var_41759_12_non_const_bytes)));

_Z10cudaMallocIfE9cudaErrorPPT_m((&__cuda_local_var_41753_12_non_const_d_a), __cuda_local_var_41759_12_non_const_bytes);
_Z10cudaMallocIfE9cudaErrorPPT_m((&__cuda_local_var_41754_12_non_const_d_b), __cuda_local_var_41759_12_non_const_bytes);
_Z10cudaMallocIfE9cudaErrorPPT_m((&__cuda_local_var_41756_12_non_const_d_c), __cuda_local_var_41759_12_non_const_bytes);



for (__cuda_local_var_41770_9_non_const_i = 0; (__cuda_local_var_41770_9_non_const_i < 5120); __cuda_local_var_41770_9_non_const_i++) {
(__cuda_local_var_41747_12_non_const_h_a[__cuda_local_var_41770_9_non_const_i]) = ((float)((_ZSt3sinIiEN9__gnu_cxx11__enable_ifIXsr3std12__is_integerIT_EE7__valueEdE6__typeES2_(__cuda_local_var_41770_9_non_const_i)) * (_ZSt3sinIiEN9__gnu_cxx11__enable_ifIXsr3std12__is_integerIT_EE7__valueEdE6__typeES2_(__cuda_local_var_41770_9_non_const_i))));
(__cuda_local_var_41748_12_non_const_h_b[__cuda_local_var_41770_9_non_const_i]) = ((float)((_ZSt3cosIiEN9__gnu_cxx11__enable_ifIXsr3std12__is_integerIT_EE7__valueEdE6__typeES2_(__cuda_local_var_41770_9_non_const_i)) * (_ZSt3cosIiEN9__gnu_cxx11__enable_ifIXsr3std12__is_integerIT_EE7__valueEdE6__typeES2_(__cuda_local_var_41770_9_non_const_i))));
}


cudaMemcpy(((void *)__cuda_local_var_41753_12_non_const_d_a), ((const void *)__cuda_local_var_41747_12_non_const_h_a), __cuda_local_var_41759_12_non_const_bytes, cudaMemcpyHostToDevice);
cudaMemcpy(((void *)__cuda_local_var_41754_12_non_const_d_b), ((const void *)__cuda_local_var_41748_12_non_const_h_b), __cuda_local_var_41759_12_non_const_bytes, cudaMemcpyHostToDevice);




__cuda_local_var_41781_9_non_const_blockSize = 1024;


__cuda_local_var_41781_20_non_const_gridSize = ((int)((__T20 = ((5120.0F) / ((float)__cuda_local_var_41781_9_non_const_blockSize))) , (__builtin_ceilf(__T20))));


(cudaConfigureCall((((void)((__T22 = ((unsigned)__cuda_local_var_41781_20_non_const_gridSize)) , (void)((((__T21.x) = __T22) , (void)((__T21.y) = 1U)) , ((__T21.z) = 1U)))) , __T21), (((void)((__T24 = ((unsigned)__cuda_local_var_41781_9_non_const_blockSize)) , (void)((((__T23.x) = __T24) , (void)((__T23.y) = 1U)) , ((__T23.z) = 1U)))) , __T23), 0UL, ((struct CUstream_st *)0LL))) ? ((void)0) : (__device_stub__Z6vecAddPfS_S_(__cuda_local_var_41753_12_non_const_d_a, __cuda_local_var_41754_12_non_const_d_b, __cuda_local_var_41756_12_non_const_d_c));


cudaMemcpy(((void *)__cuda_local_var_41750_12_non_const_h_c), ((const void *)__cuda_local_var_41756_12_non_const_d_c), __cuda_local_var_41759_12_non_const_bytes, cudaMemcpyDeviceToHost);


__cuda_local_var_41796_11_non_const_sum = (0.0F);
for (__cuda_local_var_41770_9_non_const_i = 0; (__cuda_local_var_41770_9_non_const_i < 5120); __cuda_local_var_41770_9_non_const_i++) {
__cuda_local_var_41796_11_non_const_sum += (__cuda_local_var_41750_12_non_const_h_c[__cuda_local_var_41770_9_non_const_i]);

}

printf(((const char *)"final result: %f\n"), ((double)(__cuda_local_var_41796_11_non_const_sum / (5120.0F))));


cudaFree(((void *)__cuda_local_var_41753_12_non_const_d_a));
cudaFree(((void *)__cuda_local_var_41754_12_non_const_d_b));
cudaFree(((void *)__cuda_local_var_41756_12_non_const_d_c));


free(((void *)__cuda_local_var_41747_12_non_const_h_a));
free(((void *)__cuda_local_var_41748_12_non_const_h_b));
free(((void *)__cuda_local_var_41750_12_non_const_h_c));
return 0;
}
# 490 "/usr/local/cuda/bin/../targets/x86_64-linux/include/cuda_runtime.h"
static __inline__ enum cudaError _Z10cudaMallocIfE9cudaErrorPPT_m(
float **devPtr, 
size_t size)

{
return cudaMalloc(((void **)((void *)devPtr)), size);
}
# 456 "/usr/local/include/c++/4.9.2/cmath" 3
 __attribute__((__weak__)) /* COMDAT group: _ZSt3sinIiEN9__gnu_cxx11__enable_ifIXsr3std12__is_integerIT_EE7__valueEdE6__typeES2_ */ __inline__ _ZN9__gnu_cxx11__enable_ifILb1EdE6__typeE _ZSt3sinIiEN9__gnu_cxx11__enable_ifIXsr3std12__is_integerIT_EE7__valueEdE6__typeES2_( int __x)
{ return __builtin_sin(((double)__x)); }
# 215 "/usr/local/include/c++/4.9.2/cmath" 3
 __attribute__((__weak__)) /* COMDAT group: _ZSt3cosIiEN9__gnu_cxx11__enable_ifIXsr3std12__is_integerIT_EE7__valueEdE6__typeES2_ */ __inline__ _ZN9__gnu_cxx11__enable_ifILb1EdE6__typeE _ZSt3cosIiEN9__gnu_cxx11__enable_ifIXsr3std12__is_integerIT_EE7__valueEdE6__typeES2_( int __x)
{ return __builtin_cos(((double)__x)); }
static void __sti___10_vd_cpp1_ii_a311767b(void) {   }

#include "vd.cudafe1.stub.c"
