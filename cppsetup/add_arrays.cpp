#include <print>
#include "add_arrays.h"

void AddArrays(float* a, float* b, float* res, int N){
    for (int i=0; i<N; i++) {
        res[i] = a[i] + b[i];
    }
}


int main() {
    using namespace std;
    for (int i=0; i<21; i++) {
        std::println("1<<{}: {}", i, 1<<i);
    }

    println("{}",INTMAX_MAX);

    int N = 1<<20;
    std::println("Hello World {}", N);

    float* a = new float[N];
    float* b = new float[N];
    float* res = new float[N];

    for(int i=0; i<N; i++) {
        a[i] = 1.0f;
        b[i] = 2.0f;
        res[i] = 0.0f;
    }

    AddArrays(a, b, res, N);

    float acc_err = 0.0f;
    for(int i=0; i<N; i++) {
        acc_err += (3.0f - res[i]);
    }

    println("acc_error: {}", acc_err);

    delete[] a;
    delete[] b;
    delete[] res;

    println("Calling cuda version");

    AddArraysCuda();

    return 0;
}