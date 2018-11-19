{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  version = "2018-09-27";
  name = "zsh-nix-shell-${version}";

  src = fetchFromGitHub {
    owner = "chisui";
    repo = "zsh-nix-shell";
    rev = "dceed031a54e4420e33f22a6b8e642f45cc829e2";
    sha256 = "10g8m632s4ibbgs8ify8n4h9r4x48l95gvb57lhw4khxs6m8j30q";
  };

  installPhase = ''
    mkdir -p $out/share/zsh/plugins/nix-shell
    cp *.zsh $out/share/zsh/plugins/nix-shell
    cp -r scripts $out/share/zsh/plugins/nix-shell
  '';

  meta = with stdenv.lib; {
    homepage = https://github.com/chisui/zsh-nix-shell;
    description = "ZSH plugin that lets you use ZSH in nix-shell.";
    license = licenses.bsd3;
    platforms = platforms.all;
    maintainers = with maintainers; [ chisui ];
  };
}
