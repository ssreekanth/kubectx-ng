#compdef kubens-ng kns=kubens-ng

# Zsh completion for kubens-ng

_kubens-ng() {
  local curcontext="$curcontext" state line
  typeset -A opt_args

  # Get all namespaces
  local -a namespaces
  namespaces=("${(@f)$(kubectl get namespaces -o=jsonpath='{range .items[*].metadata.name}{@}{"\n"}{end}' 2>/dev/null)}")

  _arguments -C \
    '(- *)'{-h,--help}'[show help message]' \
    '(- *)'{-c,--current}'[show current namespace]' \
    '(- *)--mode[show current mode (global/per-shell)]' \
    '1:namespace:->namespace' \
    && return 0

  case $state in
    namespace)
      # Always offer '-' for previous namespace
      compadd "$@" - "-"
      compadd "$@" -a namespaces
      ;;
  esac
}
