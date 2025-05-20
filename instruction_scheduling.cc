#include <benchmark/benchmark.h>

static void BM_InstructionScheduling(benchmark::State& state) {
    for (auto _ : state) {
        int a = 1, b = 2, c = 3, d = 4;
        for (int i = 0; i < 1000; ++i) {
            a += i;
            b *= i + 1;
            c ^= i;
            d -= i;
        }
        benchmark::DoNotOptimize(a);
        benchmark::DoNotOptimize(b);
        benchmark::DoNotOptimize(c);
        benchmark::DoNotOptimize(d);
    }
}
BENCHMARK(BM_InstructionScheduling);
BENCHMARK_MAIN();