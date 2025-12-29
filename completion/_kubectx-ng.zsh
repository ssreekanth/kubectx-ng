#compdef kubectx-ng kctx=kubectx-ng

# Zsh completion for kubectx-ng

_kubectx-ng() {
  local curcontext="$curcontext" state line
  typeset -A opt_args

  # Get all contexts from the original config file (not per-shell config)
  local orig_kubeconfig="${KUBECONFIG_ORIG:-$HOME/.kube/config}"
  local -a contexts
  contexts=("${(@f)$(KUBECONFIG="$orig_kubeconfig" kubectl config get-contexts --output='name' 2>/dev/null)}")

  _arguments -C \
    '(- *)'{-h,--help}'[show help message]' \
    '(- *)'{-c,--current}'[show current context name]' \
    '(- *)'{-u,--unset}'[unset current context]' \
    '(- *)--mode[show current mode (global/per-shell)]' \
    '-d[delete context]:context:->delete' \
    '1:context:->context' \
    && return 0

  case $state in
    context)
      # Add '-' for previous context if history exists
      local KUBECTX_GLOBAL="${XDG_CACHE_HOME:-$HOME/.kube}/kubectx"
      local KUBECTX_SHELL="${KUBECONFIG_DEST_DIR}/.kubectx.$$"
      local KUBECTX_FILE=""

      if [[ -n "${KUBECONFIG_DEST_DIR}" ]] || [[ "${KUBECTX_MODE}" == "per-shell" ]]; then
        KUBECTX_FILE="${KUBECTX_SHELL}"
      else
        KUBECTX_FILE="${KUBECTX_GLOBAL}"
      fi

      if [[ -f "$KUBECTX_FILE" ]]; then
        compadd "$@" - "-"
      fi
      compadd "$@" -a contexts
      ;;
    delete)
      compadd "$@" -a contexts
      ;;
  esac
}
