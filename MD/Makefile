all:md_35 6_35 index_20 md_index_20 md_20 1_20

md_35:md_35
	nvcc md.cu -o md_35 -arch=sm_35
6_35:6_35
	nvcc 6.cu -o 6_35 -arch=sm_35
index_20:index_20
	nvcc md_index.cu -o index_20 -arch=sm_20

md_index_20:md_index_20
	nvcc md_index.cu -o md_index_20 -arch=sm_20
md_20:
	nvcc md.cu -o md_20 -arch=sm_20
1_20:
	nvcc 1.cu -o 1_20 -arch=sm_20
