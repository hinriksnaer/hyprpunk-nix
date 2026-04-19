{ pkgs, lib, config, ... }:

let
  cfg = config.helion;
  has = backend: builtins.elem backend cfg.backends;

  # Packages per backend
  backendPackages = {
    cuda = with pkgs; [ cudaPackages.cudatoolkit cudaPackages.cudnn ];
    cute = with pkgs; [ cudaPackages.cutlass ];
    # rocm = with pkgs; [ rocmPackages.clr rocmPackages.rocm-smi ];
    # cpu = [];
  };

  # Env vars per backend
  backendEnv = lib.optionalAttrs (has "cuda" || has "cute") {
    CUDA_HOME = "${pkgs.cudaPackages.cudatoolkit}";
  };
  # // lib.optionalAttrs (has "rocm") {
  #   ROCM_PATH = "${pkgs.rocmPackages.clr}";
  # };

  # Pip extras for helion install
  pipExtras = lib.concatStringsSep "," (
    lib.optional (has "cute") "cute-cu12"
    # ++ lib.optional (has "rocm") "rocm"
  );

  selectedPackages = lib.concatMap (b: backendPackages.${b} or []) cfg.backends;
in
{
  options.helion = {
    backends = lib.mkOption {
      type = lib.types.listOf (lib.types.enum [ "cuda" "cute" /* "rocm" "cpu" */ ]);
      default = [ "cuda" ];
      description = "Hardware backends to enable (not mutually exclusive)";
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
    ] ++ selectedPackages;

    environment.sessionVariables = backendEnv // {
      HELION_BACKENDS = builtins.concatStringsSep "," cfg.backends;
      HELION_PIP_EXTRAS = if pipExtras != "" then "[${pipExtras}]" else "";
    };
  };
}
