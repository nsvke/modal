{
  pkgs ? import <nixpkgs> { },
}:

pkgs.mkShellNoCC {
  packages = [
    pkgs.quickshell
    pkgs.kdePackages.qtdeclarative
  ];
}
