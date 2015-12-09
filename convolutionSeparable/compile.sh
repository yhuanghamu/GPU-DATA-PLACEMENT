nvcc convolution_index.cu -arch=sm_20 -o convolution_index
nvcc convolution.cu  -o convolution
nvcc 1.cu -o 1
nvcc 2.cu -o 2
nvcc 2_re.cu -o 2_re
nvcc 3.cu  -o 3
nvcc 4.cu -o 4
nvcc 5.cu -o 5
#nvcc 6.cu -arch=sm_20 -o 6
