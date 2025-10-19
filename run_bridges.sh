#!/bin/bash
#SBATCH --job-name=MT_homework
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=16
#SBATCH --time=01:00:00
#SBATCH --partition=RM-shared
#SBATCH --output=mt_output_%j.txt

# Print job information
echo "================================================================"
echo "Job ID: $SLURM_JOB_ID"
echo "Job started on $(date)"
echo "Running on node: $(hostname)"
echo "Number of CPUs allocated: $SLURM_CPUS_PER_TASK"
echo "================================================================"
echo ""

# Load required modules
module load gcc/10.2.0
module list
echo ""

# Compile the codes
echo "=== Compiling codes ==="
make clean
make all
echo ""

# Verify compilation
if [ ! -f omp ] || [ ! -f madd-opt ]; then
    echo "ERROR: Compilation failed!"
    exit 1
fi
echo "Compilation successful!"
echo ""

# Run OpenMP code with different thread counts
echo "================================================================"
echo "=== OpenMP Strong Scaling Test ==="
echo "================================================================"
echo ""

N=10000
for threads in 1 2 4 8 16
do
    if [ $threads -le $SLURM_CPUS_PER_TASK ]; then
        echo "Running with $threads threads (N=$N):"
        time ./omp $N $threads
        echo ""
    fi
done

echo "================================================================"
echo "=== Matrix Addition Performance Test ==="
echo "================================================================"
echo ""

# Run matrix addition with different sizes
for size in 256 512 1024 2048
do
    echo "Matrix size: ${size}x${size}"
    time ./madd-opt $size
    echo ""
done

echo "================================================================"
echo "Job completed on $(date)"
echo "================================================================"