{ inputs, ... }: {
  # This one brings our custom packages from the 'packages' directory
  additions = final: prev: import ../packages { inherit final prev; };

  # https://nixos.wiki/wiki/Overlays
  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  modifications = final: prev: {
    authelia = inputs.authelia.legacyPackages.${final.system}.authelia;

    nerdfonts = prev.nerdfonts.override {
      fonts = [
        "JetBrainsMono"
      ];
    };

    lidarr = prev.lidarr.overrideAttrs (oldAttrs: rec {
      pname = "lidarr";
      version = "2.3.3.4204";
      src = prev.fetchurl {
        hash = "sha256-ulWg9BhDr/RFE4sfXGf+i9W0KpOYKjtk49qBeIwI9dU=";
        url = builtins.replaceStrings
          [
            oldAttrs.version
          ]
          [
            version
          ]
          oldAttrs.src.url;
      };
      installPhase = ''
        runHook preInstall

        mkdir -p $out/{bin,share/${pname}-${version}}
        cp -r * $out/share/${pname}-${version}/.
        makeWrapper "${prev.dotnet-runtime}/bin/dotnet" $out/bin/Lidarr \
          --add-flags "$out/share/${pname}-${version}/Lidarr.dll" \
          --prefix LD_LIBRARY_PATH : ${prev.lib.makeLibraryPath [
              prev.curl prev.sqlite prev.libmediainfo prev.icu  prev.openssl prev.zlib
          ]}

        runHook postInstall
      '';
    });

    readarr = prev.readarr.overrideAttrs (oldAttrs: rec {
      pname = "readarr";
      version = "0.3.28.2554";
      src = prev.fetchurl {
        hash = "sha256-GncaJNZEbApPl6Tt9k0NblRPdYnOGiR1V6VTJB8+LIU=";
        url = builtins.replaceStrings
          [
            oldAttrs.version
          ]
          [
            version
          ]
          oldAttrs.src.url;
      };

      installPhase = ''
        runHook preInstall

        mkdir -p $out/{bin,share/${pname}-${version}}
        cp -r * $out/share/${pname}-${version}/.
        makeWrapper "${prev.dotnet-runtime}/bin/dotnet" $out/bin/Readarr \
          --add-flags "$out/share/${pname}-${version}/Readarr.dll" \
          --prefix LD_LIBRARY_PATH : ${prev.lib.makeLibraryPath [
            prev.curl prev.sqlite prev.libmediainfo prev.icu prev.openssl prev.zlib
          ]}

        runHook postInstall
      '';
    });

  };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs {
      system = final.system;
    };
  };
}
