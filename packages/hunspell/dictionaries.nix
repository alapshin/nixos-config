{
  lib,
  stdenv,
  fetchFromGitHub,
}:
let
  mkDict =
    {
      pname,
      readmeFile,
      dictFileName,
      ...
    }@args:
    stdenv.mkDerivation (
      {
        inherit pname;
        installPhase = ''
          runHook preInstall
          # hunspell dicts
          install -dm755 "$out/share/hunspell"
          install -m644 ${dictFileName}.dic "$out/share/hunspell/"
          install -m644 ${dictFileName}.aff "$out/share/hunspell/"
          # myspell dicts symlinks
          install -dm755 "$out/share/myspell/dicts"
          ln -sv "$out/share/hunspell/${dictFileName}.dic" "$out/share/myspell/dicts/"
          ln -sv "$out/share/hunspell/${dictFileName}.aff" "$out/share/myspell/dicts/"
          # docs
          install -dm755 "$out/share/doc"
          install -m644 ${readmeFile} $out/share/doc/${pname}.txt
          runHook postInstall
        '';
      }
      // args
    );
  mkDictFromLibreOffice =
    {
      shortName,
      shortDescription,
      dictFileName,
      license,
      readmeFile ? "README_${dictFileName}.txt",
      sourceRoot ? dictFileName,
    }:
    mkDict rec {
      pname = "hunspell-dict-${shortName}-libreoffice";
      version = "6.3.0.4";
      inherit dictFileName readmeFile;
      src = fetchFromGitHub {
        owner = "LibreOffice";
        repo = "dictionaries";
        rev = "libreoffice-${version}";
        sha256 = "14z4b0grn7cw8l9s7sl6cgapbpwhn1b3gwc3kn6b0k4zl3dq7y63";
      };
      buildPhase = ''
        cp -a ${sourceRoot}/* .
      '';
      meta = with lib; {
        homepage = "https://wiki.documentfoundation.org/Development/Dictionaries";
        description = "Hunspell dictionary for ${shortDescription} from LibreOffice";
        license = license;
        maintainers = with maintainers; [ vlaci ];
        platforms = platforms.all;
      };
    };
in
{
  sr = mkDictFromLibreOffice {
    shortName = "sr";
    dictFileName = "sr";
    shortDescription = "Serbian";
    readmeFile = "README.txt";
    license = with lib.licenses; [
      gpl2
      lgpl21
      mpl11
    ];
  };
}
