vd:
	nvcc -G -g -o vd vd.cu
	nvprof --events inst_executed ./vd
clean:
	rm vd

test:
	nvcc --generate-line-info --cubin vd.cu
	nvcc -o vd vd.cu
	nvdisasm --print-line-info vd.cubin

