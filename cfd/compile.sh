nvcc cfd.cu -o cfd -arch=sm_35
nvcc cfd_rule.cu -o cfd_rule -arch=sm_35
nvcc 6_overhead.cu -o 6_overhead -arch=sm_35
