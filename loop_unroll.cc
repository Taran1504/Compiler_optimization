#include <benchmark/benchmark.h>

static void BM_LoopUnroll(benchmark::State& state) {
    for (auto _ : state) {
        int sum = 0;
        // Manual unrolling
        for (int i = 0; i < 1000; i += 5) {
            sum += i;
            sum += i + 1;
            sum += i + 2;
            sum += i + 3;
            sum += i + 4;
        }
        benchmark::DoNotOptimize(sum);
    }
}
BENCHMARK(BM_LoopUnroll);

static void BM_LoopUnrollPragma(benchmark::State& state) {
    for (auto _ : state) {
        int sum = 0;
        // Compiler-assisted unrolling
        #pragma unroll(5)
        for (int i = 0; i < 1000; ++i) {
            sum += i;
        }
        benchmark::DoNotOptimize(sum);
    }
}
BENCHMARK(BM_LoopUnrollPragma);

BENCHMARK_MAIN();
