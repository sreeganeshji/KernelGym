#include <cuda.h>
#include <iostream>
#include "add_arrays.h"

__global__
void AddArraysKernel(float* a, float* b, float* res, int N) {
    int i = blockDim.x * blockIdx.x + threadIdx.x;
    // std::print("blockDim: {}, blockId: {}, threadId: {}", blockDim.x, blockIdx.x, threadIdx.x);
    // if (i<4) {
    //     printf("i=%d", i);
    // }
    if (i<N) {
        res[i] = a[i] + b[i];
    }
}

void AddArraysCuda() {
    float* a;
    float* b;
    float* res;

    int N = 1<<20;

    cudaMallocManaged(&a, sizeof(float)*N);
    cudaMallocManaged(&b, sizeof(float)*N);
    cudaMallocManaged(&res, sizeof(float)*N);

    for (int i=0; i<N; i++) {
        a[i] = 1.0f;
        b[i] = 2.0f;
        res[i] = 0.0f;
    }

    int numThreads = 128;
    int numBlocks = ceil(N/numThreads + numThreads);
    
    AddArraysKernel<<<numBlocks, numThreads>>>(a, b, res, N);

    cudaError_t error = cudaGetLastError();

    std::cout << "Cuda last error: " << cudaGetErrorString(error) << '\n';

    error = cudaDeviceSynchronize();
    std::cout << "Cuda error: " << cudaGetErrorString(error) << '\n';

    for(int i=0; i<5; i++) {
        std::cout << "a[" << i << "]: " << a[i]
                  << ", b[" << i << "]: " << b[i]
                  << ", res[" << i << "]: " << res[i] << '\n';
    }

    float sum_err = 0.0f;
    for(int i=0; i<N; i++) {
        sum_err += 3.0f - res[i];
    }

    std::cout << "Received res " << sum_err << '\n';

    cudaFree(a);
    cudaFree(b);
    cudaFree(res);
}