#!/bin/bash

SOURCE="nested_loops.cc"
BINARY_NAME="benchmark"
BUILD_DIR="build"
RESULT_DIR="benchmarks"
OPT_FLAGS=("-O0" "-O2" "-O3" "-Ofast")

# Create folders if they don't exist
mkdir -p "$BUILD_DIR"
mkdir -p "$RESULT_DIR"

for flag in "${OPT_FLAGS[@]}"; do
  TIMESTAMP=$(date +%Y%m%d_%H%M%S)
  BIN="$BUILD_DIR/${BINARY_NAME}_${flag}"
  CSV_OUT="$RESULT_DIR/result_${flag}_${TIMESTAMP}.csv"

  echo "Compiling $SOURCE with $flag..."
  g++ "$SOURCE" -o "$BIN" -I/usr/local/include -L/usr/local/lib -lbenchmark -lpthread "$flag"

  if [ $? -eq 0 ]; then
    echo "Running benchmark for $flag..."
    "$BIN" --benchmark_out="$CSV_OUT" --benchmark_out_format=csv
    echo "Results saved to $CSV_OUT"
  else
    echo "❌ Compilation failed with $flag"
  fi

  echo "---------------------------"
done
