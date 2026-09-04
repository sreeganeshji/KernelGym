import torch
import numpy as np
from torch import Tensor
import ganesh_muladd_module

torch.manual_seed(123)
N = 1000_1000
a = torch.randn([N,], device="cuda")
b = torch.randn_like(a, device="cuda")
c = torch.randn(1,device="cuda")[0]
# print(f"{a} \n {b} \n {c.item()}")

res = ganesh_muladd_module.ops.muladd(a, b, c)
print(torch.testing.assert_close(res, (a*b)+c))

# print(f"Got the result {res}")
# print(f"{(a*b)+c}")
print(ganesh_muladd_module._C.__file__)