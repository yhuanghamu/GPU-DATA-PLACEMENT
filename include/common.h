#ifndef COMMON_H
#define COMMON_H

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
#include <climits>
#include <cuda_runtime.h>

using namespace std;

#define checkCudaErrors(err)           __checkCudaErrors (err, __FILE__, __LINE__)

inline void __checkCudaErrors( cudaError err, const char *file, const int line )
{
  if( cudaSuccess != err) {
    fprintf(stderr, "%s(%i) : CUDA Runtime API error %d: %s.\n",
        file, line, (int)err, cudaGetErrorString( err ) );
    exit(-1);
  }
}

inline bool
sdkCompareL2fe( const float* reference, const float* data,
                const unsigned int len, const float epsilon ) 
{
  assert( epsilon >= 0);

  float error = 0;
  float ref = 0;

  for( unsigned int i = 0; i < len; ++i) {

    float diff = reference[i] - data[i];
    error += diff * diff;
    ref += reference[i] * reference[i];
  }

  float normRef = sqrtf(ref);
  if (fabs(ref) < 1e-7) {
#ifdef _DEBUG
    std::cerr << "ERROR, reference l2-norm is 0\n";
#endif
    return false;
  }
  float normError = sqrtf(error);
  error = normError / normRef;
  bool result = error < epsilon;
#ifdef _DEBUG
  if( ! result) 
  {
    std::cerr << "ERROR, l2-norm error " 
      << error << " is greater than epsilon " << epsilon << "\n";
  }
#endif

  return result;
}

#define getLastCudaError(msg)      __getLastCudaError (msg, __FILE__, __LINE__)

inline void __getLastCudaError( const char *errorMessage, const char *file, const int line )
{
  cudaError_t err = cudaGetLastError();
  if( cudaSuccess != err) {
    fprintf(stderr, "%s(%i) : getLastCudaError() CUDA error : %s : (%d) %s.\n",
        file, line, errorMessage, (int)err, cudaGetErrorString( err ) );
    exit(-1);
  }
}

__device__ uint get_smid(void) {
     uint ret;
     asm("mov.u32 %0, %smid;" : "=r"(ret) );
     return ret;
}

vector<int>::iterator randomMFromVec(vector<int>::iterator begin, vector<int>::iterator end, size_t num_random) {
  size_t left = std::distance(begin, end);
  while (num_random--) {
    vector<int>::iterator r = begin;
    std::advance(r, rand()%left);
    std::swap(*begin, *r);
    ++begin;
    --left;
  }
  return begin;
}

#endif
