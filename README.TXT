For all the benchmarks:ConvolutionSeparable(SDK), spmv(SHOC),MAtrixAdd, MM(SDK), MD(SHOC),PathFinder(Rodinia), NW(Rodinia), Hotspot(Rodinia), Particlefilter(Rodinia)

1 First go to one folder, and run compile.sh
2 Second run file named as *_index. For example, under folder convolutionSeparable, ./convolution_index  to see the profiling information. Profiling results saved to "d_Src_D2.txt" and "c_Kernel_D2.txt"; "d_Src_D2.txt" contains array d_Src data access pattern, _D2 means the thread blocks are in two dimentions. 
  For how to run these files, please look into each config.txt.

3 Third, use analysis.py to analysis each profiling information. run "./../analysis.py d_Src_D2.txt 2" to find out where should the array be put. Here 2 means two dimensions. If d_Src_D1.txt, then run "./../analysis.py d_Src_D1.txt 1"
  e.g. "choose column = 3072
        d_Src_D2.txt should be put in texture memory!
        total priority = memory access times: 160"
   The result show that array d_Src should be put in texture memory, and the array should be reconstructed as two dimensions, the # of columns should be 3072.
   The priority is same as the memory access times which can be benefited when using texture memory.
   
4 At last, open file config.txt to see all the modified versions, you will find out the best one which is found out by the analysis.py

______________________________________________________________________________
WARNING: analysis.py is just a primeval version. For all the data access patterns in these benchmarks, it works well.



pathfinder/read_stride.py is latest!  updating convolutionSeparable
2014. 3.18 convolutiontSeparable read_stride_block.py is latest updating convolutiontSeparable read_stride_thread_block.py(constant and global works)  1Dtexture.py 2Dtexture.py shared1.py works
2014 4.1 find out that  convolution: read_stride_thread_block.py(constant and global L1 not w has problem when put together) then split into constant.py global.py    with  previous (1Dtexture.py 2D texture.py shared1.py works

2014 4.4 all things in spmv are correct!fix things in convolutions.
2014 4 12 all things 1Dtexture_noprint.py 2Dtexture_noprintout.py shared_noprintout texture_noprintout.py in spmv are correct and optimized.
2014 4 12 global_noprintout.py original one; global_noprint.py optimal one.
2014 4 12 shared_memory: output to "ldshared.txt" all threadID set to 0 so that it will be one transcation for near data for 2Dtexture_noprintout.py
2014 4 13 update constant.py to constant_noprintout.py,which deals with individule read from L1,L2,constant instead of just L1
