{ lib
, stdenvNoCC
, fetchFromGitHub
, libsForQt5
, flavors ? [ "latte" "frappe" "macchiato" "mocha" ]
}:

stdenvNoCC.mkDerivation {
  pname = "catppuccin-sddm";
  version = "unstable-2024-02-03";

  src = fetchFromGitHub {
    owner = "catppuccin";
    repo = "sddm";
    rev = "ecaeb499257010a667f3d403f4a286769f702983";
    hash = "sha256-SZnK4IMzojdNMkyuhvi8Pw7hw/JPDVq16O824msNc1I=";
  };

  # From https://github.com/catppuccin/sddm/blob/95bfcba80a3b0cb5d9a6fad422a28f11a5064991/README.md
  propagatedUserEnvPkgs = with libsForQt5; [ qtgraphicaleffects qtquickcontrols2 qtsvg ];

  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/share/sddm/themes/"
    cp -r ${lib.concatMapStringsSep " " (flavor: "src/catppuccin-${flavor}") flavors} "$out/share/sddm/themes/"

    runHook postInstall
  '';

  meta = {
    description = "Soothing pastel theme for SDDM";
    homepage = "https://github.com/catppuccin/sddm";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ Scrumplex ];
    platforms = lib.platforms.linux;
  };
}
