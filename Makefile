CC = gcc
# Path to microtime.h
CFLAGS = -O3 -march=native -fopenmp -Wall $(INCLUDE_PATH)
LIBS = -lm

all: omp madd-opt



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