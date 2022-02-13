{ pkgs ? import <nixpkgs> {} }:
let
  python-with-my-packages = pkgs.python3.withPackages (p: with p; [
    # none yet
  ]);
in
pkgs.mkShell {
  nativeBuildInputs = [ 
    python-with-my-packages 
    pkgs.openjdk

    pkgs.gtkwave
    pkgs.yosys 
    pkgs.trellis 
    pkgs.verilog

  ];

  shellHook = ''
    #alias jupiter="steam-run ../common-util/jupiter/bin/jupiter"
    export PATH="../common-util/jupiter/bin:$PATH"
  '';
}
