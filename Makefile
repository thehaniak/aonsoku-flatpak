# Makefile for building and cleaning the Flatpak package

OPTS = --arch=x86_64 --force-clean --user --install
OPTS_FULL = ${OPTS} --install-deps-from=flathub

BUILD_PATH = build

full-build: flatpak-node-generator # Build the Flatpak package
	flatpak-builder ${OPTS_FULL} ${BUILD_PATH} com.victoralvesf.aonsoku.yaml

build: flatpak-node-generator # Build the Flatpak package with dependencies already installed
	flatpak-builder ${OPTS} ${BUILD_PATH} com.victoralvesf.aonsoku.yaml

venv: # Create a Python virtual environment
	python3 -m venv .venv

flatpak-node-generator: venv # Install flatpak-node-generator in the virtual environment
	. .venv/bin/activate
	pip install flatpak-node-generator

clean: # Clean up build artifacts
	rm -rf .flatpak-builder build .venv

find:
	find ./ -name 'main' -exec find {} -name index.js \;