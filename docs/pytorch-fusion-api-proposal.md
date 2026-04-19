# Proposal: Stabilize TemplateBuffer Fusion API

## Problem

External kernel DSLs (helion, etc.) need to integrate with inductor's fusion
system. Currently, helion probes for fusion support by inspecting bytecode:

```python
# helion/_compat.py (BEFORE)
def supports_torch_compile_fusion():
    select_algorithm = importlib.import_module("torch._inductor.select_algorithm")
    from torch._inductor.ir import TemplateBuffer

    assert hasattr(select_algorithm, "ExternalTritonTemplateKernel")
    init_names = TemplateBuffer.__init__.__code__.co_names
    assert "allow_prologue_fusion" in init_names
    assert "allow_epilogue_fusion" in init_names
```

This breaks on any refactor of `TemplateBuffer.__init__`.

## Changes

### 1. `torch/_inductor/ir.py` -- TemplateBuffer

**BEFORE:**
```python
class TemplateBuffer(OperationBuffer):
    def __init__(
        self,
        layout: OutputSpec,
        inputs: Sequence[IRNode],
        make_kernel_render: Callable[..., Any] | None,
        mutated_inputs: Iterable[IRNode] | None = None,
        allowed_prologue_inps: OrderedSet[str] | None = None,
        named_inputs: dict[str, IRNode] | None = None,
    ) -> None:
        # ... setup code ...

        # These are set as instance attributes at the end of __init__,
        # not constructor parameters. External code must inspect bytecode
        # to discover they exist.
        self.allow_epilogue_fusion: bool | None = None
        self.allow_prologue_fusion: bool | None = None
```

**AFTER:**
```python
class TemplateBuffer(OperationBuffer):
    def __init__(
        self,
        layout: OutputSpec,
        inputs: Sequence[IRNode],
        make_kernel_render: Callable[..., Any] | None,
        mutated_inputs: Iterable[IRNode] | None = None,
        allowed_prologue_inps: OrderedSet[str] | None = None,
        named_inputs: dict[str, IRNode] | None = None,
        *,
        allow_epilogue_fusion: bool | None = None,
        allow_prologue_fusion: bool | None = None,
    ) -> None:
        # ... same setup code ...

        # Fusion overrides. None = fall back to global config.
        # Promoted to constructor kwargs for stable external API.
        self.allow_epilogue_fusion = allow_epilogue_fusion
        self.allow_prologue_fusion = allow_prologue_fusion
```

**What changes:** `allow_epilogue_fusion` and `allow_prologue_fusion` become
keyword-only constructor parameters (with `*` separator) instead of post-init
attributes. Default is still `None`. All existing callers are unaffected
because the new params are keyword-only with the same defaults.

### 2. `torch/_inductor/select_algorithm.py` -- ExternalTritonTemplateKernel

**BEFORE:**
```python
# ExternalTritonTemplateKernel exists but is not documented as a public API.
# External code must use hasattr() to check for its existence.
class ExternalTritonTemplateKernel:
    # ... internal implementation ...
```

**AFTER:**
```python
# Documented as the public integration point for external kernel DSLs.
class ExternalTritonTemplateKernel:
    """Public API for external Triton-based kernel DSLs to integrate with
    inductor's template system.

    External kernels that subclass or use this class can participate in
    inductor's epilogue and prologue fusion when used within torch.compile.

    See TemplateBuffer for fusion control parameters.
    """
    # ... same implementation ...
```

**What changes:** Add a docstring marking it as a public API. No code changes.

### 3. `torch/_inductor/__init__.py` -- Public exports

**BEFORE:**
```python
# ExternalTritonTemplateKernel is not exported
```

**AFTER:**
```python
# In torch/_inductor/__init__.py or a new torch/_inductor/public_api.py
from .select_algorithm import ExternalTritonTemplateKernel

__all__ = [
    ...,
    "ExternalTritonTemplateKernel",
]
```

**What changes:** Export the class so external code can import it directly.

## Effect on helion

**BEFORE (helion/_compat.py):**
```python
def supports_torch_compile_fusion() -> bool:
    if not requires_torch_version("2.11"):
        return False
    try:
        select_algorithm = importlib.import_module("torch._inductor.select_algorithm")
        from torch._inductor.ir import TemplateBuffer

        assert hasattr(select_algorithm, "ExternalTritonTemplateKernel")

        init_names = TemplateBuffer.__init__.__code__.co_names
        assert "allow_prologue_fusion" in init_names
        assert "allow_epilogue_fusion" in init_names
    except (ImportError, AttributeError, AssertionError):
        return False
    return True
```

**AFTER (helion/_compat.py):**
```python
def supports_torch_compile_fusion() -> bool:
    try:
        from torch._inductor.select_algorithm import ExternalTritonTemplateKernel
        return True
    except ImportError:
        return False
```

## Effect on other projects

Any external kernel DSL (not just helion) can now:

1. Import `ExternalTritonTemplateKernel` without worrying about it disappearing
2. Create `TemplateBuffer` instances with explicit fusion control:
   ```python
   buf = TemplateBuffer(
       layout=layout,
       inputs=inputs,
       make_kernel_render=render_fn,
       allow_epilogue_fusion=True,
       allow_prologue_fusion=True,
   )
   ```
3. No bytecode inspection, no version-specific hasattr checks

## Data flow example

### Without fusion (two kernels, memory round trip)

```
Graph: relu(matmul(x, w))

Kernel 1 (matmul):              Kernel 2 (relu):
  x_tile = tl.load(X)            tmp = tl.load(BUF0)  <-- global mem read
  w_tile = tl.load(W)            out = where(tmp>0, tmp, 0)
  acc = tl.dot(x_tile, w_tile)   tl.store(OUT, out)
  tl.store(BUF0, acc)  --> global mem write
```

### With epilogue fusion (one kernel, no round trip)

```
Graph: relu(matmul(x, w))

Single kernel:
  x_tile = tl.load(X)
  w_tile = tl.load(W)
  acc = tl.dot(x_tile, w_tile)
  acc = where(acc > 0, acc, 0)  <-- fused in-register
  tl.store(OUT, acc)            <-- single write
```

### How the scheduler decides

```
TemplateBuffer (matmul):
  allow_epilogue_fusion = True
  epilogue_fusable_outputs = {"buf0": "result"}

ComputedBuffer (relu):
  reads = {"buf0"}   <-- reads matmul output
  data = Pointwise(inner_fn = lambda idx: ops.relu(ops.load("buf0", idx)))

Scheduler sees:
  1. relu reads buf0
  2. buf0 is produced by a TemplateBuffer with allow_epilogue_fusion=True
  3. relu is a simple Pointwise (not a reduction, not a scatter)
  4. Decision: fuse relu's inner_fn into matmul's store path

Result: relu's lambda is injected into the template via <STORE_OUTPUT_0>
placeholder. The template's make_kernel_render receives the fused code
and emits a single kernel.
```

## PR scope

- ~20 lines changed in `ir.py` (move attributes to constructor kwargs)
- ~5 lines in `select_algorithm.py` (add docstring)
- ~3 lines in `__init__.py` (add export)
- Tests: verify existing fusion tests still pass, add test for constructor kwargs
- Backward compatible: all existing callers use positional args that don't change
