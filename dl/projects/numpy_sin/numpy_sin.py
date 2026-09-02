import torch
import numpy as np
from torch import Tensor

def sin_impl(x:Tensor)->Tensor:
    x_numpy = x.detach().numpy()
    res = torch.empty_like(x)
    np.sin(x_numpy, out=res.detach().numpy())
    return res

x = torch.randn(5)
torch.testing.assert_close(np.sin(x),sin_impl(x))

@torch.library.custom_op(
    "myops::numpy_sin",
    mutates_args=(),
    device_types="cpu",
)
def numpy_sin(x:Tensor) -> Tensor:
    res = torch.empty_like(x)
    np.sin(x.numpy(), out=res.numpy())
    return res


@numpy_sin.register_fake
def _(x):
    return torch.empty_like(x)

@torch.compile(fullgraph=True)
def f(x):
    return numpy_sin(x)

result = f(x)
torch.testing.assert_close(np.sin(x), result)