nvcc spmv_index.cu -arch=sm_20 -o spmv_index
nvcc spmv.cu -o spmv
nvcc 1.cu -o 1
nvcc 2.cu -o 2
