# Generated by pip2nix 0.8.0.dev1
# See https://github.com/nix-community/pip2nix

{ pkgs, fetchurl, fetchgit, fetchhg }:

self: super: {
  "Verilog-VCD" = super.buildPythonPackage rec {
    pname = "Verilog-VCD";
    version = "1.11";
    src = fetchurl {
      url = "https://files.pythonhosted.org/packages/57/80/b810c0b2b172bcb0bc2181b3a5b7c7b58854f8ed2d0bff1dfeb0885b6cfe/Verilog_VCD-1.11.tar.gz";
      sha256 = "0fk889vanadikxscfhzh23zp3wgql4c1j6j1vh916zf524vmxyig";
    };
    format = "setuptools";
    doCheck = false;
    buildInputs = [];
    checkInputs = [];
    nativeBuildInputs = [];
    propagatedBuildInputs = [];
  };
  "pyyaml" = super.buildPythonPackage rec {
    pname = "pyyaml";
    version = "6.0";
    src = fetchurl {
      url = "https://files.pythonhosted.org/packages/36/2b/61d51a2c4f25ef062ae3f74576b01638bebad5e045f747ff12643df63844/PyYAML-6.0.tar.gz";
      sha256 = "18imkjacvpxfgg1lbpraqywx3j7hr5dv99d242byqvrh2jf53yv8";
    };
    format = "setuptools";
    doCheck = false;
    buildInputs = [];
    checkInputs = [];
    nativeBuildInputs = [];
    propagatedBuildInputs = [];
  };
}
