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
all: spmv 1 2 4 5 6
spmv:
	$(NVCC) --generate-line-info --cubin $@.cu
	$(NVCC) -o $@ $@.cu
	nvdisasm  --print-line-info $@.cubin  > instruction/$@.txt
2:
	$(NVCC) --generate-line-info --cubin $@.cu
	$(NVCC) -o $@ $@.cu
	nvdisasm  --print-line-info $@.cubin  > instruction/$@.txt
4:
	$(NVCC) --generate-line-info --cubin $@.cu
	$(NVCC) -o $@ $@.cu
	nvdisasm  --print-line-info $@.cubin  > instruction/$@.txt
5:
	$(NVCC) --generate-line-info --cubin $@.cu
	$(NVCC) -o $@ $@.cu
	nvdisasm  --print-line-info $@.cubin  > instruction/$@.txt
6:
	$(NVCC) --generate-line-info --cubin $@.cu
	$(NVCC) -o $@ $@.cu
	nvdisasm  --print-line-info $@.cubin  > instruction/$@.txt
spmv:
	$(NVCC) --generate-line-info --cubin $@.cu
	$(NVCC) -o $@ $@.cu
	nvdisasm  --print-line-info $@.cubin  > instruction/$@.txt
	
prof_spmv:
	nvprof  --events all --metrics all  --csv --log-file spmv.csv ./spmv
	
trace_spmv:
	nvprof --print-gpu-trace ./spmv
	nvprof --print-api-trace ./spmv
clean:
	rm spmv
#Hints
#nvprof --print-gpu-trace ./spmv
#nvprof --print-api-trace ./spmv_index

# Metrics and event reference
reference:
	nvprof --query-metrics --query-events > prof/reference.txt
#Qucik implement
# nvcc -o 6 6.cu
