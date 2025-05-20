#!/bin/bash

# === CONFIGURATION ===

SOURCES=(
  "simple_loops.cc"
  "memory_access.cc"
  "conditional_loops.cc"
  "nested_loops.cc"
  "loop_unroll.cc"
  "function_inlining.cc"
  "instruction_scheduling.cc"
)

LABELS=(
  "SimpleLoop"
  "MemoryAccess"
  "ConditionalLoops"
  "NestedLoops"
  "LoopUnroll"
  "FunctionInlining"
  "InstructionScheduling"
)

CATEGORIES=(
  "Loops"
  "MemoryAccess"
  "Conditionals"
  "NestedLoops"
  "Loops"
  "FunctionInlining"
  "InstructionScheduling"
)

OPT_FLAGS=("-O0" "-O2" "-O3" "-Ofast")
REPEAT=5  # each benchmark will have multiple repetitions internally
REPS=10   # number of repetitions per run

BINARY_NAME="benchmark"
BUILD_DIR="build"
RESULT_DIR="benchmarks"
MERGED_CSV="merged_benchmark_results.csv"

mkdir -p "$BUILD_DIR"
mkdir -p "$RESULT_DIR"
echo "Benchmark,Time,CPU,Iterations,Optimization,Category" > "$MERGED_CSV"

TOTAL_RUNS=$(( ${#SOURCES[@]} * ${#OPT_FLAGS[@]} * REPEAT ))
COUNT=1

for i in "${!SOURCES[@]}"; do
  SRC="${SOURCES[$i]}"
  LABEL="${LABELS[$i]}"
  CATEGORY="${CATEGORIES[$i]}"

  for FLAG in "${OPT_FLAGS[@]}"; do
    BIN="$BUILD_DIR/${BINARY_NAME}${LABEL}${FLAG//-/}"

    echo "⏳ Compiling $SRC with $FLAG..."
    g++ "$SRC" -o "$BIN" -I/usr/local/include -L/usr/local/lib -lbenchmark -lpthread "$FLAG"

    if [ $? -ne 0 ]; then
      echo "❌ Compilation failed for $SRC with $FLAG"
      continue
    fi

    for ((run=1; run<=REPEAT; run++)); do
      TEMP_CSV="$RESULT_DIR/temp_result.csv"
      echo "▶ [$COUNT/$TOTAL_RUNS] Running $LABEL ($FLAG) Run $run/$REPEAT..."

      "$BIN" \
        --benchmark_out="$TEMP_CSV" \
        --benchmark_out_format=csv \
        --benchmark_repetitions=$REPS \
        --benchmark_report_aggregates_only=false \
        --benchmark_min_time=0.01 \
        > /dev/null 2>&1

      if [ -f "$TEMP_CSV" ]; then
        tail -n +2 "$TEMP_CSV" | awk -F',' -v opt="$FLAG" -v cat="$CATEGORY" 'BEGIN{OFS=","}
          {
            gsub(/ /, "", $1);
            print $1, $4, $5, $6, opt, cat
          }' >> "$MERGED_CSV"
        rm "$TEMP_CSV"
      fi

      ((COUNT++))
    done

    echo "✅ Finished $LABEL with $FLAG."
    echo "----------------------------"
  done
done

echo "🎉 All benchmarks completed. Merged CSV: $MERGED_CSV"