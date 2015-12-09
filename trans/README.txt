trans.cu: original one
nvcc trans.cu -o trans -arch=sm_35

PORPLE: surface.cu
nvcc surface.cu -o surface -arch=sm_35


