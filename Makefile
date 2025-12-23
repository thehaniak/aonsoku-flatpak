# Makefile for building, running and cleaning the Flatpak package

FLATPACK_ID = com.victoralvesf.Aonsoku
FILE_YAML = ${FLATPACK_ID}.yaml
FILE_FLATPAK = ${FLATPACK_ID}.flatpak

OPTS = --arch=x86_64 --force-clean --user
OPTS_INSTALL = ${OPTS} --install
OPTS_FULL_INSTALL = ${OPTS} --install-deps-from=flathub

BUILD_PATH=build


build: clean flatpak-node-generator # Build the Flatpak package without installing
	flatpak-builder ${OPTS} ${BUILD_PATH} ${FILE_YAML}

build-install: clean flatpak-node-generator # Build the Flatpak package with dependencies already installed
	flatpak-builder ${OPTS_INSTALL} ${BUILD_PATH} ${FILE_YAML}

build-full-install: clean flatpak-node-generator # Build the Flatpak package
	flatpak-builder ${OPTS_FULL_INSTALL} ${BUILD_PATH} ${FILE_YAML}

build-fast-install: clean-build-path flatpak-node-generator # Build the Flatpak package without cleaning .flatpak-builder directory
	flatpak-builder --user --install ${BUILD_PATH} ${FILE_YAML}

build-export: build flatpak-export # Build and export the Flatpak package
	@echo "[i] Flatpak package built and exported to ${FILE_FLATPAK}"

flatpak-export: # Export the built Flatpak package to the local repository
	flatpak build-export export ${BUILD_PATH}
	flatpak build-bundle export ${FILE_FLATPAK} ${FLATPACK_ID}

install-dependencies-locally: # Install Flatpak runtime and SDK dependencies locally
	flatpak install -y --user flathub org.freedesktop.Platform//25.08
	flatpak install -y --user flathub org.electronjs.Electron2.BaseApp//25.08
	flatpak install -y --user flathub org.freedesktop.Sdk//25.08
	flatpak install -y --user flathub org.freedesktop.Sdk.Extension.node24//25.08
	flatpak install -y --user flathub org.gnome.Platform//46
	flatpak install -y --user flathub org.gnome.Sdk//46

setup-venv: # Create a Python virtual environment
	python3 -m venv .venv

flatpak-node-generator: setup-venv # Install flatpak-node-generator in the virtual environment
	. .venv/bin/activate && pip install flatpak-node-generator

clean: # Clean up build artifacts
	rm -rf .flatpak-builder ${BUILD_PATH} .venv export ${FILE_FLATPAK}

clean-build-path: # Clean up only the build path
	rm -rf ${BUILD_PATH}

run: # Run the Flatpak application
	flatpak run ${FLATPACK_ID} --trace-deprecation

remove: # Uninstall the Flatpak application
	flatpak remove -y ${FLATPACK_ID}

lint: # Lint the Flatpak YAML file
	flatpak run --command=flatpak-builder-lint org.flatpak.Builder manifest ${FILE_YAML}
