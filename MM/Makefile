all: 0 1 2 3 4 5 6 7 8 9
test:
	nvcc -arch=sm_20  -o $@ $@.cu
	@echo "*********************Executing*********************"
	./$@
mm:
	nvcc -arch=sm_20  -o $@ $@.cu
	@echo "*********************Executing*********************"
	./$@
mm_cpu:
	nvcc -arch=sm_20  -o $@ $@.cu
	@echo "*********************Executing*********************"
	./$@

mm_cpu_1:
	nvcc -arch=sm_20  -o $@ $@.cu
	@echo "*********************Executing*********************"
	./$@
	
mm_index:
	nvcc -arch=sm_20  -o $@ $@.cu
	@echo "*********************Executing*********************"
	./$@
mm_prof:
	nvcc -arch=sm_20  -o $@ $@.cu
	@echo "*********************Executing*********************"
	./$@
mm_rule:
	nvcc -arch=sm_20  -o $@ $@.cu
	@echo "*********************Executing*********************"
	./$@
read_mm:
	nvcc -arch=sm_20  -o $@ $@.cu
	@echo "*********************Executing*********************"
	./$@
surf_1D:
	nvcc -arch=sm_20  -o $@ $@.cu
	@echo "*********************Executing*********************"
	./$@
surface:
	nvcc -arch=sm_20  -o $@ $@.cu
	@echo "*********************Executing*********************"
	./$@

0:
	nvcc -arch=sm_20  -o $@ $@.cu
	@echo "*********************Executing*********************"
	./$@
1:
	nvcc -arch=sm_20  -o $@ $@.cu
	@echo "*********************Executing*********************"
	./$@
2:
	nvcc -arch=sm_20  -o $@ $@.cu
	@echo "*********************Executing*********************"
	./$@
3: clean
	nvcc -arch=sm_20  -o $@ $@.cu
	@echo "*********************Executing*********************"
	./$@
4: clean
	nvcc -arch=sm_20  -o $@ $@.cu
	@echo "*********************Executing*********************"
	./$@
5: clean
	nvcc -arch=sm_20  -o $@ $@.cu
	@echo "*********************Executing*********************"
	./$@
6: clean
	nvcc -arch=sm_20  -o $@ $@.cu
	@echo "*********************Executing*********************"
	./$@
7: clean
	nvcc -arch=sm_20  -o $@ $@.cu
	@echo "*********************Executing*********************"
	./$@
	
7_overhead: 
	nvcc -arch=sm_20  -o $@ $@.cu
	@echo "*********************Executing*********************"
	./$@

8: clean
	nvcc -arch=sm_20  -o $@ $@.cu
	@echo "*********************Executing*********************"
	./$@

9: clean
	nvcc -arch=sm_20  -o $@ $@.cu
	@echo "*********************Executing*********************"
	./$@
clean:
	-rm 0 1 2 3 4 5 6 7 8 9 mm
