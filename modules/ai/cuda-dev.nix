# Shared CUDA + Python development base.
# Imported by project modules that need GPU development tools.
# Packages deduplicate via NixOS module system -- safe to import multiple times.
{ pkgs, ... }:

let
  cudaPackages = pkgs.cudaPackages;
in
{
  environment.systemPackages = with pkgs; [
    # Python
    python3
    python3Packages.pip
    python3Packages.virtualenv
    uv

    # CUDA -- individual packages + dev outputs for headers
    cudaPackages.cudatoolkit
    cudaPackages.cudnn
    cudaPackages.cudnn.dev
    cudaPackages.cudnn.lib
    cudaPackages.cuda_cudart
    cudaPackages.cuda_nvcc

    # Build tools
    cmake
    ninja
    gcc
    gnumake
    pkg-config
    zlib
  ];

  environment.sessionVariables = {
    CUDA_HOME = "${cudaPackages.cudatoolkit}";
    CUDA_PATH = "${cudaPackages.cudatoolkit}";
    CUDNN_INCLUDE_DIR = "${cudaPackages.cudnn.dev}/include";
    CUDNN_LIB_DIR = "${cudaPackages.cudnn.lib}/lib";
    # nvcc calls gcc which needs cuda_runtime.h + cudnn.h
    CPATH = "${cudaPackages.cuda_cudart}/include:${cudaPackages.cudnn.dev}/include";
  };
}
