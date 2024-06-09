{ inputs, ... }: {
  # This one brings our custom packages from the 'packages' directory
  additions = final: prev: import ../packages { inherit final prev; };

  # https://nixos.wiki/wiki/Overlays
  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  modifications = final: prev: {
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

    radarr = prev.radarr.overrideAttrs (oldAttrs: rec {
      version = "5.6.0.8846";
      src = prev.fetchurl {
        hash = "sha256-rKe1xQR3lkPXQBUWmKdHUu/AQ99U1kCINeXV2z/ZG5o=";
        url = builtins.replaceStrings
          [
            oldAttrs.version
          ]
          [
            version
          ]
          oldAttrs.src.url;
      };
    });

    readarr = prev.readarr.overrideAttrs (oldAttrs: rec {
      pname = "readarr";
      version = "0.3.27.2538";
      src = prev.fetchurl {
        hash = "sha256-JKGLMu7rIhMAJM2bThTQiHDgc449gWQwmku/yQEAXL4=";
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

    sonarr = prev.sonarr.overrideAttrs (oldAttrs: rec {
      pname = "sonarr";
      version = "4.0.5.1710";
      src = prev.fetchurl {
        hash = "sha256-MkRKWMhH4x5Z9mURh8qpShaozHrBFOHHwTmFlU1wqS8=";
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

        makeWrapper "${prev.dotnet-runtime}/bin/dotnet" $out/bin/NzbDrone \
          --add-flags "$out/share/sonarr-${version}/Sonarr.dll" \
          --prefix PATH : ${prev.lib.makeBinPath [ prev.ffmpeg ]} \
          --prefix LD_LIBRARY_PATH : ${prev.lib.makeLibraryPath [ prev.curl prev.sqlite prev.openssl prev.icu prev.zlib ]}

        runHook postInstall
      '';
    });

    prowlarr = prev.prowlarr.overrideAttrs (oldAttrs: rec {
      version = "1.17.2.4511";
      src = prev.fetchurl {
        hash = "sha256-bYIavvea6Nwbn22CFiWXpzPGAI13oJYAIZr2FdLkyb8=";
        url = builtins.replaceStrings
          [
            oldAttrs.version
          ]
          [
            version
          ]
          oldAttrs.src.url;
      };
    });
  };

  pr-packages = final: _prev: {
    prs = import inputs.authelia {
      system = final.system;
    };
  };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs {
      system = final.system;
    };
  };
}
