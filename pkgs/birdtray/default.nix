{ stdenv, fetchurl, qmake, qtbase, qtx11extras, sqlite }:


stdenv.mkDerivation rec {
  name = "birdtray-${version}";
  version = "1.4";

  src = fetchurl {
    url = "https://github.com/gyunaev/birdtray/archive/${version}.tar.gz";
    sha256 = "1k25s9fj5kpxv5dnlb17m8rhx0iyn6ajc6zbcz240dkajiz8cfq7";
  };

  buildInputs = [ qtbase qtx11extras sqlite ];
  nativeBuildInputs = [ qmake ];
  enableParallelBuilding = true;

  preConfigure = "cd src";
  postInstall = ''
    mkdir -p $out/bin
    cp birdtray $out/bin
  '';

  meta = with stdenv.lib; {
    description = "Tray support for Thunderbird";
    longDescription=''
      Birdtray is a system tray new mail notification for Thunderbird 60+
      which does not require extensions.
    '';
    homepage = https://github.com/gyunaev/birdtray;
    license = licenses.gpl3;
    platforms = platforms.linux;
    maintainers = with maintainers; [ alapshin ];
  };
}
