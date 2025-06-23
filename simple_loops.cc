#include <benchmark/benchmark.h>

static void BM_SimpleLoop(benchmark::State& state) {
    const int size = state.range(0);
    for (auto _ : state) {
        int sum = 0;
        for (int i = 0; i < size; ++i) {
            sum += i;
        }
        benchmark::DoNotOptimize(sum);
    }
}
BENCHMARK(BM_SimpleLoop)->Arg(1000)->Arg(10000)->Arg(100000);

static void BM_SimpleLoopWithPointer(benchmark::State& state) {
    const int size = state.range(0);
    int* array = new int[size];
    for (int i = 0; i < size; ++i) {
        array[i] = i;
    }
    
    for (auto _ : state) {
        int sum = 0;
        int* ptr = array;
        for (int i = 0; i < size; ++i) {
            sum += *ptr++;
        }
        benchmark::DoNotOptimize(sum);
    }
    
    delete[] array;
}
BENCHMARK(BM_SimpleLoopWithPointer)->Arg(1000)->Arg(10000)->Arg(100000);

BENCHMARK_MAIN();
