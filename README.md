# kubectx-ng & kubens-ng

[![Release](https://img.shields.io/github/v/release/ssreekanth/kubectx-ng)](https://github.com/ssreekanth/kubectx-ng/releases)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)
[![Shell](https://img.shields.io/badge/Shell-Bash%20%7C%20Zsh%20%7C%20Fish-green.svg)](https://github.com/ssreekanth/kubectx-ng)
[![Platform](https://img.shields.io/badge/Platform-macOS%20%7C%20Linux-lightgrey.svg)](https://github.com/ssreekanth/kubectx-ng)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-Compatible-326CE5.svg?logo=kubernetes&logoColor=white)](https://kubernetes.io/)

Next-generation kubectl context and namespace switcher utilities that combine the best features of [kubectx/kubens](https://github.com/ahmetb/kubectx) with per-shell isolation from [kubech](https://github.com/aabouzaid/kubech).

## Features

### Core Features (from kubectx/kubens)
- Interactive context/namespace selection with `fzf`
- Switch to previous context/namespace with `-`
- Color-coded current context/namespace
- List, rename, and delete contexts
- Fast and intuitive CLI

### Per-Shell Isolation (from kubech)
- **Different kubectl contexts in each terminal window/tab**
- No more accidentally running commands in the wrong cluster
- Perfect for managing multiple clusters simultaneously
- Each shell maintains its own context and namespace

### Two Operating Modes

#### 1. Global Mode (Default)
- Behaves like standard `kubectx`/`kubens`
- Changes affect all terminal windows
- Modifies `~/.kube/config` directly

#### 2. Per-Shell Mode
- Each terminal has independent context/namespace
- Uses `KUBECONFIG` environment variable
- Generates temporary config files per shell
- Safe multi-cluster operations

## Installation

1. Clone or download this repository
2. Make scripts executable:
   ```bash
   chmod +x kubectx-ng kubens-ng
   ```

3. Add to your PATH (global mode only):
   ```bash
   # Add to ~/.bashrc or ~/.zshrc
   export PATH="/path/to/kubectx-ng:$PATH"
   ```

4. **OR** Enable per-shell mode (recommended):
   ```bash
   # Add to ~/.bashrc or ~/.zshrc
   source /path/to/kubectx-ng/kubectx-ng.sh
   ```

### Shell Completions

Shell completions are available for Bash, Zsh, and Fish shells. Completions work for both the full command names (`kubectx-ng`, `kubens-ng`) and the short aliases (`kctx`, `kns`).

#### Bash

```bash
# Add to ~/.bashrc
source /path/to/kubectx-ng/completion/kubectx-ng.bash
source /path/to/kubectx-ng/completion/kubens-ng.bash
```

#### Zsh

```bash
# Add to ~/.zshrc
# Make sure completion directory is in fpath before compinit
fpath=(/path/to/kubectx-ng/completion $fpath)
autoload -U compinit && compinit
```

Alternatively, you can manually source them:
```bash
# Add to ~/.zshrc
source /path/to/kubectx-ng/completion/_kubectx-ng.zsh
source /path/to/kubectx-ng/completion/_kubens-ng.zsh
```

#### Fish

```bash
# Copy to Fish completions directory
cp /path/to/kubectx-ng/completion/kubectx-ng.fish ~/.config/fish/completions/
cp /path/to/kubectx-ng/completion/kubens-ng.fish ~/.config/fish/completions/

# Or create symlinks
ln -s /path/to/kubectx-ng/completion/kubectx-ng.fish ~/.config/fish/completions/
ln -s /path/to/kubectx-ng/completion/kubens-ng.fish ~/.config/fish/completions/
```

## Usage

### kubectx-ng (Context Switcher)

```bash
# List all contexts
kubectx-ng

# Interactive selection with fzf
kubectx-ng
# (when fzf is installed and no arguments provided)

# Switch to a context
kubectx-ng minikube

# Switch to previous context
kubectx-ng -

# Show current context
kubectx-ng -c
kubectx-ng --current

# Rename context
kubectx-ng new-name=old-name

# Rename current context
kubectx-ng new-name=.

# Delete context (global mode only)
kubectx-ng -d context-name

# Delete multiple contexts
kubectx-ng -d context1 context2 context3

# Unset current context
kubectx-ng -u
kubectx-ng --unset

# Show current mode
kubectx-ng --mode

# Show help
kubectx-ng -h
kubectx-ng --help
```

### kubens-ng (Namespace Switcher)

```bash
# List all namespaces in current context
kubens-ng

# Interactive selection with fzf
kubens-ng
# (when fzf is installed)

# Switch to a namespace
kubens-ng kube-system

# Switch to previous namespace
kubens-ng -

# Show current namespace
kubens-ng -c
kubens-ng --current

# Show current mode
kubens-ng --mode

# Show help
kubens-ng -h
kubens-ng --help
```

## Per-Shell Mode

### Setup

Source the shell integration script in your shell config:

```bash
# ~/.bashrc or ~/.zshrc
source /path/to/kubectx-ng.sh
```

This sets up:
- `KUBECONFIG_DEST_DIR` for per-shell configs
- Aliases: `kctx`, `kns`, `kubectx`, `kubens`
- Helper functions (see below)

### How It Works

In per-shell mode:
1. Each context/namespace switch creates a temporary config file
2. The `KUBECONFIG` environment variable points to this file
3. Different terminals can have different contexts simultaneously
4. No global config modifications

Example workflow:
```bash
# Terminal 1
$ kubectx-ng production
Switched to context "production" (per-shell mode).

# Terminal 2
$ kubectx-ng staging
Switched to context "staging" (per-shell mode).

# Terminal 1 is still on production!
# Terminal 2 is on staging!
```

### Helper Functions

When you source `kubectx-ng.sh`, you get these helper functions:

```bash
# Show current status
kubectx-status

# Clean up old per-shell config files
kubectx-cleanup

# Switch to global mode (current shell only)
kubectx-global

# Switch to per-shell mode (current shell only)
kubectx-per-shell
```

## Environment Variables

### Mode Control
- `KUBECTX_MODE`: Force mode (`global` or `per-shell`, default: `auto`)
- `KUBECONFIG_DEST_DIR`: Directory for per-shell configs (enables per-shell mode when set)
- `KUBECONFIG_SRC_DIR`: Additional config files directory (default: `~/.kube/config.src.d`)

### Display Customization
- `KUBECTX_IGNORE_FZF`: Set to bypass fzf interactive selection
- `KUBECTX_CURRENT_FGCOLOR`: Foreground color for current context/namespace
- `KUBECTX_CURRENT_BGCOLOR`: Background color for current context/namespace
- `NO_COLOR`: Disable colored output

### Performance
- `KUBECH_NAMESPACE_CHECK`: Namespace validation method
  - `list` (default): List all namespaces (compatible)
  - `label`: Use label selector (faster, requires k8s 1.22+)

## Examples

### Multi-Cluster Development

```bash
# Terminal 1: Work on production
$ source ~/kubectx-ng.sh
$ kctx production
$ kns production-app
$ kubectl get pods

# Terminal 2: Debug staging (simultaneously!)
$ source ~/kubectx-ng.sh
$ kctx staging
$ kns staging-debug
$ kubectl logs pod-name

# Terminal 3: Test on local cluster
$ source ~/kubectx-ng.sh
$ kctx minikube
$ kns default
$ kubectl apply -f test.yaml
```

### Global Mode for Single Context

```bash
# Don't source kubectx-ng.sh, just use directly
$ kubectx-ng production
Switched to context "production".

# This affects ALL terminals
```

### Switching Between Modes

```bash
# Start in per-shell mode
$ source ~/kubectx-ng.sh
$ kubectx-ng --mode
Current mode: per-shell

# Switch to global mode (current shell)
$ kubectx-global
Switched to global mode. Context/namespace changes will affect all terminals.

# Or set permanently
$ export KUBECTX_MODE=global
```

## Comparison

| Feature | kubectx | kubech | kubectx-ng |
|---------|---------|--------|------------|
| Fast context switching | ✅ | ❌ | ✅ |
| Interactive fzf | ✅ | ❌ | ✅ |
| Previous context (`-`) | ✅ | ❌ | ✅ |
| Per-shell isolation | ❌ | ✅ | ✅ |
| Global mode | ✅ | ❌ | ✅ |
| Rename contexts | ✅ | ❌ | ✅ (global mode) |
| Delete contexts | ✅ | ❌ | ✅ (global mode) |
| Color output | ✅ | ❌ | ✅ |
| Both modes in one tool | ❌ | ❌ | ✅ |

## Tips

1. **Use per-shell mode for multi-cluster work**: Prevents accidental operations on wrong clusters
2. **Use global mode for single cluster**: Simpler when you only work with one cluster
3. **Clean up regularly**: Run `kubectx-cleanup` to remove old per-shell config files
4. **Use fzf for speed**: Install fzf for interactive context/namespace selection
5. **Add to prompt**: Uncomment the PS1 section in `kubectx-ng.sh` to show context in your prompt
6. **Fast namespace checks**: Set `KUBECH_NAMESPACE_CHECK=label` for k8s 1.22+

## Requirements

- `kubectl` installed and configured
- Bash 4.0+ or Zsh or Fish
- Optional: `fzf` for interactive selection
- Optional: Shell completions for enhanced tab completion

## Troubleshooting

### Per-shell mode not working
```bash
# Check environment variables
$ echo $KUBECONFIG_DEST_DIR
$ echo $KUBECTX_MODE

# Ensure you sourced the script
$ source /path/to/kubectx-ng.sh
```

### Too many config files
```bash
# Clean up old per-shell configs
$ kubectx-cleanup
```

### Context not switching
```bash
# Check current mode
$ kubectx-ng --mode

# Verify kubectl is working
$ kubectl config get-contexts
```

### Permission errors
```bash
# Fix directory permissions
$ chmod 700 ~/.kube/config.dest.d
$ chmod 700 ~/.kube/config.src.d
```

## License

MIT License - See individual script headers for details.

## Credits

- Based on [kubectx](https://github.com/ahmetb/kubectx) by Ahmet Alp Balkan
- Inspired by [kubech](https://github.com/aabouzaid/kubech) by Ahmed AbouZaid
- Combined and enhanced for the best of both worlds

## Contributing

Contributions welcome! Please feel free to submit issues or pull requests.
