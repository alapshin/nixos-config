{ fetchurl
, lib
, stdenv
,
} @ args:
let
  buildFirefoxXpiAddon = lib.makeOverridable (
    { stdenv ? args.stdenv
    , fetchurl ? args.fetchurl
    , pname
    , version
    , addonId
    , url
    , sha256
    , meta
    , ...
    }:
    stdenv.mkDerivation {
      name = "${pname}-${version}";

      inherit meta;

      src = fetchurl { inherit url sha256; };

      preferLocalBuild = true;
      allowSubstitutes = true;

      buildCommand = ''
        dst="$out/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}"
        mkdir -p "$dst"
        install -v -m644 "$src" "$dst/${addonId}.xpi"
      '';
    }
  );
in
{
  inherit buildFirefoxXpiAddon;

  bypass-paywalls-clean =
    let
      version = "3.2.5.0";
    in
    buildFirefoxXpiAddon {
      pname = "bypass-paywalls-clean";
      inherit version;
      addonId = "{d133e097-46d9-4ecc-9903-fa6a722a6e0e}";
      url = "https://gitlab.com/magnolia1234/bpc-uploads/-/raw/master/bypass_paywalls_clean-${version}.xpi";
      sha256 = "sha256-m1BVji6Ka3+vRlfdulfN+Ffi81pSzlQObgwrSkbr0IU=";
      meta = with lib; {
        homepage = "https://gitlab.com/magnolia1234/bypass-paywalls-firefox-clean";
        description = "Bypass Paywalls of (custom) news sites";
        license = licenses.mit;
        platforms = platforms.all;
      };
    };

  linguist-translator =
    let
      version = "5.0.5";
    in
    buildFirefoxXpiAddon {
      pname = "linguist-translator";
      inherit version;
      addonId = "{33718e7a-4cbc-43da-b9c9-dc14dabf735}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4102378/linguist_translator-${version}.xpi";
      sha256 = "sha256-8/9zjNwvRiFegIgoQfBmwZGhdFszS2047b4t1K7Cr7c=";
      meta = with lib; {
        homepage = "https://github.com/translate-tools/linguist";
        description = "Translate web pages, highlighted text, Netflix subtitles, private messages, speak text, and save important translations to your personal dictionary to learn words in 130 languages.";
        license = licenses.gpl3;
        platforms = platforms.all;
      };
    };
}
