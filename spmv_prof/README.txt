nvcc spmv_index.cu -arch=sm_20 -o spmv_index
nvcc spmv.cu -o spmv
nvcc 1.cu -o 1
nvcc 2.cu -o 2


1. spmv_index.cu: profiling  (./spmv_index)
2. spmv.cu: original one; ulmo:0.0012433s, gpu1:0.00372541s  (./spmv)
3. 1.cu: array rowDeli is put in shared memory; ulmo:0.00127757s, gpu1:0.00376586s (./1)
4. 2.cu: BEST ONE,array rowDeli is put in constant memory; ulmo: 0.00122829s, gpu1:0.00372298s (./2)

********************************************
#original: spmv.cu
#nvcc spmv.cu -o spmv -arch=sm_35
#PORPLE:7.cu


spmv_index.cu

#define spmv_NBLOCKS 12*8*21 //22

spmv.cu
#define spmv_NBLOCKS 12*8*22 //22
