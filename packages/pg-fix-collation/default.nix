{
  postgresql,
  writeShellApplication,
  ...
}:

writeShellApplication {
  name = "pg_collationfix";
  runtimeInputs = [ postgresql ];
  text = builtins.readFile ./pg-fix-collation.sh;
}
