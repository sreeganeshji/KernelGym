import torch
from torch import Tensor

__all__ = ["muladd"]

def muladd(a:Tensor, b:Tensor, c:float)->Tensor:
    return torch.ops.my_extension.mymuladd(a,b,c)


@torch.library.register_fake("my_extension::mymuladd")
def _(a: Tensor, b: Tensor, c: float) -> Tensor:
    torch._check((a.shape == b.shape), "Shape mismatch")
    torch._check((a.dtype() == b.dtype()), "type mismatch")
    torch._check((a.dtype == torch.float), "not float")
    torch._check((a.device() == b.device()), "device mismatch")
    return torch.empty_like(a)