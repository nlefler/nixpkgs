{ stdenv, lib, fetchFromGitHub
, autoreconfHook, autoconf-archive, pkg-config, doxygen, perl
, openssl, json_c, curl, libgcrypt
, cmocka, uthash, ibm-sw-tpm2, iproute, procps, which
}:

stdenv.mkDerivation rec {
  pname = "tpm2-tss";
  version = "3.0.1";

  src = fetchFromGitHub {
    owner = "tpm2-software";
    repo = pname;
    rev = version;
    sha256 = "10wayqk7h1v3hdyd09rkjjs9989r968dpgf8m0xjqgn7q3y78n61";
  };

  nativeBuildInputs = [
    autoreconfHook autoconf-archive pkg-config doxygen perl
  ];
  buildInputs = [ openssl json_c curl libgcrypt ];
  checkInputs = [
    cmocka uthash ibm-sw-tpm2 iproute procps which
  ];

  preAutoreconf = "./bootstrap";

  enableParallelBuilding = true;

  postPatch = "patchShebangs script";

  configureFlags = [
    "--enable-unit"
    "--enable-integration"
  ];

  doCheck = true;

  postInstall = ''
    # Do not install the upstream udev rules, they rely on specific
    # users/groups which aren't guaranteed to exist on the system.
    rm -R $out/lib/udev
  '';

  meta = with lib; {
    description = "OSS implementation of the TCG TPM2 Software Stack (TSS2)";
    homepage = "https://github.com/tpm2-software/tpm2-tss";
    license = licenses.bsd2;
    platforms = platforms.linux;
    maintainers = with maintainers; [ delroth ];
  };
}
