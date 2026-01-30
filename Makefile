# Makefile for building and installing a Flatpak from an existing manifest.
#
# Usage:
#   make build
#   make install
#   make run
#   make bundle
#   make clean
#
# Notes:
# - Set MANIFEST to your .yml/.yaml/.json manifest filename if different.
# - Set APP_ID if it differs from the app-id in your manifest.
# - By default installs per-user (--user). Use INSTALL_SCOPE=--system for system install.

MANIFEST      ?= com.calibre_ebook.calibre.yaml
APP_ID        ?=

BUILD_DIR     ?= build
REPO_DIR      ?= repo
BUNDLE        ?= $(APP_ID).flatpak

# Install scope for `flatpak install`: --user (default) or --system
INSTALL_SCOPE ?= --user

# Optional: makes the bundle self-contained for installing on machines that have Flathub
RUNTIME_REPO  ?= https://flathub.org/repo/flathub.flatpakrepo

# Optional extra flags
BUILDER_FLAGS ?= --force-clean
INSTALL_FLAGS ?= -y

.PHONY: all build repo install run bundle uninstall clean distclean status

all: build

status:
	@echo "MANIFEST      = $(MANIFEST)"
	@echo "APP_ID         = $(APP_ID)"
	@echo "BUILD_DIR      = $(BUILD_DIR)"
	@echo "REPO_DIR       = $(REPO_DIR)"
	@echo "BUNDLE         = $(BUNDLE)"
	@echo "INSTALL_SCOPE  = $(INSTALL_SCOPE)"
	@echo "RUNTIME_REPO   = $(RUNTIME_REPO)"

# Build into a local build directory (does not create a repo)
build: $(MANIFEST)
	flatpak-builder $(BUILDER_FLAGS) $(BUILD_DIR) $(MANIFEST)

# Build + export into a local repo (this is what you need for install/bundle)
repo: $(MANIFEST)
	flatpak-builder $(BUILDER_FLAGS) --repo=$(REPO_DIR) $(BUILD_DIR) $(MANIFEST)

# Install the app from the local repo
install: repo
	flatpak install $(INSTALL_SCOPE) $(INSTALL_FLAGS) ./$(REPO_DIR) $(APP_ID)

# Run the installed app
run:
	flatpak run $(APP_ID)

# Create a single-file bundle (.flatpak) from the local repo
bundle: repo
	flatpak build-bundle $(REPO_DIR) $(BUNDLE) $(APP_ID) --runtime-repo=$(RUNTIME_REPO)
	@echo "Created: $(BUNDLE)"

# Uninstall the app
uninstall:
	-flatpak uninstall $(INSTALL_SCOPE) $(INSTALL_FLAGS) $(APP_ID)

# Remove build artifacts
clean:
	rm -rf $(BUILD_DIR)

# Remove build artifacts + repo + bundle
distclean: clean
	rm -rf $(REPO_DIR) $(BUNDLE)
