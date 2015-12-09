cfd:
	nvcc cfd.cu -o cfd -arch=sm_35
	./cfd
cfd_cpu:
	nvcc cfd_cpu.cu -o cfd_cpu -arch=sm_35
	./cfd_cpu
7:
	nvcc 7.cu -o 7 -arch=sm_35
	@echo "************************Executing************************"
	./7
1:
	nvcc $@.cu -o $@ -arch=sm_35
	@echo "************************Executing************************"
	./$@
2:
	nvcc $@.cu -o $@ -arch=sm_35
	@echo "************************Executing************************"
	./$@
3:
	nvcc $@.cu -o $@ -arch=sm_35
	@echo "************************Executing************************"
	./$@
4:
	nvcc $@.cu -o $@ -arch=sm_35
	@echo "************************Executing************************"
	./$@
5:
	nvcc $@.cu -o $@ -arch=sm_35
	@echo "************************Executing************************"
	./$@
6:
	nvcc $@.cu -o $@ -arch=sm_35
	@echo "************************Executing************************"
	./$@
cfd_prof:
	nvcc $@.cu -o $@ -arch=sm_35
	@echo "************************Executing************************"
	./$@
cfd_rule:
	nvcc $@.cu -o $@ -arch=sm_35
	@echo "************************Executing************************"
	./$@
