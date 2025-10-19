CC = gcc
# Path to microtime.h
INCLUDE_PATH = -I/home/tjk12/cop5522/Code
CFLAGS = -O3 -march=native -fopenmp -Wall $(INCLUDE_PATH)
LIBS = -lm

all: omp madd-opt

omp: omp.c
	$(CC) $(CFLAGS) -o omp omp.c $(LIBS)

madd-opt: madd-opt.c
	$(CC) $(CFLAGS) -o madd-opt madd-opt.c $(LIBS)

clean:
	rm -f omp madd-opt *.o

test: all
	@echo "=== Testing OpenMP code ==="
	./omp 10000 1
	@echo ""
	./omp 10000 4
	@echo ""
	@echo "=== Testing Matrix Addition ==="
	./madd-opt 512
	@echo ""
	./madd-opt 1024