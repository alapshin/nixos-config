{ lib
, stdenv
, python3
, radicale3
, rustPlatform
, fetchFromGitHub
}:

let
  python = python3.override {
    packageOverrides = self: super: {
      flask-wtf = super.flask-wtf.overridePythonAttrs (old: rec {
        version = "0.15.1";
        src = old.src.override {
          inherit version;
          sha256 = "ff177185f891302dc253437fe63081e7a46a4e99aca61dfe086fb23e54fff2dc";
        };
        patches = [];
        doCheck = false;
      });


      etebase = super.etebase.overridePythonAttrs (old: rec {
        pname = "etebase";
        version = "0.31.6";

        src = fetchFromGitHub {
          owner = "etesync";
          repo = "etebase-py";
          rev = "v${version}";
          hash = "sha256-T61nPW3wjBRjmJ81w59T1b/Kxrwwqvyj3gILE9OF/5Q=";
        };
        cargoDeps = rustPlatform.fetchCargoTarball {
          inherit src;
          name = "${pname}-${version}";
          hash = "sha256-wrMNtcaLAsWBVeJbYbYo+Xmobl01lnUbR9NUqqUzUgU=";
        };
      });
    };
  };
in python.pkgs.buildPythonApplication rec {
  pname = "etesync-dav";
  version = "0.32.1";

  src = python.pkgs.fetchPypi {
    inherit pname version;
    sha256 = "a4e2ee83932755d29ac39c1e74005ec289880fd2d4d2164f09fe2464a294d720";
  };

  propagatedBuildInputs = with python.pkgs; [
    appdirs
    etebase
    etesync
    flask
    flask-wtf
    msgpack
    pysocks
    setuptools
    (python.pkgs.toPythonModule (radicale3.override { python3 = python; }))
    requests
  ] ++ requests.optional-dependencies.socks;

  doCheck = false;

  meta = with lib; {
    homepage = "https://www.etesync.com/";
    description = "Secure, end-to-end encrypted, and privacy respecting sync for contacts, calendars and tasks";
    license = licenses.gpl3;
    maintainers = with maintainers; [ valodim ];
    broken = stdenv.isDarwin; # pyobjc-framework-Cocoa is missing
  };
}
