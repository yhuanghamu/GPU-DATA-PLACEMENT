#define N 1024
__global__ void VectorAdd(float* A, float* B, float* C)
{
	int i = threadIdx.x;
	C[i] = A[i] + B[i];
}

__global__ void MatAdd(float A[N][N],float* B[N][N],float*C[N][N])
{
	int i = blockIdx.x * blcokDim.x + threadIdx.x;
	int j = blockIdx.y * blockDim.y + threadIdx.y;
	if (i<N && j<N)
		C[i][j] = A[i][j] + B[i][j];
}

int main()
{
	VectorAdd<<<1,N,>>>(A,B,C);

	dim3 numBlocks( N/threadsPerBlock.x, N/threadsPerBlock.y);
	dim3 threadsPerBlock(16,16);

	MatAdd<<< numBlocks, threadsPerBlock >>>(A,B,C);
	__syncthreads();
	return 0;
}