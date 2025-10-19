#include <stdio.h>
#include <microtime.h>
#include <stdlib.h>
#include <omp.h>  // Added for OpenMP

int main(int argc, char **argv)
{
  
  int N, i, a, j;
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

  // Allocate suitably aligned memory: cache line size 64B, float 4B, so align to 64B
  if (posix_memalign((void **)&A, 64, N * sizeof(float)) != 0) {
    fprintf(stderr, "Memory allocation failed in file %s, line %d\n", __FILE__, __LINE__);
    exit(1);
  }
  
  time1 = microtime();

  a = 2;

  // Parallelize the outer loop with reduction on 'a' to maintain correctness
  // Use guided schedule for load balancing (work per iteration ~O(i), so guided adapts chunk sizes)
  // and to avoid false sharing (larger initial chunks reduce cache line conflicts)
  #pragma omp parallel for num_threads(NThreads) reduction(+:a) private(x,j) schedule(guided)
  for(i=0; i < N; i++) 
    { 
      a += 2*i;
      for(j = 0; j < i; j++)
	{
	  x = 1.0/(i+j+1.0);
	  A[i] = x + 1.0;
	}
    }

  
  time2 = microtime();
  
  t = time2-time1;
  printf("\nTime = %g us\tN = %d\tNThreads = %d\n", t, N, NThreads);
  printf("A[N/2] = %g\ta = %d\n\n", (double) A[N/2], a);

  free(A);

  return 0;
}
