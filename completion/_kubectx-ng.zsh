#compdef kubectx-ng kctx=kubectx-ng

# Zsh completion for kubectx-ng

local KUBECTX_GLOBAL="${XDG_CACHE_HOME:-$HOME/.kube}/kubectx"
local KUBECTX_SHELL="${KUBECONFIG_DEST_DIR}/.kubectx.$$"
local KUBECTX_FILE=""

# Determine which kubectx file to use based on mode
if [[ -n "${KUBECONFIG_DEST_DIR}" ]] || [[ "${KUBECTX_MODE}" == "per-shell" ]]; then
  KUBECTX_FILE="${KUBECTX_SHELL}"
else
  KUBECTX_FILE="${KUBECTX_GLOBAL}"
fi

# Get all contexts
local context_array=("${(@f)$(kubectl config get-contexts --output='name' 2>/dev/null)}")
local all_contexts=(\'${^context_array}\')

# Build completion arguments
local -a args

# Add flags
args+=(
  '(- *)'{-h,--help}'[show help message]'
  '(- *)'{-c,--current}'[show current context name]'
  '(- *)'{-u,--unset}'[unset current context]'
  '(- *)--mode[show current mode (global/per-shell)]'
  '-d[delete context]:context:->contexts'
)

# Add context completion
if [[ -f "$KUBECTX_FILE" ]]; then
  # Show '-' if there's a saved previous context
  args+=('1: :(- ${all_contexts})')
else
  args+=('1: :(${all_contexts})')
fi

_arguments -s -S $args

# Handle -d flag with multiple contexts
if [[ $state == contexts ]]; then
  _values 'contexts' ${all_contexts}
fi
