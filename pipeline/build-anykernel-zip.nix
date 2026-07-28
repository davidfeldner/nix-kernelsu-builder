{
  stdenv,
  lib,
  zip,
  callPackage,
  # User args
  arch,
  kernel,
  kernelImageName,
  variant,
  ...
}:
let
  sources = callPackage ../_sources/generated.nix { };
in
stdenv.mkDerivation {
  name = "anykernel-zip";
  inherit (sources."anykernel-${variant}") src;

  nativeBuildInputs = [ zip ];

  postPatch = lib.optionalString (variant == "osm0sis") ''
    substituteInPlace anykernel.sh \
      --replace-fail "kernel.string=ExampleKernel by osm0sis @ xda-developers" "kernel.string=Very Cool Lineage Kernel" \
      --replace-fail "IS_SLOT_DEVICE=0" "IS_SLOT_DEVICE=1" \
      --replace-fail "device.name1=maguro" "device.name1=alioth" \
      --replace-fail "device.name2=toro" "device.name2=aliothin" \
      --replace-fail "device.name3=toroplus" "device.name3=" \
      --replace-fail "device.name4=tuna" "device.name4=" \
      --replace-fail "BLOCK=/dev/block/platform/omap/omap_hsmmc.0/by-name/boot;" "BLOCK=/dev/block/bootdevice/by-name/boot;"
  '';

  buildPhase = ''
    runHook preBuild

    cp ${kernel}/arch/${arch}/boot/${kernelImageName} .
    if [ -f ${kernel}/arch/${arch}/boot/dtbo.img ]; then
      cp ${kernel}/arch/${arch}/boot/dtbo.img .
    fi

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    zip -r $out/anykernel.zip *

    runHook postInstall
  '';

  dontFixup = true;
}
