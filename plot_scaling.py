#!/usr/bin/env python3

import matplotlib.pyplot as plt
import pandas as pd
import numpy as np

# Set style for better-looking plots
plt.style.use('seaborn-v0_8-darkgrid')

# Read strong scaling data
strong = pd.read_csv('strong_scaling.csv')

# Read weak scaling data
weak = pd.read_csv('weak_scaling.csv')

# Create figure with two subplots
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

# ========== Strong Scaling Plot ==========
ax1.plot(strong['threads'], strong['speedup'], 'o-', linewidth=2, markersize=8, 
         label='Measured Speedup', color='#2E86AB')
# Ideal speedup line
ax1.plot(strong['threads'], strong['threads'], '--', linewidth=2, 
         label='Ideal Speedup', color='#A23B72', alpha=0.7)

ax1.set_xlabel('Number of Threads', fontsize=12, fontweight='bold')
ax1.set_ylabel('Speedup', fontsize=12, fontweight='bold')
ax1.set_title('Strong Scaling: OpenMP Performance\n(Fixed Problem Size N=10,000)', 
              fontsize=13, fontweight='bold')
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)
ax1.set_xticks(strong['threads'])

# Add efficiency annotations
for idx, row in strong.iterrows():
    eff_percent = row['efficiency'] * 100
    ax1.annotate(f'{eff_percent:.1f}%', 
                xy=(row['threads'], row['speedup']),
                xytext=(5, 5), textcoords='offset points',
                fontsize=8, alpha=0.7)

# ========== Weak Scaling Plot ==========
ax2.plot(weak['threads'], weak['efficiency'], 's-', linewidth=2, markersize=8,
         label='Measured Efficiency', color='#F18F01')
# Ideal efficiency line (1.0)
ax2.axhline(y=1.0, linestyle='--', linewidth=2, 
            label='Ideal Efficiency', color='#A23B72', alpha=0.7)

ax2.set_xlabel('Number of Threads', fontsize=12, fontweight='bold')
ax2.set_ylabel('Parallel Efficiency', fontsize=12, fontweight='bold')
ax2.set_title('Weak Scaling: OpenMP Performance\n(Problem Size Scales with Threads)', 
              fontsize=13, fontweight='bold')
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)
ax2.set_xticks(weak['threads'])
ax2.set_ylim([0, 1.1])

# Add efficiency value annotations
for idx, row in weak.iterrows():
    eff_percent = row['efficiency'] * 100
    ax2.annotate(f'{eff_percent:.1f}%', 
                xy=(row['threads'], row['efficiency']),
                xytext=(5, -15), textcoords='offset points',
                fontsize=8, alpha=0.7)

plt.tight_layout()
plt.savefig('scaling_results.png', dpi=300, bbox_inches='tight')
print("Plot saved as 'scaling_results.png'")
plt.show()

# ========== Print Summary Statistics ==========
print("\n" + "="*60)
print("STRONG SCALING SUMMARY (N=1,000,000)")
print("="*60)
print(strong.to_string(index=False))
print("\nMaximum Speedup: {:.2f}x with {} threads".format(
    strong['speedup'].max(), 
    strong.loc[strong['speedup'].idxmax(), 'threads']))
print("Parallel Efficiency at max threads: {:.1f}%".format(
    strong.iloc[-1]['efficiency'] * 100))

print("\n" + "="*60)
print("WEAK SCALING SUMMARY (N scales with threads)")
print("="*60)
print(weak.to_string(index=False))
print("\nAverage Efficiency: {:.1f}%".format(weak['efficiency'].mean() * 100))
print("Efficiency at max threads: {:.1f}%".format(weak.iloc[-1]['efficiency'] * 100))
print("="*60)

# Create caption file
with open('figure_caption.txt', 'w') as f:
    f.write("Figure Caption:\n")
    f.write("="*60 + "\n\n")
    f.write("Strong and Weak Scaling Results for OpenMP Parallelization of OMP-Q.c\n\n")
    f.write("Left Panel (Strong Scaling):\n")
    f.write(f"- Fixed problem size: N = 10,000\n")
    f.write(f"- System: cs-ssh (shared memory multicore system)\n")
    f.write(f"- Compiler: GCC with -O3 -march=native -fopenmp\n")
    f.write(f"- Schedule: static with chunk size 16\n")
    f.write(f"- Maximum speedup: {strong['speedup'].max():.2f}x with {int(strong.loc[strong['speedup'].idxmax(), 'threads'])} threads\n")
    f.write(f"- Each data point represents best of 3 runs\n\n")
    f.write("Right Panel (Weak Scaling):\n")
    f.write(f"- Problem size scales with threads: N = 1,000 × threads\n")
    f.write(f"- System: cs-ssh (shared memory multicore system)\n")
    f.write(f"- Compiler: GCC with -O3 -march=native -fopenmp\n")
    f.write(f"- Schedule: static with chunk size 16\n")
    f.write(f"- Average efficiency: {weak['efficiency'].mean()*100:.1f}%\n")
    f.write(f"- Each data point represents best of 3 runs\n\n")
    f.write("Reproduction Instructions:\n")
    f.write("1. Compile: make\n")
    f.write("2. Run scaling tests: bash run_scaling_tests.sh\n")
    f.write("3. Generate plots: python3 plot_scaling.py\n")

print("\nFigure caption saved to 'figure_caption.txt'")