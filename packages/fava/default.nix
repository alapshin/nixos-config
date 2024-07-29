{ lib
, fetchPypi
, python3Packages
}:

python3Packages.buildPythonApplication rec {
  pname = "fava";
  version = "1.28";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-sWHVkR0/0VMGzH5OMxOCK4usf7G0odzMtr82ESRQhrk=";
  };

  postPatch = ''
    substituteInPlace tests/test_cli.py \
      --replace-fail '"fava"' '"${placeholder "out"}/bin/fava"'
  '';

  build-system = [ python3Packages.setuptools-scm ];

  dependencies = with python3Packages; [
    babel
    beancount2
    cheroot
    click
    flask
    flask-babel
    jaraco-functools
    jinja2
    markdown2
    ply
    regex
    simplejson
    werkzeug
    watchfiles
  ];

  nativeCheckInputs = [ python3Packages.pytestCheckHook ];

  preCheck = ''
    export HOME=$TEMPDIR
  '';

  pythonRelaxDeps = [
    "beancount"
  ];

  meta = with lib; {
    description = "Web interface for beancount";
    mainProgram = "fava";
    homepage = "https://beancount.github.io/fava";
    changelog = "https://beancount.github.io/fava/changelog.html";
    license = licenses.mit;
    maintainers = with maintainers; [
      bhipple
      sigmanificient
    ];
  };
}
