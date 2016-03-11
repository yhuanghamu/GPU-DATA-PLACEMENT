
# Location of the CUDA Toolkit binaries and libraries
CUDA_PATH       ?= /usr/local/cuda-7.0
CUDA_INC_PATH   ?= $(CUDA_PATH)/include
CUDA_BIN_PATH   ?= $(CUDA_PATH)/bin
CUDA_LIB_PATH  ?= $(CUDA_PATH)/lib64
# Common binaries
NVCC            ?= $(CUDA_BIN_PATH)/nvcc
all: vd vd_shared vd_constant vd_tex	
vd:
	$(NVCC) --generate-line-info --cubin $@.cu
	$(NVCC) -o $@ $@.cu
	nvdisasm  --print-line-info $@.cubin  > instruction/$@_instruction.txt
vd_shared:
	$(NVCC) --generate-line-info --cubin $@.cu
	$(NVCC) -o $@ $@.cu
	nvdisasm  --print-line-info $@.cubin  > instruction/$@_instruction.txt
vd_constant:
	$(NVCC) --generate-line-info --cubin $@.cu
	$(NVCC) -o $@ $@.cu
	nvdisasm  --print-line-info $@.cubin  > instruction/$@_instruction.txt
vd_tex:
	$(NVCC) --generate-line-info --cubin $@.cu
	$(NVCC) -o $@ $@.cu
	nvdisasm  --print-line-info $@.cubin  > instruction/$@_instruction.txt

vd2:
	$(NVCC) --generate-line-info --cubin $@.cu
	$(NVCC) -o $@ $@.cu
	nvdisasm  --print-line-info $@.cubin  > instruction/$@_instruction.txt
vd_shared2:
	$(NVCC) --generate-line-info --cubin $@.cu
	$(NVCC) -o $@ $@.cu
	nvdisasm  --print-line-info $@.cubin  > instruction/$@_instruction.txt
vd_constant2:
	$(NVCC) --generate-line-info --cubin $@.cu
	$(NVCC) -o $@ $@.cu
	nvdisasm  --print-line-info $@.cubin  > instruction/$@_instruction.txt
vd_tex2:
	$(NVCC) --generate-line-info --cubin $@.cu
	$(NVCC) -o $@ $@.cu
	nvdisasm  --print-line-info $@.cubin  > instruction/$@_instruction.txt
clean:
	rm -f vd vd_shared vd_constant vd_tex *.cubin
	
# nvcc --generate-line-info --cubin  vd.cu
# nvdisasm  --print-line-info vd.cubin
