#include <cuda.h>
#include <print>
__global__
void AddArraysKernelOld(float* a, float* b, float* res, int N) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;

    if(i<N) {
        res[i] = a[i] + b[i];
    }
}

float* AddArraysCudaOld() {
    using namespace std;
    println("Executing addarr old");

    float* a;
    float* b;
    float* res;

    int N = 1<<20;

    a = static_cast<float*>(malloc(sizeof(float) * N));
    b = static_cast<float*>(malloc(sizeof(float) * N));
    res = static_cast<float*>(malloc(sizeof(float) * N));

    float* a_d;
    float* b_d;
    float* res_d;

    cudaMalloc(&a_d, sizeof(float)*N);
    cudaMalloc(&b_d, sizeof(float)*N);
    cudaMalloc(&res_d, sizeof(float)*N);

    for(int i=0; i<N; i++) {
        a[i] = 1.0f;
        b[i] = 2.0f;
        res[i] = 0.0f;
    }

    cudaMemcpy(a_d, a, sizeof(float)*N, cudaMemcpyHostToDevice);
    cudaMemcpy(b_d, b, sizeof(float)*N, cudaMemcpyHostToDevice);
    
    int numThreads = 256;

    AddArraysKernelOld<<<ceil((N+numThreads-1)/numThreads), numThreads>>>(a_d, b_d, res_d, N);

    cudaDeviceSynchronize();

    cudaError_t lastErr = cudaGetLastError();


    cudaMemcpy(res, res_d, sizeof(float)*N, cudaMemcpyDeviceToHost);

    println("Called kernel. LastErr: {} - {}", cudaGetErrorName(lastErr), cudaGetErrorString(lastErr));

    for(int i=0; i<5; i++) {
        println("i: {}, a: {}, b: {}, res:{}, diff: {}", i, a[i], b[i], res[i], (3.0f - res[i]));
    }

    float total_err = 0.0f;

    for(int i=0; i<N; i++) {
        total_err += 3.0f - res[i];
    }

    println("total accumulated err: {}", total_err);

    cudaFree(a_d);
    cudaFree(b_d);
    cudaFree(res_d);
    free(a);
    free(b);
    
    return res;
}