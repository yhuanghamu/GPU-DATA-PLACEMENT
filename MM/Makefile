FLAGS ?= -arch=sm_35
all:
#nvcc md_index.cu -o $(FLAGS)
#./md_index
	nvcc 0.cu -o 0 $(FLAGS)
	./0
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
	nvcc 7.cu -o 7 $(FLAGS)
	./7
	nvcc 7_overhead.cu -o 7_overhead $(FLAGS)
	./7_overhead
	nvcc 8.cu -o 8 $(FLAGS)
	./8
	nvcc 9.cu -o 9 $(FLAGS)
	./9


prof: 0 1 2 3 4 5 6 7 7_overhead 8 9
	nvprof  --events all --metrics all  --csv --log-file 0.csv ./0
	nvprof  --events all --metrics all  --csv --log-file 1.csv ./1
	nvprof  --events all --metrics all  --csv --log-file 2.csv ./2
	nvprof  --events all --metrics all  --csv --log-file 3.csv ./3
	nvprof  --events all --metrics all  --csv --log-file 4.csv ./4
	nvprof  --events all --metrics all  --csv --log-file 5.csv ./5
	nvprof  --events all --metrics all  --csv --log-file 6.csv ./6
	nvprof  --events all --metrics all  --csv --log-file 7.csv ./7
	nvprof  --events all --metrics all  --csv --log-file 7_overhead.csv ./7_overhead
	nvprof  --events all --metrics all  --csv --log-file 8.csv ./8
	nvprof  --events all --metrics all  --csv --log-file 9.csv ./9
clean:
	-rm 0 1 2 3 4 5 6 7 7_overhead 8 9

                                                                   
