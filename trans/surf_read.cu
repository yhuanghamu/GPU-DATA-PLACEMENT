
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

#define trans_GRID_X 160
#define trans_GRID_Y 480

#define trans_NBLOCKS (trans_GRID_X*trans_GRID_Y) 
texture<float,1,cudaReadModeElementType> tex_1DA;
texture<float,2,cudaReadModeElementType> tex_A;
surface<void,2> surf;
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
  for(unsigned int xIndex =0;xIndex<width;xIndex++){
   
   for (unsigned int yIndex =0;yIndex<height;yIndex++){
    if (xIndex < width && yIndex < height)
    {
       unsigned int index_in  = xIndex + width * yIndex;
       unsigned int index_out = yIndex + height * xIndex;
      if( h_odata[index_out] != h_idata[index_in]) {printf("failed!%d %d %f %f \n ",xIndex,yIndex,h_odata[index_out],h_idata[index_in]);return;}
    }
    }
    }
    printf("GOOD!trans passed\n");
    return;
}

__global__ void trans_kernel(float *odata, float* idata, int width, int height)
{
   unsigned int xIndex = trans_BLOCK_SIZE * blockIdx.x + threadIdx.x;//%trans_BLOCK_SIZE;
   unsigned int yIndex = trans_BLOCK_SIZE * blockIdx.y + threadIdx.y;///trans_BLOCK_SIZE;

   if (xIndex < width && yIndex < height)
   {
       unsigned int index_in  = xIndex + width * yIndex;
       unsigned int index_out = yIndex + height * xIndex;
   //    if(threadIdx.y%2==1)
	//odata[index_out] = tex1Dfetch(tex_1DA,index_in);//tex2D(tex_A,index_in%width,index_in/width);//idata[index_in];
   //	else{
float temp;
surf2Dread(&temp,surf,xIndex*4,yIndex,cudaBoundaryModeTrap);
	odata[index_out] = temp;//idata[index_in];
//	}
//surf2Dwrite(idata[index_in],surf,yIndex*sizeof(float),xIndex);
	}
}

int main(int argc, char **argv) {
  cudaSetDevice(2);
  srand(2013);

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
 cudaChannelFormatDesc forB= cudaCreateChannelDesc<float>();//cudaCreateChannelDesc(32,0,0,0,cudaChannelFormatKindFloat);
  cudaArray* A_Array;
  cudaArray* B_Array;
 cudaMallocArray(&A_Array, &channelDescA, trans_size_x,trans_size_y);
 cudaMallocArray(&B_Array, &forB,trans_size_x,trans_size_y,cudaArraySurfaceLoadStore);
 cudaMemcpyToArray(A_Array, 0, 0, h_trans_idata, trans_mem_size,
                      cudaMemcpyHostToDevice);
cudaMemcpyToArray(B_Array, 0, 0, h_trans_idata, trans_mem_size,
                      cudaMemcpyHostToDevice);
 tex_A.addressMode[0] = cudaAddressModeWrap;
    tex_A.addressMode[1] = cudaAddressModeWrap;
    tex_A.filterMode     = cudaFilterModePoint;
 cudaBindTextureToArray(tex_A, A_Array, channelDescA);
cudaBindSurfaceToArray(surf,B_Array,forB);
cudaBindTexture(0,tex_1DA,d_trans_idata,trans_mem_size);
  cudaEvent_t kernel_start, kernel_stop;
  cudaEventCreate(&kernel_start);
  cudaEventCreate(&kernel_stop);
  float kernel_time = 0.0f;
float* h_trans_odata = (float*) malloc(trans_mem_size);
  cudaEventRecord(kernel_start, 0);
  // setup execution parameters
  dim3 trans_grid(trans_GRID_X, trans_GRID_Y, 1);
  dim3 trans_block(trans_BLOCK_SIZE, trans_BLOCK_SIZE, 1);
 

  trans_kernel<<<trans_grid, trans_block>>>(d_trans_odata, d_trans_idata, trans_size_x, trans_size_y);
//cudaMemcpyFromArray(d_trans_odata,B_Array,0,0,trans_mem_size,cudaMemcpyDeviceToDevice);
  //cudaDeviceSynchronize();
//cudaMemcpy( h_trans_odata, d_trans_odata, trans_mem_size, cudaMemcpyDeviceToHost);
  cudaEventRecord(kernel_stop, 0);
  cudaEventSynchronize(kernel_stop);

  // get elapsed time
  kernel_time = 0.0f;
  cudaEventElapsedTime(&kernel_time, kernel_start, kernel_stop);
  kernel_time *= 1.e-3; // Convert to seconds
  
  cout << "kernel exe time: " << kernel_time << endl;
  cudaMemcpy( h_trans_odata, d_trans_odata, trans_mem_size, cudaMemcpyDeviceToHost);
//cudaMemcpyFromArray(h_trans_odata,B_Array,0,0,trans_mem_size,cudaMemcpyDeviceToHost);

  // check result
  trans_checkResults(h_trans_idata, h_trans_odata, trans_size_x, trans_size_y);


  return 0;
}

