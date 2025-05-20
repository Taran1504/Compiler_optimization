#include <benchmark/benchmark.h>

inline int add(int a, int b) {
    return a + b;
}

static void BM_FunctionInlining(benchmark::State& state) {
    for (auto _ : state) {
        int sum = 0;
        for (int i = 0; i < 1000; ++i) {
            sum = add(sum, i);
        }
        benchmark::DoNotOptimize(sum);
    }
}
BENCHMARK(BM_FunctionInlining);
BENCHMARK_MAIN();