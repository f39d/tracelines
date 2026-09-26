#!/bin/sh
set -e

# Configuration
REPO="f39d/tracelines"
BINARY_NAME="tracelines"
DEFAULT_INSTALL_DIR="/usr/local/bin"

# Colored logging helpers
info() { printf "\033[34m[INFO]\033[0m %s\n" "$1"; }
success() { printf "\033[32m[SUCCESS]\033[0m %s\n" "$1"; }
error() { printf "\033[31m[ERROR]\033[0m %s\n" "$1" >&2; exit 1; }

# 1. Detect Operating System
detect_os() {
  OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
  case "$OS" in
    linux) OS="linux" ;;
    darwin) OS="darwin" ;;
    mingw*|msys*|cygwin*)
      error "Windows is not directly supported via curl | sh. Please download the .zip binary directly from https://github.com/$REPO/releases."
      ;;
    *) error "Unsupported operating system: $OS" ;;
  esac
}

# 2. Detect Architecture
detect_arch() {
  ARCH="$(uname -m)"
  case "$ARCH" in
    x86_64|amd64) ARCH="amd64" ;;
    arm64|aarch64) ARCH="arm64" ;;
    *) error "Unsupported architecture: $ARCH" ;;
  esac
}

# 3. Detect Download Tool (curl or wget)
detect_downloader() {
  if command -v curl >/dev/null 2>&1; then
    DOWNLOADER="curl"
  elif command -v wget >/dev/null 2>&1; then
    DOWNLOADER="wget"
  else
    error "Neither curl nor wget were found. Please install one of them to proceed."
  fi
}

download_file() {
  url="$1"
  output="$2"
  if [ "$DOWNLOADER" = "curl" ]; then
    curl -fsSL "$url" -o "$output"
  elif [ "$DOWNLOADER" = "wget" ]; then
    wget -qO "$output" "$url"
  fi
}

# 4. Resolve Target Installation Directory
resolve_install_dir() {
  INSTALL_DIR="${INSTALL_DIR:-$DEFAULT_INSTALL_DIR}"
  
  # Allow non-root users to install to ~/.local/bin if /usr/local/bin isn't writable
  if [ "$INSTALL_DIR" = "$DEFAULT_INSTALL_DIR" ] && [ ! -w "$INSTALL_DIR" ] && [ "$(id -u)" -ne 0 ]; then
    INSTALL_DIR="$HOME/.local/bin"
    info "Default install directory ($DEFAULT_INSTALL_DIR) is not writable. Installing to $INSTALL_DIR instead."
  fi
}

main() {
  detect_os
  detect_arch
  detect_downloader
  resolve_install_dir

  info "Detecting latest release version for $REPO..."
  
  # Fetch latest tag name from GitHub Releases
  LATEST_RELEASE_URL="https://github.com/$REPO/releases/latest"
  if [ "$DOWNLOADER" = "curl" ]; then
    TAG="$(curl -fsSL -o /dev/null -w "%{url_effective}" "$LATEST_RELEASE_URL" | sed 's#.*/tag/##')"
  elif [ "$DOWNLOADER" = "wget" ]; then
    TAG="$(wget --max-redirect=0 "$LATEST_RELEASE_URL" 2>&1 | grep -i "Location:" | sed 's#.*/tag/##' | tr -d '\r')"
  fi

  if [ -z "$TAG" ]; then
    error "Failed to fetch the latest version tag from GitHub."
  fi

  # Strip leading 'v' for GoReleaser naming convention matching
  VERSION="${TAG#v}"
  ARCHIVE_NAME="${BINARY_NAME}_${VERSION}_${OS}_${ARCH}.tar.gz"
  DOWNLOAD_URL="https://github.com/$REPO/releases/download/${TAG}/${ARCHIVE_NAME}"

  # Set up temporary working directory
  TMP_DIR="$(mktemp -d 2>/dev/null || mktemp -d -t 'tracelines')"
  trap 'rm -rf "$TMP_DIR"' EXIT INT TERM

  info "Downloading $BINARY_NAME $TAG ($OS/$ARCH)..."
  download_file "$DOWNLOAD_URL" "$TMP_DIR/$ARCHIVE_NAME"

  info "Extracting archive..."
  tar -xzf "$TMP_DIR/$ARCHIVE_NAME" -C "$TMP_DIR"

  if [ ! -f "$TMP_DIR/$BINARY_NAME" ]; then
    error "Extracted archive did not contain binary '$BINARY_NAME'."
  fi

  # Ensure target installation directory exists
  mkdir -p "$INSTALL_DIR"

  info "Installing $BINARY_NAME to $INSTALL_DIR..."
  if [ -w "$INSTALL_DIR" ]; then
    mv "$TMP_DIR/$BINARY_NAME" "$INSTALL_DIR/$BINARY_NAME"
    chmod +x "$INSTALL_DIR/$BINARY_NAME"
  else
    info "Elevated permissions required to write to $INSTALL_DIR"
    sudo mv "$TMP_DIR/$BINARY_NAME" "$INSTALL_DIR/$BINARY_NAME"
    sudo chmod +x "$INSTALL_DIR/$BINARY_NAME"
  fi

  success "Successfully installed $BINARY_NAME ($TAG) to $INSTALL_DIR/$BINARY_NAME"

  # Check if installation directory is in PATH
  case ":$PATH:" in
    *":$INSTALL_DIR:"*) ;;
    *)
      printf "\n\033[33m[WARNING]\033[0m %s is not in your PATH.\n" "$INSTALL_DIR"
      printf "Add it to your shell config file (e.g., ~/.bashrc or ~/.zshrc):\n"
      printf "  export PATH=\"\$PATH:%s\"\n\n" "$INSTALL_DIR"
      ;;
  esac
}

main "$@"