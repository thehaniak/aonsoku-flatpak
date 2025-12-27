# Makefile for building, running and cleaning the Flatpak package

FLATPACK_ID = io.github.victoralvesf.aonsoku
FILE_YAML = ${FLATPACK_ID}.yaml
FILE_FLATPAK = ${FLATPACK_ID}.flatpak

OPTS = --arch=x86_64 --force-clean --user --verbose
OPTS_INSTALL = ${OPTS} --install
OPTS_FULL_INSTALL = ${OPTS_INSTALL} --install-deps-from=flathub

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
	rm -rf .flatpak-builder ${BUILD_PATH} .venv export temp-aonsoku ${FILE_FLATPAK}

clean-build-path: # Clean up only the build path
	rm -rf ${BUILD_PATH}

update-node-modules: clean flatpak-node-generator # Update node modules in the Flatpak package
	git clone https://github.com/victoralvesf/aonsoku.git temp-aonsoku
	cd temp-aonsoku && npm install electron-builder@latest --verbose
	cd temp-aonsoku && npm install --package-lock-only --verbose
	cd temp-aonsoku && flatpak-node-generator npm package-lock.json -o ../01-generated-sources.json
	cd temp-aonsoku && flatpak-node-generator npm node_modules/minipass-sized/package-lock.json -o ../02-generated-sources.json
	jq -sc "flatten | unique | sort_by(.type)" 01-generated-sources.json 02-generated-sources.json > generated-sources.json
	rm -rf temp-aonsoku 01-generated-sources.json 02-generated-sources.json

run: # Run the Flatpak application
	flatpak run ${FLATPACK_ID} --trace-deprecation --verbose --ostree-verbose --filesystem=xdg-desktop:create --filesystem=home

remove: # Uninstall the Flatpak application
	flatpak remove -y ${FLATPACK_ID}

lint: # Lint the Flatpak YAML file
	flatpak run --command=flatpak-builder-lint org.flatpak.Builder manifest ${FILE_YAML}
