{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, makeWrapper
, fontconfig
, libxkbcommon
, wayland
, libGL
, vulkan-loader
, libx11
, libxcursor
, libxi
, libxrandr
, openssh
, xdg-utils
}:

let
  runtimeLibraries = [
    fontconfig
    libxkbcommon
    wayland
    libGL
    vulkan-loader
    libx11
    libxcursor
    libxi
    libxrandr
  ];
in
stdenv.mkDerivation rec {
  pname = "rex-rune";
  version = "0.4.2";

  src = fetchurl {
    url = "https://github.com/shuv1337/rex-rune/releases/download/v${version}/rex-linux-${version}-x86_64-linux-gnu.tar.gz";
    hash = "sha256-y/bgci4xZate+AqkMQpjUF7UI5lxwzWLnxy1bfuPPD4=";
  };

  nativeBuildInputs = [ autoPatchelfHook makeWrapper ];
  buildInputs = runtimeLibraries ++ [ stdenv.cc.cc.lib ];

  installPhase = ''
    runHook preInstall

    install -Dm755 bin/rex-linux $out/bin/rex-linux
    install -Dm644 resources/dev.shuv.rex-linux.desktop \
      $out/share/applications/dev.shuv.rex-linux.desktop
    substituteInPlace $out/share/applications/dev.shuv.rex-linux.desktop \
      --replace-fail 'Exec=rex-linux' "Exec=$out/bin/rex-linux"
    for size in 32 128 256; do
      install -Dm644 resources/icons/''${size}x''${size}/apps/dev.shuv.rex-linux.png \
        $out/share/icons/hicolor/''${size}x''${size}/apps/dev.shuv.rex-linux.png
    done
    install -Dm644 LICENSE $out/share/licenses/rex-linux/LICENSE
    cp -r licenses $out/share/licenses/rex-linux/third-party

    runHook postInstall
  '';

  postFixup = ''
    wrapProgram $out/bin/rex-linux \
      --prefix PATH : ${lib.makeBinPath [ fontconfig openssh xdg-utils ]} \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath runtimeLibraries}
  '';

  meta = {
    description = "Native Linux Rune client for existing Rex terminal servers";
    homepage = "https://github.com/shuv1337/rex-rune";
    license = lib.licenses.mit;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "rex-linux";
  };
}
