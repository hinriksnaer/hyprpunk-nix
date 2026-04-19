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
    # Hardware backends to enable. Not mutually exclusive -- enable multiple.
    # Available: "cuda", "cute"
    # Future: "rocm", "cpu"
    #
    # cuda -- NVIDIA CUDA toolkit + cuDNN (base GPU support)
    # cute -- CUTLASS library (for CuTe kernel development)
    backends = [ "cuda" ];
  };
}
