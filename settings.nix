# ── User settings ──
# Single source of truth for all user-specific configuration.
# Change these values to match your system, then rebuild.
{
  username = "hawker";

  # Projects to include in the dev container.
  # Each entry pulls in project-specific packages and setup scripts.
  # Available: "helion"
  projects = [ "helion" ];

  # Helion configuration
  helion = {
    # Hardware backend for GPU kernel compilation.
    # "cuda" -- NVIDIA CUDA toolkit + cuDNN
    # "cute" -- CUDA + cuDNN + CUTLASS (for CuTe kernels)
    backend = "cuda";
  };
}
