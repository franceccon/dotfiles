{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, wrapGAppsHook3
, nix-update-script
, cairo
, fontconfig
, freetype
, gdk-pixbuf
, glib
, glib-networking
, gtk-layer-shell
, gtk3
, harfbuzz
, libayatana-appindicator
, libepoxy
, libGL
, libsecret
, libsoup_3
, libx11
, pango
, webkitgtk_4_1
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "kero";
  version = "2.1.31";

  src = fetchurl {
    url = "https://github.com/egoist/kero/releases/download/v${finalAttrs.version}/kero-${finalAttrs.version}-linux-amd64.tar.gz";
    hash = "sha256-peiEdxTdTeYBNEV0JWe7QUJt9G2pE5MRxdRcCWuDUhE=";
  };

  sourceRoot = ".";

  nativeBuildInputs = [
    autoPatchelfHook
    wrapGAppsHook3
  ];

  buildInputs = [
    cairo
    gdk-pixbuf
    glib
    glib-networking
    gtk3
    harfbuzz
    libsoup_3
    webkitgtk_4_1
  ];

  # The Go binary dlopens these libraries at runtime.
  runtimeLibs = lib.makeLibraryPath [
    cairo
    fontconfig
    freetype
    gdk-pixbuf
    glib
    gtk-layer-shell
    gtk3
    harfbuzz
    libayatana-appindicator
    libepoxy
    libGL
    libsecret
    libsoup_3
    libx11
    pango
    webkitgtk_4_1
  ];

  dontWrapGApps = true;

  installPhase = ''
    runHook preInstall

    # Keep the binary beside its terminal library, fonts and daemon executable.
    install -Dm755 -t $out/lib/kero kero libghostty-vt.so
    cp -r fonts $out/lib/kero/

    install -Dm644 kero.png $out/share/pixmaps/kero.png
    install -Dm644 kero.desktop $out/share/applications/kero.desktop

    runHook postInstall
  '';

  preFixup = ''
    makeWrapper $out/lib/kero/kero $out/bin/kero \
      "''${gappsWrapperArgs[@]}" \
      --set GTK_USE_PORTAL 1 \
      --prefix LD_LIBRARY_PATH : "$runtimeLibs"
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Native terminal app for running coding agents in sessions that outlive the window";
    homepage = "https://kero.sh";
    changelog = "https://github.com/egoist/kero/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    mainProgram = "kero";
    platforms = [ "x86_64-linux" ];
  };
})
