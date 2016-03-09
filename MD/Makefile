FLAGS ?= -arch=sm_35
all:
#nvcc md_index.cu -o $(FLAGS) 
#./md_index
	nvcc md.cu -o md $(FLAGS)
	./md
	nvcc 1.cu -o 1 $(FLAGS)
	./1
	nvcc 2.cu -o 2 $(FLAGS)
	./2
	nvcc 3.cu -o 3 $(FLAGS)
	./3
	nvcc 4.cu -o 4 $(FLAGS)
	./4
#nvcc 4_overhead.cu -o 4_overhead $(FLAGS)
	nvcc 5.cu -o 5 $(FLAGS)
	./5
	nvcc 6.cu -o 6 $(FLAGS)	
	./6
#nvcc 6_1_overhead.cu -o 6_1_overhead $(FLAGS)
	nvcc 6_overhead.cu -o 6_overhead $(FLAGS)
	./6_overhead
#nvcc 7.cu -o 7 $(FLAGS)
	./7
	
prof:md 1 2 3 4 5 6 6_overheaad 7
	nvprof  --events all --metrics all  --csv --log-file 1.csv ./0
	nvprof  --events all --metrics all  --csv --log-file 2.csv ./0
	nvprof  --events all --metrics all  --csv --log-file 3.csv ./0
	nvprof  --events all --metrics all  --csv --log-file 4.csv ./0
	nvprof  --events all --metrics all  --csv --log-file 5.csv ./0
	nvprof  --events all --metrics all  --csv --log-file 6.csv ./0
	nvprof  --events all --metrics all  --csv --log-file 6_overhead.csv ./6_overhead
	nvprof  --events all --metrics all  --csv --log-file 7.csv ./7

