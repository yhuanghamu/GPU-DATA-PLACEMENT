/*
 * Copyright 1993-2012 NVIDIA Corporation.  All rights reserved.
 *
 * Please refer to the NVIDIA end user license agreement (EULA) associated
 * with this source code for terms and conditions that govern your use of
 * this software. Any use, reproduction, disclosure, or distribution of
 * this software and related documentation outside the terms of the EULA
 * is strictly prohibited.
 *
 */

/*
* This sample implements a separable convolution filter
* of a 2D image with an arbitrary kernel.
*/

// CUDA runtime
#include <cuda_runtime.h>

// Utilities and system includes
//#include <helper_functions.h>
#include <cuda.h>
#include "../include/common.h"
//#include <ctime.h>
#include <time.h>

#define KERNEL_RADIUS 8
#define KERNEL_LENGTH (2 * KERNEL_RADIUS + 1)
int line[1000000][6];
int yy=0;
__constant__ float c_Kernel[KERNEL_LENGTH];
void setConvolutionKernel(float *h_Kernel)
{
    cudaMemcpyToSymbol(c_Kernel, h_Kernel, KERNEL_LENGTH * sizeof(float));
}


////////////////////////////////////////////////////////////////////////////////
// Row convolution filter
////////////////////////////////////////////////////////////////////////////////
#define   ROWS_BLOCKDIM_X 16
#define   ROWS_BLOCKDIM_Y 4
#define ROWS_RESULT_STEPS 8
#define   ROWS_HALO_STEPS 1
void convolutionRowsKernel_CPU(
    float *d_Dst,
    float *d_Src,
    float *kernel,
    int imageW,
    int imageH,
    int pitch
)
{FILE *f = fopen("hha.txt","w");
     float s_Data[ROWS_BLOCKDIM_Y][(ROWS_RESULT_STEPS + 2 * ROWS_HALO_STEPS) * ROWS_BLOCKDIM_X];

    //Offset to the left halo edge
    for(int tx=0;tx<ROWS_BLOCKDIM_X;tx++)
     for(int ty = 0;ty<ROWS_BLOCKDIM_Y;ty++)
{


    const int baseX = (0 * ROWS_RESULT_STEPS - ROWS_HALO_STEPS) * ROWS_BLOCKDIM_X + tx;
    const int baseY = 0 * ROWS_BLOCKDIM_Y + ty;

    d_Src += baseY * pitch + baseX;
    d_Dst += baseY * pitch + baseX;

    //Load main data
#pragma unroll

    for (int i = ROWS_HALO_STEPS; i < ROWS_HALO_STEPS + ROWS_RESULT_STEPS; i++)
    {
        s_Data[ty][tx + i * ROWS_BLOCKDIM_X] = d_Src[i * ROWS_BLOCKDIM_X];
    //fprintf(f,"1 0 0 %d %d %d\n",i-ROWS_HALO_STEPS,ty*ROWS_BLOCKDIM_X+tx,baseY*pitch+baseX+i*ROWS_BLOCKDIM_X);
    line[yy][0]=1;line[yy][1]=0;line[yy][2]=0;line[yy][3]=i-ROWS_HALO_STEPS;line[yy][4]=ty*ROWS_BLOCKDIM_X+tx;line[yy][5]=baseY*pitch+baseX+i*ROWS_BLOCKDIM_X;  
  yy++;
  }

    //Load left halo
#pragma unroll

    for (int i = 0; i < ROWS_HALO_STEPS; i++)
    {
        s_Data[ty][tx + i * ROWS_BLOCKDIM_X] = (baseX >= -i * ROWS_BLOCKDIM_X) ? d_Src[i * ROWS_BLOCKDIM_X] : 0;
 // fprintf(f,"1 0 1 %d %d %d\n",i,ty*ROWS_BLOCKDIM_X+tx,baseY*pitch+baseX+i*ROWS_BLOCKDIM_X);  
  line[yy][0]=1;line[yy][1]=0;line[yy][2]=1;line[yy][3]=i;line[yy][4]=ty*ROWS_BLOCKDIM_X+tx;line[yy][5]=baseY*pitch+baseX+i*ROWS_BLOCKDIM_X;
  yy++;

   }

    //Load right halo
#pragma unroll

    for (int i = ROWS_HALO_STEPS + ROWS_RESULT_STEPS; i < ROWS_HALO_STEPS + ROWS_RESULT_STEPS + ROWS_HALO_STEPS; i++)
    {
        s_Data[ty][tx + i * ROWS_BLOCKDIM_X] = (imageW - baseX > i * ROWS_BLOCKDIM_X) ? d_Src[i * ROWS_BLOCKDIM_X] : 0;
  //fprintf(f,"1 0 2 %d %d %d\n",(i-ROWS_HALO_STEPS-ROWS_RESULT_STEPS),ty*ROWS_BLOCKDIM_X+tx,baseY*pitch+baseX+i*ROWS_BLOCKDIM_X);  
    line[yy][0]=1;line[yy][1]=0;line[yy][2]=2;line[yy][3]=i-ROWS_HALO_STEPS;line[yy][4]=ty*ROWS_BLOCKDIM_X+tx;line[yy][5]=baseY*pitch+baseX+i*ROWS_BLOCKDIM_X;
  yy++;
 
 }
 
}
    //Compute and store results
 //   __syncthreads();
#pragma unroll
  for(int tx=0;tx<ROWS_BLOCKDIM_X;tx++)
     for(int ty = 0;ty<ROWS_BLOCKDIM_Y;ty++)
{
    const int baseX = (0 * ROWS_RESULT_STEPS - ROWS_HALO_STEPS) * ROWS_BLOCKDIM_X + tx;
    const int baseY = 0 * ROWS_BLOCKDIM_Y + ty;

    d_Src += baseY * pitch + baseX;
    d_Dst += baseY * pitch + baseX;

    for (int i = ROWS_HALO_STEPS; i < ROWS_HALO_STEPS + ROWS_RESULT_STEPS; i++)
    {
        float sum = 0;

#pragma unroll

        for (int j = -KERNEL_RADIUS; j <= KERNEL_RADIUS; j++)
        {
            sum += kernel[KERNEL_RADIUS - j] * s_Data[ty][tx + i * ROWS_BLOCKDIM_X + j];
   // fprintf(f,"0 0 0 %d %d %d\n",(i-ROWS_HALO_STEPS)*(2*KERNEL_RADIUS+1)+j+KERNEL_RADIUS,ty*ROWS_BLOCKDIM_X+tx,KERNEL_RADIUS - j);    
    line[yy][0]=0;line[yy][1]=0;line[yy][2]=0;line[yy][3]=(i-ROWS_HALO_STEPS)*(2*KERNEL_RADIUS+1)+j+KERNEL_RADIUS;line[yy][4]=ty*ROWS_BLOCKDIM_X+tx;line[yy][5]=baseY*pitch+baseX+i*ROWS_BLOCKDIM_X;
  yy++;
 
   }

        d_Dst[i * ROWS_BLOCKDIM_X] = sum;
  fprintf(f,"2 1 0 %d %d %d\n",(i-ROWS_HALO_STEPS),ty*ROWS_BLOCKDIM_X+tx,baseY*pitch+baseX+i*ROWS_BLOCKDIM_X);  
  
line[yy][0]=2;line[yy][1]=1;line[yy][2]=0;line[yy][3]=(i-ROWS_HALO_STEPS);line[yy][4]=ty*ROWS_BLOCKDIM_X+tx;line[yy][5]=baseY*pitch+baseX+i*ROWS_BLOCKDIM_X;
yy++;
}
}
}
__global__ void convolutionRowsKernel(
    float *d_Dst,
    float *d_Src,
    int imageW,
    int imageH,
    int pitch
)
{
    __shared__ float s_Data[ROWS_BLOCKDIM_Y][(ROWS_RESULT_STEPS + 2 * ROWS_HALO_STEPS) * ROWS_BLOCKDIM_X];

    //Offset to the left halo edge
    const int baseX = (blockIdx.x * ROWS_RESULT_STEPS - ROWS_HALO_STEPS) * ROWS_BLOCKDIM_X + threadIdx.x;
    const int baseY = blockIdx.y * ROWS_BLOCKDIM_Y + threadIdx.y;

    d_Src += baseY * pitch + baseX;
    d_Dst += baseY * pitch + baseX;

    //Load main data
#pragma unroll

    for (int i = ROWS_HALO_STEPS; i < ROWS_HALO_STEPS + ROWS_RESULT_STEPS; i++)
    {
        s_Data[threadIdx.y][threadIdx.x + i * ROWS_BLOCKDIM_X] = d_Src[i * ROWS_BLOCKDIM_X];
    }

    //Load left halo
#pragma unroll

    for (int i = 0; i < ROWS_HALO_STEPS; i++)
    {
        s_Data[threadIdx.y][threadIdx.x + i * ROWS_BLOCKDIM_X] = (baseX >= -i * ROWS_BLOCKDIM_X) ? d_Src[i * ROWS_BLOCKDIM_X] : 0;
    }

    //Load right halo
#pragma unroll

    for (int i = ROWS_HALO_STEPS + ROWS_RESULT_STEPS; i < ROWS_HALO_STEPS + ROWS_RESULT_STEPS + ROWS_HALO_STEPS; i++)
    {
        s_Data[threadIdx.y][threadIdx.x + i * ROWS_BLOCKDIM_X] = (imageW - baseX > i * ROWS_BLOCKDIM_X) ? d_Src[i * ROWS_BLOCKDIM_X] : 0;
    }

    //Compute and store results
    __syncthreads();
#pragma unroll

    for (int i = ROWS_HALO_STEPS; i < ROWS_HALO_STEPS + ROWS_RESULT_STEPS; i++)
    {
        float sum = 0;

#pragma unroll

        for (int j = -KERNEL_RADIUS; j <= KERNEL_RADIUS; j++)
        {
            sum += c_Kernel[KERNEL_RADIUS - j] * s_Data[threadIdx.y][threadIdx.x + i * ROWS_BLOCKDIM_X + j];
        }

        d_Dst[i * ROWS_BLOCKDIM_X] = sum;
    }
}

void convolutionRowsGPU(
    float *d_Dst,
    float *d_Src,
    int imageW,
    int imageH
)
{
    assert(ROWS_BLOCKDIM_X * ROWS_HALO_STEPS >= KERNEL_RADIUS);
    assert(imageW % (ROWS_RESULT_STEPS * ROWS_BLOCKDIM_X) == 0);
    assert(imageH % ROWS_BLOCKDIM_Y == 0);

    dim3 blocks(imageW / (ROWS_RESULT_STEPS * ROWS_BLOCKDIM_X), imageH / ROWS_BLOCKDIM_Y);
    dim3 threads(ROWS_BLOCKDIM_X, ROWS_BLOCKDIM_Y);

    convolutionRowsKernel<<<blocks, threads>>>(
        d_Dst,
        d_Src,
        imageW,
        imageH,
        imageW
    );
    getLastCudaError("convolutionRowsKernel() execution failed\n");
}



////////////////////////////////////////////////////////////////////////////////
// Column convolution filter
////////////////////////////////////////////////////////////////////////////////
#define   COLUMNS_BLOCKDIM_X 16
#define   COLUMNS_BLOCKDIM_Y 8
#define COLUMNS_RESULT_STEPS 8
#define   COLUMNS_HALO_STEPS 1

__global__ void convolutionColumnsKernel(
    float *d_Dst,
    float *d_Src,
    int imageW,
    int imageH,
    int pitch
)
{
    __shared__ float s_Data[COLUMNS_BLOCKDIM_X][(COLUMNS_RESULT_STEPS + 2 * COLUMNS_HALO_STEPS) * COLUMNS_BLOCKDIM_Y + 1];

    //Offset to the upper halo edge
    const int baseX = blockIdx.x * COLUMNS_BLOCKDIM_X + threadIdx.x;
    const int baseY = (blockIdx.y * COLUMNS_RESULT_STEPS - COLUMNS_HALO_STEPS) * COLUMNS_BLOCKDIM_Y + threadIdx.y;
    d_Src += baseY * pitch + baseX;
    d_Dst += baseY * pitch + baseX;

    //Main data
#pragma unroll

    for (int i = COLUMNS_HALO_STEPS; i < COLUMNS_HALO_STEPS + COLUMNS_RESULT_STEPS; i++)
    {
        s_Data[threadIdx.x][threadIdx.y + i * COLUMNS_BLOCKDIM_Y] = d_Src[i * COLUMNS_BLOCKDIM_Y * pitch];
    }

    //Upper halo
#pragma unroll

    for (int i = 0; i < COLUMNS_HALO_STEPS; i++)
    {
        s_Data[threadIdx.x][threadIdx.y + i * COLUMNS_BLOCKDIM_Y] = (baseY >= -i * COLUMNS_BLOCKDIM_Y) ? d_Src[i * COLUMNS_BLOCKDIM_Y * pitch] : 0;
    }

    //Lower halo
#pragma unroll

    for (int i = COLUMNS_HALO_STEPS + COLUMNS_RESULT_STEPS; i < COLUMNS_HALO_STEPS + COLUMNS_RESULT_STEPS + COLUMNS_HALO_STEPS; i++)
    {
        s_Data[threadIdx.x][threadIdx.y + i * COLUMNS_BLOCKDIM_Y]= (imageH - baseY > i * COLUMNS_BLOCKDIM_Y) ? d_Src[i * COLUMNS_BLOCKDIM_Y * pitch] : 0;
    }

    //Compute and store results
    __syncthreads();
#pragma unroll

    for (int i = COLUMNS_HALO_STEPS; i < COLUMNS_HALO_STEPS + COLUMNS_RESULT_STEPS; i++)
    {
        float sum = 0;
#pragma unroll

        for (int j = -KERNEL_RADIUS; j <= KERNEL_RADIUS; j++)
        {
            sum += c_Kernel[KERNEL_RADIUS - j] * s_Data[threadIdx.x][threadIdx.y + i * COLUMNS_BLOCKDIM_Y + j];
        }

        d_Dst[i * COLUMNS_BLOCKDIM_Y * pitch] = sum;
    }
}

void convolutionColumnsGPU(
    float *d_Dst,
    float *d_Src,
    int imageW,
    int imageH
)
{
    assert(COLUMNS_BLOCKDIM_Y * COLUMNS_HALO_STEPS >= KERNEL_RADIUS);
    assert(imageW % COLUMNS_BLOCKDIM_X == 0);
    assert(imageH % (COLUMNS_RESULT_STEPS * COLUMNS_BLOCKDIM_Y) == 0);

    dim3 blocks(imageW / COLUMNS_BLOCKDIM_X, imageH / (COLUMNS_RESULT_STEPS * COLUMNS_BLOCKDIM_Y));
    dim3 threads(COLUMNS_BLOCKDIM_X, COLUMNS_BLOCKDIM_Y);

    convolutionColumnsKernel<<<blocks, threads>>>(
        d_Dst,
        d_Src,
        imageW,
        imageH,
        imageW
    );
    getLastCudaError("convolutionColumnsKernel() execution failed\n");
}

void convolutionRowCPU(
    float *h_Dst,
    float *h_Src,
    float *h_Kernel,
    int imageW,
    int imageH,
    int kernelR
)
{
    for (int y = 0; y < imageH; y++)
        for (int x = 0; x < imageW; x++)
        {
            float sum = 0;

            for (int k = -kernelR; k <= kernelR; k++)
            {
                int d = x + k;

                if (d >= 0 && d < imageW)
                    sum += h_Src[y * imageW + d] * h_Kernel[kernelR - k];
            }

            h_Dst[y * imageW + x] = sum;
        }
}



////////////////////////////////////////////////////////////////////////////////
// Reference column convolution filter
////////////////////////////////////////////////////////////////////////////////
void convolutionColumnCPU(
    float *h_Dst,
    float *h_Src,
    float *h_Kernel,
    int imageW,
    int imageH,
    int kernelR
)
{
    for (int y = 0; y < imageH; y++)
        for (int x = 0; x < imageW; x++)
        {
            float sum = 0;

            for (int k = -kernelR; k <= kernelR; k++)
            {
                int d = y + k;

                if (d >= 0 && d < imageH)
                    sum += h_Src[d * imageW + x] * h_Kernel[kernelR - k];
            }

            h_Dst[y * imageW + x] = sum;
        }
}



////////////////////////////////////////////////////////////////////////////////
// Main program
////////////////////////////////////////////////////////////////////////////////
int main(int argc, char **argv)
{
    // start logs
    printf("[%s] - Starting...\n", argv[0]);

    float
    *h_Kernel,
    *h_Input,
    *h_Buffer,
    *h_OutputCPU,
    *h_OutputGPU;

    float
    *d_Input,
    *d_Output,
    *d_Buffer;


    const int imageW = 3072;
    const int imageH = 3072;
    const int iterations = 16;

    struct timespec t1,t2,t3,t4,t5,t6;
    clock_gettime(CLOCK_MONOTONIC,&t5);

    //Use command-line specified CUDA device, otherwise use device with highest Gflops/s
    //findCudaDevice(argc, (const char **)argv);

    

    printf("Image Width x Height = %i x %i\n\n", imageW, imageH);
    printf("Allocating and initializing host arrays...\n");
    h_Kernel    = (float *)malloc(KERNEL_LENGTH * sizeof(float));
    h_Input     = (float *)malloc(imageW * imageH * sizeof(float));
    h_Buffer    = (float *)malloc(imageW * imageH * sizeof(float));
    h_OutputCPU = (float *)malloc(imageW * imageH * sizeof(float));
    h_OutputGPU = (float *)malloc(imageW * imageH * sizeof(float));
    srand(200);

    for (unsigned int i = 0; i < KERNEL_LENGTH; i++)
    {
        h_Kernel[i] = (float)(rand() % 16);
    }

    for (unsigned i = 0; i < imageW * imageH; i++)
    {
        h_Input[i] = (float)(rand() % 16);
    }

    printf("Allocating and initializing CUDA arrays...\n");
    checkCudaErrors(cudaMalloc((void **)&d_Input,   imageW * imageH * sizeof(float)));
    checkCudaErrors(cudaMalloc((void **)&d_Output,  imageW * imageH * sizeof(float)));
    checkCudaErrors(cudaMalloc((void **)&d_Buffer , imageW * imageH * sizeof(float)));

    setConvolutionKernel(h_Kernel);
    checkCudaErrors(cudaMemcpy(d_Input, h_Input, imageW * imageH * sizeof(float), cudaMemcpyHostToDevice));

    printf("Running GPU convolution (%u identical iterations)...\n\n", iterations);

    for (int i = -1; i < iterations; i++)
    {
        //i == -1 -- warmup iteration
        if (i == 0)
        {
            checkCudaErrors(cudaDeviceSynchronize());
           // clock_gettime(CLOCK_MONOTONIC,&t1);
        }
if(i==1) clock_gettime(CLOCK_MONOTONIC,&t1);
        convolutionRowsGPU(
            d_Buffer,
            d_Input,
            imageW,
            imageH
        );
cudaDeviceSynchronize();
if(i==1) clock_gettime(CLOCK_MONOTONIC,&t2);
if(i==1)  clock_gettime(CLOCK_MONOTONIC,&t3);
if(i==1)convolutionRowsKernel_CPU(
            h_Buffer,
            h_Input,
           h_Kernel,  
            imageW,
            imageH,imageW
        );
if(i==1)  clock_gettime(CLOCK_MONOTONIC,&t4);

        convolutionColumnsGPU(
            d_Output,
            d_Buffer,
            imageW,
            imageH
        );
    }

    checkCudaErrors(cudaDeviceSynchronize());
    //clock_gettime(CLOCK_MONOTONIC,&t2);
    double gpuTime = ((t2.tv_sec-t1.tv_sec)+ (t2.tv_nsec-t1.tv_nsec)/1.e9);/// (double)iterations;
    printf("convolutionSeparable, Throughput = %.4f MPixels/sec, Time = %.5f s, Size = %u Pixels, NumDevsUsed = %i, Workgroup = %u\n",
           (1.0e-6 * (double)(imageW * imageH)/ gpuTime), gpuTime, (imageW * imageH), 1, 0);
    double cpuTime = ((t4.tv_sec-t3.tv_sec)+ (t4.tv_nsec-t3.tv_nsec)/1.e9);
    printf("CPUTIME: %f\n",cpuTime);
    printf("\nReading back GPU results...\n\n");
    checkCudaErrors(cudaMemcpy(h_OutputGPU, d_Output, imageW * imageH * sizeof(float), cudaMemcpyDeviceToHost));

    printf("Checking the results...\n");
    printf(" ...running convolutionRowCPU()\n");
    convolutionRowCPU(
        h_Buffer,
        h_Input,
        h_Kernel,
        imageW,
        imageH,
        KERNEL_RADIUS
    );

    printf(" ...running convolutionColumnCPU()\n");
    convolutionColumnCPU(
        h_OutputCPU,
        h_Buffer,
        h_Kernel,
        imageW,
        imageH,
        KERNEL_RADIUS
    );

    printf(" ...comparing the results\n");
    double sum = 0, delta = 0;

    for (unsigned i = 0; i < imageW * imageH; i++)
    {
        delta += (h_OutputGPU[i] - h_OutputCPU[i]) * (h_OutputGPU[i] - h_OutputCPU[i]);
        sum   += h_OutputCPU[i] * h_OutputCPU[i];
    }

    double L2norm = sqrt(delta / sum);
    printf(" ...Relative L2 norm: %E\n\n", L2norm);
    printf("Shutting down...\n");


    checkCudaErrors(cudaFree(d_Buffer));
    checkCudaErrors(cudaFree(d_Output));
    checkCudaErrors(cudaFree(d_Input));
    free(h_OutputGPU);
    free(h_OutputCPU);
    free(h_Buffer);
    free(h_Input);
    free(h_Kernel);

    

    cudaDeviceReset();
clock_gettime(CLOCK_MONOTONIC,&t6);
printf("Total Time : %f\n",(t6.tv_sec-t5.tv_sec)+ (t6.tv_nsec-t5.tv_nsec)/1.e9);

    if (L2norm > 1e-6)
    {
        printf("Test failed!\n");
        exit(EXIT_FAILURE);
    }

    printf("Test passed\n");
    exit(EXIT_SUCCESS);
}
