spmv:
	nvcc spmv.cu -o spmv -arch=sm_35
	./spmv
spmv_index:
	nvcc spmv_index.cu -o spmv_index -arch=sm_35
	./spmv_index
prof_spmv:
	nvprof  --events all --metrics all  --log-file spmv_prof.txt ./spmv 
prof_spmv_index:
	nvprof  --events all --metrics all  --log-file spmv_index_prof.txt ./spmv_index
clean:
	rm spmv spmv_index

#Hints
#nvprof --print-gpu-trace ./spmv
#nvprof --print-api-trace ./spmv_index