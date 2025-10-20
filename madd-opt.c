#include <stdio.h>
#include "microtime.h"
#include <string.h>
#include <stdlib.h>
#include <immintrin.h>  // AVX intrinsics

#define TILE_SIZE 64  // Tile size for blocking

int main(int argc, char **argv)
{
  int N, i, j, ii, jj;
  double *A, *B, *C, result=0.0;
  double time1, time2;
  
  if(argc != 2)
  {
    fprintf(stderr, "USAGE: %s Matrix-Dimension\n", argv[0]);
    exit(1);
  }
  
  N = atoi(argv[1]);
  if(N <= 0)
  {
    fprintf(stderr, "N = %d should be positive\n", N);
    exit(2);
  }    
  
  // Allocate memory with 64B alignment for AVX operations
  A = (double *) aligned_alloc(64, N*N*sizeof(double));
  B = (double *) aligned_alloc(64, N*N*sizeof(double));
  C = (double *) aligned_alloc(64, N*N*sizeof(double));

  if(A==0 || B==0 || C==0)
  {
    fprintf(stderr, "Memory allocation failed in file %s, line %d\n", __FILE__, __LINE__);
    exit(1);
  }

  memset(C, 0, N*N*sizeof(C[0]));
  
  for(i=0; i<N; i++)
    for(j=0; j<N; j++)
      A[i*N+j] = B[i*N+j] = 0.1;
  
  time1 = microtime();

  // Optimized matrix addition with tiling and AVX
  // Outer loops: tile the matrix into TILE_SIZE x TILE_SIZE blocks
  for(ii=0; ii<N; ii+=TILE_SIZE)
  {
    for(jj=0; jj<N; jj+=TILE_SIZE)
    {
      // Inner loops: process each tile
      int i_end = (ii + TILE_SIZE < N) ? ii + TILE_SIZE : N;
      int j_end = (jj + TILE_SIZE < N) ? jj + TILE_SIZE : N;
      
      for(i=ii; i<i_end; i++)
      {
        j = jj;
        
        // Process 4 doubles at a time using AVX (256-bit = 4 x 64-bit doubles)
        for(; j + 3 < j_end; j+=4)
        {
          int idx = i*N+j;
          
          // Load 4 doubles from A and B
          __m256d a_vec = _mm256_load_pd(&A[idx]);
          __m256d b_vec = _mm256_load_pd(&B[idx]);
          __m256d c_vec = _mm256_load_pd(&C[idx]);
          
          // Perform addition: C = C + A + B
          c_vec = _mm256_add_pd(c_vec, _mm256_add_pd(a_vec, b_vec));
          
          // Store result
          _mm256_store_pd(&C[idx], c_vec);
        }
        
        // Handle remaining elements (scalar)
        for(; j<j_end; j++)
        {
          C[i*N+j] += A[i*N+j] + B[i*N+j];
        }
      }
    }
  }

  time2 = microtime();
  
  printf("Time = %g us\tTimer Resolution = %g us\tPerformance = %g Gflop/s\n", 
         time2-time1, get_microtime_resolution(), N*N*1e-3/(time2-time1));
  
  for(i=0; i<N; i++) /* Check correctness */
    for(j=0; j<N; j++)
      result += C[i*N+j];
  
  printf("Sum of matrix elements = %g\tExpected value = %g\n", result, (double) 0.2*N*N);
  
  free(A);
  free(B);
  free(C);
  
  return 0;
}