#include <cuda.h>
#include <stdio.h>
#include <stdlib.h>
#include <vector>
#include <algorithm>
#include <iostream>
//#define n 256000

using namespace std;
__constant__ int d_B[64000];
int CPU_results(int *C, int *B,int *A,int N)
{
 for(int i=0;i<N;i++)
  C[B[i]]=A[i];
 return 0;
}
int check_results(int *C, int *B, int *A, int N)
{
 for(int i=0; i<N; i++)
 { if(C[B[i]]!=A[i]) 
  {
   cout<<i<<endl;
   cout<<A[i]<<" "<<C[B[i]]<<endl;
   printf("Sorry! Checking Failed!\n");
   return 0;
  }
 }
 printf("Good! Checking Passed!\n");
 return 1;
}

__global__ void kernel(int *d_C, int *d_A, int N)
{
 int tid = blockIdx.x * blockDim.x + threadIdx.x;
 if(tid >= N) return;
 int x = d_B[d_B[tid]];
}

int main(int argc, char *argv[])
{
 int N=atoi(argv[1]);
 int *A, *B, *C, *d_A, *d_B, *d_C;
 A=(int *)malloc(N*sizeof(int));
 B=(int *)malloc(N*sizeof(int));
 C=(int *)malloc(N*sizeof(int));
 cudaMalloc((void **)&d_A, N*sizeof(int));
 cudaMalloc((void **)&d_B, N*sizeof(int));
 cudaMalloc((void **)&d_C, N*sizeof(int));
 srand(2013);
 vector<int> BV(N);
 for(int i=0; i<N; i++)
 {
  A[i]=rand()%N;
  //cout<<"A["<<i<<"]="<<A[i]<<endl;
  BV[i]=i;//rand()%N;
  }
  random_shuffle(BV.begin(),BV.end());
 for(int i=0;i<N;i++)
 B[i]=BV[i];
 
 cudaMemcpy(d_A,A,N*sizeof(int),cudaMemcpyHostToDevice);
 cudaMemcpyToSymbol(d_B,B,N*sizeof(int));
 int blocks= 256;
 struct timespec time_start, time_end;
 clock_gettime(CLOCK_MONOTONIC,&time_start);
 kernel<<<(N+255)/256,blocks>>>(d_C,d_A,N);
 cudaThreadSynchronize();
 clock_gettime(CLOCK_MONOTONIC,&time_end);
 double kernel_time=(time_end.tv_sec-time_start.tv_sec)*1.e9+time_end.tv_nsec-time_start.tv_nsec;
 cout<<"GPU kernel time= "<<kernel_time*1.e-9<<endl;
 //for(int i=0;i<N;i++)
 //cout<<"C "<<i<<"="<<C[i]<<endl;
 clock_gettime(CLOCK_MONOTONIC,&time_start);
 //CPU_results(C,B,A,N);
 clock_gettime(CLOCK_MONOTONIC,&time_end);
 kernel_time=(time_end.tv_sec-time_start.tv_sec)*1.e9+time_end.tv_nsec-time_start.tv_nsec;
 cout<<"CPU time= "<<kernel_time*1.e-9<<endl;
 cudaMemcpy(C,d_C,N*sizeof(int),cudaMemcpyDeviceToHost);
 //check_results(C,B,A,N);
 return 0;
}
