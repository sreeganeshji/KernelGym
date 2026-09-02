import torch
from torch import Tensor
import numpy as np

def numpysin_impl(x:Tensor) -> Tensor:
    res = torch.empty_strided(x.shape, tuple(reversed(x.stride())))
    # print(f"xshape: {x.shape} res: {res.shape} \n stride s: {x.stride()} res: {res.stride()}")
    # print(f"offset: x: {x.storage_offset()}, res: {res.storage_offset()}")
    np.sin(x.detach().numpy(), out=res.numpy())
    return res




@torch.library.custom_op("mynumpy::brokennumpy_sin", mutates_args=(), device_types="cpu")
def numpysin_op(x:Tensor) -> Tensor:
    return numpysin_impl(x)

@torch.library.register_fake("mynumpy::brokennumpy_sin")
def broken_op(x:Tensor)->Tensor:
    return torch.empty_like(x)

@torch.compile(fullgraph=True)
def f(x:Tensor)->Tensor:
    return numpysin_impl(x)

torch.manual_seed(42)
x = torch.randn(2,3)
print(f"offset: {x.storage_offset()} stride: {x.stride()}")
numpysin_impl(x)

print(f"calling f with x: {x} \n f(x): {f(x)}")

try:
    torch.library.opcheck(numpysin_op, (x,))
except Exception as e:
    print(e)
    '''
    opcheck(op, ...): test_faketensor failed with When comparing the output of 
    mynumpy.brokennumpy_sin.default on FakeTensor and concrete Tensors, found 
    mismatched tensor metadata: Stride mismatch! Strides are (1, 3) and (3, 1) 
    (mismatched at 0)! (scroll up for stack trace)
    '''

@numpysin_op.register_fake
def _(x:Tensor):
    r = torch.empty_strided(x.shape, tuple(reversed(x.stride())))
    return r

try:
    torch.library.opcheck(numpysin_op, (x,))
except Exception as e:
    print(e)