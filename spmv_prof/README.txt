#original: spmv.cu
#nvcc spmv.cu -o spmv -arch=sm_35
#PORPLE:7.cu


spmv_index.cu

	#define spmv_NBLOCKS 12*8*21 //22
	
spmv.cu
	#define spmv_NBLOCKS 12*8*22 //22
