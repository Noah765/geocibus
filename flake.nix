{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = inputs: let
    pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
    inherit (inputs.nixpkgs) lib;
  in {
    # Only necessary for the first build (for more details see https://github.com/NixOS/nixpkgs/issues/341147)
    devShell.x86_64-linux = pkgs.mkShell {
      buildInputs = with pkgs; [pkg-config gtk3];
      shellHook = "flutter clean; flutter run";
    };
    packages.x86_64-linux = {
      download = pkgs.writeShellScriptBin "windows-vm-download" "cd windows-vm; ${lib.getExe' pkgs.quickemu "quickget"} windows 11";
      # Apply a fix for https://github.com/quickemu-project/quickemu/issues/1475
      configure = pkgs.writeShellScriptBin "windows-vm-configure" ''
        cd windows-vm
        tail -n +2 windows-11.conf > tmp
        mv tmp windows-11.conf
        sed 's/guest_os="windows"/guest_os="windows-server"/g' windows-11.conf > tmp
        mv tmp windows-11.conf
        sed 's/secureboot="off"/secureboot="on"/g' windows-11.conf > tmp
        mv tmp windows-11.conf
      '';
      default = pkgs.writeShellScriptBin "windows-vm" "cd windows-vm; ${lib.getExe' pkgs.quickemu "quickemu"} --vm windows-11.conf";
    };
  };
}
