#include <torch/csrc/stable/library.h>
#include <torch/csrc/stable/ops.h>
#include <torch/csrc/stable/tensor.h>
#include <torch/headeronly/macros/Macros.h>
#include <torch/headeronly/core/ScalarType.h>
#include <python.h>

namespace ts = torch::stable;

extern "C" {
    // Creates a dummy modoule for python to import.
    PyObject* PyInit__C(void) {
        static struct PyModuleDef moduleDef = {
            PyModuleDef_HEAD_INIT,
            "_C",
            NULL, // Name of the doc
            -1, // size of per-interpreter state, -1 keeps it in the global vars.
            NULL, // methods
        };

        return PyModule_Create(&moduleDef);
    }
}

ts::Tensor custom_mathmul_cpu(ts::Tensor a, ts::Tensor b, double c) {
    STD_TORCH_CHECK(a.scalar_type() == b.scalar_type(), "Type mismatch");
    STD_TORCH_CHECK(a.device() == b.device(), "Device mismatch");
    STD_TORCH_CHECK(a.sizes() == b.sizes(), "Size mismatch");

    ts::Tensor a_cntg = ts::contiguous(a);
    ts::Tensor b_cntg = ts::contiguous(b);
    ts::Tensor res = ts::empty_like(a);

    const float* a_ptr = a_cntg.const_data_ptr<float>();
    const float* b_ptr = b_cntg.const_data_ptr<float>();
    float* res_ptr = res.mutable_data_ptr<float>();

    for(uint64_t i=0; i<res.numel(); i++) {
        res_ptr[i] = (a_ptr[i] * b_ptr[i]) + c;
    }

    return res;
}

STABLE_TORCH_LIBRARY(mathmul, m){
    m.def("mathmul(a:Tensor, b:Tensor, c:Float)->Tensor");
}

STABLE_TORCH_LIBRARY_IMPL(mathmul, CPU, m){
    m.impl("mathmul", TORCH_BOX(&custom_mathmul_cpu));
}
