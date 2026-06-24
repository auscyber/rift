{
  pkgs,
  crane,
  commonArgs,
  cargoArtifacts,
}:
let
  lib = pkgs.lib;
  craneLib = crane.mkLib pkgs;
in
craneLib.buildPackage (
  commonArgs
  // {
    inherit cargoArtifacts;

    nativeBuildInputs = [
      pkgs.installShellFiles
      pkgs.makeBinaryWrapper
    ];

    postInstall = ''
      # Generate shell completions and the man page using the installed xtask.
      $out/bin/xtask dist

      # Remove xtask from the final output; it is only needed during install.
      rm $out/bin/xtask

      installShellCompletion --cmd rift ./comp/rift.{bash,fish,zsh,nu}
      installShellCompletion --cmd rift-cli ./comp/rift-cli.{bash,fish,zsh,nu}

      installManPage ./man/rift.1
      installManPage ./man/rift-cli.1
    '';

    nativeInstallCheckInputs = [ pkgs.versionCheckHook ];
    doInstallCheck = false;
    versionCheckProgram = "${placeholder "out"}/bin/rift";
    versionCheckProgramArg = "--version";

    meta = {
      description = "Rift Window manager";
      homepage = "https://github.com/acsandmann/rift";
      license = lib.licenses.eupl12;
      mainProgram = "rift";
      maintainers = with lib.maintainers; [
        auscyber
      ];
    };
  }
)
