#include <omp.h>
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
#include <vector>
#include "../include/common.h"
#define K 1

using namespace std;


#define spmv_NBLOCKS 12*8*21 //22
#define spmv_BLOCK_SIZE 256
#define WARP_SIZE 32

static const double MAX_RELATIVE_ERROR = .02;

static const int PAD_FACTOR = 16;
int line[100000][6];
int yy =0;
void spmv_CPU(const float* val,
                       const int    * cols,
                       const int    * rowDelimiters,
                       const float  * vec,
                       const int dim, float * out)
{
float partialSums[spmv_BLOCK_SIZE];
  // Thread ID in block
//#pragma omp for
int *sum=(int *)malloc(sizeof(int)*256);
  for(int t = 0; t<256;t++){
  // Thread ID within warp
  int id = t & (WARP_SIZE-1);
  int warpsPerBlock = 256 / WARP_SIZE;
  // One row per warp
  int myRow = (0 * warpsPerBlock) + (t / WARP_SIZE);
  
   //float partialSums[spmv_BLOCK_SIZE];

  if (myRow < dim)
  {
    int warpStart = rowDelimiters[myRow];
    int warpEnd = rowDelimiters[myRow+1];
  //   fprintf(f,"0 0 0 0 %d %d\n",t,myRow);
  // fprintf(f,"0 0 1 0 %d %d\n",t,myRow+1); 
/*
line[yy][0]= 0;line[yy][1]=0;line[yy][2]=0;line[yy][3]=0;line[yy][4]=t;line[yy][5]=myRow;
yy++;
line[yy][0]= 0;line[yy][1]=0;line[yy][2]=1;line[yy][3]=0;line[yy][4]=t;line[yy][5]=myRow+1;
yy++;*/
    float mySum = 0;
    for (int j = warpStart + id; j < warpEnd; j += WARP_SIZE)
    {
      int col = cols[j];
      mySum += val[j] * vec[col];
//  fprintf(f,"1 0 0 %d %d %d\n",(j-warpStart)/WARP_SIZE,t,j);
  // fprintf(f,"2 0 0 %d %d %d\n",(j-warpStart)/WARP_SIZE,t,col);
  // fprintf(f,"3 0 0 %d %d %d\n",(j-warpStart)/WARP_SIZE,t,j);
/*line[yy][0]= 1;line[yy][1]=0;line[yy][2]=0;line[yy][3]=(j-warpStart)/WARP_SIZE;line[yy][4]=t;line[yy][5]=j;
yy++;
line[yy][0]= 2;line[yy][1]=0;line[yy][2]=0;line[yy][3]=(j-warpStart)/WARP_SIZE;line[yy][4]=t;line[yy][5]=col;
yy++;*/
line[yy][0]= 3;line[yy][1]=0;line[yy][2]=0;line[yy][3]=(j-warpStart)/WARP_SIZE;line[yy][4]=t;line[yy][5]=col;//j;
sum[t] += col;
yy++;



    }
/*
    partialSums[t] = mySum;

    // Reduce partial sums
    if (id < 16) partialSums[t] += partialSums[t+16];
    if (id <  8) partialSums[t] += partialSums[t+ 8];
    if (id <  4) partialSums[t] += partialSums[t+ 4];
    if (id <  2) partialSums[t] += partialSums[t+ 2];
    if (id <  1) partialSums[t] += partialSums[t+ 1];

    // Write result 
    if (id == 0)
    {
      out[myRow] = partialSums[t];
    }*/
  }
printf("%d %d\n",t,sum[t]);
 }
}


void fill(float *A, const int n, const float maxi)
{
  for (int j = 0; j < n; j++) 
  {
    A[j] = ((float) maxi * (rand() / (RAND_MAX + 1.0f)));
  }
}

void initRandomMatrix(int *cols, int *rowDelimiters, const int n, const int dim)
{
  int nnzAssigned = 0;

  // Figure out the probability that a nonzero should be assigned to a given
  // spot in the matrix
  double prob = (double)n / ((double)dim * (double)dim);

  // Seed random number generator
  srand48(2013);

  // Randomly decide whether entry i,j gets a value, but ensure n values
  // are assigned
  bool fillRemaining = false;
  for (int i = 0; i < dim; i++)
  {
    rowDelimiters[i] = nnzAssigned;
    for (int j = 0; j < dim; j++)
    {
      int numEntriesLeft = (dim * dim) - ((i * dim) + j);
      int needToAssign   = n - nnzAssigned;
      if (numEntriesLeft <= needToAssign) {
        fillRemaining = true;
      }
      if ((nnzAssigned < n && drand48() <= prob) || fillRemaining)
      {
        // Assign (i,j) a value
        cols[nnzAssigned] = j;
        nnzAssigned++;
      }
    }
  }
  // Observe the convention to put the number of non zeroes at the end of the
  // row delimiters array
  rowDelimiters[dim] = n;
  assert(nnzAssigned == n);
}

void convertToPadded(float *A, int *cols, int dim, int *rowDelimiters, 
                     float **newA_ptr, int **newcols_ptr, int *newIndices, 
                     int *newSize) 
{
  // determine total padded size and new row indices
  int paddedSize = 0;  
  int rowSize; 

  for (int i=0; i<dim; i++) 
  {    
    newIndices[i] = paddedSize; 
    rowSize = rowDelimiters[i+1] - rowDelimiters[i]; 
    if (rowSize % PAD_FACTOR != 0) 
    {
      rowSize += PAD_FACTOR - rowSize % PAD_FACTOR; 
    } 
    paddedSize += rowSize; 
  }
  *newSize = paddedSize; 
  newIndices[dim] = paddedSize; 

  cudaMallocHost(newA_ptr, paddedSize * sizeof(float)); 
  cudaMallocHost(newcols_ptr, paddedSize * sizeof(int)); 

  float *newA = *newA_ptr; 
  int *newcols = *newcols_ptr; 

  memset(newA, 0, paddedSize * sizeof(float)); 

  // fill newA and newcols
  for (int i=0; i<dim; i++) 
  {
    for (int j=rowDelimiters[i], k=newIndices[i]; j<rowDelimiters[i+1]; 
        j++, k++) 
    {
      newA[k] = A[j]; 
      newcols[k] = cols[j]; 
    }
  }
}

void spmvCpu(const float *val, const int *cols, const int *rowDelimiters, 
	     const float *vec, int dim, float *out) 
{
  for (int i=0; i<dim; i++) 
  {
    float t = 0; 
    for (int j = rowDelimiters[i]; j < rowDelimiters[i + 1]; j++)
    {
      int col = cols[j]; 
      t += val[j] * vec[col];
    }    
    out[i] = t; 
  }
}

void spmv_verifyResults(const float *cpuResults, const float *gpuResults,
                   const int size) 
{
  bool passed = true; 
  for (int i = 0; i < size; i++)
  {
    if (fabs(cpuResults[i] - gpuResults[i]) / cpuResults[i] 
        > MAX_RELATIVE_ERROR) 
    {
      cout << "Failed! Mismatch at i: "<< i << " ref: " << cpuResults[i] <<
          " dev: " << gpuResults[i] << endl;
      return;
    }
  }

  cout << "spmv passed" << endl;
}












__global__ void 
spmv_kernel(const float* val,
                       const int    * cols,
                       const int    * rowDelimiters,
                       const float  * vec,
                       const int dim, float * out)
{
  // Thread ID in block
  int t = threadIdx.x; 
  // Thread ID within warp
  int id = t & (WARP_SIZE-1);
  int warpsPerBlock = blockDim.x / WARP_SIZE;
  // One row per warp
  int myRow = (blockIdx.x * warpsPerBlock) + (t / WARP_SIZE);

  __shared__ volatile float partialSums[spmv_BLOCK_SIZE];

  if (myRow < dim) 
  {
    int warpStart = rowDelimiters[myRow];
    int warpEnd = rowDelimiters[myRow+1];
    float mySum = 0;
    for (int j = warpStart + id; j < warpEnd; j += WARP_SIZE)
    {
      int col = cols[j]; 
      mySum += val[j] * vec[col];
    }
    partialSums[t] = mySum;

    // Reduce partial sums
    if (id < 16) partialSums[t] += partialSums[t+16];
    if (id <  8) partialSums[t] += partialSums[t+ 8];
    if (id <  4) partialSums[t] += partialSums[t+ 4];
    if (id <  2) partialSums[t] += partialSums[t+ 2];
    if (id <  1) partialSums[t] += partialSums[t+ 1];

    // Write result 
    if (id == 0)
    {
      out[myRow] = partialSums[t];
    }
  }
}



int main(int argc, char **argv) {
cudaSetDevice(2);
  srand(2013);
  struct timespec t3,t4;
  clock_gettime(CLOCK_MONOTONIC,&t3);
  float *h_spmv_val, *h_spmv_valPad;
  int *h_spmv_cols, *h_spmv_colsPad;
  int *h_rowDelimiters, *h_rowDelimitersPad;
  float *h_spmv_vec, *h_spmv_out, *spmv_refOut;
  int spmv_nItems, nItemsPadded, spmv_numRows;

  spmv_numRows = spmv_NBLOCKS * (spmv_BLOCK_SIZE/WARP_SIZE);
  spmv_nItems = spmv_numRows * spmv_numRows / 50; // 1% of entries will be non-zero
  float maxval = 200.0;
  cudaMallocHost(&h_spmv_val, spmv_nItems * sizeof(float)); 
  cudaMallocHost(&h_spmv_cols, spmv_nItems * sizeof(int)); 
  cudaMallocHost(&h_rowDelimiters, (spmv_numRows + 1) * sizeof(int)); 
  fill(h_spmv_val, spmv_nItems, maxval); 
  initRandomMatrix(h_spmv_cols, h_rowDelimiters, spmv_nItems, spmv_numRows);

  // Set up remaining host data
  int paddedSize = spmv_numRows + (PAD_FACTOR - spmv_numRows % PAD_FACTOR);
  cudaMallocHost(&h_spmv_vec, spmv_numRows * sizeof(float)) ;
  spmv_refOut = new float[spmv_numRows];
  cudaMallocHost(&h_rowDelimitersPad, (spmv_numRows + 1) * sizeof(int)); 
  fill(h_spmv_vec, spmv_numRows, maxval);

  cudaMallocHost(&h_spmv_out, paddedSize * sizeof(float)); 
  convertToPadded(h_spmv_val, h_spmv_cols, spmv_numRows, h_rowDelimiters, &h_spmv_valPad,
          &h_spmv_colsPad, h_rowDelimitersPad, &nItemsPadded);

  // Compute reference solution
  spmvCpu(h_spmv_val, h_spmv_cols, h_rowDelimiters, h_spmv_vec, spmv_numRows, spmv_refOut);

  float *d_spmv_val, *d_spmv_vec, *d_spmv_out;
  int *d_spmv_cols, *d_rowDelimiters;

  // Allocate device memory
  cudaMalloc(&d_spmv_val,  spmv_nItems * sizeof(float));
  cudaMalloc(&d_spmv_cols, spmv_nItems * sizeof(int));
  cudaMalloc(&d_spmv_vec,  spmv_numRows * sizeof(float));
  cudaMalloc(&d_spmv_out,  spmv_numRows * sizeof(float));
  cudaMalloc(&d_rowDelimiters, (spmv_numRows+1) * sizeof(int));

  // Transfer data to device
  cudaMemcpy(d_spmv_val, h_spmv_val,   spmv_nItems * sizeof(float), cudaMemcpyHostToDevice);
  cudaMemcpy(d_spmv_cols, h_spmv_cols, spmv_nItems * sizeof(int), cudaMemcpyHostToDevice);
  cudaMemcpy(d_spmv_vec, h_spmv_vec, spmv_numRows * sizeof(float), cudaMemcpyHostToDevice);
  cudaMemcpy(d_rowDelimiters, h_rowDelimiters, (spmv_numRows+1) * sizeof(int), cudaMemcpyHostToDevice);

  cudaEvent_t kernel_start, kernel_stop;
  cudaEventCreate(&kernel_start);
  cudaEventCreate(&kernel_stop);
  float kernel_time = 0.0f;

  cudaEventRecord(kernel_start, 0);

  // Setup thread configuration
  int spmv_grid = (int) ceil(spmv_numRows / (float)(spmv_BLOCK_SIZE / WARP_SIZE));

  spmv_kernel <<<spmv_grid, spmv_BLOCK_SIZE>>>
  (d_spmv_val, d_spmv_cols, d_rowDelimiters, d_spmv_vec, spmv_numRows, d_spmv_out);

  cudaDeviceSynchronize();

  cudaEventRecord(kernel_stop, 0);
  cudaEventSynchronize(kernel_stop);
 
  // get elapsed time
  kernel_time = 0.0f;
  cudaEventElapsedTime(&kernel_time, kernel_start, kernel_stop);
  kernel_time *= 1.e-3; // Convert to seconds
  
  cout << "kernel exe time: " << kernel_time << endl;
  struct timespec t1, t2;
  clock_gettime(CLOCK_MONOTONIC,&t1);
  spmv_CPU(h_spmv_val,h_spmv_cols,h_rowDelimiters,h_spmv_vec,spmv_numRows,h_spmv_out);
  clock_gettime(CLOCK_MONOTONIC,&t2);
double kernel_timehh = (t2.tv_sec-t1.tv_sec)*1.e9+t2.tv_nsec-t1.tv_nsec;
  printf("Kernel time %f\n",kernel_timehh*1.e-9);
  cudaMemcpy(h_spmv_out, d_spmv_out, spmv_numRows * sizeof(float), cudaMemcpyDeviceToHost);
  spmv_verifyResults(spmv_refOut, h_spmv_out, spmv_numRows);
clock_gettime(CLOCK_MONOTONIC,&t4);
double total = (t4.tv_sec-t3.tv_sec)*1.e9+t4.tv_nsec-t3.tv_nsec;
  printf("total time %f\n",total*1.e-9);
  return 0;
}

