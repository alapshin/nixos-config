{ lib
, buildPythonPackage
, fetchFromGitHub
, beancount
, beautifulsoup4
, bottle
, chardet
, python-dateutil
, google-api-python-client
, google-auth-oauthlib
, lxml
, oauth2client
, ply
, pytest
, python-magic
, requests
}:

buildPythonPackage rec {
  version = "20230510";
  pname = "beanprice";

  src = fetchFromGitHub {
    owner = "beancount";
    repo = pname;
    rev = "b7611027d28b473e9ee63e0ddda117ed3328187e";
    hash = "sha256-nH92Jz6QsH9vCmCn/foFSEdkaQRFuEnnTyhF++qNyZ4=";
  };

  # Tests require files not included in the PyPI archive.
  doCheck = false;

  catchConflicts = false;

  propagatedBuildInputs = [
    beancount
    python-dateutil
    requests
    # pytest really is a runtime dependency
    # https://github.com/beancount/beancount/blob/v2/setup.py#L81-L82
    pytest
  ];

  meta = with lib; {
    homepage = "https://gitlab.com/chrisberkhout/pricehist";
    description = "Price quotes fetcher for Beancount";
    longDescription = ''
      A script to fetch market data prices from various sources on the internet
      and render them for plain text accounting price syntax (and Beancount).
    '';
    license = licenses.gpl2Only;
    maintainers = with maintainers; [ alapshin ];
  };
}
