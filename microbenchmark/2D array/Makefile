
# Location of the CUDA Toolkit binaries and libraries
CUDA_PATH       ?= /usr/local/cuda
CUDA_INC_PATH   ?= $(CUDA_PATH)/include
CUDA_BIN_PATH   ?= $(CUDA_PATH)/bin
CUDA_LIB_PATH  ?= $(CUDA_PATH)/lib64
LINE_INFO	?= no
ifeq ($(LINE_INFO),yes)
	GEN_LINE_INFO ?= --generate-line-info
	PRINT_LINE_INFO ?= --print-line-info
	
else
	GEN_LINE_INFO ?=
	PRINT_LINE_INFO ?=
endif
# Common binaries
NVCC            ?= $(CUDA_BIN_PATH)/nvcc
all: vd vd_shared vd_constant vd_tex	
vd_g_2d:
	$(NVCC) $(GEN_LINE_INFO) --cubin $@.cu
	$(NVCC) -o $@ $@.cu
	nvdisasm  $(PRINT_LINE_INFO) $@.cubin  > sass/$@_sass.txt
vd_c_2d:
	$(NVCC) $(GEN_LINE_INFO) --cubin $@.cu
	$(NVCC) -o $@ $@.cu
	nvdisasm  $(PRINT_LINE_INFO) $@.cubin  > sass/$@_sass.txt
vd_s_2d:
	$(NVCC) $(GEN_LINE_INFO) --cubin $@.cu
	$(NVCC) -o $@ $@.cu
	nvdisasm  $(PRINT_LINE_INFO) $@.cubin  > sass/$@_sass.txt
vd_t_2d:
	$(NVCC) $(GEN_LINE_INFO) --cubin $@.cu
	$(NVCC) -o $@ $@.cu
	nvdisasm  $(PRINT_LINE_INFO) $@.cubin  > sass/$@_sass.txt

clean:
	rm -f vd_g_2d vd_c_2d vd_s_2d vd_t_2d *.cubin
	
# nvcc $(GEN_LINE_INFO) --cubin  vd.cu
# nvdisasm  $(PRINT_LINE_INFO) vd.cubin
