#include <benchmark/benchmark.h>
#include <vector>
#include <random>

static void BM_SequentialAccess(benchmark::State& state) {
  std::vector<int> data(1024);
  for (auto _ : state) {
    for (int i = 0; i < 1024; ++i) {
      data[i] += 1;
    }
    benchmark::DoNotOptimize(data);
  }
}
BENCHMARK(BM_SequentialAccess);

static void BM_RandomAccess(benchmark::State& state) {
  std::vector<int> data(1024);
  std::random_device rd;
  std::mt19937 gen(rd());
  std::uniform_int_distribution<> dis(0, 1023);

  for (auto _ : state) {
    for (int i = 0; i < 1024; ++i) {
      data[dis(gen)] += 1;
    }
    benchmark::DoNotOptimize(data);
  }
}
BENCHMARK(BM_RandomAccess);

BENCHMARK_MAIN();