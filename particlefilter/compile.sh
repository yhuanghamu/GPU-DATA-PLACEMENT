/usr/local/cuda/bin/nvcc -I/usr/local/cuda/include -L/usr/local/cuda/lib64 -lcuda -g -lm -O3 -use_fast_math -arch sm_35 test.cu -o test
/usr/local/cuda/bin/nvcc -I/usr/local/cuda/include -L/usr/local/cuda/lib64 -lcuda -g -lm -O3 -use_fast_math -arch sm_35 prof.cu -o prof
/usr/local/cuda/bin/nvcc -I/usr/local/cuda/include -L/usr/local/cuda/lib64 -lcuda -g -lm -O3 -use_fast_math -arch sm_35 index.cu -o index
/usr/local/cuda/bin/nvcc -I/usr/local/cuda/include -L/usr/local/cuda/lib64 -lcuda -g -lm -O3 -use_fast_math -arch sm_35 naive.cu -o naive
/usr/local/cuda/bin/nvcc -I/usr/local/cuda/include -L/usr/local/cuda/lib64 -lcuda -g -lm -O3 -use_fast_math -arch sm_35 best.cu -o best
/usr/local/cuda/bin/nvcc -I/usr/local/cuda/include -L/usr/local/cuda/lib64 -lcuda -g -lm -O3 -use_fast_math -arch sm_35 best1.cu -o best1
/usr/local/cuda/bin/nvcc -I/usr/local/cuda/include -L/usr/local/cuda/lib64 -lcuda -g -lm -O3 -use_fast_math -arch sm_35 best2.cu -o best2
/usr/local/cuda/bin/nvcc -I/usr/local/cuda/include -L/usr/local/cuda/lib64 -lcuda -g -lm -O3 -use_fast_math -arch sm_35 best3.cu -o best3
