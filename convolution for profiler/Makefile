################################################################################
#
# Copyright 1993-2012 NVIDIA Corporation.  All rights reserved.
#
# NOTICE TO USER:   
#
# This source code is subject to NVIDIA ownership rights under U.S. and 
# international Copyright laws.  
#
# NVIDIA MAKES NO REPRESENTATION ABOUT THE SUITABILITY OF THIS SOURCE 
# CODE FOR ANY PURPOSE.  IT IS PROVIDED "AS IS" WITHOUT EXPRESS OR 
# IMPLIED WARRANTY OF ANY KIND.  NVIDIA DISCLAIMS ALL WARRANTIES WITH 
# REGARD TO THIS SOURCE CODE, INCLUDING ALL IMPLIED WARRANTIES OF 
# MERCHANTABILITY, NONINFRINGEMENT, AND FITNESS FOR A PARTICULAR PURPOSE.   
# IN NO EVENT SHALL NVIDIA BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL, 
# OR CONSEQUENTIAL DAMAGES, OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS 
# OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE 
# OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE 
# OR PERFORMANCE OF THIS SOURCE CODE.  
#
# U.S. Government End Users.  This source code is a "commercial item" as 
# that term is defined at 48 C.F.R. 2.101 (OCT 1995), consisting  of 
# "commercial computer software" and "commercial computer software 
# documentation" as such terms are used in 48 C.F.R. 12.212 (SEPT 1995) 
# and is provided to the U.S. Government only as a commercial end item.  
# Consistent with 48 C.F.R.12.212 and 48 C.F.R. 227.7202-1 through 
# 227.7202-4 (JUNE 1995), all U.S. Government End Users acquire the 
# source code with only those rights set forth herein.
#
################################################################################
#
# Makefile project only supported on Mac OSX and Linux Platforms)
#
################################################################################

# OS Name (Linux or Darwin) => LINUX/linux
OSUPPER = $(shell uname -s 2>/dev/null | tr [:lower:] [:upper:])
OSLOWER = $(shell uname -s 2>/dev/null | tr [:upper:] [:lower:])

# Flags to detect 32-bit or 64-bit OS platform =>64/x86_64
OS_SIZE = $(shell uname -m | sed -e "s/i.86/32/" -e "s/x86_64/64/")
OS_ARCH = $(shell uname -m | sed -e "s/i386/i686/")

# These flags will override any settings
ifeq ($(i386),1)
	OS_SIZE = 32
	OS_ARCH = i686
endif

ifeq ($(x86_64),1)
	OS_SIZE = 64
	OS_ARCH = x86_64
endif

# Flags to detect either a Linux system (linux) or Mac OSX (darwin)
DARWIN = $(strip $(findstring DARWIN, $(OSUPPER)))

# Location of the CUDA Toolkit binaries and libraries
CUDA_PATH       ?= /usr/local/cuda-7.0
CUDA_INC_PATH   ?= $(CUDA_PATH)/include
CUDA_BIN_PATH   ?= $(CUDA_PATH)/bin
ifneq ($(DARWIN),)
  CUDA_LIB_PATH  ?= $(CUDA_PATH)/lib
else
  ifeq ($(OS_SIZE),32)
    CUDA_LIB_PATH  ?= $(CUDA_PATH)/lib
  else
    CUDA_LIB_PATH  ?= $(CUDA_PATH)/lib64
  endif
endif

# Common binaries
NVCC            ?= $(CUDA_BIN_PATH)/nvcc
GCC             ?= g++

# Extra user flags
EXTRA_NVCCFLAGS ?=
EXTRA_LDFLAGS   ?=

# CUDA code generation flags
#GENCODE_SM10    := -gencode arch=compute_10,code=sm_10
GENCODE_SM20    := -gencode arch=compute_20,code=sm_20
GENCODE_SM30    := -gencode arch=compute_30,code=sm_30 -gencode arch=compute_35,code=sm_35
#GENCODE_FLAGS   := $(GENCODE_SM10) $(GENCODE_SM20) $(GENCODE_SM30)
GENCODE_FLAGS   := $(GENCODE_SM20) $(GENCODE_SM30)
#GENCODE_FLAGS   := $(GENCODE_SM20)

# OS-specific build flags
ifneq ($(DARWIN),) 
      LDFLAGS   := -Xlinker -rpath $(CUDA_LIB_PATH) -L$(CUDA_LIB_PATH) -lcudart
      CCFLAGS   := -arch $(OS_ARCH) 
else
  ifeq ($(OS_SIZE),32)
      LDFLAGS   := -L$(CUDA_LIB_PATH) -lcudart
      CCFLAGS   := -m32
  else
      LDFLAGS   := -L$(CUDA_LIB_PATH) -lcudart
      CCFLAGS   := -m64
  endif
endif

# OS-architecture specific flags
ifeq ($(OS_SIZE),32)
      NVCCFLAGS := -m32
else
      NVCCFLAGS := -m64
endif

# Debug build flags
ifeq ($(dbg),1)
      CCFLAGS   += -g
      NVCCFLAGS += -g -G
      TARGET := debug
else
      TARGET := release
endif


# Common includes and paths for CUDA
INCLUDES      := -I$(CUDA_INC_PATH) -I. -I.. -I../../common/inc -I../include/

# Target rules
all: 3 4 6 7 8 9 

build: convolutionSeparable

main.o: main.cpp
	$(GCC) $(CCFLAGS) $(INCLUDES) -o $@ -c $<

convolutionSeparable_gold.o: convolutionSeparable_gold.cpp
	$(GCC) $(CCFLAGS) $(INCLUDES) -o $@ -c $<

convolutionSeparable.o: convolutionSeparable.cu
	$(NVCC) $(NVCCFLAGS) $(EXTRA_NVCCFLAGS) $(GENCODE_FLAGS) $(INCLUDES) -o $@ -c $<

convolutionSeparable: main.o convolutionSeparable_gold.o convolutionSeparable.o 
	$(GCC) $(CCFLAGS) -o $@ $+ $(LDFLAGS) $(EXTRA_LDFLAGS)
	mkdir -p ../../bin/$(OSLOWER)/$(TARGET)
	cp $@ ../../bin/$(OSLOWER)/$(TARGET)

run: build
	./convolutionSeparable

#0:
#	$(NVCC) $(NVCCFLAGS) $(EXTRA_NVCCFLAGS) $(GENCODE_FLAGS) -o $@ $@.cu
#	./$@
3:
	$(NVCC) $(NVCCFLAGS) $(EXTRA_NVCCFLAGS) $(GENCODE_FLAGS) -o $@ $@.cu
	#./$@
	#nvprof  --events all --metrics all  --log-file $@_prof.txt ./$@
4:
	$(NVCC) $(NVCCFLAGS) $(EXTRA_NVCCFLAGS) $(GENCODE_FLAGS) -o $@ $@.cu
	#./$@
	#nvprof  --events all --metrics all  --log-file $@_prof.txt ./$@
6:
	$(NVCC) $(NVCCFLAGS) $(EXTRA_NVCCFLAGS) $(GENCODE_FLAGS) -o $@ $@.cu
	#./$@
	#nvprof  --events all --metrics all  --log-file $@_prof.txt ./$@
7:
	$(NVCC) $(NVCCFLAGS) $(EXTRA_NVCCFLAGS) $(GENCODE_FLAGS) -o $@ $@.cu
	#./$@
	#nvprof  --events all --metrics all  --log-file $@_prof.txt ./$@
8:
	$(NVCC) $(NVCCFLAGS) $(EXTRA_NVCCFLAGS) $(GENCODE_FLAGS) -o $@ $@.cu
	#./$@
	#nvprof  --events all --metrics all  --log-file $@_prof.txt ./$@
9:
	$(NVCC) $(NVCCFLAGS) $(EXTRA_NVCCFLAGS) $(GENCODE_FLAGS) -o $@ $@.cu
	#./$@
	#nvprof  --events all --metrics all  --log-file $@_prof.txt ./$@
nvprof:  3 4 6 7 8 9 
	mkdir -p nvprof_result
	nvprof  --events all --metrics all  --log-file nvprof_result/1_prof.txt ./1
	nvprof  --events all --metrics all  --log-file nvprof_result/3_prof.txt ./3
	nvprof  --events all --metrics all  --log-file nvprof_result/4_prof.txt ./4
	nvprof  --events all --metrics all  --log-file nvprof_result/5_prof.txt ./5
	nvprof  --events all --metrics all  --log-file nvprof_result/convolution_prof.txt ./convolution
	nvprof  --events all --metrics all  --log-file nvprof_result/9_prof.txt ./9
awk:
	
	awk -f dong_proc.awk 1_prof.txt >1_prof_awk.txt
	awk -f dong_proc.awk 3_prof.txt >3_prof_awk.txt
	awk -f dong_proc.awk 4_prof.txt >4_prof_awk.txt
	awk -f dong_proc.awk 5_prof.txt >5_prof_awk.txt
	awk -f dong_proc.awk convolution_prof.txt >convolution_prof_awk.txt
	awk -f dong_proc.awk 9_prof.txt >9_prof_awk.txt


	
cuobjdump: 1 3 4 5 convolution
	mkdir -p cuobjdump_result
#	cuobjdump -ptx -sass -elf 1 > cuobjdump_result/1_cuobjdump.txt
	cuobjdump -sass 1 > cuobjdump_result/1_cuobjdump.txt
	cuobjdump -ptx -sass -elf 3 > cuobjdump_result/3_cuobjdump.txt
	cuobjdump -ptx -sass -elf 4 > cuobjdump_result/4_cuobjdump.txt
	cuobjdump -ptx -sass -elf 5 > cuobjdump_result/5_cuobjdump.txt
	cuobjdump -ptx -sass -elf convolution > cuobjdump_result/convolution_cuobjdump.txt
clean:
	rm -f convolutionSeparable main.o convolutionSeparable_gold.o convolutionSeparable.o 0 1 2 3 4 5 convolution
