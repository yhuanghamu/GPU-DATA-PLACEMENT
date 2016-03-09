FLAGS ?= -arch=sm_30
all:
	nvcc md_index.cu -o $(FLAGS) 
	nvcc md.cu -o md $(FLAGS)
	nvcc 1.cu -o 1 $(FLAGS)
	nvcc 2.cu -o 2 $(FLAGS)
	nvcc 3.cu -o 3 $(FLAGS)
	nvcc 4.cu -o 4 $(FLAGS)
	nvcc 4_overhead.cu -o 4_overhead $(FLAGS)
	nvcc 5.cu -o 5 $(FLAGS)
	nvcc 6.cu -o 6 $(FLAGS)
	nvcc 6_1_overhead.cu -o 6_1_overhead $(FLAGS)
	nvcc 6_overhead.cu -o 6_overhead $(FLAGS)
	nvcc 7.cu -o 7 $(FLAGS)
