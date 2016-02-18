

int run();
void fill(float *A, const int n, const float maxi);

void initRandomMatrix(int *cols, int *rowDelimiters, const int n, const int dim);

void convertToPadded(float *A, int *cols, int dim, int *rowDelimiters, 
                     float **newA_ptr, int **newcols_ptr, int *newIndices, 
                     int *newSize);
void spmvCpu(const float *val, const int *cols, const int *rowDelimiters, 
	     const float *vec, int dim, float *out);

void spmv_verifyResults(const float *cpuResults, const float *gpuResults,
                   const int size);
