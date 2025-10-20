#include <stdio.h>
#include "microtime.h"
#include <stdlib.h>



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

  // You must allocate suitably aligned memory unlike this code
  A = (float *) malloc(N*sizeof(A[0])); 
  
  if(A==0)
    {
      fprintf(stderr, "Memory allocation failed in file %s, line %d\n", __FILE__, __LINE__);
      exit(1);
    }

  time1 = microtime();

  a = 2;

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
