#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#define N 1024

__constant__ double c_a[N];
__constant__ double c_b[N];

void setConstant(double *h_a, double *h_b)
{
    cudaMemcpyToSymbol(c_a, h_a, N * sizeof(double));
	cudaMemcpyToSymbol(c_b, h_b, N * sizeof(double));
}
// CUDA kernel. Each thread takes care of one element of c
__global__ void vecAdd(double *c)
{
    // Get our global thread ID
    int id = blockIdx.x*blockDim.x+threadIdx.x;
	
    // Make sure we do not go out of bounds
    if (id < N)
        c[id] = c_a[id] + c_b[id];
}

int main( int argc, char* argv[] )
{
    // Size of vectors
    //int n = 10000;
	
    // Host input vectors
    double *h_a;
    double *h_b;
    //Host output vector
    double *h_c;
	
    // Device input vectors
    double *d_a;
    double *d_b;
    //Device output vector
    double *d_c;
	
    // Size, in bytes, of each vector
    size_t bytes = N*sizeof(double);
	
    // Allocate memory for each vector on host
    h_a = (double*)malloc(bytes);
    h_b = (double*)malloc(bytes);
    h_c = (double*)malloc(bytes);
	// Allocate memory for each vector on GPU
    cudaMalloc(&d_a, bytes);
    cudaMalloc(&d_b, bytes);
    cudaMalloc(&d_c, bytes);
	
    int i;
    // Initialize vectors on host
    for( i = 0; i < N; i++ ) {
        h_a[i] = sin(i)*sin(i);
        h_b[i] = cos(i)*cos(i);
    }
	
    // Copy host vectors to device
    checkCudaErrors(cudaMemcpy( d_a, h_a, bytes, cudaMemcpyHostToDevice));
    checkCudaErrors(cudaMemcpy( d_b, h_b, bytes, cudaMemcpyHostToDevice));
	
    int blockSize, gridSize;
	
    // Number of threads in each thread block
    blockSize = 1024;
	
    // Number of thread blocks in grid
    gridSize = (int)ceil((float)N/blockSize);
	
    // Execute the kernel
    vecAdd<<<gridSize, blockSize>>>(d_c);
	
    // Copy array back to host
    cudaMemcpy( h_c, d_c, bytes, cudaMemcpyDeviceToHost );
	
    // Sum up vector c and print result divided by n, this should equal 1 within error
    double sum = 0;
    for(i=0; i<N; i++)
        sum += h_c[i];
    printf("final result: %f\n", sum/N);
	
    // Release device memory
    cudaFree(d_a);
    cudaFree(d_b);
    cudaFree(d_c);
	
    // Release host memory
    free(h_a);
    free(h_b);
    free(h_c);
	return 0;
}
