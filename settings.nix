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
    # Enable CUTLASS/CuTe kernel development (adds cutlass package
    # and installs helion with [cute-cu12] extras).
    # CUDA toolkit + cuDNN are always included.
    cute = false;
  };
}
