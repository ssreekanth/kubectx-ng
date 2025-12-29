# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2025-12-27

### Fixed
- **Shell completions now show all contexts** after switching contexts in per-shell mode
  - Completions now read from `KUBECONFIG_ORIG` (original config) instead of the current per-shell config
  - Previously, after switching to a context, tab completion would only show the current context instead of all available contexts
- **Completions work reliably** even when Homebrew's `kubectx` is installed
  - Added `precmd` hook to ensure kubectx-ng completions stay registered
  - Automatically overrides conflicting completions from Homebrew or oh-my-zsh

### Added
- **Automatic completion registration** when sourcing `kubectx-ng.sh`
  - Bash and Zsh completions are automatically loaded and registered
  - No manual completion setup needed for per-shell mode users
  - Completions persist even if other tools try to override them
- Enhanced troubleshooting section in README for completion issues

### Changed
- Rewrote Zsh completion functions to use `compadd` for more reliable dynamic completion
- Removed `kubectx` and `kubens` command aliases to avoid conflicts with Homebrew's kubectx
  - Users should use `kubectx-ng`/`kctx` and `kubens-ng`/`kns` instead
  - This prevents confusion and completion conflicts when both tools are installed
- Updated shell integration to show: `Commands: kctx, kubectx-ng, kns, kubens-ng` (removed kubectx/kubens)

### Technical Details
- Completion functions now properly handle per-shell mode by reading all contexts from the original kubeconfig
- Added automatic re-registration of completions via `precmd` hook to handle late-loading completion systems
- Improved completion function structure for better maintainability

## [1.0.0] - 2025-12-27

### Added
- Initial release combining features from kubectx/kubens and kubech
- `kubectx-ng` - kubectl context switcher with dual-mode support
- `kubens-ng` - kubectl namespace switcher with dual-mode support
- Two operating modes:
  - Global mode: Traditional behavior affecting all terminals
  - Per-shell mode: Isolated contexts per terminal window
- Interactive selection with `fzf` support
- Previous context/namespace switching with `-` flag
- Color-coded output for current context/namespace
- Context management features:
  - List all contexts
  - Switch contexts
  - Rename contexts (global mode)
  - Delete contexts (global mode)
  - Unset current context
- Shell integration script (`kubectx-ng.sh`) with:
  - Command aliases: `kctx`, `kns` (short forms of `kubectx-ng`, `kubens-ng`)
  - Helper functions: `kubectx-status`, `kubectx-cleanup`, `kubectx-global`, `kubectx-per-shell`
  - Per-shell state management
  - Automatic completion registration
- Shell completions for:
  - Bash (supports both full names and aliases)
  - Zsh (supports both full names and aliases)
  - Fish (supports both full names and aliases)
- Environment variable customization:
  - `KUBECTX_MODE` - Force mode (global/per-shell/auto)
  - `KUBECONFIG_DEST_DIR` - Per-shell configs directory
  - `KUBECONFIG_SRC_DIR` - Additional configs directory
  - `KUBECTX_IGNORE_FZF` - Bypass fzf selection
  - `KUBECTX_CURRENT_FGCOLOR` - Color customization
  - `KUBECTX_CURRENT_BGCOLOR` - Color customization
  - `NO_COLOR` - Disable colored output
  - `KUBECH_NAMESPACE_CHECK` - Namespace validation method
- Comprehensive documentation in README.md
- Apache 2.0 License

### Features
- Per-shell isolation using `KUBECONFIG` environment variable
- Self-contained config generation with `kubectl config view --flatten --minify`
- Shell PID tracking for consistent state management
- Temporary file communication pattern for subprocess-to-parent variable export
- Shell-agnostic implementation (Bash, Zsh, Fish compatible)
- Fast namespace validation with label selector option (k8s 1.22+)
- Automatic cleanup of old per-shell config files

[1.1.0]: https://github.com/ssreekanth/kubectx-ng/releases/tag/v1.1.0
[1.0.0]: https://github.com/ssreekanth/kubectx-ng/releases/tag/v1.0.0
