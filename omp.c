#include <stdio.h>
#include "microtime.h"
#include <stdlib.h>
#include <omp.h>

int main(int argc, char **argv)
{
  int N, i, j;
  long long int a; // Changed to long long int to prevent overflow
  float *A=0, x;
  double t, time1, time2;
  int NThreads = 1;
  
  if(argc != 3)
  {
    fprintf(stderr, "USAGE: %s Size NumberOfThreads\n", argv[0]);
    exit(1);
  }
  
  N = atoi(argv[1]);
  NThreads = atoi(argv[2]);
  
  omp_set_num_threads(NThreads);

  A = (float *) aligned_alloc(64, N*sizeof(float));
  
  if(A==0)
  {
    fprintf(stderr, "Memory allocation failed in file %s, line %d\n", __FILE__, __LINE__);
    exit(1);
  }

  time1 = microtime();

  a = 2LL; // Use LL for long long literals

  // Using a static schedule because the overhead of dynamic/guided was too high
  // for the very fast inner loop, as determined by previous performance tests.
  #pragma omp parallel for schedule(static) private(j, x) reduction(+:a)
  for(i=0; i < N; i++) 
  { 
    a += 2LL * i;
    for(j = 0; j < i; j++)
    {
      x = 1.0f/(i+j+1.0f);
      A[i] = x + 1.0f;
    }
  }
  
  time2 = microtime();
  
  t = time2-time1;
  // Use %lld to print the long long int for 'a'
  printf("\nTime = %g us\tN = %d\tNThreads = %d\n", t * 1e6, N, NThreads);
  printf("A[N/2] = %g\ta = %lld\n\n", (double) A[N/2], a);

  free(A);

  return 0;
}

