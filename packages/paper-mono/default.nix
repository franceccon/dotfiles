{ lib, stdenv, fetchurl, pkgs }:
stdenv.mkDerivation rec {
  pname = "paper-mono";
  version = "1.000";
  src = fetchurl {
    url = "https://github.com/paper-design/${pname}/releases/download/v${version}/${pname}-v${version}.zip";
    sha256 = "sha256-hkJlKYXch79M/QfImUKJnmEcPHdPwlKEwN1P6GqZOhM=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -vp $out/share/fonts/opentype

    mv -v paper-mono-v1.000/fonts/otf/*.otf $out/share/fonts/opentype

    runHook postInstall
  '';

  sourceRoot = ".";
  nativeBuildInputs = [ pkgs.unzip ];
  buildInputs = [ pkgs.unzip ];

  meta = with lib; {
    description = "";
    homepage = "https://paper.design/mono";
    license = licenses.unfree;
    maintainers = [ ];
    platforms = platforms.all;
  };
}
