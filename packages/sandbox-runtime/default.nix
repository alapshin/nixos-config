{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nodejs,
  ripgrep,
  bubblewrap,
  socat,
  stdenv,
  makeWrapper,
  gcc,
  libseccomp,
}:

let
  version = "0.0.26-unstable-2025-01-09";

  src = fetchFromGitHub {
    owner = "anthropic-experimental";
    repo = "sandbox-runtime";
    rev = "f5902cd08e6eb396d148b7cb69cef8d3c7fe7ba7";
    hash = "sha256-Aab/MtXtAShkH4toQfD2w1tc9kdqXcGjM0/N6HI27TI=";
  };

  # Build seccomp binaries from source (Linux only)
  seccomp-binaries = stdenv.mkDerivation {
    pname = "sandbox-runtime-seccomp";
    inherit version src;

    nativeBuildInputs = [
      gcc
      libseccomp
    ];

    buildPhase = ''
      runHook preBuild

      # Determine architecture directory name
      case "${stdenv.hostPlatform.system}" in
        x86_64-linux)
          ARCH_DIR="x64"
          ;;
        aarch64-linux)
          ARCH_DIR="arm64"
          ;;
        *)
          echo "Unsupported architecture: ${stdenv.hostPlatform.system}"
          exit 1
          ;;
      esac

      cd vendor/seccomp-src

      # Build BPF generator (requires libseccomp)
      gcc -o seccomp-unix-block seccomp-unix-block.c -static -lseccomp -O2
      strip seccomp-unix-block

      # Generate BPF filter bytecode
      mkdir -p ../seccomp/$ARCH_DIR
      ./seccomp-unix-block ../seccomp/$ARCH_DIR/unix-block.bpf

      # Build apply-seccomp binary
      gcc -o ../seccomp/$ARCH_DIR/apply-seccomp apply-seccomp.c -static -O2
      strip ../seccomp/$ARCH_DIR/apply-seccomp

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      # Copy the built binaries to output
      mkdir -p $out
      cp -r vendor/seccomp $out/

      runHook postInstall
    '';

    meta = with lib; {
      description = "Seccomp binaries for sandbox-runtime";
      platforms = platforms.linux;
    };
  };

in
buildNpmPackage {
  pname = "sandbox-runtime";
  inherit version src;

  npmDepsHash = "sha256-bKR7jDF/FYnKvsD77oseqHq/UHg5nRHiPoTxbUOkwNk=";

  nativeBuildInputs = [
    nodejs
    makeWrapper
  ];

  # Runtime dependencies
  buildInputs = [
    ripgrep
  ]
  ++ lib.optionals stdenv.isLinux [
    bubblewrap
    socat
  ];

  # Copy seccomp binaries from separate derivation
  postBuild =
    lib.optionalString stdenv.isLinux ''
      mkdir -p vendor
      cp -r ${seccomp-binaries}/seccomp vendor/
      cp -r vendor dist/
    ''
    + lib.optionalString stdenv.isDarwin ''
      # On macOS, copy vendor directory if it exists (no seccomp binaries needed)
      if [ -d vendor ]; then
        cp -r vendor dist/
      fi
    '';

  # Wrap the binary to ensure runtime dependencies are available
  postFixup =
    lib.optionalString stdenv.isLinux ''
      wrapProgram $out/bin/srt \
        --prefix PATH : ${
          lib.makeBinPath [
            bubblewrap
            socat
            ripgrep
          ]
        }
    ''
    + lib.optionalString stdenv.isDarwin ''
      wrapProgram $out/bin/srt \
        --prefix PATH : ${lib.makeBinPath [ ripgrep ]}
    '';

  meta = with lib; {
    description = "A lightweight sandboxing tool for enforcing filesystem and network restrictions on arbitrary processes";
    longDescription = ''
      Anthropic Sandbox Runtime (srt) is a lightweight sandboxing tool for enforcing
      filesystem and network restrictions on arbitrary processes at the OS level,
      without requiring a container. It uses native OS sandboxing primitives
      (sandbox-exec on macOS, bubblewrap on Linux) and proxy-based network filtering.
    '';
    homepage = "https://github.com/anthropic-experimental/sandbox-runtime";
    license = licenses.asl20;
    maintainers = [ ];
    platforms = platforms.unix;
    mainProgram = "srt";
  };
}
