{ pkgs, ... }:

pkgs.stdenv.mkDerivation {
  name = "clang-r547379";
  src = pkgs.fetchurl {
    url = "https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/refs/heads/master/clang-r547379.tar.gz";
    sha256 = "sha256-I+AbYWGku69YAVotDLg7/JG9RZ4vTqDctz3Y+4cTzqE=";
  };
  nativeBuildInputs = [ pkgs.autoPatchelfHook ];
  buildInputs = [
    pkgs.stdenv.cc.cc.lib
    pkgs.zlib
    pkgs.libxml2
  ];

  sourceRoot = ".";
  autoPatchelfIgnoreMissingDeps = [
    "liblog.so"
    "libbz2.so.1"
    "libncursesw.so.5"
    "libtinfo.so.5"
    "libcrypt.so.1"
    "libpanelw.so.5"
  ];

  installPhase = ''
    mkdir -p $out
    cp -r . $out
  '';
}
