{ lib
, stdenv
, pkgs
, requireFile
, autoPatchelfHook
, makeWrapper
,
}:
stdenv.mkDerivation rec {
  name = "delta";
  version = "0.0.1";

  src = requireFile rec {
    name = "delta-linux-x86_64.tar.gz";
    message = ''
      Please add ${name} to the nixos store by running

      nix-prefetch-url --type sha256 file:///home/fra/Downloads/${name}

      and updating the sha256 below if necessary.
    '';
    sha256 = "0hwqrsb8rr2h7g71qx703gsnwcrka13n8zc8y0m6qwld9pj042xs";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  # Libraries needed for Delta to run
  buildInputs = with pkgs; [
    stdenv.cc.cc.lib
    libGL
    libxkbcommon
    xorg.libX11
    xorg.libXcursor
    xorg.libXi
    xorg.libXrandr
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
    cp -r share $out/

    # Copy the licenses
    cp licenses.md $out/ || true

    # Check if delta exists and create wrapper
    if ![ -f "$out/bin/delta" ]; then
      echo "Could not find delta executable in bin directory"
      ls -la $out/bin
      exit 1
    fi

    # Rename the original binary to avoid conflicts
    mv $out/bin/delta $out/bin/delta-original

    # Create a wrapper script that sets up the correct environment
    makeWrapper $out/bin/delta-original $out/bin/delta \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath buildInputs}
  '';

  meta = {
    description = "High-performance, multiplayer code editor from the creators of Atom and Tree-sitter";
    homepage = "https://delta.dev";
    license = lib.licenses.gpl3Only;
    maintainers = [ ];
    mainProgram = "delta";
    platforms = lib.platforms.linux;
  };
}
