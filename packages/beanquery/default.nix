{
  lib,
  beancount,
  buildPythonPackage,
  click,
  fetchPypi,
  python-dateutil,
  pytestCheckHook,
  setuptools,
  tatsu,
}:
buildPythonPackage rec {
  pname = "beanquery";
  version = "0.1.0";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-tp4Jm4Qhshm7zDKTr3fjxMyterJb9SD+5IeIZy/79ko=";
  };

  build-system = [ setuptools ];

  dependencies = [
    beancount
    click
    python-dateutil
    tatsu
  ];

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "find = {}" "find = { exclude = [ \"docs*\" ] }"
  '';

  pythonRelaxDeps = [ "tatsu" ];

  nativeCheckInputs = [ pytestCheckHook ];

  pythonImportsCheck = [
    "beanquery"
  ];

  meta = with lib; {
    homepage = "https://github.com/beancount/beanquery";
    description = "Beancount Query Language";
    longDescription = ''
      A customizable light-weight SQL query tool that works on tabular data,
      including Beancount.
    '';
    license = licenses.gpl2Only;
    maintainers = with maintainers; [ alapshin ];
    mainProgram = "bean-query";
  };
}
