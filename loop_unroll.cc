#include <benchmark/benchmark.h>

static void BM_LoopUnroll(benchmark::State& state) {
    for (auto _ : state) {
        int sum = 0;
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
BENCHMARK_MAIN();