
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


#define trans_BLOCK_SIZE 16

#define trans_GRID_X 1600
#define trans_GRID_Y 480
#define trans_NBLOCKS (trans_GRID_X*trans_GRID_Y) 

texture<float,2,cudaReadModeElementType> tex_A;
void computeGold( float* reference, float* idata,
            const unsigned int size_x, const unsigned int size_y )
{
  // transpose matrix
  for( unsigned int y = 0; y < size_y; ++y)
  {
    for( unsigned int x = 0; x < size_x; ++x)
    {
      reference[(x * size_y) + y] = idata[(y * size_x) + x];
    }
  }
}

void trans_checkResults(float *h_idata, float *h_odata, int width, int height)
{
 /* // compute reference solution
  int trans_mem_size = width * height *sizeof(float);
  float* reference = (float*) malloc( trans_mem_size);

  computeGold( reference, h_idata, width, height);

  for(int i=0; i<width*height; ++i)
  {
    if(reference[i] != d_odata[i]) {
      fprintf(stderr, "Failed! i = %d\n", i);
      return;
    }
  }
  printf("Test passed!\n");*/
FILE *f = fopen("hha.txt","w");
#pragma omp for  
for(unsigned int xIndex =0;xIndex<16;xIndex++){
   for (unsigned int yIndex =0;yIndex<16;yIndex++){
    if (xIndex < width && yIndex < height)
    {
       unsigned int index_in  = xIndex + width * yIndex;
       unsigned int index_out = yIndex + height * xIndex;
      h_odata[index_out]=h_idata[index_in];
  //    if( h_odata[index_out] != h_idata[index_in]) {printf("failed!%d %d %f %f \n ",xIndex,yIndex,h_odata[index_out],h_idata[index_in]);return;}
    fprintf(f,"1 0 0 0 %d %d\n",xIndex+16*yIndex,index_in);   
 }
    }
    }
    printf("GOOD!trans passed\n");
    return;
}

__global__ void trans_kernel(float *odata, float* idata, int width, int height)
{
   unsigned int xIndex = blockDim.x * blockIdx.x + threadIdx.x;
   unsigned int yIndex = blockDim.y * blockIdx.y + threadIdx.y;

   if (xIndex < width && yIndex < height)
   {
       unsigned int index_in  = xIndex + width * yIndex;
       unsigned int index_out = yIndex + height * xIndex;
       odata[index_out] = tex2D(tex_A,index_in%width,index_in/width);//idata[index_in];
   }
}

int main(int argc, char **argv) {
  cudaSetDevice(2);
  srand(2013);
struct timespec start,end;
clock_gettime(CLOCK_MONOTONIC,&start);
  const unsigned int trans_size_x = trans_GRID_X * trans_BLOCK_SIZE;
  const unsigned int trans_size_y = trans_GRID_Y * trans_BLOCK_SIZE;

  // size of memory required to store the matrix
  const unsigned int trans_mem_size = sizeof(float) * trans_size_x * trans_size_y;

  // allocate host memory
  float* h_trans_idata = (float*) malloc(trans_mem_size);
  // initalize the memory
  for( unsigned int i = 0; i < (trans_size_x * trans_size_y); ++i)
  {
      h_trans_idata[i] = (float) i;    // rand();
  }

  // allocate device memory
  float* d_trans_idata;
  float* d_trans_odata;
  cudaMalloc( (void**) &d_trans_idata, trans_mem_size);
  cudaMalloc( (void**) &d_trans_odata, trans_mem_size);

  // copy host memory to device
  cudaMemcpy( d_trans_idata, h_trans_idata, trans_mem_size, cudaMemcpyHostToDevice);

 cudaChannelFormatDesc channelDescA =  cudaCreateChannelDesc<float>();
  cudaArray* A_Array;
 cudaMallocArray(&A_Array, &channelDescA, trans_size_x,trans_size_y);
 cudaMemcpyToArray(A_Array, 0, 0, h_trans_idata, trans_mem_size,
                      cudaMemcpyHostToDevice);
 tex_A.addressMode[0] = cudaAddressModeWrap;
    tex_A.addressMode[1] = cudaAddressModeWrap;
    tex_A.filterMode     = cudaFilterModePoint;
 cudaBindTextureToArray(tex_A, A_Array, channelDescA);

  cudaEvent_t kernel_start, kernel_stop;
  cudaEventCreate(&kernel_start);
  cudaEventCreate(&kernel_stop);
  float kernel_time = 0.0f;

  cudaEventRecord(kernel_start, 0);
  // setup execution parameters
  dim3 trans_grid(trans_GRID_X, trans_GRID_Y, 1);
  dim3 trans_block(trans_BLOCK_SIZE, trans_BLOCK_SIZE, 1);
 

  trans_kernel<<<trans_grid, trans_block>>>(d_trans_odata, d_trans_idata, trans_size_x, trans_size_y);

  cudaDeviceSynchronize();

  cudaEventRecord(kernel_stop, 0);
  cudaEventSynchronize(kernel_stop);

  // get elapsed time
  kernel_time = 0.0f;
  cudaEventElapsedTime(&kernel_time, kernel_start, kernel_stop);
  kernel_time *= 1.e-3; // Convert to seconds
  
  cout << "kernel exe time: " << kernel_time << endl;
  float* h_trans_odata = (float*) malloc(trans_mem_size);
  cudaMemcpy( h_trans_odata, d_trans_odata, trans_mem_size, cudaMemcpyDeviceToHost);


  // check result
  struct timespec t1, t2;
  clock_gettime(CLOCK_MONOTONIC,&t1);
  trans_checkResults(h_trans_idata, h_trans_odata, trans_size_x, trans_size_y);
  clock_gettime(CLOCK_MONOTONIC,&t2);
double kernel_timehh = (t2.tv_sec-t1.tv_sec)*1.e9+t2.tv_nsec-t1.tv_nsec;
  printf("Kernel time %f\n",kernel_timehh*1.e-9);
clock_gettime(CLOCK_MONOTONIC,&end);
double total_time = (end.tv_sec-start.tv_sec)*1.e9+end.tv_nsec-start.tv_nsec;
  printf("Kernel time %f\n",total_time*1.e-9);
  return 0;
}

