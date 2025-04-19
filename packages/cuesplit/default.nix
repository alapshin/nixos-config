{
  cuetools,
  enca,
  flac,
  iconv,
  shntool,
  monkeysAudio,
  writeShellApplication,
  ...
}:

writeShellApplication {
  name = "cuesplit";
  runtimeInputs = [
    cuetools
    enca
    flac
    iconv
    shntool
    monkeysAudio
  ];
  text = builtins.readFile ./cuesplit.sh;
}
