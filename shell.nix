{ pkgs ? (import <nixpkgs> {}).pkgsCross.riscv32-embedded }:
let
  python-with-my-packages = pkgs.buildPackages.python3.withPackages (p: with p; [
    pyyaml
  ]);

in
pkgs.mkShell {

  nativeBuildInputs = [ 
    python-with-my-packages 
    pkgs.buildPackages.openjdk

    pkgs.buildPackages.gtkwave
    pkgs.buildPackages.yosys 
    pkgs.buildPackages.trellis 
    pkgs.buildPackages.verilog
    pkgs.buildPackages.ctags

  ];

  shellHook = ''
    #alias jupiter="steam-run ../common-util/jupiter/bin/jupiter"
    export PATH="../common-util/jupiter/bin:$PATH"
  '';
}
