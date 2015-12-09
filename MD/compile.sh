nvcc md_index.cu -o md_index -arch=sm_20
nvcc md.cu -o md -arch=sm_20
nvcc 1.cu -o 1 -arch=sm_20
