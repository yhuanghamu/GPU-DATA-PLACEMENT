#define __NV_CUBIN_HANDLE_STORAGE__ static
#include "crt/host_runtime.h"
#include "vd.fatbin.c"
extern void __device_stub__Z6vecAddPfS_S_(float *, float *, float *);
static void __nv_cudaEntityRegisterCallback(void **);
static void __sti____cudaRegisterAll_10_vd_cpp1_ii_a311767b(void) __attribute__((__constructor__));
void __device_stub__Z6vecAddPfS_S_(float *__par0, float *__par1, float *__par2){__cudaSetupArgSimple(__par0, 0UL);__cudaSetupArgSimple(__par1, 8UL);__cudaSetupArgSimple(__par2, 16UL);__cudaLaunch(((char *)((void ( *)(float *, float *, float *))vecAdd)));}
# 6 "vd.cu"
void vecAdd( float *__cuda_0,float *__cuda_1,float *__cuda_2)
# 7 "vd.cu"
{__device_stub__Z6vecAddPfS_S_( __cuda_0,__cuda_1,__cuda_2);
# 14 "vd.cu"
}
# 1 "vd.cudafe1.stub.c"
static void __nv_cudaEntityRegisterCallback( void **__T25) {  __nv_dummy_param_ref(__T25); __nv_save_fatbinhandle_for_managed_rt(__T25); __cudaRegisterEntry(__T25, ((void ( *)(float *, float *, float *))vecAdd), _Z6vecAddPfS_S_, (-1)); }
static void __sti____cudaRegisterAll_10_vd_cpp1_ii_a311767b(void) {  __cudaRegisterBinary(__nv_cudaEntityRegisterCallback);  }
