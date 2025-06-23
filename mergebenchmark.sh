#!/bin/bash

# === Enhanced Configuration ===
declare -A BENCHMARK_CONFIG=(
    ["simple_loops.cc"]="SimpleLoop:Loops:"
    ["memory_access.cc"]="MemoryAccess:MemoryAccess:-DACCESS_SIZE=4096"
    ["conditional_loops.cc"]="ConditionalLoop:Conditionals:"
    ["nested_loops.cc"]="NestedLoop:NestedLoops:"
    ["loop_unroll.cc"]="LoopUnroll:Loops:"
    ["function_inlining.cc"]="FunctionInlining:FunctionInlining:"
    ["instruction_scheduling.cc"]="InstructionScheduling:InstructionScheduling:"
)

OPT_FLAGS=("-O0" "-O2" "-O3" "-Ofast")
REPEAT=5
REPS=10
MIN_TIME=0.05
ARCH_FLAGS="-march=native -mtune=native"

BINARY_NAME="benchmark"
BUILD_DIR="build"
RESULT_DIR="benchmarks"
MERGED_CSV="merged_benchmark_results.csv"
LOG_FILE="benchmark.log"

mkdir -p "$BUILD_DIR"
mkdir -p "$RESULT_DIR"
echo "Benchmark,Time,CPU,Iterations,Optimization,Category" > "$MERGED_CSV"
echo "Benchmark Log" > "$LOG_FILE"

TOTAL_RUNS=$(( ${#BENCHMARK_CONFIG[@]} * ${#OPT_FLAGS[@]} * REPEAT ))
COUNT=1

log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

get_cpu_info() {
    echo "CPU Information:" | tee -a "$LOG_FILE"
    lscpu | tee -a "$LOG_FILE"
    echo "" | tee -a "$LOG_FILE"
}

get_cpu_info

for SRC in "${!BENCHMARK_CONFIG[@]}"; do
    IFS=':' read -r LABEL CATEGORY EXTRA_FLAGS <<< "${BENCHMARK_CONFIG[$SRC]}"
    
    for FLAG in "${OPT_FLAGS[@]}"; do
        BIN="$BUILD_DIR/${BINARY_NAME}_${LABEL}_${FLAG//-/}"
        
        log "Compiling $SRC with $FLAG $EXTRA_FLAGS..."
        g++ "$SRC" -o "$BIN" \
            -I/usr/local/include \
            -L/usr/local/lib \
            -lbenchmark -lpthread \
            $FLAG $ARCH_FLAGS $EXTRA_FLAGS 2>> "$LOG_FILE"

        if [ $? -ne 0 ]; then
            log "Compilation failed for $SRC with $FLAG"
            continue
        fi

        for ((run=1; run<=REPEAT; run++)); do
            TEMP_CSV="$RESULT_DIR/temp_${LABEL}_${FLAG//-/}_run$run.csv"
            log "▶ [$COUNT/$TOTAL_RUNS] Running $LABEL ($FLAG) Run $run/$REPEAT..."

            "$BIN" \
                --benchmark_out="$TEMP_CSV" \
                --benchmark_out_format=csv \
                --benchmark_repetitions=$REPS \
                --benchmark_report_aggregates_only=false \
                --benchmark_min_time=$MIN_TIME \
                >> "$LOG_FILE" 2>&1

            if [ -f "$TEMP_CSV" ]; then
                awk -F',' -v opt="$FLAG" -v cat="$CATEGORY" 'BEGIN{OFS=","}
                NR > 1 {
                    gsub(/ /, "", $1);
                    print $1, $4, $5, $6, opt, cat
                }' "$TEMP_CSV" >> "$MERGED_CSV"
                rm "$TEMP_CSV"
            fi

            ((COUNT++))
        done

        log "Finished $LABEL with $FLAG"
        log "----------------------------"
    done
done

log "All benchmarks completed. Generating analysis..."
