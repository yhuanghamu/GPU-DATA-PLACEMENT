NVCC = nvcc
objects = 1 2 optimized surf_1D surface trans transpose
build: $(objects)
1 2 optimized surf_1D surface trans transpose::
	$(NVCC) -o $@ $@.cu
#	./$@
	nvprof  --events all --metrics all  --csv --log-file $@.csv ./$@
clean:
	rm $(objects)
