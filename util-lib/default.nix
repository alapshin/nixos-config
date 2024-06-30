{ lib }:
rec {
  capitalize = str:
    lib.strings.toUpper (lib.strings.substring 0 1 str) +
    lib.strings.substring 1 (lib.strings.stringLength str) str;
}
