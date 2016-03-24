#makefile

#include ../../common/make.config
CUDA_PATH       ?= /usr/local/cuda-7.0
INCLUDE   ?= $(CUDA_PATH)/include
CUDA_BIN_PATH   ?= $(CUDA_PATH)/bin
CUDA_LIB_DIR  ?= $(CUDA_PATH)/lib64
NVCC            ?= $(CUDA_BIN_PATH)/nvcc

objects =

all: $(objects)

1 best1 best2 best3_1000 best3 best4 best5 best ex_particle_CUDA_float_seq naive naive_cpu original:
	$(NVCC) -I$(INCLUDE) -L$(CUDA_LIB_DIR) -lcuda -g -lm -O3 -use_fast_math -arch sm_20 $@.cu -o $@
	./$@ -x 128 -y 128 -z 2 -np 1000
#nvprof  --events all --metrics all  --csv --log-file $@.csv ./$@
#naive: index.cu
#	$(NVCC) -I$(INCLUDE) -L$(CUDA_LIB_DIR) -lcuda -g -lm -O3 -use_fast_math -arch sm_20 $@.cu -o $@
	
#float: ex_particle_CUDA_float_seq.cu
#	$(NVCC) -I$(INCLUDE) -L$(CUDA_LIB_DIR) -lcuda -g -lm -O3 -use_fast_math -arch sm_20 $@.cu -o $@

clean:
	rm $(objects)
