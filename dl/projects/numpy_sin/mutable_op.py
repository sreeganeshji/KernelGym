import torch
import numpy as np
from torch import Tensor

@torch.library.custom_op(
    "mylib::mutable_sin",
    mutates_args={"out"}
)
def my_sin(x:Tensor, out:Tensor) -> None:
    if (x.shape != out.shape):
        raise RuntimeError("Shape mismatch")
    if (x.dtype != out.dtype):
        raise RuntimeError("Type mismatch")
    if (x.device != out.device): 
        raise RuntimeError("Device mismatch")
    np.sin(x.detach().numpy(), out=out.numpy())


x = torch.randn((3,2))
out = torch.empty_like(x)
out_ref = np.sin(x)
my_sin(x,out)
torch.testing.assert_close(out, out_ref)