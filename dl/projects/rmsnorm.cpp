#include <torch/csrc/stable/library.h>
#include <torch/csrc/stable/ops.h>
#include <torch/csrc/stable/tensor.h>
#include <torch/headeronly/core/ScalarType.h>
#include <torch/headeronly/macros/Macros.h>

namespace ts = torch::stable;

ts::Tensor rms_norm(const ts::Tensor& x, const int N) {
    STD_TORCH_CHECK(x.scalar_type() == torch::headeronly::ScalarType::Float);

    ts::Tensor x_cont = ts::contiguous(x);
    ts::Tensor res = ts::empty_like(x);

    const float* x_ptr = x_cont.const_data_ptr<float>();
    float* res_ptr = res.mutable_data_ptr<float>();
    
    float sum = 0;

    for(int i=0; i<N; i++) {
        sum += pow(x_ptr[i], 2);
    }

    sum = sum / (float) N;
    sum = sqrt(sum);

    for(int i=0; i<N; i++) {
        res_ptr[i] = x_ptr[i] / sum;
    }

    return res;

}