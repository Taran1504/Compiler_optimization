#include <benchmark/benchmark.h>

// Portable noinline definition
#ifdef __GNUC__
#define NOINLINE __attribute__((noinline))
#elif defined(_MSC_VER)
#define NOINLINE __declspec(noinline)
#else
#define NOINLINE
#endif

NOINLINE int no_inline_add(int a, int b) {
    return a + b;
}

inline int inline_add(int a, int b) {
    return a + b;
}

static void BM_FunctionInlining(benchmark::State& state) {
    for (auto _ : state) {
        int sum = 0;
        for (int i = 0; i < state.range(0); ++i) {
            sum = inline_add(sum, i);
        }
        benchmark::DoNotOptimize(sum);
    }
}
BENCHMARK(BM_FunctionInlining)->Arg(1000)->Arg(10000);

static void BM_NoInlineFunction(benchmark::State& state) {
    for (auto _ : state) {
        int sum = 0;
        for (int i = 0; i < state.range(0); ++i) {
            sum = no_inline_add(sum, i);
        }
        benchmark::DoNotOptimize(sum);
    }
}
BENCHMARK(BM_NoInlineFunction)->Arg(1000)->Arg(10000);

BENCHMARK_MAIN();
