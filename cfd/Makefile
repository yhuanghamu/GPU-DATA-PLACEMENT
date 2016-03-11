all:

	nvcc cfd.cu -o cfd -arch=sm_35
	./cfd

	nvcc cfd_cpu.cu -o cfd_cpu -arch=sm_35
	./cfd_cpu

	nvcc 7.cu -o 7 -arch=sm_35
	@echo "************************Executing************************"
	./7

	nvcc 1.cu -o 1 -arch=sm_35
	@echo "************************Executing************************"
	./1
	
	nvcc 2.cu -o 2 -arch=sm_35
	@echo "************************Executing************************"
	./2

	nvcc 3.cu -o 3 -arch=sm_35
	@echo "************************Executing************************"
	./3

	nvcc 4.cu -o 4 -arch=sm_35
	@echo "************************Executing************************"
	./4

	nvcc 6.cu -o 6 -arch=sm_35
	@echo "************************Executing************************"
	./6
	nvcc 6_overhead.cu -o 6_overhead -arch=sm_35
	@echo "************************Executing************************"
	./6_overhead


	nvcc cfd_prof.cu -o cfd_prof -arch=sm_35
	@echo "************************Executing************************"
	./cfd_prof

	nvcc cfd_rule.cu -o cfd_rule -arch=sm_35
	@echo "************************Executing************************"
	./cfd_rule

prof : cfd cfd_cpu 7 1 2 3 4 6 6_overhead cfd_prof cfd_rule
	nvprof  --events all --metrics all  --csv --log-file cfd.csv ./cfd
	nvprof  --events all --metrics all  --csv --log-file cfd_cpu.csv ./cfd_cpu	
	nvprof  --events all --metrics all  --csv --log-file 7.csv ./7
	nvprof  --events all --metrics all  --csv --log-file 1.csv ./1
	nvprof  --events all --metrics all  --csv --log-file 2.csv ./2
	nvprof  --events all --metrics all  --csv --log-file 3.csv ./3
	nvprof  --events all --metrics all  --csv --log-file 4.csv ./4
	nvprof  --events all --metrics all  --csv --log-file 6.csv ./6
	nvprof  --events all --metrics all  --csv --log-file 6_overhead.csv ./6_overhead
	nvprof  --events all --metrics all  --csv --log-file cfd_prof ./cfd_prof
	nvprof  --events all --metrics all  --csv --log-file cfd_rule.csv ./cfd_rule


clean:
	 -rm cfd cfd_cpu 7 1 2 3 4 5 6 cfd_prof cfd_rule
