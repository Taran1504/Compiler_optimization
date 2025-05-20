#!/bin/bash

# Directory setup
BENCHMARK_DIR="benchmarks"
RESULTS_DIR="${BENCHMARK_DIR}/results"
BUILD_DIR="build"

# Create directories if they don't exist
mkdir -p ${RESULTS_DIR}
mkdir -p ${BUILD_DIR}

# Compiler settings
COMPILER="g++"
OPTIMIZATION_LEVELS=("-O0" "-O2" "-O3" "-Ofast")
BENCHMARK_CATEGORIES=("Loops" "MemoryAccess" "Conditionals" "NestedLoops" "FunctionInlining" "InstructionScheduling")

# Build and run benchmarks for each optimization level
run_benchmarks() {
    local opt_level=$1
    echo "Running benchmarks with ${opt_level}..."
    
    # Build
    ${COMPILER} ${opt_level} -std=c++17 \
        ${BENCHMARK_DIR}/src/*.cpp \
        -I${BENCHMARK_DIR}/include \
        -lbenchmark -lpthread \
        -o ${BUILD_DIR}/benchmark_${opt_level//-/}

    # Run and save results
    timestamp=$(date +%Y%m%d_%H%M%S)
    result_file="${RESULTS_DIR}/benchmark_results_${opt_level//-/}_${timestamp}.csv"
    ./${BUILD_DIR}/benchmark_${opt_level//-/} \
        --benchmark_format=csv \
        --benchmark_out="${result_file}" \
        --benchmark_repetitions=10
}

# Clean previous builds
clean_build() {
    echo "Cleaning previous builds..."
    rm -rf ${BUILD_DIR}/*
}

# Main execution
main() {
    clean_build
    
    # Run benchmarks for each optimization level
    for opt_level in "${OPTIMIZATION_LEVELS[@]}"; do
        run_benchmarks "${opt_level}"
    done
    
    # Combine results
    echo "Combining results..."
    {
        # Write header
        echo "Benchmark,Time,CPU,Iterations,Optimization,Category"
        
        # Combine all result files
        for file in ${RESULTS_DIR}/benchmark_results_*.csv; do
            opt_level=$(echo ${file} | grep -oP 'O[0-9fast]+')
            tail -n +2 "${file}" | while IFS=, read -r benchmark time cpu iterations rest; do
                # Determine category
                category=""
                for cat in "${BENCHMARK_CATEGORIES[@]}"; do
                    if [[ ${benchmark} =~ ${cat} ]]; then
                        category=${cat}
                        break
                    fi
                done
                echo "${benchmark},${time},${cpu},${iterations},-${opt_level},${category}"
            done
        done
    } > "${RESULTS_DIR}/merged_benchmark_results.csv"
    
    echo "Benchmarking complete. Results saved in ${RESULTS_DIR}/merged_benchmark_results.csv"
}

# Run the script
main