#!/bin/bash

# Script to run scaling tests on cs-ssh and collect data
# Run this after compiling with make

echo "Running Strong Scaling Tests (Fixed N=50_000)"
echo "=============================================="
echo ""

# Strong scaling: fixed problem size, varying threads
N=50000
rm -f strong_scaling_raw.csv strong_scaling.csv

for threads in 1 2 4 8 16
do
    echo "Testing with $threads threads..."
    
    # Run once (you can run 3 times and take best if you want)
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
    speedup=$(echo "scale=4; $baseline / $time_val" | bc)
    efficiency=$(echo "scale=4; $speedup / $threads" | bc)
    echo "$threads,$time_val,$speedup,$efficiency" >> strong_scaling.csv
    echo "  $threads threads: Time=$time_val us, Speedup=$speedup, Efficiency=$efficiency"
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
    N=$((10000 * threads))
    echo "Testing with $threads threads (N=$N)..."
    
    output=$(./omp $N $threads 2>&1)
    time_val=$(echo "$output" | grep "Time =" | awk '{print $3}')
    
    echo "Time for $threads threads: $time_val us"
    echo "$threads,$N,$time_val" >> weak_scaling_raw.csv
done

echo ""
# Calculate weak scaling efficiency
baseline=$(head -1 weak_scaling_raw.csv | awk -F',' '{print $3}')
echo "Baseline (1 thread): $baseline us"

echo "threads,N,time_us,efficiency" > weak_scaling.csv
while IFS=',' read -r threads N time_val
do
    efficiency=$(echo "scale=4; $baseline / $time_val" | bc)
    echo "$threads,$N,$time_val,$efficiency" >> weak_scaling.csv
    echo "  $threads threads (N=$N): Time=$time_val us, Efficiency=$efficiency"
done < weak_scaling_raw.csv

echo ""
echo "=============================================="
echo "Scaling tests complete!"
echo "Results saved to:"
echo "  - strong_scaling.csv"
echo "  - weak_scaling.csv"
echo "=============================================="