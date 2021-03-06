{ lib, stdenv, python3, openssl
, enableSystemd ? stdenv.isLinux
}:

with python3.pkgs;

let
  matrix-synapse-ldap3 = buildPythonPackage rec {
    pname = "matrix-synapse-ldap3";
    version = "0.1.3";

    src = fetchPypi {
      inherit pname version;
      sha256 = "0a0d1y9yi0abdkv6chbmxr3vk36gynnqzrjhbg26q4zg06lh9kgn";
    };

    propagatedBuildInputs = [ service-identity ldap3 twisted ];

    # ldaptor is not ready for py3 yet
    doCheck = !isPy3k;
    checkInputs = [ ldaptor mock ];
  };

in buildPythonApplication rec {
  pname = "matrix-synapse";
  version = "1.2.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0pr17n52vdq490q6c282nqnn51j5k0lf7mzaazpxjy4q86pxdfy5";
  };

  patches = [
    # adds an entry point for the service
    ./homeserver-script.patch
  ];

  propagatedBuildInputs = [
    bcrypt
    bleach
    canonicaljson
    daemonize
    frozendict
    jinja2
    jsonschema
    lxml
    matrix-synapse-ldap3
    msgpack
    netaddr
    phonenumbers
    pillow
    (prometheus_client.overrideAttrs (x: {
      src = fetchPypi {
        pname = "prometheus_client";
        version = "0.3.1";
        sha256 = "093yhvz7lxl7irnmsfdnf2030lkj4gsfkg6pcmy4yr1ijk029g0p";
      };
    }))
    psutil
    psycopg2
    pyasn1
    pymacaroons
    pynacl
    pyopenssl
    pysaml2
    pyyaml
    requests
    signedjson
    sortedcontainers
    treq
    twisted
    unpaddedbase64
  ] ++ lib.optional enableSystemd systemd;

  checkInputs = [ mock parameterized openssl ];

  checkPhase = ''
    PYTHONPATH=".:$PYTHONPATH" ${python3.interpreter} -m twisted.trial tests
  '';

  meta = with stdenv.lib; {
    homepage = https://matrix.org;
    description = "Matrix reference homeserver";
    license = licenses.asl20;
    maintainers = with maintainers; [ ralith roblabla ekleog pacien ];
  };
}
