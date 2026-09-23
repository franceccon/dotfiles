# Cap — open-source screen recorder (CapSoftware/Cap), Tauri + webkitgtk.
#
# Upstream ships macOS, Windows and a Linux .deb; there is no Nix package and no
# GitHub release asset (the artifacts live on CrabNebula's CDN, which is what
# https://cap.so/download/linux-deb redirects to). So this unpacks the .deb the
# same way packages/goose-desktop.nix does.
#
# BUMPING: the CDN asset id is opaque and changes every release — there is no
# versioned URL (`/download/cap/cap/<version>/deb-x86_64` is a 404). Re-resolve
# it and take the new hash:
#
#   curl -sIL -o /dev/null -w '%{url_effective}\n' https://cap.so/download/linux-deb
#   nix store prefetch-file --json <that url> | jq -r .hash
#
# package definition from https://github.com/vpittamp/nixos-config
{ lib
, stdenv
, fetchurl
, dpkg
, autoPatchelfHook
, makeWrapper
, wrapGAppsHook3
, alsa-lib
, cairo
, gdk-pixbuf
, glib
, gtk3
, libayatana-appindicator
, gst_all_1
, libdrm
, libGL
, libsoup_3
, libva
, openssl
, pipewire
, libxkbcommon
, pulseaudio
, vulkan-loader
, wayland
, webkitgtk_4_1
, libx11
}:

let
  version = "0.5.9";

  src = fetchurl {
    url = "https://cdn.crabnebula.app/asset/01KZEFJYCGN6YJ32PQ7AX334RZ";
    name = "cap-${version}-amd64.deb";
    hash = "sha256-4HzsmdG7nIYmAoZjcyIeLq4sOo7lljRqAUbTQcIkbMI=";
  };

  # Everything the shipped ELFs actually NEED, read off `patchelf --print-needed`
  # over usr/bin/* and the bundled usr/lib/cap/*.so. The ffmpeg family
  # (libav*, libsw*, libpostproc) and libonnxruntime/libheif are vendored in the
  # .deb, so they are deliberately absent here and resolved through the extra
  # runpath added below instead.
  runtimeLibs = [
    alsa-lib
    cairo
    gdk-pixbuf
    glib
    gtk3
    libayatana-appindicator
    libsoup_3
    libva
    openssl
    pipewire
    webkitgtk_4_1
    libx11
    stdenv.cc.cc.lib
  ];

  # webkitgtk plays HTML5 media through GStreamer and loads the elements as
  # plugins at runtime. With none on the path the WebProcess does not degrade to
  # a silent poster frame — it takes SIGSEGV inside MediaPlayerPrivateGStreamer
  # the moment a page touches a <video>, which Cap's welcome screen does. The
  # window then stays up but paints nothing at all, so this reads as "the app
  # launched and is invisible" rather than as a media failure.
  gstPlugins = with gst_all_1; [
    gstreamer
    gst-plugins-base
    gst-plugins-good
    gst-plugins-bad
    gst-libav
  ];

  # Resolved by dlopen rather than by DT_NEEDED, so autoPatchelf cannot see them
  # and they have to go on LD_LIBRARY_PATH instead.
  dlopenLibs = [
    libayatana-appindicator
    libva
    libGL
    libdrm
    libxkbcommon
    wayland
    # wgpu dlopens libvulkan.so.1. Without it, it does not fail loudly — it
    # quietly falls back to its OpenGL backend, reports
    # adapter_backend=Gl / device_type=Other, and then dies creating the device:
    #   "Failed to setup renderer: Parent device is lost"
    # which reads as a driver problem rather than a missing loader. With it,
    # the same call picks the discrete GPU over Vulkan and the export runs.
    # /run/opengl-driver/lib carries the Mesa ICDs but not the loader itself.
    vulkan-loader
  ];
in
stdenv.mkDerivation {
  pname = "cap";
  inherit version src;

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    makeWrapper
    wrapGAppsHook3
  ];

  buildInputs = runtimeLibs;

  # The vendored ffmpeg/onnxruntime sit next to the binaries rather than in a
  # standard prefix, so give every patched ELF an explicit runpath entry for
  # them instead of relying on autoPatchelf's search of buildInputs.
  appendRunpaths = [ "${placeholder "out"}/lib/cap" ];

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x $src .
    runHook postUnpack
  '';

  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/lib $out/share
    cp -r usr/lib/cap $out/lib/cap
    cp -r usr/lib/Cap $out/lib/Cap
    cp -r usr/share/applications $out/share/applications
    cp -r usr/share/icons $out/share/icons

    for b in Cap cap-cli cap-exporter cap-muxer; do
      install -Dm755 usr/bin/$b $out/bin/$b
    done

    # `cap` is the name a person types; `Cap` is the name the .desktop file and
    # StartupWMClass use, so keep both pointing at the same binary.
    ln -s $out/bin/Cap $out/bin/cap

    substituteInPlace $out/share/applications/Cap.desktop \
      --replace-fail 'Exec=Cap' "Exec=$out/bin/Cap"

    runHook postInstall
  '';

  preFixup = ''
    gappsWrapperArgs+=(
      # webkitgtk's DMABUF renderer draws an empty window under the NVIDIA
      # driver, which is exactly what ryzen runs. Disabling it costs a little
      # WebView compositing performance and is the difference between a UI and
      # a blank rectangle. Harmless on the AMD/Intel machines.
      --set-default WEBKIT_DISABLE_DMABUF_RENDERER 1

      # The tray icon is dlopen'd by soname (libappindicator-sys tries
      # libayatana-appindicator3.so.1, then libappindicator3.so), and a dlopen
      # is invisible to autoPatchelf — nothing NEEDs the library, so it never
      # lands in any RUNPATH and Cap panics on startup:
      #   "Failed to load ayatana-appindicator3 or appindicator3 dynamic library"
      # The rest are here for the same reason: VAAPI loads its driver at
      # runtime, and the GL/wayland/xkb libraries are resolved late by GTK.
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath dlopenLibs}
      --prefix GST_PLUGIN_SYSTEM_PATH_1_0 : ${
        lib.makeSearchPathOutput "lib" "lib/gstreamer-1.0" gstPlugins
      }

      # System-audio capture shells out to `pactl` to find the monitor source.
      # Upstream's .deb declares pulseaudio-utils for this; without it Cap
      # reports "no monitor input found", which points at ALSA config rather
      # than at a missing binary (see CapSoftware/Cap#2142).
      --prefix PATH : ${lib.makeBinPath [ pulseaudio ]}
    )
  '';

  meta = {
    description = "Open source screen recorder — beautiful, shareable recordings";
    homepage = "https://cap.so";
    downloadPage = "https://cap.so/download";
    # AGPLv3, except the cap-camera*/scap-* crates which are MIT. This package
    # ships upstream's prebuilt .deb rather than building from that source.
    license = lib.licenses.agpl3Only;
    platforms = [ "x86_64-linux" ];
    mainProgram = "Cap";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
