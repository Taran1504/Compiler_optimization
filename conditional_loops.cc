#include <benchmark/benchmark.h>

static void BM_ConditionalLoop(benchmark::State& state) {
    const int size = state.range(0);
    int sum = 0;
    for (auto _ : state) {
        for (int i = 0; i < size; ++i) {
            if (i % 2 == 0) [[likely]] {
                sum += i;
            } else [[unlikely]] {
                sum -= i;
            }
        }
        benchmark::DoNotOptimize(sum);
    }
}
BENCHMARK(BM_ConditionalLoop)->Arg(1024)->Arg(2048)->Arg(4096);

static void BM_ConditionalLoopNoBranch(benchmark::State& state) {
    const int size = state.range(0);
    int sum = 0;
    for (auto _ : state) {
        for (int i = 0; i < size; ++i) {
            sum += (i % 2 == 0) ? i : -i;
        }
        benchmark::DoNotOptimize(sum);
    }
}
BENCHMARK(BM_ConditionalLoopNoBranch)->Arg(1024)->Arg(2048)->Arg(4096);

static void BM_ConditionalLoopBitwise(benchmark::State& state) {
    const int size = state.range(0);
    int sum = 0;
    for (auto _ : state) {
        for (int i = 0; i < size; ++i) {
            sum += ((i & 1) - 1) & ~i | (~(i & 1) + 1) & i;
        }
        benchmark::DoNotOptimize(sum);
    }
}
BENCHMARK(BM_ConditionalLoopBitwise)->Arg(1024)->Arg(2048)->Arg(4096);

BENCHMARK_MAIN();
