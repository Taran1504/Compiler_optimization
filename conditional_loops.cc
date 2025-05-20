#include <benchmark/benchmark.h>

static void BM_ConditionalLoop(benchmark::State& state) {
  int sum = 0;
  for (auto _ : state) {
    for (int i = 0; i < 1024; ++i) {
      if (i % 2 == 0) {
        sum += i;
      } else {
        sum -= i;
      }
    }
    benchmark::DoNotOptimize(sum);
  }
}
BENCHMARK(BM_ConditionalLoop);

BENCHMARK_MAIN();