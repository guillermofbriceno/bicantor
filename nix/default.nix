{ pkgs ? (import <nixpkgs> {}).pkgsCross.riscv32-embedded }:
let
  packageOverrides = pkgs.callPackage ./python-packages.nix  {  };
  python = pkgs.buildPackages.python3.override { inherit packageOverrides; };
  pythonWithPackages = python.withPackages (ps: [ ps.pyyaml ps.Verilog-VCD ]);
in
pkgs.mkShell {

  nativeBuildInputs = [ 
    #python-with-my-packages 
    pythonWithPackages

    pkgs.buildPackages.openjdk

    # Simulation and Synthesis
    pkgs.buildPackages.yosys 
    pkgs.buildPackages.trellis 
    pkgs.buildPackages.verilog

    pkgs.buildPackages.ctags
    pkgs.buildPackages.gtkwave
    
    # Verification
    pkgs.buildPackages.symbiyosys 
    pkgs.buildPackages.boolector 
    pkgs.buildPackages.z3
  ];

  shellHook = ''
    #alias jupiter="steam-run ../common-util/jupiter/bin/jupiter"
    export PATH="../common-util/jupiter/bin:$PATH"
  '';
}
