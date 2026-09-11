{ lib
, appimageTools
, fetchurl
,
}:
let
  pname = "tldraw-offline";
  version = "1.18.0";

  src = fetchurl {
    url = "https://github.com/tldraw/tldraw-offline/releases/download/v${version}/tldraw-offline-linux-x86_64.AppImage";
    hash = "sha256-WmST1Mv1bCJyLQ+Tah2Y2AvceXacDR+GxDElcCE7s+k=";
  };

  appimageContents = appimageTools.extractType2 { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -m 444 -D ${appimageContents}/${pname}.desktop -t $out/share/applications
    substituteInPlace $out/share/applications/${pname}.desktop \
      --replace-fail 'Exec=AppRun' 'Exec=${pname}'
    cp -r ${appimageContents}/usr/share/icons $out/share
    cp -r ${appimageContents}/usr/share/mime $out/share
  '';

  meta = {
    description = "Desktop app for using tldraw with local files";
    homepage = "https://github.com/tldraw/tldraw-offline";
    license = lib.licenses.unfree;
    mainProgram = pname;
    maintainers = [ ];
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}
