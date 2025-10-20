#!/bin/bash

# Script to run scaling tests on cs-ssh and collect data
# Run this after compiling with make

# NOTE: Set N to a reasonable value. The algorithm is O(N^2).
# N=50000 should be a good starting point for modern CPUs.
N=50000

echo "Running Strong Scaling Tests (Fixed N=$N)"
echo "=============================================="
echo ""

# Strong scaling: fixed problem size, varying threads
rm -f strong_scaling_raw.csv strong_scaling.csv

for threads in 1 2 4 8 16
do
    echo "Testing with $threads threads..."

    # Run the compiled program
    output=$(./omp $N $threads 2>&1)
    time_val=$(echo "$output" | grep "Time =" | awk '{print $3}')

    echo "Time for $threads threads: $time_val us"
    echo "$threads,$time_val" >> strong_scaling_raw.csv
done

echo ""
echo "Strong scaling data saved to strong_scaling_raw.csv"
echo ""

# Calculate speedup and efficiency
echo "Calculating speedup and efficiency..."
baseline=$(head -1 strong_scaling_raw.csv | cut -d',' -f2)
echo "Baseline (1 thread): $baseline us"

echo "threads,time_us,speedup,efficiency" > strong_scaling.csv
while IFS=',' read -r threads time_val
do
    # Check if baseline and time_val are non-empty and greater than 0
    if [ -n "$baseline" ] && [ -n "$time_val" ] && [ $(echo "$time_val > 0" | bc -l) -eq 1 ]; then
        speedup=$(echo "scale=4; $baseline / $time_val" | bc -l)
        efficiency=$(echo "scale=4; $speedup / $threads" | bc -l)
        echo "$threads,$time_val,$speedup,$efficiency" >> strong_scaling.csv
        echo "  $threads threads: Time=$time_val us, Speedup=$speedup, Efficiency=$efficiency"
    else
        echo "  $threads threads: Invalid time value ('$time_val'). Skipping calculation."
    fi
done < strong_scaling_raw.csv

echo ""
echo "=============================================="
echo "Running Weak Scaling Tests (N scales with threads)"
echo "=============================================="
echo ""

# Weak scaling: problem size scales with threads
rm -f weak_scaling_raw.csv weak_scaling.csv

for threads in 1 2 4 8 16
do
    # Base N for weak scaling is smaller to ensure timely completion
    N_weak=$((10000 * threads))
    echo "Testing with $threads threads (N=$N_weak)..."

    output=$(./omp $N_weak $threads 2>&1)
    time_val=$(echo "$output" | grep "Time =" | awk '{print $3}')

    echo "Time for $threads threads: $time_val us"
    echo "$threads,$N_weak,$time_val" >> weak_scaling_raw.csv
done

echo ""
# Calculate weak scaling efficiency
baseline=$(head -1 weak_scaling_raw.csv | awk -F',' '{print $3}')
echo "Baseline (1 thread): $baseline us"

echo "threads,N,time_us,efficiency" > weak_scaling.csv
while IFS=',' read -r threads N_weak time_val
do
    # Check if baseline and time_val are non-empty and greater than 0
    if [ -n "$baseline" ] && [ -n "$time_val" ] && [ $(echo "$time_val > 0" | bc -l) -eq 1 ]; then
        efficiency=$(echo "scale=4; $baseline / $time_val" | bc -l)
        echo "$threads,$N_weak,$time_val,$efficiency" >> weak_scaling.csv
        echo "  $threads threads (N=$N_weak): Time=$time_val us, Efficiency=$efficiency"
    else
        echo "  $threads threads (N=$N_weak): Invalid time value ('$time_val'). Skipping calculation."
    fi
done < weak_scaling_raw.csv

echo ""
echo "=============================================="
echo "Scaling tests complete!"
echo "Results saved to:"
echo "  - strong_scaling.csv"
echo "  - weak_scaling.csv"
echo "=============================================="