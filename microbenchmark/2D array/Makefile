
# Location of the CUDA Toolkit binaries and libraries
CUDA_PATH       ?= /usr/local/cuda
CUDA_INC_PATH   ?= $(CUDA_PATH)/include
CUDA_BIN_PATH   ?= $(CUDA_PATH)/bin
CUDA_LIB_PATH  ?= $(CUDA_PATH)/lib64
# Common binaries
NVCC            ?= $(CUDA_BIN_PATH)/nvcc
all: vd vd_shared vd_constant vd_tex	
vd_g_2d:
	$(NVCC) --generate-line-info --cubin $@.cu
	$(NVCC) -o $@ $@.cu
	nvdisasm  --print-line-info $@.cubin  > instruction/$@_instruction.txt
vd_c_2d:
	$(NVCC) --generate-line-info --cubin $@.cu
	$(NVCC) -o $@ $@.cu
	nvdisasm  --print-line-info $@.cubin  > instruction/$@_instruction.txt
vd_s_2d:
	$(NVCC) --generate-line-info --cubin $@.cu
	$(NVCC) -o $@ $@.cu
	nvdisasm  --print-line-info $@.cubin  > instruction/$@_instruction.txt
vd_t_2d:
	$(NVCC) --generate-line-info --cubin $@.cu
	$(NVCC) -o $@ $@.cu
	nvdisasm  --print-line-info $@.cubin  > instruction/$@_instruction.txt

clean:
	rm -f vd_g_2d vd_c_2d vd_s_2d vd_t_2d *.cubin
	
# nvcc --generate-line-info --cubin  vd.cu
# nvdisasm  --print-line-info vd.cubin
