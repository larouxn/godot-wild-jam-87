# Cursed 💀

- https://rhitakorrr.itch.io/cursed
- https://itch.io/jam/godot-wild-jam-87

## Development

### Nix

The development of this project is setup via a Nix flake, so the first thing to do is to install Nix if you don't have it already. There are a couple variants of Nix:

- [Nix](https://nixos.org/download/)
- [Lix](https://lix.systems/install/)
- [Determinate Systems Nix Installer](https://determinate.systems/nix-installer/)

I personally use Lix, but any of them should work.

The Nix shell will install all the dependencies needed to work on the project, including the Godot engine itself. I highly recommend using the version of the editor provided by the shell since:

- it comes with all the export templates needed to export builds pre-installed.
- it will ensure we are all using the same version of the editor and export templates.

See [Makefile](#Makefile) for how to launch the editor from the shell.

### Direnv / nix-direnv

[direnv](https://direnv.net/) is a utility that will let you automatically enter a Nix shell when you enter a directory instead of having to type `nix develop` to get into the development environment. Feel free to install it if it sounds convenient.

[nix-direnv](https://github.com/nix-community/nix-direnv) is an extension to direnv that improves direnv's Nix support. If you install direnv, I suggest setting this up as well.

### pre-commit

The project has pre-commit setup with a couple hooks that will ensure code is properly formatted and passes a linter check before being committed. It will be configured the first time you run `nix develop`.

### Makefile

> [!NOTE]\
> If you aren't using direnv to enter a Nix shell, make sure you run `nix develop` before running commands from the Makefile!

The project has a Makefile with some convenient commands:

- `make all` - export a release build for all four platforms
- `make linux` - export a release build for Linux
- `make windows` - export a release build for Windows
- `make macOS` - export a release build for macOS
- `make web` - export a release build for the web

By default (if you just run `make`), it will run `make all`.

Additionally, the Makefile includes some .PHONY targets to do some useful, non-build things:

- `make run-web` - export the web build and start an HTTP server on port 8000 that you can navigate to in your browser to test the browser build
- `make open-editor` - open the project in the editor; this is just a shortcut for `nix run --impure .#editor`
