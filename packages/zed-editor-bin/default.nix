{ lib
, stdenv
, pkgs
, fetchurl
, autoPatchelfHook
, makeWrapper
,
}:
stdenv.mkDerivation rec {
  name = "zed-editor";
  version = "1.22.0";

  src = fetchurl {
    url = "https://github.com/zed-industries/zed/releases/download/v${version}/zed-linux-x86_64.tar.gz";
    sha256 = "sha256-XOOZGzSo+tCiNiX1ghzaYBxxUKbMaWg8CXuNGwg6vFA=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  # Libraries needed for Zed to run
  buildInputs = with pkgs; [
    stdenv.cc.cc.lib
    glib
    libGL
    libxkbcommon
    libx11
    libxcursor
    libxi
    libxrandr
    openssl
    alsa-lib
    vulkan-loader
    wayland
  ];

  installPhase = ''
    # Create the destination directory
    mkdir -p $out

    # Copy all directories from the app structure
    cp -r bin $out/
    cp -r lib $out/
    cp -r libexec $out/
    cp -r share $out/

    # Copy the licenses
    cp licenses.md $out/ || true

    # Check if zed exists and create wrapper
    if ![ -f "$out/bin/zed" ]; then
      echo "Could not find zed executable in bin directory"
      ls -la $out/bin
      exit 1
    fi
    # Rename the original binary to avoid conflicts
    mv $out/bin/zed $out/bin/zed-original

    # Create a wrapper script that sets up the correct environment
    makeWrapper $out/bin/zed-original $out/bin/zed \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath buildInputs}
  '';

  meta = {
    description = "High-performance, multiplayer code editor from the creators of Atom and Tree-sitter";
    homepage = "https://zed.dev";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [
      GaetanLepage
      niklaskorz
    ];
    mainProgram = "zed";
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
}
