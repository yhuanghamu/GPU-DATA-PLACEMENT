Sample: CUDA Separable Convolution
Minimum spec: GeForce 8

This sample implements a separable convolution filter of a 2D signal with a gaussian kernel.

Key concepts:

1. convolution_index.cu: Profiling(To support -arch=sm_20, can only be run on ulmo)          (./convolution_index)
2. convolution.cu:  original one(c_Kernel in constant memory, d_Src in global memory); ulmo:Time = 0.00281 s, gpu1:0.00299 s (./convolution)
3. 1.cu:  c_Kernel and d_Src are in global memory; ulmo: Time = 0.01463 s, gpu1:0.07275 s  (./1)
4. 2.cu:  small size(c_Kernel and d_Src are in constant memory); ulmo: Time = 0.00004 s, gpu1:0.00004 s (./2)
    2_re.cu: small size of original one(c_Kernel in constant memory, d_Src in global memory); ulmo: Time = 0.00002 s, gpu1:0.00002 s (./2_re)
5. 3.cu:  BEST ONE(c_Kernel in constant memory, d_Src in texture memory);  ulmo: Time = 0.00250 s,gpu1:0.00331 s (./3)
6. 4.cu:  small size(c_Kernel in global memory, d_Src in constant memory); ulmo: Time = 0.00004 s,gpu1:0.00005 s (./4)
7. 5.cu:  c_Kernel in texture memory, d_Src in global memory; ulmo: Time = 0.00279 s, gpu1:0.00734 s   (./5)
8. con-rule.cu : ~4.cu
