{
  description = "Godot Wild Jam #87";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    git-hooks.url = "github:cachix/git-hooks.nix";
    git-hooks.inputs.nixpkgs.follows = "nixpkgs";

    nixgl.url = "github:nix-community/nixGL";
    nixgl.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, git-hooks, nixgl }:
    let
      systems = [ "x86_64-linux" ];

      forEachSystem = f: nixpkgs.lib.genAttrs systems
        (system: f { inherit system; pkgs = nixpkgs.legacyPackages.${system}; });

      mkGodotWrapper = pkgs: pkgs.writeShellApplication {
        name = "godot";
        runtimeInputs = [ pkgs.bubblewrap ];
        text = ''
          mkdir -p ~/.local/share/godot/export_templates
          bwrap \
            --dev-bind / / \
            --ro-bind \
              ${pkgs.godot_4-export-templates-bin}/share/godot/export_templates \
              ~/.local/share/godot/export_templates \
            ${pkgs.godot_4}/bin/godot "$@"
        '';
      };
    in
    {
      checks = forEachSystem ({ system, pkgs }:
        let
          gdtool = exe: {
            enable = true;
            package = pkgs.gdtoolkit_4;
            entry = "${pkgs.gdtoolkit_4}/bin/${exe}";
            types = [ "gdscript" ];
            require_serial = true;
          };
        in
        {
          pre-commit-check = git-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              # Nix
              nixpkgs-fmt.enable = true;
              statix.enable = true;

              # GDScript
              gdformat = gdtool "gdformat";
              gdlint = gdtool "gdlint";
            };
          };
        });

      devShells = forEachSystem ({ system, pkgs }: {
        default =
          let
            inherit (self.checks.${system}.pre-commit-check) shellHook enabledPackages;
          in
          pkgs.mkShell {
            inherit shellHook;
            buildInputs = [
              pkgs.gnumake
              pkgs.python3
              (mkGodotWrapper pkgs)
            ] ++ enabledPackages;
          };
      });

      apps = forEachSystem ({ system, pkgs }:
        {
          editor = {
            type = "app";
            program =
              let
                editor = pkgs.writeShellApplication {
                  name = "editor";
                  runtimeInputs = [ nixgl.packages.${system}.default ];
                  text = ''
                    nixGL ${mkGodotWrapper pkgs}/bin/godot -e project.godot
                  '';
                };
              in
              "${editor}/bin/editor";
          };
        }
      );
    };
}
