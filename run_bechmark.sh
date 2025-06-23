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
OPT_FLAGS=("-O0" "-O2" "-O3" "-Ofast")
REPEAT=40  # Each binary runs 40 times

BINARY_NAME="benchmark"
BUILD_DIR="build"
RESULT_DIR="benchmarks"
MERGED_CSV="merged_benchmark_results.csv"

# === SETUP ===
mkdir -p "$BUILD_DIR"
mkdir -p "$RESULT_DIR"
echo "Benchmark,Time,CPU,Iterations" > "$MERGED_CSV"  # CSV Header

TOTAL_RUNS=$(( ${#SOURCES[@]} * ${#OPT_FLAGS[@]} * REPEAT ))
COUNT=1

# === MAIN LOOP ===
for i in "${!SOURCES[@]}"; do
  SRC="${SOURCES[$i]}"
  LABEL="${LABELS[$i]:-Source_$i}"

  for FLAG in "${OPT_FLAGS[@]}"; do
    BIN="$BUILD_DIR/${BINARY_NAME}_${LABEL}_${FLAG//-/}"

    echo "⏳ Compiling $SRC with $FLAG..."
    g++ "$SRC" -o "$BIN" -I/usr/local/include -L/usr/local/lib -lbenchmark -lpthread "$FLAG"

    if [ $? -ne 0 ]; then
      echo "Compilation failed for $SRC with $FLAG"
      continue
    fi

    for ((run=1; run<=$REPEAT; run++)); do
      TEMP_CSV="$RESULT_DIR/temp_result.csv"
      echo "▶️ [$COUNT/$TOTAL_RUNS] Running $LABEL ($FLAG) Run $run/$REPEAT..."
      "$BIN" --benchmark_out="$TEMP_CSV" --benchmark_out_format=csv > /dev/null 2>&1

      if [ -f "$TEMP_CSV" ]; then
        tail -n +2 "$TEMP_CSV" | awk -v label="${LABEL}_${FLAG}" -F, 'BEGIN{OFS=","} {print label,$4,$5,$6}' >> "$MERGED_CSV"
        rm "$TEMP_CSV"
      fi
      ((COUNT++))
    done

    echo "Finished $LABEL with $FLAG."
    echo "----------------------------"
  done

done

echo "All benchmarks completed. Merged CSV: $MERGED_CSV"
