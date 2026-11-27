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
  pname = "rex-rune-bin";
  version = "0.13.1";

  src = fetchurl {
    url = "https://github.com/shuv1337/rex-rune/releases/download/v${version}/rex-rune-${version}-x86_64-linux-gnu.tar.gz";
    hash = "sha256-wlDK67/Df80rXM9gXVFj04Zdsjc2eiSzJqBIpTTvArM=";
  };

  nativeBuildInputs = [ autoPatchelfHook makeWrapper ];
  buildInputs = runtimeLibraries ++ [ stdenv.cc.cc.lib ];

  installPhase = ''
    runHook preInstall

    install -Dm755 bin/rex-rune $out/bin/rex-rune
    ln -s rex-rune $out/bin/rex-linux

    install -Dm644 resources/dev.shuv.rex-rune.desktop \
      $out/share/applications/dev.shuv.rex-rune.desktop
    substituteInPlace $out/share/applications/dev.shuv.rex-rune.desktop \
      --replace-fail 'Exec=rex-rune' "Exec=$out/bin/rex-rune"

    for size in 32 128 256; do
      install -Dm644 resources/icons/''${size}x''${size}/apps/dev.shuv.rex-rune.png \
        $out/share/icons/hicolor/''${size}x''${size}/apps/dev.shuv.rex-rune.png
    done

    install -Dm644 LICENSE $out/share/licenses/rex-rune/LICENSE
    cp -r licenses $out/share/licenses/rex-rune/third-party

    runHook postInstall
  '';

  postFixup = ''
    wrapProgram $out/bin/rex-rune \
      --prefix PATH : ${lib.makeBinPath [ fontconfig openssh xdg-utils ]} \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath runtimeLibraries}
  '';

  meta = {
    description = "Native Linux Rune client for existing Rex terminal servers";
    homepage = "https://github.com/shuv1337/rex-rune";
    license = lib.licenses.mit;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "rex-rune";
  };
}
