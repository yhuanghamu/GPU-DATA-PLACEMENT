
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

using namespace std;
#define mm_STREAM 0 
#define pf_STREAM 1

#define mm_BLOCK_SIZE 16
//#define mm_SUPER_BLOCKS_PER_SM 4
//int mm_SUPER_BLOCKS_PER_SM = 4;

#define iSizeMultiple 4 //must be multipes of 15

#define WA (4 * mm_BLOCK_SIZE) // Matrix A width
#define HA (4 * mm_BLOCK_SIZE) // Matrix A height
//#define WB (mm_SUPER_BLOCKS_PER_SM * mm_BLOCK_SIZE) // Matrix B width
#define WB (6 * 10 * mm_BLOCK_SIZE) // Matrix B width
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
#define pf_NBLOCKS 254*60 //16*6*2
#define pf_BLOCK_SIZE 256
#define STR_SIZE 256
#define HALO 1 // halo width along one direction when advancing to the next iteration

#define BENCH_PRINT
#define IN_RANGE(x, min, max)   ((x)>=(min) && (x)<=(max))
#define CLAMP_RANGE(x, min, max) x = (x<(min)) ? min : ((x>(max)) ? max : x )
#define MIN(a, b) ((a)<=(b) ? (a) : (b))

int pf_rows, pf_cols;
int* pf_data;
int** wall;
int* pf_result;
#define M_SEED 9
int pyramid_height;

//#define BENCH_PRINT

  void
init(int argc, char** argv)
{

  pf_data = new int[pf_rows*pf_cols];
  wall = new int*[pf_rows];
  for(int n=0; n<pf_rows; n++)
    wall[n]=pf_data+pf_cols*n;
  pf_result = new int[pf_cols];

  int seed = M_SEED;
  srand(seed);

  for (int i = 0; i < pf_rows; i++)
  {
    for (int j = 0; j < pf_cols; j++)
    {
      wall[i][j] = rand() % 10;
    }
  }
}

  void 
fatal(char *s)
{
  fprintf(stderr, "error: %s\n", s);

}


void check_kernel(
    int iteration, 
    int *gpuWall,
    int *gpuSrc,
    int *gpuResults,
    int cols, 
    int rows,
    int startStep,
    int border,
    int dimGrid, 
    int dimBlock)
{



  for(int bx=0;bx<dimGrid;bx++){
    int prev[pf_BLOCK_SIZE];
    int result[pf_BLOCK_SIZE];
    for (int tx=0;tx<dimBlock;tx++)
    {     
      int small_block_cols = pf_BLOCK_SIZE-iteration*HALO*2;

      // calculate the boundary for the block according to 
      // the boundary of its small block
      int blkX = small_block_cols*bx-border;
      int blkXmax = blkX+pf_BLOCK_SIZE-1;

      // calculate the global thread coordination
      int xidx = blkX+tx;

      // effective range within this block that falls within 
      // the valid range of the input data
      // used to rule out computation outside the boundary.
      int validXmin = (blkX < 0) ? -blkX : 0;
      int validXmax = (blkXmax > cols-1) ? pf_BLOCK_SIZE-1-(blkXmax-cols+1) : pf_BLOCK_SIZE-1;

      int W = tx-1;
      int E = tx+1;

      W = (W < validXmin) ? validXmin : W;
      E = (E > validXmax) ? validXmax : E;

      bool isValid = IN_RANGE(tx, validXmin, validXmax);

      if(IN_RANGE(xidx, 0, cols-1)){
        prev[tx] = gpuSrc[xidx];
      }
    }
    //__syncthreads(); // [Ronny] Added sync to avoid race on prev Aug. 14 2012

    for (int tx=0;tx<dimBlock;tx++)
    {    
      int small_block_cols = pf_BLOCK_SIZE-iteration*HALO*2;

      // calculate the boundary for the block according to 
      // the boundary of its small block
      int blkX = small_block_cols*bx-border;
      int blkXmax = blkX+pf_BLOCK_SIZE-1;

      // calculate the global thread coordination
      int xidx = blkX+tx;

      // effective range within this block that falls within 
      // the valid range of the input data
      // used to rule out computation outside the boundary.
      int validXmin = (blkX < 0) ? -blkX : 0;
      int validXmax = (blkXmax > cols-1) ? pf_BLOCK_SIZE-1-(blkXmax-cols+1) : pf_BLOCK_SIZE-1;

      int W = tx-1;
      int E = tx+1;

      W = (W < validXmin) ? validXmin : W;
      E = (E > validXmax) ? validXmax : E;

      bool isValid = IN_RANGE(tx, validXmin, validXmax);
      bool computed;
      for (int i=0; i<iteration ; i++){ 
        computed = false;
        if( IN_RANGE(tx, i+1, pf_BLOCK_SIZE-i-2) &&  \
            isValid){
          computed = true;
          int left = prev[W];
          int up = prev[tx];
          int right = prev[E];
          int shortest = MIN(left, up);
          shortest = MIN(shortest, right);
          int index = cols*(startStep+i)+xidx;
          result[tx] = shortest + gpuWall[index];

        }
        //__syncthreads();
        if(i==iteration-1)
          break;
        if(computed)	 //Assign the computation range
          prev[tx]= result[tx];
        // __syncthreads(); // [Ronny] Added sync to avoid race on prev Aug. 14 2012
      }

      // update the global memory
      // after the last iteration, only threads coordinated within the 
      // small block perform the calculation and switch on ``computed''
      if (computed){
        //gpuResults[xidx]=result[tx];	
        if(gpuResults[xidx]!=result[tx]){printf("failed!%d %d %d %d\n",tx,bx,result[tx],gpuResults[xidx]);return;}	
      }
    }
  }
  printf("GOOD Kernel passed!\n");
  return;
}
__global__ void
mm_kernel( float* C, float* A, float* B, int wA, int wB)
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
}

__global__ void pf_kernel(
    int iteration, 
    int *gpuWall,
    int *gpuSrc,
    int *gpuResults,
    int cols, 
    int rows,
    int startStep,
    int border)
{

  __shared__ int prev[pf_BLOCK_SIZE];
  __shared__ int result[pf_BLOCK_SIZE];

  int bx = blockIdx.x;
  int tx=threadIdx.x;


  int small_block_cols = pf_BLOCK_SIZE-iteration*HALO*2;

  // calculate the boundary for the block according to 
  // the boundary of its small block
  int blkX = small_block_cols*bx-border;
  int blkXmax = blkX+pf_BLOCK_SIZE-1;

  // calculate the global thread coordination
  int xidx = blkX+tx;

  // effective range within this block that falls within 
  // the valid range of the input data
  // used to rule out computation outside the boundary.
  int validXmin = (blkX < 0) ? -blkX : 0;
  int validXmax = (blkXmax > cols-1) ? pf_BLOCK_SIZE-1-(blkXmax-cols+1) : pf_BLOCK_SIZE-1;

  int W = tx-1;
  int E = tx+1;

  W = (W < validXmin) ? validXmin : W;
  E = (E > validXmax) ? validXmax : E;

  bool isValid = IN_RANGE(tx, validXmin, validXmax);

  if(IN_RANGE(xidx, 0, cols-1)){
    prev[tx] = gpuSrc[xidx];
  }
  __syncthreads(); // [Ronny] Added sync to avoid race on prev Aug. 14 2012
  bool computed;
  for (int i=0; i<iteration ; i++){ 
    computed = false;
    if( IN_RANGE(tx, i+1, pf_BLOCK_SIZE-i-2) &&  \
        isValid){
      computed = true;
      int left = prev[W];
      int up = prev[tx];
      int right = prev[E];
      int shortest = MIN(left, up);
      shortest = MIN(shortest, right);
      int index = cols*(startStep+i)+xidx;
      result[tx] = shortest + gpuWall[index];

    }
    __syncthreads();
    if(i==iteration-1)
      break;
    if(computed)	 //Assign the computation range
      prev[tx]= result[tx];
    __syncthreads(); // [Ronny] Added sync to avoid race on prev Aug. 14 2012
  }

  // update the global memory
  // after the last iteration, only threads coordinated within the 
  // small block perform the calculation and switch on ``computed''
  if (computed){
    gpuResults[xidx]=result[tx];		
  }
}

int main(int argc, char **argv) {
  cudaSetDevice(1);
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

  pyramid_height=1;
  pf_cols=pf_NBLOCKS*pf_BLOCK_SIZE;
  pf_rows=2;//iteration=rows-1
  init(argc, argv);
  /* --------------- pyramid parameters --------------- */
  int borderCols = (pyramid_height)*HALO;
  int smallBlockCol = pf_BLOCK_SIZE-(pyramid_height)*HALO*2;
  printf("pf_cols=%d %d smallBlockcol\n",pf_cols,pf_rows,smallBlockCol);
  int blockCols = pf_cols/smallBlockCol+((pf_cols%smallBlockCol==0)?0:1);

  printf("pyramidHeight: %d\ngridSize: [%d]\nborder:[%d]\nblockSize: %d\nblockGrid:[%d]\ntargetBlock:[%d]\n",\
      pyramid_height, pf_cols, borderCols, pf_BLOCK_SIZE, blockCols, smallBlockCol);

  int *gpuWall, *gpuResult[2];
  int pf_size = pf_rows*pf_cols;

  cudaMalloc((void**)&gpuResult[0], sizeof(int)*pf_cols);
  cudaMalloc((void**)&gpuResult[1], sizeof(int)*pf_cols);
  cudaMemcpy(gpuResult[0], pf_data, sizeof(int)*pf_cols, cudaMemcpyHostToDevice);
  cudaMalloc((void**)&gpuWall, sizeof(int)*(pf_size-pf_cols));
  cudaMemcpy(gpuWall, pf_data+pf_cols, sizeof(int)*(pf_size-pf_cols), cudaMemcpyHostToDevice);

  int t = 0;

  cudaEvent_t kernel_start, kernel_stop;
  cudaEventCreate(&kernel_start);
  cudaEventCreate(&kernel_stop);
  float kernel_time = 0.0f;

  cudaEventRecord(kernel_start, 0);

  cudaStream_t stream[2];
  cudaStreamCreate(&stream[0]);
  cudaStreamCreate(&stream[1]);

  int iters[2] = {1, 1};
  int finished[2] = {0, 0};
  // setup execution parameters
  dim3 mm_grid(mm_GRID_X, mm_GRID_Y);
  dim3 mm_block(mm_BLOCK_SIZE, mm_BLOCK_SIZE);

  mm_kernel<<< mm_grid, mm_block, 0, stream[mm_STREAM]>>>(d_C, d_A, d_B, uiWA, uiWB);

  int pf_block=(pf_BLOCK_SIZE);
  int pf_grid=(blockCols);  

  pf_kernel<<<pf_grid, pf_block, 0, stream[pf_STREAM]>>>(
      MIN(pyramid_height, pf_rows-t-1), 
      gpuWall, gpuResult[0], gpuResult[1],
      pf_cols,pf_rows, t, borderCols);


cudaStreamSynchronize(stream[mm_STREAM]);
cudaStreamSynchronize(stream[pf_STREAM]);

  for (int i = 0; i < 2; ++i)
    cudaStreamDestroy(stream[i]);

  cudaEventRecord(kernel_stop, 0);
  cudaEventSynchronize(kernel_stop);

  // get elapsed time
  kernel_time = 0.0f;
  cudaEventElapsedTime(&kernel_time, kernel_start, kernel_stop);
  kernel_time *= 1.e-3; // Convert to seconds

  cout << "kernel exe time: " << kernel_time << endl;
  // copy result from device to host
  checkCudaErrors(cudaMemcpy(h_C, d_C, mem_size_C, cudaMemcpyDeviceToHost) );

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


  cudaMemcpy(pf_result, gpuResult[1], sizeof(int)*pf_cols, cudaMemcpyDeviceToHost);

  check_kernel(MIN(pyramid_height, pf_rows-t-1), pf_data+pf_cols, pf_data, pf_result
      ,pf_cols,pf_rows, t, borderCols,pf_grid, pf_BLOCK_SIZE);

  cudaFree(gpuWall);
  cudaFree(gpuResult[0]);
  cudaFree(gpuResult[1]);

  delete [] pf_data;
  delete [] wall;
  delete [] pf_result;

  return 0;
}

