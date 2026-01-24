{
  lib,
  fetchzip,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation rec {
  pname = "firefox-ui-fix";
  version = "8.7.5";

  src = fetchzip {
    url = "https://github.com/black7375/Firefox-UI-Fix/releases/download/v${version}/Lepton.zip";
    hash = "sha256-HA+JLODHOJuErbXnnG3sB6wxECmrr+XGSWxJHAB9tug=";
    stripRoot = false;
  };

  installPhase = ''
    runHook preInstall
    mkdir -p "$out"
    cp -r . "$out"
    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/black7375/Firefox-UI-Fix";
    downloadPage = "https://github.com/black7375/Firefox-UI-Fix/releases";
    description = "An improvement to Firefox's Proton UI.";
    longDescription = ''
      Custom userChrome.css and user.js for Firefox that improves on the Proton UI.
    '';
    license = licenses.mpl20;
    platforms = platforms.all;
    maintainers = [ maintainers.mithicspirit ];
  };
}
