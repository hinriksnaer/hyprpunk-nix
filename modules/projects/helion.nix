{ pkgs, lib, config, ... }:

let
  cfg = config.helion;
in
{
  options.helion = {
    cute = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable CUTLASS/CuTe kernel development";
    };
  };

  config = {
    environment.systemPackages = with pkgs; [
      # Python
      python3
      python3Packages.pip
      python3Packages.virtualenv
      uv

      # Build tools
      clang_20
      zlib
      ninja

      # CUDA (always included)
      cudaPackages.cudatoolkit
      cudaPackages.cudnn
    ] ++ lib.optionals cfg.cute [
      # CuTe/CUTLASS (opt-in)
      cudaPackages.cutlass
    ];

    environment.sessionVariables = {
      CUDA_HOME = "${pkgs.cudaPackages.cudatoolkit}";
      HELION_CUTE = if cfg.cute then "1" else "";
      HELION_PIP_EXTRAS = if cfg.cute then "[cute-cu12]" else "";
    };
  };
}
