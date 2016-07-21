
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

vd_g: vd_g_i vd_g_f vd_g_d
vd_g_i:
	$(NVCC) --generate-line-info --cubin $@.cu
	$(NVCC) -o $@ $@.cu
	nvdisasm  --print-line-info $@.cubin  > sass/$@.txt
vd_g_f:
	$(NVCC) --generate-line-info --cubin $@.cu
	$(NVCC) -o $@ $@.cu
	nvdisasm  --print-line-info $@.cubin  > sass/$@.txt
vd_g_d:
	$(NVCC) --generate-line-info --cubin $@.cu
	$(NVCC) -o $@ $@.cu
	nvdisasm  --print-line-info $@.cubin  > sass/$@.txt

vd_c: vd_c_i vd_c_f vd_c_d
vd_c_i:
	$(NVCC) --generate-line-info --cubin $@.cu
	$(NVCC) -o $@ $@.cu
	nvdisasm  --print-line-info $@.cubin  > sass/$@.txt
vd_c_f:
	$(NVCC) --generate-line-info --cubin $@.cu
	$(NVCC) -o $@ $@.cu
	nvdisasm  --print-line-info $@.cubin  > sass/$@.txt
vd_c_d:
	$(NVCC) --generate-line-info --cubin $@.cu
	$(NVCC) -o $@ $@.cu
	nvdisasm  --print-line-info $@.cubin  > sass/$@.txt

vd_s: vd_s_i vd_s_f vd_s_d
vd_s_i:
	$(NVCC) --generate-line-info --cubin $@.cu
	$(NVCC) -o $@ $@.cu
	nvdisasm  --print-line-info $@.cubin  > sass/$@.txt
vd_s_f:
	$(NVCC) --generate-line-info --cubin $@.cu
	$(NVCC) -o $@ $@.cu
	nvdisasm  --print-line-info $@.cubin  > sass/$@.txt
vd_s_d:
	$(NVCC) --generate-line-info --cubin $@.cu
	$(NVCC) -o $@ $@.cu
	nvdisasm  --print-line-info $@.cubin  > sass/$@.txt

vd_t: vd_t_i vd_t_f vd_t_d
vd_t_i:
	$(NVCC) --generate-line-info --cubin $@.cu
	$(NVCC) -o $@ $@.cu
	nvdisasm  --print-line-info $@.cubin  > sass/$@.txt
vd_t_f:
	$(NVCC) --generate-line-info --cubin $@.cu
	$(NVCC) -o $@ $@.cu
	nvdisasm  --print-line-info $@.cubin  > sass/$@.txt
vd_t_d:
	$(NVCC) --generate-line-info --cubin $@.cu
	$(NVCC) -o $@ $@.cu
	nvdisasm  --print-line-info $@.cubin  > sass/$@.txt
clean:
	rm -f vd_g_f vd_s vd_c vd_t *.cubin
	
# nvcc --generate-line-info --cubin  vd.cu
# nvdisasm  --print-line-info vd.cubin
