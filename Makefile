CC = gcc
CFLAGS = -O3 -march=native -fopenmp -Wall
LIBS = -lm

# Default target
all: omp madd-opt

# Rule for omp
omp: omp.o microtime.o
	$(CC) $(CFLAGS) -o omp omp.o microtime.o $(LIBS)

# Rule for madd-opt, now correctly linking microtime.o
madd-opt: madd-opt.o microtime.o
	$(CC) $(CFLAGS) -o madd-opt madd-opt.o microtime.o $(LIBS)

# A pattern rule that tells 'make' how to compile any .c file into a .o (object) file.
# The -c flag tells gcc to compile but not link.
%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

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


