#!/usr/bin/env bash
#
# Shell integration for kubectx-ng and kubens-ng
# Source this file in your .bashrc, .zshrc, or other shell config to enable per-shell mode
#
# Usage:
#   Add to your shell config:
#     source /path/to/kubectx-ng.sh
#
#   Or for global mode only:
#     # Don't source this file, just add to PATH
#

# Configuration
export KUBECONFIG_SRC_DIR="${KUBECONFIG_SRC_DIR:-$HOME/.kube/config.src.d}"
export KUBECONFIG_DEST_DIR="${KUBECONFIG_DEST_DIR:-$HOME/.kube/config.dest.d}"
export KUBECTX_MODE="${KUBECTX_MODE:-per-shell}"
# Store the original KUBECONFIG to prevent it from growing on each context switch
export KUBECONFIG_ORIG="${KUBECONFIG_ORIG:-$HOME/.kube/config}"

# Create directories
mkdir -p "${KUBECONFIG_SRC_DIR}" "${KUBECONFIG_DEST_DIR}"
chmod 700 "${KUBECONFIG_SRC_DIR}" "${KUBECONFIG_DEST_DIR}"

# Find the directory where this script is located
# Can be overridden by setting KUBECTX_NG_DIR before sourcing
if [[ -n "${KUBECTX_NG_DIR:-}" ]]; then
  # User manually specified the directory
  SCRIPT_DIR="${KUBECTX_NG_DIR}"
elif [[ -n "${BASH_SOURCE[0]:-}" ]]; then
  # Bash
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
elif [[ -n "${ZSH_VERSION:-}" ]]; then
  # Zsh - get the sourced file path
  # In zsh, ${(%):-%N} gives the current script being sourced
  local _this_script="${(%):-%N}"
  SCRIPT_DIR="$(cd "$(dirname "$_this_script")" && pwd)"
else
  # Fallback: try to find the script in common locations
  if [[ -f "$HOME/.kube/kubectx-ng/kubectx-ng" ]]; then
    SCRIPT_DIR="$HOME/.kube/kubectx-ng"
  else
    echo "Warning: Could not determine script directory. Please set KUBECTX_NG_DIR manually."
    SCRIPT_DIR="."
  fi
fi

# Functions instead of aliases (more reliable across shells and contexts)
# These functions capture KUBECONFIG changes from the scripts for per-shell mode
kctx() {
  # Use a temp file to communicate KUBECONFIG changes
  # This allows fzf to run interactively while still capturing env changes
  local tmpfile="/tmp/.kubectx-ng.$$"

  # Run the script with the temp file path
  # Pass the shell PID so the script can maintain consistent state files
  KUBECTX_EXPORT_FILE="$tmpfile" KUBECTX_SHELL_PID="$$" "${SCRIPT_DIR}/kubectx-ng" "$@"
  local exit_code=$?

  # Check if script wrote KUBECONFIG changes to temp file
  if [[ -f "$tmpfile" ]]; then
    local action
    action=$(cat "$tmpfile")
    rm -f "$tmpfile"

    # Extract the value after "EXPORT:" or check for "UNSET"
    if [[ "$action" == EXPORT:* ]]; then
      # Set KUBECONFIG - remove "EXPORT:" prefix
      export KUBECONFIG="${action#EXPORT:}"
    elif [[ "$action" == "UNSET" ]]; then
      # Unset KUBECONFIG
      unset KUBECONFIG
    fi
  fi

  return $exit_code
}

# Also define kubectx-ng as a function for convenience
kubectx-ng() {
  kctx "$@"
}

kns() {
  # Use a temp file to communicate KUBECONFIG changes
  # This allows fzf to run interactively while still capturing env changes
  local tmpfile="/tmp/.kubens-ng.$$"

  # Run the script with the temp file path
  # Pass the shell PID so the script can maintain consistent state files
  KUBECTX_EXPORT_FILE="$tmpfile" KUBECTX_SHELL_PID="$$" "${SCRIPT_DIR}/kubens-ng" "$@"
  local exit_code=$?

  # Check if script wrote KUBECONFIG changes to temp file
  if [[ -f "$tmpfile" ]]; then
    local action
    action=$(cat "$tmpfile")
    rm -f "$tmpfile"

    # Extract the value after "EXPORT:" or check for "UNSET"
    if [[ "$action" == EXPORT:* ]]; then
      # Set KUBECONFIG - remove "EXPORT:" prefix
      export KUBECONFIG="${action#EXPORT:}"
    elif [[ "$action" == "UNSET" ]]; then
      # Unset KUBECONFIG
      unset KUBECONFIG
    fi
  fi

  return $exit_code
}

# Also define kubens-ng as a function for convenience
kubens-ng() {
  kns "$@"
}

# Helper function to clean up old per-shell configs
kubectx-cleanup() {
  if [[ -d "${KUBECONFIG_DEST_DIR}" ]]; then
    local count
    count=$(find "${KUBECONFIG_DEST_DIR}" -name "*.yaml" -type f | wc -l)
    if [[ $count -gt 0 ]]; then
      echo "Removing ${count} per-shell config files from ${KUBECONFIG_DEST_DIR}"
      rm -f "${KUBECONFIG_DEST_DIR}"/*.yaml
      echo "Cleanup complete."
    else
      echo "No config files to clean up."
    fi
  fi
}

# Helper function to switch to global mode
kubectx-global() {
  export KUBECTX_MODE="global"
  unset KUBECONFIG
  echo "Switched to global mode. Context/namespace changes will affect all terminals."
}

# Helper function to switch to per-shell mode
kubectx-per-shell() {
  export KUBECTX_MODE="per-shell"
  echo "Switched to per-shell mode. Context/namespace changes only affect this terminal."
}

# Helper function to show current status
kubectx-status() {
  echo "Mode: $(${SCRIPT_DIR}/kubectx-ng --mode | head -1)"
  echo "Current context: $(kubectl config current-context 2>/dev/null || echo '<none>')"
  echo "Current namespace: $(${SCRIPT_DIR}/kubens-ng -c 2>/dev/null || echo '<none>')"

  if [[ "${KUBECTX_MODE}" == "per-shell" ]]; then
    echo ""
    echo "Per-shell settings:"
    echo "  KUBECONFIG_DEST_DIR: ${KUBECONFIG_DEST_DIR}"
    echo "  KUBECONFIG: ${KUBECONFIG:-<not set>}"
  fi
}

# Optional: Add kubectl context to PS1 prompt
# Uncomment to enable
# _kubectx_ps1() {
#   local ctx ns
#   ctx=$(kubectl config current-context 2>/dev/null || echo "")
#   if [[ -n "${ctx}" ]]; then
#     ns=$(kubectl config view -o=jsonpath="{.contexts[?(@.name==\"${ctx}\")].context.namespace}" 2>/dev/null)
#     ns="${ns:-default}"
#     echo "[⎈ ${ctx}:${ns}] "
#   fi
# }
# PS1='$(_kubectx_ps1)'$PS1

echo "kubectx-ng shell integration loaded"
echo "  Script directory: ${SCRIPT_DIR}"
echo "  Mode: ${KUBECTX_MODE}"
echo "  Commands: kctx, kubectx-ng, kns, kubens-ng"
echo "  Helpers: kubectx-status, kubectx-cleanup, kubectx-global, kubectx-per-shell"

# Register completions explicitly to override any conflicting completions (e.g., from Homebrew)
if [[ -n "${ZSH_VERSION:-}" ]]; then
  # Zsh: Load and register completion functions
  if [[ -d "${SCRIPT_DIR}/completion" ]]; then
    # Source the completion files directly to define the functions
    if [[ -f "${SCRIPT_DIR}/completion/_kubectx-ng.zsh" ]]; then
      source "${SCRIPT_DIR}/completion/_kubectx-ng.zsh"
      # Unregister any existing completions first
      compdef -d kctx 2>/dev/null
      compdef -d kubectx-ng 2>/dev/null
      # Explicitly register for kctx and kubectx-ng
      compdef _kubectx-ng kctx
      compdef _kubectx-ng kubectx-ng
      echo "  Completions registered: kctx, kubectx-ng"

      # Re-register after all initialization completes to override any late-loading completions
      # Use precmd hook to re-register on first prompt
      _kubectx_ng_ensure_completion() {
        if [[ ${_comps[kctx]} != "_kubectx-ng" ]]; then
          compdef _kubectx-ng kctx kubectx-ng
        fi
        # Remove this hook after first run
        precmd_functions=(${precmd_functions:#_kubectx_ng_ensure_completion})
      }
      precmd_functions+=(_kubectx_ng_ensure_completion)
    fi
    if [[ -f "${SCRIPT_DIR}/completion/_kubens-ng.zsh" ]]; then
      source "${SCRIPT_DIR}/completion/_kubens-ng.zsh"
      # Unregister any existing completions first
      compdef -d kns 2>/dev/null
      compdef -d kubens-ng 2>/dev/null
      # Explicitly register for kns and kubens-ng
      compdef _kubens-ng kns
      compdef _kubens-ng kubens-ng
      echo "  Completions registered: kns, kubens-ng"

      # Re-register after all initialization completes
      _kubens_ng_ensure_completion() {
        if [[ ${_comps[kns]} != "_kubens-ng" ]]; then
          compdef _kubens-ng kns kubens-ng
        fi
        # Remove this hook after first run
        precmd_functions=(${precmd_functions:#_kubens_ng_ensure_completion})
      }
      precmd_functions+=(_kubens_ng_ensure_completion)
    fi
  fi
elif [[ -n "${BASH_VERSION:-}" ]]; then
  # Bash: Source completion files
  if [[ -f "${SCRIPT_DIR}/completion/kubectx-ng.bash" ]]; then
    source "${SCRIPT_DIR}/completion/kubectx-ng.bash"
    echo "  Bash completions loaded"
  fi
  if [[ -f "${SCRIPT_DIR}/completion/kubens-ng.bash" ]]; then
    source "${SCRIPT_DIR}/completion/kubens-ng.bash"
  fi
fi
