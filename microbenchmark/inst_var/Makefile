all:vd vd_tex vd_constant vd_shared
	
vd:vd.cu
	nvcc -O0 -DN=1024 -o vd vd.cu
	nvprof --events inst_executed,thread_inst_executed ./vd
	nvcc -O0 -DN=2048 -o vd vd.cu
	nvprof --events inst_executed,thread_inst_executed ./vd
	nvcc -O0 -DN=4096 -o vd vd.cu
	nvprof --events inst_executed,thread_inst_executed ./vd
	nvcc -O0 -DN=8192 -o vd vd.cu
	nvprof --events inst_executed,thread_inst_executed ./vd
	nvcc -O0 -DN=16384 -o vd vd.cu
	nvprof --events inst_executed,thread_inst_executed ./vd
	nvcc -O0 -DN=32768 -o vd vd.cu
	nvprof --events inst_executed,thread_inst_executed ./vd
	nvcc -O0 -DN=65536 -o vd vd.cu
	nvprof --events inst_executed,thread_inst_executed ./vd
	nvcc -O0 -DN=131072 -o vd vd.cu
	nvprof --events inst_executed,thread_inst_executed ./vd
	nvcc -O0 -DN=262144 -o vd vd.cu
	nvprof --events inst_executed,thread_inst_executed ./vd
	nvcc -O0 -DN=524288 -o vd vd.cu
	nvprof --events inst_executed,thread_inst_executed ./vd
vd_tex:vd_tex.cu
	nvcc -o vd_tex vd_tex.cu
	nvprof --events inst_executed,thread_inst_executed ./vd_tex
#	nvcc -DN=1024 -o vd_tex vd_tex.cu
#	nvprof --events inst_executed,thread_inst_executed ./vd_tex
#	nvcc -O0 -DN=2048 -o vd_tex vd_tex.cu
	#nvprof --events inst_executed,thread_inst_executed ./vd_tex
#	nvcc -O0 -DN=4096 -o vd_tex vd_tex.cu
#	nvprof --events inst_executed,thread_inst_executed ./vd_tex
#	nvcc -O0 -DN=8192 -o vd_tex vd_tex.cu
#	nvprof --events inst_executed,thread_inst_executed ./vd_tex
#	nvcc -O0 -DN=16384 -o vd_tex vd_tex.cu
#	nvprof --events inst_executed,thread_inst_executed ./vd_tex
#	nvcc -O0 -DN=32768 -o vd_tex vd_tex.cu
#	nvprof --events inst_executed,thread_inst_executed ./vd_tex
#	nvcc -O0 -DN=65536 -o vd_tex vd_tex.cu
#	nvprof --events inst_executed,thread_inst_executed ./vd_tex
#	nvcc -O0 -DN=131072 -o vd_tex vd_tex.cu
#	nvprof --events inst_executed,thread_inst_executed ./vd_tex
#	nvcc -O0 -DN=262144 -o vd_tex vd_tex.cu
#	nvprof --events inst_executed,thread_inst_executed ./vd_tex
#	nvcc -O0 -DN=524288 -o vd_tex vd_tex.cu
#	nvprof --events inst_executed,thread_inst_executed ./vd_tex

vd_constant:
#	nvcc -O0  -o vd_constant vd_constant.cu
#	nvprof --events inst_executed,thread_inst_executed ./vd_constant
	nvcc -DN=1024 -o vd_constant vd_constant.cu
	nvprof --events inst_executed,thread_inst_executed ./vd_constant
	nvcc -DN=2048 -o vd_constant vd_constant.cu
	nvprof --events inst_executed,thread_inst_executed ./vd_constant
	nvcc -DN=4096 -o vd_constant vd_constant.cu
	nvprof --events inst_executed,thread_inst_executed ./vd_constant
	nvcc -DN=8192 -o vd_constant vd_constant.cu
	nvprof --events inst_executed,thread_inst_executed ./vd_constant
vd_shared:
#	nvcc -O0  -o vd_shared vd_shared.cu
#	nvprof --events inst_executed,thread_inst_executed ./vd_shared
	nvcc -DN=1024 -o vd_shared vd_shared.cu
	nvprof --events inst_executed,thread_inst_executed ./vd_shared
	nvcc -DN=2048 -o vd_shared vd_shared.cu
	nvprof --events inst_executed,thread_inst_executed ./vd_shared
	nvcc -DN=4096 -o vd_shared vd_shared.cu
	nvprof --events inst_executed,thread_inst_executed ./vd_shared
	nvcc -DN=8192 -o vd_shared vd_shared.cu
	nvprof --events inst_executed,thread_inst_executed ./vd_shared
	nvcc -DN=16384 -o vd_shared vd_shared.cu
	nvprof --events inst_executed,thread_inst_executed ./vd_shared
	nvcc -DN=32768 -o vd_shared vd_shared.cu
	nvprof --events inst_executed,thread_inst_executed ./vd_shared
	nvcc -DN=65536 -o vd_shared vd_shared.cu
	nvprof --events inst_executed,thread_inst_executed ./vd_shared
	nvcc -DN=131072 -o vd_shared vd_shared.cu
	nvprof --events inst_executed,thread_inst_executed ./vd_shared
	nvcc -DN=262144 -o vd_shared vd_shared.cu
	nvprof --events inst_executed,thread_inst_executed ./vd_shared
	nvcc -DN=524288 -o vd_shared vd_shared.cu
	nvprof --events inst_executed,thread_inst_executed ./vd_shared
clean:
	rm -rf vd vd_tex vd_constant vd_shared
vd_inst:
	nvprof --events inst_executed,thread_inst_executed ./vd
test:
	nvcc --generate-line-info --cubin vd.cu
	nvcc -o vd vd.cu
	nvdisasm --print-line-info vd.cubin

