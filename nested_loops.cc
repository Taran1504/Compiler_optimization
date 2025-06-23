#include <benchmark/benchmark.h>

static void BM_NestedLoop(benchmark::State& state) {
    int sum = 0;
    const int size = state.range(0);
    for (auto _ : state) {
        for (int i = 0; i < size; ++i) {
            for (int j = 0; j < size; ++j) {
                sum += i * j;
            }
        }
        benchmark::DoNotOptimize(sum);
    }
}
BENCHMARK(BM_NestedLoop)->Arg(128)->Arg(256)->Arg(512);

static void BM_NestedLoopTiled(benchmark::State& state) {
    int sum = 0;
    const int size = state.range(0);
    const int tile_size = state.range(1);
    
    for (auto _ : state) {
        for (int ii = 0; ii < size; ii += tile_size) {
            for (int jj = 0; jj < size; jj += tile_size) {
                for (int i = ii; i < ii + tile_size && i < size; ++i) {
                    for (int j = jj; j < jj + tile_size && j < size; ++j) {
                        sum += i * j;
                    }
                }
            }
        }
        benchmark::DoNotOptimize(sum);
    }
}
BENCHMARK(BM_NestedLoopTiled)->Args({128, 16})->Args({128, 32})->Args({256, 32})->Args({256, 64});

BENCHMARK_MAIN();
