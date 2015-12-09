
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

#define cfd_NBLOCKS 16*6*2
//#define cfd_SUPER_BLOCKS_PER_SM 5
#define cfd_BLOCK_SIZE 256
//const int cfd_BLOCK_SIZE = 256;
const int cfd_nBlksPerCluster = 16; 
const int cfd_nAtom = cfd_BLOCK_SIZE * cfd_NBLOCKS;
const int cfd_maxNeighbors = 8;
texture<float,1,cudaReadModeElementType> tex_mx;
texture<float,1,cudaReadModeElementType> tex_my;
texture<float,1,cudaReadModeElementType> tex_mz;
texture<float,1,cudaReadModeElementType> tex_energy;
texture<float,1,cudaReadModeElementType> tex_density;
texture<int,1,cudaReadModeElementType> tex_neighbor;
texture<float,1,cudaReadModeElementType> tex_normals;

inline int * cfd_myBuildNeighborList_blkSchedule(const int nAtom, 
        int* neighborList, int blockSz)
{
  //create non-uniform data sharing
  //but avoid that tasks sharing the same data are neighbor tasks by randomization
  vector<int> atomInds(nAtom);
  vector<int> blkInds((nAtom+blockSz-1)/blockSz);
  for(int i=0; i<blkInds.size(); ++i)
    blkInds[i] = i;
  random_shuffle(blkInds.begin(), blkInds.end());

  int *blkOrder = (int*)malloc(blkInds.size()*sizeof(int));
  for(int i=0; i<blkInds.size(); ++i)
    blkOrder[i] = blkInds[i];

  int j=0; 
  for(vector<int>::iterator it=blkInds.begin(); it!=blkInds.end(); ++it)
  {
    int blkInd = *it;
    for(int i=0; i<blockSz; ++i)
      atomInds[j++] = blkInd*blockSz + i;
  }
  int superBlockSz = blockSz * cfd_nBlksPerCluster;
  // Build Neighbor List
  for (int i = 0; i < nAtom; i++)
  {
    int start = i - i%superBlockSz; //difference is here
    //int end = i + (superBlockSz - i%superBlockSz)-1;

    int nNeighbors = 0;
    do {
      int j = start + rand() % superBlockSz;
      if (i == j || j>=nAtom) continue; // An atom cannot be its own neighbor
      neighborList[nNeighbors*nAtom + atomInds[i]] = atomInds[j];
      nNeighbors ++; 
    } while(nNeighbors<cfd_maxNeighbors);

  }
  return blkOrder;
}

#define GAMMA 1.4f
#define VAR_DENSITY 0
#define VAR_MOMENTUM 1
#define NDIM 3
#define VAR_DENSITY_ENERGY (VAR_MOMENTUM+NDIM)
#define NVAR (VAR_DENSITY_ENERGY+1)

__host__ __device__ inline void compute_velocity(float& density, float3& momentum, float3& velocity)
{
	velocity.x = momentum.x / density;
	velocity.y = momentum.y / density;
	velocity.z = momentum.z / density;
}

__host__ __device__ inline float compute_speed_sqd(float3& velocity)
{
	return velocity.x*velocity.x + velocity.y*velocity.y + velocity.z*velocity.z;
}

__host__ __device__ inline float compute_pressure(float& density, float& density_energy, float& speed_sqd)
{
	return (float(GAMMA)-float(1.0f))*(density_energy - float(0.5f)*density*speed_sqd);
}

__host__ __device__ inline float compute_speed_of_sound(float& density, float& pressure)
{
	return sqrtf(float(GAMMA)*pressure/density);
}
__host__ __device__ __host__ inline void compute_flux_contribution(float& density, float3& momentum, float& density_energy, float& pressure, float3& velocity, float3& fc_momentum_x, float3& fc_momentum_y, float3& fc_momentum_z, float3& fc_density_energy)
{
	fc_momentum_x.x = velocity.x*momentum.x + pressure;
	fc_momentum_x.y = velocity.x*momentum.y;
	fc_momentum_x.z = velocity.x*momentum.z;
	
	
	fc_momentum_y.x = fc_momentum_x.y;
	fc_momentum_y.y = velocity.y*momentum.y + pressure;
	fc_momentum_y.z = velocity.y*momentum.z;

	fc_momentum_z.x = fc_momentum_x.z;
	fc_momentum_z.y = fc_momentum_y.z;
	fc_momentum_z.z = velocity.z*momentum.z + pressure;

	float de_p = density_energy+pressure;
	fc_density_energy.x = velocity.x*de_p;
	fc_density_energy.y = velocity.y*de_p;
	fc_density_energy.z = velocity.z*de_p;
}

void check_cfd(int nelr, int* elements_surrounding_elements, float*
    normals, float* density, float* mx, float* my, float* mz, float* density_energy, float* fluxes)
    {
      const float smoothing_coefficient = float(0.2f);
	//const int i = (blockDim.x*blockIdx.x + threadIdx.x);
	for(int i=0;i<cfd_NBLOCKS*cfd_BLOCK_SIZE;i++){
	int j, nb;
	float3 normal; float normal_len;
	float factor;
	
	//float density_i = variables[i + VAR_DENSITY*nelr];  
	float density_i = density[i];
	float3 momentum_i;
	//momentum_i.x = variables[i + (VAR_MOMENTUM+0)*nelr];
	//momentum_i.y = variables[i + (VAR_MOMENTUM+1)*nelr];
	//momentum_i.z = variables[i + (VAR_MOMENTUM+2)*nelr];
  momentum_i.x = mx[i];
  momentum_i.y = my[i];
  momentum_i.z = mz[i];

	//float density_energy_i = variables[i + VAR_DENSITY_ENERGY*nelr];
	float density_energy_i = density_energy[i];

	float3 velocity_i;             				compute_velocity(density_i, momentum_i, velocity_i);
	float speed_sqd_i                          = compute_speed_sqd(velocity_i);
	float speed_i                              = sqrtf(speed_sqd_i);
	float pressure_i                           = compute_pressure(density_i, density_energy_i, speed_sqd_i);
	float speed_of_sound_i                     = compute_speed_of_sound(density_i, pressure_i);
	float3 flux_contribution_i_momentum_x, flux_contribution_i_momentum_y, flux_contribution_i_momentum_z;
	float3 flux_contribution_i_density_energy;	
	compute_flux_contribution(density_i, momentum_i, density_energy_i, pressure_i, velocity_i, flux_contribution_i_momentum_x, flux_contribution_i_momentum_y, flux_contribution_i_momentum_z, flux_contribution_i_density_energy);
	
	//float flux_i_density = float(0.0f);
	float flux_i_density = 0.0;
	float3 flux_i_momentum;
	flux_i_momentum.x = float(0.0f);
	flux_i_momentum.y = float(0.0f);
	flux_i_momentum.z = float(0.0f);
	float flux_i_density_energy = float(0.0f);
		
	float3 velocity_nb;
	float density_nb, density_energy_nb;
	float3 momentum_nb;
	float3 flux_contribution_nb_momentum_x, flux_contribution_nb_momentum_y, flux_contribution_nb_momentum_z;
	float3 flux_contribution_nb_density_energy;	
	float speed_sqd_nb, speed_of_sound_nb, pressure_nb;
	
	#pragma unroll
	for(j = 0; j < cfd_maxNeighbors; j++)
	{
		nb = elements_surrounding_elements[i + j*nelr];
    //optimal layout already 
    // |X for neighbor 0, X for neighbor 1, ... | Y for neighbor 0, Y for neighbor 1, ...
    // |Z for neighbor 0, Z for neighbor 1, ... |
		normal.x = normals[i + (j + 0*cfd_maxNeighbors)*nelr]; 
		normal.y = normals[i + (j + 1*cfd_maxNeighbors)*nelr];
		normal.z = normals[i + (j + 2*cfd_maxNeighbors)*nelr];
		normal_len = sqrtf(normal.x*normal.x + normal.y*normal.y + normal.z*normal.z);
		
		if(nb >= 0) 	// a legitimate neighbor
		{
			//density_nb = variables[nb + VAR_DENSITY*nelr];
			//momentum_nb.x = variables[nb + (VAR_MOMENTUM+0)*nelr];
			//momentum_nb.y = variables[nb + (VAR_MOMENTUM+1)*nelr];
			//momentum_nb.z = variables[nb + (VAR_MOMENTUM+2)*nelr];
			density_nb = density[nb];
			momentum_nb.x = mx[nb];
			momentum_nb.y = my[nb];
			momentum_nb.z = mz[nb];
			//density_energy_nb = variables[nb + VAR_DENSITY_ENERGY*nelr];
			density_energy_nb = density_energy[nb];
												compute_velocity(density_nb, momentum_nb, velocity_nb);
			speed_sqd_nb                      = compute_speed_sqd(velocity_nb);
			pressure_nb                       = compute_pressure(density_nb, density_energy_nb, speed_sqd_nb);
			speed_of_sound_nb                 = compute_speed_of_sound(density_nb, pressure_nb);
			                                    compute_flux_contribution(density_nb, momentum_nb, density_energy_nb, pressure_nb, velocity_nb, flux_contribution_nb_momentum_x, flux_contribution_nb_momentum_y, flux_contribution_nb_momentum_z, flux_contribution_nb_density_energy);
			
			// artificial viscosity
			//factor = -normal_len*smoothing_coefficient*float(0.5f)*(speed_i + sqrtf(speed_sqd_nb) + speed_of_sound_i + speed_of_sound_nb);
      factor = 1.3;
			flux_i_density += factor*(density_i-density_nb);
			flux_i_density_energy += factor*(density_energy_i-density_energy_nb);
			flux_i_momentum.x += factor*(momentum_i.x-momentum_nb.x);
			flux_i_momentum.y += factor*(momentum_i.y-momentum_nb.y);
			flux_i_momentum.z += factor*(momentum_i.z-momentum_nb.z);

			// accumulate cell-centered fluxes
			factor = float(0.5f)*normal.x;
			flux_i_density += factor*(momentum_nb.x+momentum_i.x);
			flux_i_density_energy += factor*(flux_contribution_nb_density_energy.x+flux_contribution_i_density_energy.x);
			flux_i_momentum.x += factor*(flux_contribution_nb_momentum_x.x+flux_contribution_i_momentum_x.x);
			flux_i_momentum.y += factor*(flux_contribution_nb_momentum_y.x+flux_contribution_i_momentum_y.x);
			flux_i_momentum.z += factor*(flux_contribution_nb_momentum_z.x+flux_contribution_i_momentum_z.x);
			
			factor = float(0.5f)*normal.y;
			flux_i_density += factor*(momentum_nb.y+momentum_i.y);
			flux_i_density_energy += factor*(flux_contribution_nb_density_energy.y+flux_contribution_i_density_energy.y);
			flux_i_momentum.x += factor*(flux_contribution_nb_momentum_x.y+flux_contribution_i_momentum_x.y);
			flux_i_momentum.y += factor*(flux_contribution_nb_momentum_y.y+flux_contribution_i_momentum_y.y);
			flux_i_momentum.z += factor*(flux_contribution_nb_momentum_z.y+flux_contribution_i_momentum_z.y);
			
			factor = float(0.5f)*normal.z;
			flux_i_density += factor*(momentum_nb.z+momentum_i.z);
			flux_i_density_energy += factor*(flux_contribution_nb_density_energy.z+flux_contribution_i_density_energy.z);
			flux_i_momentum.x += factor*(flux_contribution_nb_momentum_x.z+flux_contribution_i_momentum_x.z);
			flux_i_momentum.y += factor*(flux_contribution_nb_momentum_y.z+flux_contribution_i_momentum_y.z);
			flux_i_momentum.z += factor*(flux_contribution_nb_momentum_z.z+flux_contribution_i_momentum_z.z);
		}
	}

		/*if(((pow((fluxes[i + VAR_DENSITY*nelr] - flux_i_density),2)/flux_i_density)>0.001)||\
          ((pow((fluxes[i + (VAR_MOMENTUM+0)*nelr] - flux_i_momentum.x),2)/flux_i_momentum.x)>0.001)||\
          ((pow((fluxes[i + (VAR_MOMENTUM+1)*nelr] - flux_i_momentum.y),2)/flux_i_momentum.y)>0.001)||\
          ((pow((fluxes[i + (VAR_MOMENTUM+2)*nelr] - flux_i_momentum.z),2)/flux_i_momentum.z)>0.001)||\
          ((pow((fluxes[i + VAR_DENSITY_ENERGY*nelr]- flux_i_density_energy),2)/flux_i_density_energy)>0.001))*/
          
     if(((abs((fluxes[i + VAR_DENSITY*nelr] - flux_i_density)/flux_i_density)>0.01)&&(abs((fluxes[i + VAR_DENSITY*nelr] - flux_i_density))>0.01))||\
                  ((abs((fluxes[i + (VAR_MOMENTUM+0)*nelr] - flux_i_momentum.x)/flux_i_momentum.x)>0.01)&&(abs((fluxes[i + (VAR_MOMENTUM+0)*nelr] - flux_i_momentum.x))>0.01))||\
          ((abs((fluxes[i + (VAR_MOMENTUM+1)*nelr] - flux_i_momentum.y)/flux_i_momentum.y)>0.01)&&(abs((fluxes[i + (VAR_MOMENTUM+1)*nelr] - flux_i_momentum.y))>0.01))||\
          ((abs((fluxes[i + (VAR_MOMENTUM+2)*nelr] - flux_i_momentum.z)/flux_i_momentum.z)>0.01)&&(abs((fluxes[i + (VAR_MOMENTUM+2)*nelr] - flux_i_momentum.z))>0.01))||\
          ((abs((fluxes[i + VAR_DENSITY_ENERGY*nelr]- flux_i_density_energy)/flux_i_density_energy)>0.01)&&(abs((fluxes[i + VAR_DENSITY_ENERGY*nelr]- flux_i_density_energy))>0.01)))
              {printf("failed!%d,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f\n",i,fluxes[i + VAR_DENSITY*nelr],flux_i_density,\
                                                                 fluxes[i + (VAR_MOMENTUM+0)*nelr],flux_i_momentum.x,\
                                                                 fluxes[i + (VAR_MOMENTUM+1)*nelr] , flux_i_momentum.y,\
                                                                 fluxes[i + (VAR_MOMENTUM+2)*nelr],flux_i_momentum.z,\
                                                                 fluxes[i + VAR_DENSITY_ENERGY*nelr],flux_i_density_energy);
	       return;} 
	 }
	 printf("GOOD! passed!\n");
	 return;
  }
__global__ void cfd_kernel(int nelr,int* elements_surrounding_elements, const float*  
    normals, const float* __restrict__ density,  float*  mx, float* my, float*  mz, float* density_energy, float* fluxes)
{
	const float smoothing_coefficient = float(0.2f);
	const int i = (blockDim.x*blockIdx.x + threadIdx.x);
	
	int j, nb;
	float3 normal; float normal_len;
	float factor;
	
	//float density_i = variables[i + VAR_DENSITY*nelr];  
	float density_i = density[i];
	float3 momentum_i;
	//momentum_i.x = variables[i + (VAR_MOMENTUM+0)*nelr];
	//momentum_i.y = variables[i + (VAR_MOMENTUM+1)*nelr];
	//momentum_i.z = variables[i + (VAR_MOMENTUM+2)*nelr];
  momentum_i.x = tex1Dfetch(tex_mx,i);//mx[i];
  momentum_i.y = tex1Dfetch(tex_my,i);//my[i];
  momentum_i.z = tex1Dfetch(tex_mz,i); //mz[i];

	//float density_energy_i = variables[i + VAR_DENSITY_ENERGY*nelr];
	float density_energy_i = tex1Dfetch(tex_energy,i);//density_energy[i];

	float3 velocity_i;             				compute_velocity(density_i, momentum_i, velocity_i);
	float speed_sqd_i                          = compute_speed_sqd(velocity_i);
	float speed_i                              = sqrtf(speed_sqd_i);
	float pressure_i                           = compute_pressure(density_i, density_energy_i, speed_sqd_i);
	float speed_of_sound_i                     = compute_speed_of_sound(density_i, pressure_i);
	float3 flux_contribution_i_momentum_x, flux_contribution_i_momentum_y, flux_contribution_i_momentum_z;
	float3 flux_contribution_i_density_energy;	
	compute_flux_contribution(density_i, momentum_i, density_energy_i, pressure_i, velocity_i, flux_contribution_i_momentum_x, flux_contribution_i_momentum_y, flux_contribution_i_momentum_z, flux_contribution_i_density_energy);
	
	//float flux_i_density = float(0.0f);
	float flux_i_density = 0.0;
	float3 flux_i_momentum;
	flux_i_momentum.x = float(0.0f);
	flux_i_momentum.y = float(0.0f);
	flux_i_momentum.z = float(0.0f);
	float flux_i_density_energy = float(0.0f);
		
	float3 velocity_nb;
	float density_nb, density_energy_nb;
	float3 momentum_nb;
	float3 flux_contribution_nb_momentum_x, flux_contribution_nb_momentum_y, flux_contribution_nb_momentum_z;
	float3 flux_contribution_nb_density_energy;	
	float speed_sqd_nb, speed_of_sound_nb, pressure_nb;
	
	#pragma unroll
	for(j = 0; j < cfd_maxNeighbors; j++)
	{
		nb = tex1Dfetch(tex_neighbor,i+j*nelr);//elements_surrounding_elements[i + j*nelr];
    //optimal layout already 
    // |X for neighbor 0, X for neighbor 1, ... | Y for neighbor 0, Y for neighbor 1, ...
    // |Z for neighbor 0, Z for neighbor 1, ... |
		normal.x = tex1Dfetch(tex_normals,i + (j + 0*cfd_maxNeighbors)*nelr);//normals[i + (j + 0*cfd_maxNeighbors)*nelr]; 
		normal.y = tex1Dfetch(tex_normals,i + (j + 1*cfd_maxNeighbors)*nelr);//normals[i + (j + 1*cfd_maxNeighbors)*nelr];
		normal.z = tex1Dfetch(tex_normals,i + (j + 2*cfd_maxNeighbors)*nelr);//normals[i + (j + 2*cfd_maxNeighbors)*nelr];
		normal_len = sqrtf(normal.x*normal.x + normal.y*normal.y + normal.z*normal.z);
		
		if(nb >= 0) 	// a legitimate neighbor
		{
			//density_nb = variables[nb + VAR_DENSITY*nelr];
			//momentum_nb.x = variables[nb + (VAR_MOMENTUM+0)*nelr];
			//momentum_nb.y = variables[nb + (VAR_MOMENTUM+1)*nelr];
			//momentum_nb.z = variables[nb + (VAR_MOMENTUM+2)*nelr];
			density_nb = density[nb];
			momentum_nb.x = tex1Dfetch(tex_mx,nb);//mx[nb];
			momentum_nb.y = tex1Dfetch(tex_my,nb);//my[nb];
			momentum_nb.z = tex1Dfetch(tex_mz,nb);//mz[nb];
			//density_energy_nb = variables[nb + VAR_DENSITY_ENERGY*nelr];
			density_energy_nb = tex1Dfetch(tex_energy,nb);//density_energy[nb];
												compute_velocity(density_nb, momentum_nb, velocity_nb);
			speed_sqd_nb                      = compute_speed_sqd(velocity_nb);
			pressure_nb                       = compute_pressure(density_nb, density_energy_nb, speed_sqd_nb);
			speed_of_sound_nb                 = compute_speed_of_sound(density_nb, pressure_nb);
			                                    compute_flux_contribution(density_nb, momentum_nb, density_energy_nb, pressure_nb, velocity_nb, flux_contribution_nb_momentum_x, flux_contribution_nb_momentum_y, flux_contribution_nb_momentum_z, flux_contribution_nb_density_energy);
			
			// artificial viscosity
			//factor = -normal_len*smoothing_coefficient*float(0.5f)*(speed_i + sqrtf(speed_sqd_nb) + speed_of_sound_i + speed_of_sound_nb);
      factor = 1.3;
			flux_i_density += factor*(density_i-density_nb);
			flux_i_density_energy += factor*(density_energy_i-density_energy_nb);
			flux_i_momentum.x += factor*(momentum_i.x-momentum_nb.x);
			flux_i_momentum.y += factor*(momentum_i.y-momentum_nb.y);
			flux_i_momentum.z += factor*(momentum_i.z-momentum_nb.z);

			// accumulate cell-centered fluxes
			factor = float(0.5f)*normal.x;
			flux_i_density += factor*(momentum_nb.x+momentum_i.x);
			flux_i_density_energy += factor*(flux_contribution_nb_density_energy.x+flux_contribution_i_density_energy.x);
			flux_i_momentum.x += factor*(flux_contribution_nb_momentum_x.x+flux_contribution_i_momentum_x.x);
			flux_i_momentum.y += factor*(flux_contribution_nb_momentum_y.x+flux_contribution_i_momentum_y.x);
			flux_i_momentum.z += factor*(flux_contribution_nb_momentum_z.x+flux_contribution_i_momentum_z.x);
			
			factor = float(0.5f)*normal.y;
			flux_i_density += factor*(momentum_nb.y+momentum_i.y);
			flux_i_density_energy += factor*(flux_contribution_nb_density_energy.y+flux_contribution_i_density_energy.y);
			flux_i_momentum.x += factor*(flux_contribution_nb_momentum_x.y+flux_contribution_i_momentum_x.y);
			flux_i_momentum.y += factor*(flux_contribution_nb_momentum_y.y+flux_contribution_i_momentum_y.y);
			flux_i_momentum.z += factor*(flux_contribution_nb_momentum_z.y+flux_contribution_i_momentum_z.y);
			
			factor = float(0.5f)*normal.z;
			flux_i_density += factor*(momentum_nb.z+momentum_i.z);
			flux_i_density_energy += factor*(flux_contribution_nb_density_energy.z+flux_contribution_i_density_energy.z);
			flux_i_momentum.x += factor*(flux_contribution_nb_momentum_x.z+flux_contribution_i_momentum_x.z);
			flux_i_momentum.y += factor*(flux_contribution_nb_momentum_y.z+flux_contribution_i_momentum_y.z);
			flux_i_momentum.z += factor*(flux_contribution_nb_momentum_z.z+flux_contribution_i_momentum_z.z);
		}
	}

	fluxes[i + VAR_DENSITY*nelr] = flux_i_density;
	fluxes[i + (VAR_MOMENTUM+0)*nelr] = flux_i_momentum.x;
	fluxes[i + (VAR_MOMENTUM+1)*nelr] = flux_i_momentum.y;
	fluxes[i + (VAR_MOMENTUM+2)*nelr] = flux_i_momentum.z;
	fluxes[i + VAR_DENSITY_ENERGY*nelr] = flux_i_density_energy;
//if (threadIdx.x==0) atomicAdd(d_flag,1);
}

int main(int argc, char **argv) {
  cudaSetDevice(2);
  srand(2013);
  // Allocate problem data on host
  //posVecType*   position;
  //forceVecType* force;
  float *density;
  float *mx;
  float *my;
  float *mz;
  float *density_energy;
  float *normals;
  float *fluxes;
  int* cfd_neighborList;

  cudaMallocHost((void**)&density, cfd_nAtom*sizeof(float));
  cudaMallocHost((void**)&mx, cfd_nAtom*sizeof(float));
  cudaMallocHost((void**)&my, cfd_nAtom*sizeof(float));
  cudaMallocHost((void**)&mz, cfd_nAtom*sizeof(float));
  cudaMallocHost((void**)&density_energy, cfd_nAtom*sizeof(float));
  cudaMallocHost((void**)&normals, cfd_nAtom*NDIM*cfd_maxNeighbors*sizeof(float));
  cudaMallocHost((void**)&fluxes, cfd_nAtom*NVAR*sizeof(float));
  cudaMallocHost((void**)&cfd_neighborList, cfd_nAtom*cfd_maxNeighbors*sizeof(int));

  // Allocate device memory for position and force
  //forceVecType* d_force;
  //posVecType*   d_position;
  float *d_density;
  float *d_mx;
  float *d_my;
  float *d_mz;
  float *d_density_energy;
  float *d_normals;
  float *d_fluxes;
  cudaMalloc((void**)&d_density, cfd_nAtom*sizeof(float));
  cudaMalloc((void**)&d_mx, cfd_nAtom*sizeof(float));
  cudaMalloc((void**)&d_my, cfd_nAtom*sizeof(float));
  cudaMalloc((void**)&d_mz, cfd_nAtom*sizeof(float));
  cudaMalloc((void**)&d_density_energy, cfd_nAtom*sizeof(float));
  cudaMalloc((void**)&d_normals, cfd_nAtom*NDIM*cfd_maxNeighbors*sizeof(float));
  cudaMalloc((void**)&d_fluxes, cfd_nAtom*NVAR*sizeof(float));
  cudaMemset(d_fluxes, 0, cfd_nAtom*NVAR*sizeof(float));
  //cudaMemset(d_force, 0, cfd_nAtom*sizeof(forceVecType));

  // Allocate device memory for neighbor list
  int* d_cfd_neighborList;
  cudaMalloc((void**)&d_cfd_neighborList, cfd_nAtom*cfd_maxNeighbors*sizeof(int));

  //cout << "Initializing test problem (this can take several "
   //       "minutes for large problems)\n";

  // Initialize positions -- random distribution in cubic domain
  // domainEdge constant specifies edge length
  for (int i = 0; i < cfd_nAtom; i++)
  {
      density[i] = (float)(drand48());
      density_energy[i] = (float)(drand48() );
      mx[i] = (float)(drand48() );
      my[i] = (float)(drand48() );
      mz[i] = (float)(drand48() );
    /*
      density[i] = 1.1+i*0.01;

      density_energy[i] = 1.1+i*0.01;
      mx[i] = 1.1+i*0.01;
      my[i] = 1.1+i*0.01;
      mz[i] = 1.1+i*0.01;
      */
  }
  for(int i=0; i<cfd_nAtom*NDIM*cfd_maxNeighbors; ++i)
    normals[i] = (float)(drand48());

  cfd_myBuildNeighborList_blkSchedule(cfd_nAtom, cfd_neighborList, cfd_BLOCK_SIZE);

  cudaMemcpy(d_cfd_neighborList, cfd_neighborList, cfd_maxNeighbors*cfd_nAtom*sizeof(int), cudaMemcpyHostToDevice);
  // Copy data to GPU
  cudaMemcpy(d_density, density, cfd_nAtom*sizeof(float), cudaMemcpyHostToDevice);
  cudaMemcpy(d_mx, mx, cfd_nAtom*sizeof(float), cudaMemcpyHostToDevice);
  cudaMemcpy(d_my, my, cfd_nAtom*sizeof(float), cudaMemcpyHostToDevice);
  cudaMemcpy(d_mz, mz, cfd_nAtom*sizeof(float), cudaMemcpyHostToDevice);
  cudaMemcpy(d_density_energy, density_energy, cfd_nAtom*sizeof(float), cudaMemcpyHostToDevice);
  cudaMemcpy(d_normals, normals, cfd_nAtom*NDIM*cfd_maxNeighbors*sizeof(float), cudaMemcpyHostToDevice);
cudaSetDeviceFlags(cudaDeviceMapHost);
  int *flag_cfd,*d_flag_cfd;
  cudaHostAlloc((void**)&flag_cfd,sizeof( int),cudaHostAllocMapped);
  cudaHostGetDevicePointer((void**)&d_flag_cfd,(void*)flag_cfd,0);
 
 cudaBindTexture(0,tex_mx,d_mx,cfd_nAtom*sizeof(float));
  cudaBindTexture(0,tex_my,d_my,cfd_nAtom*sizeof(float));
 cudaBindTexture(0,tex_mz,d_mz,cfd_nAtom*sizeof(float));   
 cudaBindTexture(0,tex_energy,d_density_energy,cfd_nAtom*sizeof(float)); 
 cudaBindTexture(0,tex_density,d_density,cfd_nAtom*sizeof(float));
  cudaBindTexture(0,tex_neighbor,d_cfd_neighborList,cfd_maxNeighbors*cfd_nAtom*sizeof(int));
  cudaBindTexture(0,tex_normals,d_normals,cfd_nAtom*NDIM*cfd_maxNeighbors*sizeof(float));
cudaEvent_t kernel_start, kernel_stop;
  cudaEventCreate(&kernel_start);
  cudaEventCreate(&kernel_stop);
  float kernel_time = 0.0f;

  cudaEventRecord(kernel_start, 0);

  int cfd_gridSize  = (cfd_nAtom-1+cfd_BLOCK_SIZE) / cfd_BLOCK_SIZE;

  cfd_kernel<<<cfd_gridSize, cfd_BLOCK_SIZE>>>(cfd_nAtom, d_cfd_neighborList, d_normals, d_density, d_mx, d_my, d_mz, d_density_energy,
      d_fluxes);


  cudaDeviceSynchronize();

  cudaEventRecord(kernel_stop, 0);
  cudaEventSynchronize(kernel_stop);

  // get elapsed time
  kernel_time = 0.0f;
  cudaEventElapsedTime(&kernel_time, kernel_start, kernel_stop);
  kernel_time *= 1.e-3; // Convert to seconds
  
  cout << "kernel exe time: " << kernel_time << endl;

  cudaMemcpy(fluxes, d_fluxes, cfd_nAtom*NVAR*sizeof(float), cudaMemcpyDeviceToHost);
  check_cfd(cfd_nAtom,cfd_neighborList,normals,density,mx,my,mz,density_energy,fluxes);
  
  //TODO:verified on small inputs
  /*
  ifstream fluxesF("../org/fluxes.txt");
  for(int i=0; i<cfd_nAtom*NVAR; ++i) {
    float f;
    fluxesF >> f;
    if(abs(f - fluxes[i]) > 0.001) {
      fprintf(stderr, "Test failed! i = %d\n", i);
      return 1;
    }
  }*/
 // printf("Test passed!\n");
 // fluxesF.close();


  return 0;
}

