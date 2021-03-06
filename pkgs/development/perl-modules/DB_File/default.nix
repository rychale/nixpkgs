{fetchurl, buildPerlPackage, db}:

buildPerlPackage {
  pname = "DB_File";
  version = "1.851";

  src = fetchurl {
    url = "mirror://cpan/authors/id/P/PM/PMQS/DB_File-1.851.tar.gz";
    sha256 = "1j276mng1nwxxdxnb3my427s5lb6zlnssizcnxricnvaa170kdv8";
  };

  preConfigure = ''
    cat > config.in <<EOF
    PREFIX = size_t
    HASH = u_int32_t
    LIB = ${db.out}/lib
    INCLUDE = ${db.dev}/include
    EOF
  '';
}
