{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # HTTP API
    bruno
    hurl
    xh

    yamlfmt

    # AI
    # aider-chat
    # whisper-ctranslate2
  ];
}
