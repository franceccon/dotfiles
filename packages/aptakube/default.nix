{ lib, stdenv, pkgs, fetchurl, autoPatchelfHook, dpkg, ... }:

stdenv.mkDerivation rec {
  name = "aptakube";
  version = "1.21.1";

  src = fetchurl {
    url = "https://github.com/aptakube/aptakube/releases/download/${version}/aptakube_${version}_amd64.deb";
    sha256 = "sha256-z2YoKyyCOBaapns03b9dzFc9sAtvU/ropqCHioN9F4k=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
  ];

  buildInputs = with pkgs; [ webkitgtk_4_1 ];

  unpackPhase = ''
    runHook preUnpack
    dpkg -X $src .
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r usr/share usr/bin $out
    runHook postInstall
  '';

  meta = with lib; {
    homepage = "";
    description = "";
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    license = [ ];
    platforms = [ "x86_64-linux" ];
    maintainers = [ ];
  };
}
