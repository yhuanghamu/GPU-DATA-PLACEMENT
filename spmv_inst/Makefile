# Location of the CUDA Toolkit binaries and libraries
CUDA_PATH       ?= /usr/local/cuda-7.0
CUDA_INC_PATH   ?= $(CUDA_PATH)/include
CUDA_BIN_PATH   ?= $(CUDA_PATH)/bin
CUDA_LIB_PATH  ?= $(CUDA_PATH)/lib64
# Common binaries
NVCC            ?= $(CUDA_BIN_PATH)/nvcc
				
#spmv:
#	$(NVCC) $@.cu -o $@ -arch=sm_35
#	./spmv
#spmv_index:
#	$(NVCC) spmv_index.cu -o spmv_index -arch=sm_35
#	./spmv_index
#prof_spmv:
#	nvprof  --events all --metrics all  --csv --log-file spmv_prof.csv ./spmv 
#prof_spmv_index:
#	nvprof  --events all --metrics all --csv --log-file spmv_index_prof.csv ./spmv_index
#objects = 0 1 2 3 4 5 6 7 8 9 10 11	
#all: $(objects).cu
#	$(NVCC) -o $(objects) $(objects).cu
all:
	nvcc -o 0 0.cu
	nvcc -o 1 1.cu
	nvcc -o 2 2.cu
	nvcc -o 3 3.cu
	nvcc -o 4 4.cu
	nvcc -o 5 5.cu
	nvcc -o 6 6.cu
	nvcc -o 7 7.cu
	nvcc -o 8 8.cu
	nvcc -o 9 9.cu
	nvcc -o 10 10.cu
	nvcc -o 11 11.cu

prof: 0 1 2 4 5 6 7 8 9 10 11
	nvprof  --events all --metrics all  --csv --log-file 0.csv ./0
	nvprof  --events all --metrics all  --csv --log-file 1.csv ./1
	nvprof  --events all --metrics all  --csv --log-file 2.csv ./2
	nvprof  --events all --metrics all  --csv --log-file 3.csv ./3
	nvprof  --events all --metrics all  --csv --log-file 4.csv ./4
	nvprof  --events all --metrics all  --csv --log-file 5.csv ./5
	nvprof  --events all --metrics all  --csv --log-file 6.csv ./6
	nvprof  --events all --metrics all  --csv --log-file 7.csv ./7
	nvprof  --events all --metrics all  --csv --log-file 8.csv ./8
	nvprof  --events all --metrics all  --csv --log-file 9.csv ./9
	nvprof  --events all --metrics all  --csv --log-file 10.csv ./10
	nvprof  --events all --metrics all  --csv --log-file 10.csv ./11
inst:
	nvcc --generate-line-info --cubin 0.cu
	nvdisasm  -g -c 0.cubin  > instruction/0.txt
	nvcc --generate-line-info --cubin 1.cu
	nvdisasm  -g -c 1.cubin  > instruction/1.txt
	nvcc --generate-line-info --cubin 2.cu
	nvdisasm  -g -c 2.cubin  > instruction/2.txt
	nvcc --generate-line-info --cubin 3.cu
	nvdisasm  -g -c 3.cubin  > instruction/3.txt
	nvcc --generate-line-info --cubin 4.cu
	nvdisasm  -g -c 4.cubin  > instruction/4.txt
	nvcc --generate-line-info --cubin 5.cu
	nvdisasm  -g -c 5.cubin  > instruction/5.txt
	nvcc --generate-line-info --cubin 6.cu
	nvdisasm  -g -c 6.cubin  > instruction/6.txt
	nvcc --generate-line-info --cubin 7.cu
	nvdisasm  -g -c 7.cubin  > instruction/7.txt
	nvcc --generate-line-info --cubin 8.cu
	nvdisasm  -g -c 8.cubin  > instruction/8.txt
	nvcc --generate-line-info --cubin 9.cu
	nvdisasm  -g -c 9.cubin  > instruction/9.txt

	
#2:
#	$(NVCC) --generate-line-info --cubin $@.cu
#	$(NVCC) -o $@ $@.cu
#	nvdisasm  --print-line-info $@.cubin  > instruction/$@.txt
#4:
#	$(NVCC) --generate-line-info --cubin $@.cu
#	$(NVCC) -o $@ $@.cu
#	nvdisasm  --print-line-info $@.cubin  > instruction/$@.txt
#5:
#	$(NVCC) --generate-line-info --cubin $@.cu
#	$(NVCC) -o $@ $@.cu
#	nvdisasm  --print-line-info $@.cubin  > instruction/$@.txt
#6:
#	$(NVCC) --generate-line-info --cubin $@.cu
#	$(NVCC) -o $@ $@.cu
#	nvdisasm  --print-line-info $@.cubin  > instruction/$@.txt
#spmv:
#	$(NVCC) --generate-line-info --cubin $@.cu
#	$(NVCC) -o $@ $@.cu
#	nvdisasm  --print-line-info $@.cubin  > instruction/$@.txt

#prof_spmv:
#	nvprof  --events all --metrics all  --csv --log-file spmv.csv ./spmv
	
trace_spmv:
	nvprof --print-gpu-trace ./spmv
	nvprof --print-api-trace ./spmv
clean:
	rm *.cubin
#Hints
#nvprof --print-gpu-trace ./spmv
#nvprof --print-api-trace ./spmv_index

# Metrics and event reference
reference:
	nvprof --query-metrics --query-events > prof/reference.txt
#Qucik implement
# nvcc -o 6 6.cu
