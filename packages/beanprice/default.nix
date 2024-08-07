{ lib
, beancount3
, buildPythonPackage
, click
, fetchFromGitHub
, pytestCheckHook
, python-dateutil
, regex
, requests
, setuptools
}:
buildPythonPackage rec {
  pname = "beanprice";
  version = "1.2.1-unstable-2024-06-19";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "beancount";
    repo = "beanprice";
    rev = "e894c9182f4d16f9a46ccb87bdaeca1a7dede040";
    hash = "sha256-l96W77gldE06Za8fj84LADGCqlYeWlHKvWQO+oLy1gI=";
  };

  build-system = [
    setuptools
  ];

  dependencies = [
    beancount3
    python-dateutil
    requests
  ];

  nativeCheckInputs = [
    click
    pytestCheckHook
    regex
  ];

  pythonImportsCheck = [
    "beancount"
    "beanprice"
  ];

  meta = with lib; {
    homepage = "https://github.com/beancount/beanprice";
    description = "Price quotes fetcher for Beancount";
    longDescription = ''
      A script to fetch market data prices from various sources on the internet
      and render them for plain text accounting price syntax (and Beancount).
    '';
    license = licenses.gpl2Only;
    maintainers = with maintainers; [ alapshin ];
    mainProgram = "bean-price";
  };
}
