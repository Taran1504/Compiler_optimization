#include <benchmark/benchmark.h>

static void BM_NestedLoop(benchmark::State& state) {
  int sum = 0;
  for (auto _ : state) {
    for (int i = 0; i < 128; ++i) {
      for (int j = 0; j < 128; ++j) {
        sum += i * j;
      }
    }
    benchmark::DoNotOptimize(sum);
  }
}
BENCHMARK(BM_NestedLoop);

static void BM_NestedLoopTiled(benchmark::State& state) {
    int sum = 0;
    for(auto _ : state){
        for(int ii = 0; ii < 128; ii += 32){
            for(int jj = 0; jj < 128; jj+=32){
                for(int i = ii; i < ii + 32; ++i){
                    for(int j = jj; j < jj + 32; ++j){
                        sum += i * j;
                    }
                }
            }
        }
        benchmark::DoNotOptimize(sum);
    }
}
BENCHMARK(BM_NestedLoopTiled);

BENCHMARK_MAIN();