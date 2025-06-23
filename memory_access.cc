#include <benchmark/benchmark.h>
#include <vector>
#include <random>
#include <algorithm>

#ifndef ACCESS_SIZE
#define ACCESS_SIZE 1024
#endif
#include <numeric>

static void BM_SequentialAccess(benchmark::State& state) {
    std::vector<int> data(ACCESS_SIZE, 1);
    for (auto _ : state) {
        for (size_t i = 0; i < data.size(); ++i) {
            data[i] += 1;
        }
        benchmark::DoNotOptimize(data);
    }
}
BENCHMARK(BM_SequentialAccess);

static void BM_StridedAccess(benchmark::State& state) {
    std::vector<int> data(ACCESS_SIZE, 1);
    const int stride = state.range(0);
    for (auto _ : state) {
        for (size_t i = 0; i < data.size(); i += stride) {
            data[i] += 1;
        }
        benchmark::DoNotOptimize(data);
    }
}
BENCHMARK(BM_StridedAccess)->Arg(1)->Arg(2)->Arg(4)->Arg(8)->Arg(16);

static void BM_RandomAccess(benchmark::State& state) {
    std::vector<int> data(ACCESS_SIZE, 1);
    std::vector<size_t> indices(ACCESS_SIZE);
    
    // Fill with sequential indices
    std::iota(indices.begin(), indices.end(), 0);
    
    // Shuffle indices
    std::random_device rd;
    std::mt19937 g(rd());
    std::shuffle(indices.begin(), indices.end(), g);

    for (auto _ : state) {
        for (size_t i : indices) {
            data[i] += 1;
        }
        benchmark::DoNotOptimize(data);
    }
}
BENCHMARK(BM_RandomAccess);

BENCHMARK_MAIN();
