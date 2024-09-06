{ pkgs, ... }:
{
  home.packages = with pkgs; [
    hurl
    xh
    yamlfmt

    # AI
    aider-chat
    whisper-ctranslate2
  ];
}
