{ lib, stdenv, pkgs, fetchurl, installShellFiles }:

stdenv.mkDerivation rec {
  name = "gitbutler-cli";
  version = "0.23.2-3329";

  src = fetchurl {
    url = "https://releases.gitbutler.com/releases/release/${version}/linux/x86_64/but";
    sha256 = "sha256-kufbn/9UiK81+HKx0RyFACLVwYdQhaygs7elF6MbKNU=";
  };

  nativeBuildInputs = with pkgs; [
    installShellFiles
    writableTmpDirAsHomeHook
  ];

  unpackPhase = ''
    mkdir -p gitbutler
    cp $src gitbutler/but
  '';

  installPhase = ''
    runHook preInstall

    install -D -t $out/bin gitbutler/*

    runHook postInstall
  '';

  preFixup =
    let
      libPath = [
        pkgs.dbus.lib
        pkgs.zlib
        stdenv.cc.cc.libgcc or null
      ];
    in
    ''
      patchelf \
        --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
        --set-rpath "${lib.makeLibraryPath libPath}" \
        $out/bin/but
    '';

  postFixup = ''
    installShellCompletion --cmd but \
      --bash <($out/bin/but completions bash) \
      --fish <($out/bin/but completions fish) \
      --zsh <($out/bin/but completions zsh)
  '';

  meta = with lib; {
    homepage = "";
    description = "";
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    license = [ licenses.unfree ];
    platforms = [ "x86_64-linux" ];
    maintainers = [ ];
  };
}
