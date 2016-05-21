all:vd vd_tex vd_constant vd_shared
	
vd:
	nvcc -O0  -o vd vd.cu
	nvprof --events inst_executed,thread_inst_executed ./vd
vd_tex:
	nvcc -O0  -o vd_tex vd_tex.cu
	nvprof --events inst_executed,thread_inst_executed ./vd_tex
vd_shared:
	nvcc -O0  -o vd_shared vd_shared.cu
	nvprof --events inst_executed,thread_inst_executed ./vd_shared
vd_constant:
	nvcc -O0  -o vd_constant vd_constant.cu
	nvprof --events inst_executed,thread_inst_executed ./vd_constant
clean:
	rm -rf vd vd_tex vd_constant vd_shared

test:
	nvcc --generate-line-info --cubin vd.cu
	nvcc -o vd vd.cu
	nvdisasm --print-line-info vd.cubin

