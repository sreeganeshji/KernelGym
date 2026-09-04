from setuptools import setup, extension
from torch.utils import cpp_extension

setup(
    name="ganesh_cpp_ext", 
    packages=["ganesh_muladd_module"],
    ext_modules=[
    cpp_extension.CUDAExtension(
        "ganesh_muladd_module._C",
        sources=["muladd.cpp", "muladd_torch.cu"],
        extra_compile_args={
            "cxx": [
                # define Py_LIMITED_API with min version 3.9 to expose only the stable
                # limited API subset from Python.h
                "-DPy_LIMITED_API=0x03090000",
                # define TORCH_TARGET_VERSION with min version 2.10 to expose only the
                # stable API subset from torch
                "-DTORCH_TARGET_VERSION=0x020a000000000000",
            ]
        },
    py_limited_api=True)], # Build 1 wheel across multiple py versions
    cmdclass={"build_ext": cpp_extension.BuildExtension},
    options={"bdist_wheel": {"py_limited_api": "cp39"}}
)