
#include <cassert>
#include <cfloat>
#include <cuda_runtime_api.h>
#include <cuda.h>
#include <iostream>
#include <stdio.h>
#include <list>
#include <map>
#include <math.h>
#include <stdlib.h>
#include <vector>
#include <set>
#include <algorithm>
#include <iterator>
#include <fstream>
#include "../include/common.h"
#define K 1
using namespace std;

#define mm_BLOCK_SIZE 16
//#define mm_SUPER_BLOCKS_PER_SM 4
//int mm_SUPER_BLOCKS_PER_SM = 4;

#define iSizeMultiple 4 //must be multipes of 15

#define WA (4 * mm_BLOCK_SIZE) // Matrix A width
#define HA (4 * mm_BLOCK_SIZE) // Matrix A height
//#define WB (mm_SUPER_BLOCKS_PER_SM * mm_BLOCK_SIZE) // Matrix B width
#define WB (60 * mm_BLOCK_SIZE) // Matrix B width
#define HB WA  // Matrix B height
#define WC WB  // Matrix C width 
#define HC HA  // Matrix C height

#define mm_GRID_X (WC*iSizeMultiple/mm_BLOCK_SIZE)
#define mm_GRID_Y (HC*iSizeMultiple/mm_BLOCK_SIZE)
#define mm_NBLOCKS (mm_GRID_X*mm_GRID_Y)

#define AS(i, j) As[i][j]
#define BS(i, j) Bs[i][j]

void randomInit(float* data, int size)
{
    for (int i = 0; i < size; ++i)
        data[i] = rand() / (float)RAND_MAX;
}

void
computeGold(float* C, const float* A, const float* B, unsigned int hA, unsigned int wA, unsigned int wB)
{
  for (unsigned int i = 0; i < hA; ++i)
    for (unsigned int j = 0; j < wB; ++j) {
      double sum = 0;
      for (unsigned int k = 0; k < wA; ++k) {
        double a = A[i * wA + k];
        double b = B[k * wB + j];
        sum += a * b;
      }
      C[i * wB + j] = (float)sum;
    }
}
__global__ void
mm_kernel( float* C, float* A, float* B, int wA, int wB, int *index_A,int *index_B)
{
  // Block index
  int bx = blockIdx.x;
  int by = blockIdx.y;

  // Thread index
  int tx = threadIdx.x;
  int ty = threadIdx.y;

  // Index of the first sub-matrix of A processed by the block
  int aBegin = wA * mm_BLOCK_SIZE * by;

  // Index of the last sub-matrix of A processed by the block
  int aEnd   = aBegin + wA - 1;

  // Step size used to iterate through the sub-matrices of A
  int aStep  = mm_BLOCK_SIZE;

  // Index of the first sub-matrix of B processed by the block
  int bBegin = mm_BLOCK_SIZE * bx;

  // Step size used to iterate through the sub-matrices of B
  int bStep  = mm_BLOCK_SIZE * wB;

  // Csub is used to store the element of the block sub-matrix
  // that is computed by the thread
  float Csub = 0;

  // Loop over all the sub-matrices of A and B
  // required to compute the block sub-matrix
  for (int a = aBegin, b = bBegin;
      a <= aEnd;
      a += aStep, b += bStep) {

    // Declaration of the shared memory array As used to
    // store the sub-matrix of A
    __shared__ float As[mm_BLOCK_SIZE][mm_BLOCK_SIZE];

    // Declaration of the shared memory array Bs used to
    // store the sub-matrix of B
    __shared__ float Bs[mm_BLOCK_SIZE][mm_BLOCK_SIZE];

    // Load the matrices from device memory
    // to shared memory; each thread loads
    // one element of each matrix
    AS(ty, tx) = A[a + wA * ty + tx];
    BS(ty, tx) = B[b + wB * ty + tx];
if(blockIdx.x==0&&blockIdx.y==0&&threadIdx.x<4&&threadIdx.y<4)
{//printf("thread %d: access %d\n",threadIdx.y*4+threadIdx.x, a + wA * ty + tx);
 atomicAdd(&index_A[(threadIdx.y*4+threadIdx.x)*wA*wA+a+wA*ty+tx],1);
 atomicAdd(&index_B[(threadIdx.y*4+threadIdx.x)*wA*wB+b+wB*ty+tx],1);
}  
    // Synchronize to make sure the matrices are loaded
    __syncthreads();

    // Multiply the two matrices together;
    // each thread computes one element
    // of the block sub-matrix
#pragma unroll
    for (int k = 0; k < mm_BLOCK_SIZE; ++k)
      Csub += AS(ty, k) * BS(k, tx);

    // Synchronize to make sure that the preceding
    // computation is done before loading two new
    // sub-matrices of A and B in the next iteration
    __syncthreads();
  }

  // Write the block sub-matrix to device memory;
  // each thread writes one element
  int c = wB * mm_BLOCK_SIZE * by + mm_BLOCK_SIZE * bx;

  C[c + wB * ty + tx] = Csub;
//if (threadIdx.x==0&&threadIdx.y==0) atomicAdd(d_flag,1);

}

int main(int argc, char **argv) {
//  cudaSetDevice(1);
  srand(2013);
  unsigned int uiWA, uiHA, uiWB, uiHB, uiWC, uiHC;

  uiWA = WA * iSizeMultiple;
  uiHA = HA * iSizeMultiple;
  uiWB = WB * iSizeMultiple;
  uiHB = HB * iSizeMultiple;
  uiWC = WC * iSizeMultiple;
  uiHC = HC * iSizeMultiple;

  // allocate host memory for matrices A and B
  unsigned int size_A = uiWA * uiHA;
  unsigned int mem_size_A = sizeof(float) * size_A;
  float* h_A = (float*)malloc(mem_size_A);
  unsigned int size_B = uiWB * uiHB;
  unsigned int mem_size_B = sizeof(float) * size_B;
  float* h_B = (float*)malloc(mem_size_B);

  // initialize host memory
  randomInit(h_A, size_A);
  randomInit(h_B, size_B);

  // allocate device memory
  float* d_A, *d_B, *d_C;
  unsigned int size_C = uiWC * uiHC;
  unsigned int mem_size_C = sizeof(float) * size_C;

  // allocate host memory for the result
  float* h_C      = (float*) malloc(mem_size_C);
  float* h_CUBLAS = (float*) malloc(mem_size_C);

  checkCudaErrors(cudaMalloc((void**) &d_A, mem_size_A));
  checkCudaErrors(cudaMalloc((void**) &d_B, mem_size_B));

  // copy host memory to device
  checkCudaErrors(cudaMemcpy(d_A, h_A, mem_size_A, cudaMemcpyHostToDevice) );
  checkCudaErrors(cudaMemcpy(d_B, h_B, mem_size_B, cudaMemcpyHostToDevice) );

  checkCudaErrors(cudaMalloc((void**) &d_C, mem_size_C));

  cudaEvent_t kernel_start, kernel_stop;
  cudaEventCreate(&kernel_start);
  cudaEventCreate(&kernel_stop);
  float kernel_time = 0.0f;

  cudaEventRecord(kernel_start, 0);
  // setup execution parameters
  dim3 mm_grid(mm_GRID_X, mm_GRID_Y);
  dim3 mm_block(mm_BLOCK_SIZE, mm_BLOCK_SIZE);
 // int mm_grid=mm_GRID_X*mm_GRID_Y;
  int *A_index=(int *)malloc(16*sizeof(int)*uiWA*uiHA);
  int *index_A,*index_B;
  int *B_index=(int *)malloc(16*sizeof(int)*uiWB*uiHB);
  cudaMalloc((void **)&index_A,16*sizeof(int)*uiWA*uiHA);
  cudaMalloc((void **)&index_B,16*sizeof(int)*uiWB*uiHB);
  cudaMemset(index_A,0,16*sizeof(int)*uiHA*uiWA);
  cudaMemset(index_B,0,16*sizeof(int)*uiHB*uiWB); 
 mm_kernel<<< mm_grid, mm_block>>>(d_C, d_A, d_B, uiWA, uiWB,index_A,index_B);


  cudaDeviceSynchronize();

  cudaEventRecord(kernel_stop, 0);
  cudaEventSynchronize(kernel_stop);

  // get elapsed time
  kernel_time = 0.0f;
  cudaEventElapsedTime(&kernel_time, kernel_start, kernel_stop);
  kernel_time *= 1.e-3; // Convert to seconds
  
  cout << "kernel exe time: " << kernel_time << endl;
  // copy result from device to host
  checkCudaErrors(cudaMemcpy(h_C, d_C, mem_size_C, cudaMemcpyDeviceToHost) );
  cudaMemcpy(A_index, index_A, 16*sizeof(int)*uiWA*uiWA, cudaMemcpyDeviceToHost);
  cudaMemcpy(B_index, index_B, 16*uiWA*uiWB*sizeof(int), cudaMemcpyDeviceToHost);
   FILE *f1=fopen("A_D2.txt","w");
 for(int ii=0;ii<16;ii++){
    // fprintf(f2,"\n");
     for(int jj=0;jj<uiWA*uiWA;jj++)
    {if(A_index[ii*uiWA*uiWA+jj]!=0)
     fprintf(f1,"%d,%d ;",jj,A_index[ii*uiWA*uiWA+jj]);
   }
fprintf(f1,"\n");}
 FILE *f2=fopen("B_D2.txt","w");
 for(int ii=0;ii<16;ii++){
    // fprintf(f2,"\n");
     for(int jj=0;jj<uiWA*uiWB;jj++)
    {if(B_index[ii*uiWA*uiWB+jj]!=0)
     fprintf(f2,"%d,%d ;",jj,B_index[ii*uiWA*uiWB+jj]);
   }
fprintf(f2,"\n");}
  // compute reference solution
  float* reference = (float*)malloc(mem_size_C);
  computeGold(reference, h_A, h_B, uiHA, uiWA, uiWB);

  // check result (matrixMul)
  bool resCUDA = sdkCompareL2fe(reference, h_C, size_C, 1.0e-6f);
  printf("CUDA matrixMul compares %s\n\n", (true == resCUDA) ? "passed" : "FAIL");

//   ofstream f1("mm_correct.txt");
//   for(int i=0; i<size_C; ++i)
//     f1 << reference[i] << endl;
//   f1.close();
// 
//   ofstream f2("mm_gpu.txt");
//   for(int i=0; i<size_C; ++i)
//     f2 << h_C[i] << endl;
//   f2.close();


  // clean up memory
  free(h_A);
  free(h_B);
  free(h_C);
  free(reference);
  checkCudaErrors(cudaFree(d_A));
  checkCudaErrors(cudaFree(d_B));
  checkCudaErrors(cudaFree(d_C));
    printf("Profiling results saved to \"A_D2.txt\" and \"B_D2.txt\"\n");
    printf("Please use analysis.py to analysis them\n");

  return 0;
}

