#!/bin/bash

# Script to run scaling tests on cs-ssh and collect data
# Run this after compiling with make

echo "Running Strong Scaling Tests (Fixed N=10000)"
echo "=============================================="
echo ""

# Strong scaling: fixed problem size, varying threads
N=10000
echo "threads,time_us,speedup,efficiency" > strong_scaling.csv

for threads in 1 2 4 8 16
do
    echo "Testing with $threads threads..."
    # Run 3 times and take the best time
    best_time=999999999
    
    for run in 1 2 3
    do
        output=$(./omp $N $threads 2>&1)
        time_val=$(echo "$output" | grep "Time =" | awk '{print $3}')
        
        # Compare and keep best time
        if (( $(echo "$time_val < $best_time" | bc -l) )); then
            best_time=$time_val
        fi
    done
    
    echo "Best time for $threads threads: $best_time us"
    echo "$threads,$best_time" >> strong_scaling_raw.csv
done

echo ""
echo "Strong scaling data saved to strong_scaling_raw.csv"
echo ""

# Calculate speedup and efficiency
echo "Calculating speedup and efficiency..."
baseline=$(head -2 strong_scaling_raw.csv | tail -1 | cut -d',' -f2)

echo "threads,time_us,speedup,efficiency" > strong_scaling.csv
while IFS=',' read -r threads time_val
do
    if [ "$threads" != "threads" ]; then
        speedup=$(echo "scale=4; $baseline / $time_val" | bc)
        efficiency=$(echo "scale=4; $speedup / $threads" | bc)
        echo "$threads,$time_val,$speedup,$efficiency" >> strong_scaling.csv
        echo "  $threads threads: Speedup=$speedup, Efficiency=$efficiency"
    fi
done < strong_scaling_raw.csv

echo ""
echo "=============================================="
echo "Running Weak Scaling Tests (N scales with threads)"
echo "=============================================="
echo ""

# Weak scaling: problem size scales with threads
# N per thread = 1000, so N = 1000 * threads
echo "threads,N,time_us,efficiency" > weak_scaling.csv

for threads in 1 2 4 8 16
do
    N=$((1000 * threads))
    echo "Testing with $threads threads (N=$N)..."
    
    # Run 3 times and take the best time
    best_time=999999999
    
    for run in 1 2 3
    do
        output=$(./omp $N $threads 2>&1)
        time_val=$(echo "$output" | grep "Time =" | awk '{print $3}')
        
        if (( $(echo "$time_val < $best_time" | bc -l) )); then
            best_time=$time_val
        fi
    done
    
    echo "Best time for $threads threads: $best_time us"
    echo "$threads,$N,$best_time" >> weak_scaling_raw.csv
done

echo ""
# Calculate weak scaling efficiency
baseline=$(head -2 weak_scaling_raw.csv | tail -1 | awk -F',' '{print $3}')

echo "threads,N,time_us,efficiency" > weak_scaling.csv
while IFS=',' read -r threads N time_val
do
    if [ "$threads" != "threads" ]; then
        efficiency=$(echo "scale=4; $baseline / $time_val" | bc)
        echo "$threads,$N,$time_val,$efficiency" >> weak_scaling.csv
        echo "  $threads threads (N=$N): Time=$time_val us, Efficiency=$efficiency"
    fi
done < weak_scaling_raw.csv

echo ""
echo "=============================================="
echo "Scaling tests complete!"
echo "Results saved to:"
echo "  - strong_scaling.csv"
echo "  - weak_scaling.csv"
echo "=============================================="
echo ""
echo "To generate plots, use the provided Python script:"
echo "  python3 plot_scaling.py"