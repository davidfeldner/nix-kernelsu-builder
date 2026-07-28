{
  pkgs,
  lib,
  # User args
  clangVersion,
  src,
  arch,
  defconfigs,
  kernelSU,
  susfs,
  bbg,
  makeFlags,
  additionalKernelConfig ? "",
  stdenv,
  ...
}:
let
  clang-r547379 = pkgs.callPackage ../pkgs/android-clang-r547379.nix { };
  finalMakeFlags = [
    "ARCH=${arch}"
    "O=$out"
    "LLVM=1"
    "LLVM_IAS=1"
    "CC=${clang-r547379}/bin/clang"
    "LD=${clang-r547379}/bin/ld.lld"
    "AR=${clang-r547379}/bin/llvm-ar"
    "NM=${clang-r547379}/bin/llvm-nm"
    "OBJCOPY=${clang-r547379}/bin/llvm-objcopy"
    "OBJDUMP=${clang-r547379}/bin/llvm-objdump"
    "STRIP=${clang-r547379}/bin/llvm-strip"
    "HOSTCC=${pkgs.stdenv.cc}/bin/cc"
    "HOSTCXX=${pkgs.stdenv.cc}/bin/c++"
    "HOSTLD=${pkgs.stdenv.cc}/bin/ld"

    "CROSS_COMPILE=aarch64-linux-gnu-"
  ]
  ++ makeFlags;

  defconfig = lib.last defconfigs;
  kernelConfigCmd = pkgs.callPackage ./kernel-config-cmd.nix {
    inherit
      arch
      defconfig
      defconfigs
      additionalKernelConfig
      kernelSU
      susfs
      bbg
      finalMakeFlags
      ;
  };
in
stdenv.mkDerivation {
  name = "clang-kernel-${builtins.toString clangVersion}";
  inherit src;

  nativeBuildInputs =
    with pkgs;
    [
      bc
      bison
      flex
      openssl
      perl
      python3
      zlib
      xz
      cpio
      breakpointHook
    ]
    ++ [ clang-r547379 ];

  env.NIX_CC_WRAPPER_SUPPRESS_TARGET_WARNING = "1";

  hardeningDisable = [ "all" ];

  buildPhase = ''
    runHook preBuild

    ${kernelConfigCmd}

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    make -j$(nproc) \
      HOSTCC=${pkgs.stdenv.cc}/bin/cc \
      HOSTCXX=${pkgs.stdenv.cc}/bin/c++ \
      HOSTLD=${pkgs.stdenv.cc}/bin/ld \
      ${builtins.concatStringsSep " " finalMakeFlags}

    runHook postInstall
  '';

  dontFixup = true;
}
