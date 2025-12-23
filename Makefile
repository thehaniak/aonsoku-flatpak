# Makefile for building, running and cleaning the Flatpak package

OPTS = --arch=x86_64 --force-clean --user --install
OPTS_FULL = ${OPTS} --install-deps-from=flathub

BUILD_PATH=build

full-build: clean flatpak-node-generator # Build the Flatpak package
	flatpak-builder ${OPTS_FULL} ${BUILD_PATH} com.victoralvesf.aonsoku.yaml

build: clean flatpak-node-generator # Build the Flatpak package with dependencies already installed
	flatpak-builder ${OPTS} ${BUILD_PATH} com.victoralvesf.aonsoku.yaml

fast-build: clean-build-path flatpak-node-generator # Build the Flatpak package without cleaning .flatpak-builder directory
	flatpak-builder --user --install ${BUILD_PATH} com.victoralvesf.aonsoku.yaml

venv: # Create a Python virtual environment
	python3 -m venv .venv

flatpak-node-generator: venv # Install flatpak-node-generator in the virtual environment
	. .venv/bin/activate && pip install flatpak-node-generator

clean: # Clean up build artifacts
	rm -rf .flatpak-builder ${BUILD_PATH} .venv

clean-build-path: # Clean up only the build path
	rm -rf ${BUILD_PATH}

run: # Run the Flatpak application
	flatpak run com.victoralvesf.Aonsoku --trace-deprecation

remove: # Uninstall the Flatpak application
	flatpak remove -y com.victoralvesf.Aonsoku
