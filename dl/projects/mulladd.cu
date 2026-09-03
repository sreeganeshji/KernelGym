#include <torch/csrc/stable/library.h>
#include <torch/csrc/stable/ops.h>
#include <torch/csrc/stable/tensor.h>
#include <torch/headeronly/macros/Macros.h>
#include <torch/headeronly/core/ScalarType.h>

namespace ts = torch::stable;

__global__
void muladd_cuda_kernel(float* a, float* b, float c, float* res, int N) {
    int x = blockIdx.x * blockDim.x + threadIdx.x;

    if(x < N) {
        res[x] = (a[x] * b[x]) + c;
    }
}

ts::Tensor custom_muladd_cuda(ts::Tensor a, ts::Tensor b, double c) {
    /*
    allocate memory on device
    */
   STD_TORCH_CHECK(a.sizes() == b.sizes(), "Shape mismatch");
   STD_TORCH_CHECK(a.device() == b.device(), "Device mismatch");
   STD_TORCH_CHECK(a.scalar_type() == b.scalar_type(), "Type mismatch");
    
    float* a_d, *b_d, *res_d;
    int64_t N = a.numel();
    cudaMalloc(&a_d, N * a.element_size());
    cudaMalloc(&b_d, N * a.element_size());
    cudaMalloc(&res_d, N * a.element_size());

    cudaMemcpy(a_d, a.const_data_ptr<float>(), N, cudaMemcpyHostToDevice);
    cudaMemcpy(b_d, b.const_data_ptr<float>(), N, cudaMemcpyHostToDevice);
    
    muladd_cuda_kernel(a_d, b_d, c, res_d, N);

    ts::Tensor res = ts::empty_like(a);
    cudaMemcpy(res.mutable_data_ptr<float>(), res_d, N, cudaMemcpyDeviceToHost);

    return res;
}

STABLE_TORCH_LIBRARY_IMPL(my_muladd, CUDA, m){
    m.impl("my_muladd", TORCH_BOX(&custom_muladd_cuda));
}