#include <stdio.h>
#include <stdlib.h>
#include <omp.h>
#include "microtime.h" // Assuming microtime.h is in the same directory or in the include path

int main(int argc, char **argv)
{
  int N, i, a, j;
  float *A = 0, x;
  double t, time1, time2;
  int NThreads = 1;

  if (argc != 3)
  {
    fprintf(stderr, "USAGE: %s Size NumberOfThreads\n", argv[0]);
    exit(1);
  }

  N = atoi(argv[1]);
  NThreads = atoi(argv[2]);

  // Set the number of OpenMP threads
  omp_set_num_threads(NThreads);

  // Allocate memory for array A with 64-byte alignment to match cache line size.
  A = (float *)aligned_alloc(64, N * sizeof(float));

  if (A == 0)
  {
    fprintf(stderr, "Memory allocation failed in file %s, line %d\n", __FILE__, __LINE__);
    exit(1);
  }

  time1 = microtime();

  a = 2;

  #pragma omp parallel for schedule(guided, 16) private(j, x) reduction(+:a)
  for (i = 0; i < N; i++)
  {
    a += 2 * i;
    for (j = 0; j < i; j++)
    {
      x = 1.0 / (i + j + 1.0);
      A[i] = x + 1.0;
    }
  }

  time2 = microtime();

  t = time2 - time1;
  printf("\nTime = %g us\tN = %d\tNThreads = %d\n", t, N, NThreads);
  printf("A[N/2] = %g\ta = %d\n\n", (double)A[N / 2], a);

  free(A);

  return 0;
}

