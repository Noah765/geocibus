{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = inputs: let
    pkgs = import inputs.nixpkgs {
      system = "x86_64-linux";
      config.allowUnfree = true;
    };
    inherit (inputs.nixpkgs) lib;
  in {
    devShells.x86_64-linux = {
      default = pkgs.mkShell {buildInputs = with pkgs; [flutter pkg-config gtk3];};
      web = pkgs.mkShell {
        buildInputs = [pkgs.flutter];
        CHROME_EXECUTABLE = lib.getExe pkgs.google-chrome;
      };
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
