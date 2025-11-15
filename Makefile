game_file_name = game

game_files := $(shell \
	find . -path ./exports -prune \
	-o -path ./.godot -prune \
	-o -type f -print)

.PHONY: all
all: linux windows macOS web

.PHONY: clean
clean:
	rm -rf exports

.PHONY: linux
linux: exports/linux/$(game_file_name).x86_64

.PHONY: windows
windows: exports/windows/$(game_file_name).exe

.PHONY: macOS
macOS: exports/macOS/$(game_file_name).zip

.PHONY: web
web: exports/web/$(game_file_name).html

.PHONY: run-web
run-web: web
	$(info )
	$(info Open http://localhost:8000/$(game_file_name).html in your browser.)
	$(info )
	python -m http.server -d exports/web

.PHONY: open-editor
open-editor:
	nix run --impure .#editor

exports/linux/$(game_file_name).x86_64: $(game_files)
	rm -rf exports/linux &>/dev/null || true
	mkdir -p exports/linux
	godot --export-release Linux exports/linux/$(game_file_name).x86_64 --headless project.godot

exports/windows/$(game_file_name).exe: $(game_files)
	rm -rf exports/windows &>/dev/null || true
	mkdir -p exports/windows
	godot --export-release "Windows Desktop" exports/windows/$(game_file_name).exe --headless project.godot

exports/macOS/$(game_file_name).zip: $(game_files)
	rm -rf exports/macOS &>/dev/null || true
	mkdir -p exports/macOS
	godot --export-release "macOS" exports/macOS/$(game_file_name).zip --headless project.godot

exports/web/$(game_file_name).html: $(game_files)
	rm -rf exports/web &>/dev/null || true
	mkdir -p exports/web
	godot --export-release "Web" exports/web/$(game_file_name).html --headless project.godot
