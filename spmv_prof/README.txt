nvcc spmv_index.cu -arch=sm_20 -o spmv_index
nvcc spmv.cu -o spmv
nvcc 1.cu -o 1
nvcc 2.cu -o 2
********************************************
file			val			cols	rowDelimiters	vec			out		partialSums		spmv_NBLOCKS	Remarks
spmv.cu			global		global	global			global		global	shared			12*8*22
1.cu			global		global	shared			global		global	shared			12*8*21			1.cu === 3.cu
2.cu			global		global	constant		global		global	shared			12*8*21		
4.cu			global		global	shared(NA)		tex1D		global	shared			12*8*21			uncorrect/ 4_overhead = 4
5.cu			tex1D((NA)	global	global			global		global	shared			12*8*21			uncorrect/
6.cu			global		global	tex1D			constant	global	shared			12*8*21		
7.cu			global		global	global			tex1D		global	shared			12*8*22
8.cu			global		global	shared(NA)		tex1D		global	shared			12*8*21			uncorrect
9.cu			tex1D		tex1D	constant		global		global	shared			12*8*21		
10.cu 			tex1D		tex1D	global			tex1D		global	shared			12*8*22
11.cu			global		global	global			tex1D		global	shared			12*8*22			uncorrect/sparse items difference
combine.cu		global		global	global			global		global	shared			12*8*21			ldg
read.cu			global		global	global			global		global	shared			12*8*21*2		ldg/==read_spmv.cu


1. spmv_index.cu: profiling  (./spmv_index)
2. spmv.cu: original one; ulmo:0.0012433s, gpu1:0.00372541s  (./spmv)
3. 1.cu: array rowDeli is put in shared memory; ulmo:0.00127757s, gpu1:0.00376586s (./1)
4. 2.cu: BEST ONE,array rowDeli is put in constant memory; ulmo: 0.00122829s, gpu1:0.00372298s (./2)


volatile ?
const __restrict__
********************************************
#original: spmv.cu
#nvcc spmv.cu -o spmv -arch=sm_35
#PORPLE:7.cu


spmv_index.cu

#define spmv_NBLOCKS 12*8*21 //22

spmv.cu
#define spmv_NBLOCKS 12*8*22 //22


