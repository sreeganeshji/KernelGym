#define USE_CUDA

#include <torch/csrc/stable/tensor.h>
#include <torch/csrc/stable/ops.h>
#include <torch/csrc/stable/library.h>
#include <torch/csrc/inductor/aoti_torch/c/shim.h>
#include <torch/headeronly/macros/Macros.h>
#include <torch/headeronly/core/ScalarType.h>
#include <torch/csrc/stable/c/shim.h>
#include <cuda.h>
#include <cuda_runtime.h>
#include <iostream>

// #include <Python.h>

namespace ts = torch::stable;


// extern "C" {

// PyObject* PyInit__C(void) {
//     static struct PyModuleDef moduleDef = {
//         PyModuleDef_HEAD_INIT,
//         "_C",   // module name
//         NULL,   // module documentation
//         -1,     // per-interpreter state size
//         NULL    // methods
//     };

//     return PyModule_Create(&moduleDef);
// }

// }

__global__
void mulladd_kernel(const float* a, const float* b, float c, float* res, int N) {
    int i = (blockIdx.x * blockDim.x) + threadIdx.x;

    if (i < N) {
        res[i] = (a[i] * b[i]) + c;
    }
}

ts::Tensor muladd(ts::Tensor a, ts::Tensor b, double c) {
    std::cout<<"Calling host to deliiver to cuda"<<std::endl;
    STD_TORCH_CHECK(a.sizes().equals(b.sizes()), "Shapes mismatch");
    STD_TORCH_CHECK(a.scalar_type() == torch::headeronly::ScalarType::Float, "Not float");
    STD_TORCH_CHECK(b.scalar_type() == torch::headeronly::ScalarType::Float, "Not float");
    STD_TORCH_CHECK(a.device().type() == torch::headeronly::DeviceType::CUDA);
    STD_TORCH_CHECK(b.device().type() == torch::headeronly::DeviceType::CUDA);

    ts::Tensor a_cnt = ts::contiguous(a);
    ts::Tensor b_cnt = ts::contiguous(b);
    ts::Tensor res = ts::empty_like(a_cnt);

    int N = a.numel();
    void* cudaStream_ptr = nullptr;
    TORCH_ERROR_CODE_CHECK(aoti_torch_get_current_cuda_stream(a.get_device_index(), &cudaStream_ptr));
    cudaStream_t cudaStream = static_cast<cudaStream_t>(cudaStream_ptr);

        
    // Divide up N into num_blocks (gridDim) and num of threads per block
    int threads = 128;
    mulladd_kernel<<<ceil((N+threads-1)/threads), threads, 0, cudaStream>>>(a_cnt.const_data_ptr<float>(), b_cnt.const_data_ptr<float>(), c, res.mutable_data_ptr<float>(), N);

    return res;
}

STABLE_TORCH_LIBRARY_IMPL(my_extension, CUDA, m) {
    m.impl("mymuladd", TORCH_BOX(&muladd));
}