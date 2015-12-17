Diff-analysis of Matrix Multiplication Benchmarks.
PATH: /home/ychuang/benchmark/GPU-DATA-PLACEMENT/MM
Original benchmark: mm.cu
Usuage:
        nvcc mm.cu -o mm -arch=sm_20
Summary:
•	mm.cu is the original benchmark to compute the product of two matrices, A*B.
        it uses shared memory to served as temporary space to reduce global memory access. 
        A [] [] & B [] [] -> global memory
        As [] [] & Bs [] [] -> shared memory
•	1.cu ~ 9.cu are based on mm.cu, which means that they also use shared memory. 
        The differences are that A[][] & B[][] could be put  in texture memory instead of global memory.
        kernel 1 to 9 are combinations of different combinations of texture memory and global memory usage.
        e.g. A [] [] -> tex2D, B [] [] -> global
             A [] [] -> global, b[] []-> tex1Dfetch
•	0.cu is the non-optimize GPU kernel. 
        no shared memory be used, global memory only.
•	mm_cpu_1.cu   Serial code -> C language only
       mm_cpu.cu     OpenMP version
•	The other differences are matrix size and block sizes, not a big problem.
Profiling suggestion:
1.	Set the same matrix sizes and block sizes.
2.	Take 0.cu, mm.cu and 1.cu as our profiling candidates. They cover three different data-placement cases, which are global memory only, global-shared memory and texture-shared memory, respectively. (2-9.cu share too many similarities.)

	   
Details:
########################Matrix Multiplication Benchmarks############################################

Matrix element initiated with random floating number.
Compare the GPU result with CPU result.

####################################################################################################
mm.cu : original matrix muliplication file
A: 384*384
B: 384*384

grid size: 48*48
block size: 32*32
Use shared memory: frequent used data be placed in shared memory
	global memory A[64][64],B[64][960]
	shared memory As[32][32]; Bs[32][32]

####################################################################################################
0.cu
A: 64*64
B: 64*960
grid size: 240*240
block size: 16*16
Global memory only:
	A[64][64]; B[64][960]
####################################################################################################
1.cu
A: 64*64
B: 64*960
grid size: 48*48
block size: 16*16
Use shared memory: frequent used data be placed in shared memory
	Texture memory(tex2D) A[64][64],B[64][960]
	shared memory As[32][32]; Bs[32][32]
	
texture<float,2,cudaReadModeElementType> tex_A;
texture<float,2,cudaReadModeElementType> tex_B;
texture<float,2,cudaReadModeElementType> tex_c;
####################################################################################################
2.cu
A: 64*64
B: 64*960
grid size: 48*48
block size: 16*16
Use shared memory: frequent used data be placed in shared memory
	Texture memory(tex2D) A[64][64],B[64][960]
	shared memory As[32][32]; Bs[32][32]
texture<float,2,cudaReadModeElementType> tex_A;
texture<float,2,cudaReadModeElementType> tex_B;
####################################################################################################
3.cu  //TODO
A: 128*128
B: 128*1920
grid size: 48*48
block size: 32*32
Use shared memory: frequent used data be placed in shared memory
	Texture memory(tex2D) A[64][64],B[64][960]
	shared memory As[32][32]; Bs[32][32]
texture<float,2,cudaReadModeElementType> tex_A;
texture<float,2,cudaReadModeElementType> tex_B;
####################################################################################################
texture<float,1,cudaReadModeElementType> tex_A;
tex1Dfetch VS tex2D

all  Use shared memory: frequent used data be placed in shared memory


####################################################################################################
7 overhead

float _temp1,_temp2;
if(gotoGlobal[0]==0)
	_temp1=A[a+wA*ty+tx];
else if(gotoGlobal[0]==1)
	_temp1= tex1Dfetch(tex_A,a+wA*ty+tx);
else if(gotoGlobal[0]==3)
	_temp1= __ldg(&A[a+wA*ty+tx]);
if(gotoGlobal[1]==0)
	_temp2=B[b + wB * ty + tx];
else if(gotoGlobal[1]==1)
	_temp2= tex1Dfetch(tex_B,b + wB * ty + tx);
else if(gotoGlobal[1]==3)
	_temp2= __ldg(&B[b + wB * ty + tx]);
    AS(ty, tx) = _temp1;//tex1Dfetch(tex_A,a+wA*ty+tx);
    BS(ty, tx) =_temp2;//tex1Dfetch(tex_B, b + wB * ty
####################################################################################################
mm_cpu.cu
use openmp kernel to simulation mm.cu
####################################################################################################
mm_cpu_1.cu
mm_cpu.cu 's non-openmp version

####################################################################################################
mm_index.cu
atomicAdd index
####################################################################################################
mm_prof.cu
get thread id
####################################################################################################
read_mm vs mm 
AS(ty, tx) = __ldg(&A[a + wA * ty + tx]);
    BS(ty, tx) = __ldg(&B[b + wB * ty + tx]);
####################################################################################################

