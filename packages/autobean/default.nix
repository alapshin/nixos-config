{
  lib,
  beancount,
  beancount-plugin-utils,
  fetchFromGitHub,
  buildPythonPackage,
  pdm-pep517,
  pyyaml,
  python-dateutil,
  requests,
}:

buildPythonPackage rec {
  pname = "autobean";
  version = "0.2.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "SEIAROTg";
    repo = "autobean";
    rev = "v${version}";
    sha256 = "sha256-Qc8erF9yF8HnxhKQmyTAbJ196C93NgiaDBr+7kBjLDs=";
  };

  build-system = [ pdm-pep517 ];

  dependencies = [
    beancount
    beancount-plugin-utils
    python-dateutil
    pyyaml
    requests
  ];

  meta = with lib; {
    homepage = "https://github.com/SEIAROTg/autobean";
    description = "A collection of plugins and scripts that help automating bookkeeping with beancount.";
    license = licenses.gpl2Only;
    maintainers = with maintainers; [ alapshin ];
  };
}
