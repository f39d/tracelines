> [!IMPORTANT]
> Tracelines is currently in in pre-release. Full public release is planned for 2027.

![Alt text](./tl-logo.svg)
# Tracelines
Traceability as Code

**Tracelines** is a CLI tool built on the concept of **Traceability as Code**. It manages and validates complex, interconnected relationships across your project artifacts—requirements, specs, source code, and tests—by storing them in a persistent, version-controlled format directly inside your repository.

Tracelines scans your configured data sources and generates a single authoritative file: `tracelines.graph.yml`. By committing this snapshot alongside your code or specs, you get:

- **Version-Controlled Traceability:** Every commit captures the exact state of your project's artifact graph.
- **CI/CD Integration:** Automatically validate trace links and detect orphan specs or unmapped code before merging.
- **Zero Infrastructure Overhead:** No external databases, servers, or extra services needed.

## Installation

### 1. Homebrew (macOS & Linux) — Recommended

The easiest way to install and maintain `tracelines` on macOS and Linux is via Homebrew.

```bash
# Tap the repository and install in a single command
brew install f39d/tracelines/tracelines
```

Or step-by-step:

```bash
# 1. Tap the repository
brew tap f39d/tracelines

# 2. Install Tracelines
brew install tracelines
```

To upgrade in the future:

```bash
brew update && brew upgrade tracelines
```

### 2. Standalone Shell Installer (Linux & macOS / CI/CD Pipelines)

For headless CI/CD environments, Docker containers, or systems without Homebrew:

```bash
curl -fsSL [https://raw.githubusercontent.com/f39d/tracelines/main/install.sh](https://raw.githubusercontent.com/f39d/tracelines/main/install.sh) | sh
```

To install into a custom directory without root privileges:

```bash
INSTALL_DIR=$HOME/.local/bin curl -fsSL [https://raw.githubusercontent.com/f39d/tracelines/main/install.sh](https://raw.githubusercontent.com/f39d/tracelines/main/install.sh) | sh
```

### 3. Declarative CLI Management (Aqua / Mise)

If your team manages developer tooling declaratively in repository configuration files:

#### Using Aqua (`aqua.yaml`)

Add `tracelines` to your project's `aqua.yaml`:

```yaml
packages:
  - name: f39d/tracelines@v1.0.0 # Replace with desired version
```

Then run:

```bash
aqua i
```

#### Using Mise (`.mise.toml`)

Add `tracelines` to your `.mise.toml`:

```toml
[tools]
"github:f39d/tracelines" = "latest"
```

### 4. Direct Binary Download (Windows / Manual)

Pre-compiled binary archives for all supported operating systems and architectures (`darwin/amd64`, `darwin/arm64`, `linux/amd64`, `linux/arm64`, `windows/amd64`, `windows/arm64`) are published on the [GitHub Releases](https://www.google.com/search?q=https://github.com/f39d/tracelines/releases&utm_source=gemini) page.

1. Download the matching `.tar.gz` (Linux/macOS) or `.zip` (Windows) archive for your system from the latest release.
2. Extract the archive.
3. Move the `tracelines` binary to a location in your system's `PATH` (e.g., `/usr/local/bin` or `C:\Program Files\tracelines`).

Tracelines is proudly ❤️ built and meticulously 🧐 tested by [F39](https://www.f39.design/)

> [!NOTE]
> If you like Tracelines, you will absolutely love the [Scindex](https://github.com/scindex/scindex)