#compdef kubens-ng kns=kubens-ng

# Zsh completion for kubens-ng

# Get all namespaces
local namespaces
namespaces=$(kubectl get namespaces -o=jsonpath='{range .items[*].metadata.name}{@}{"\n"}{end}' 2>/dev/null)

# Build completion arguments
_arguments -s -S \
  '(- *)'{-h,--help}'[show help message]' \
  '(- *)'{-c,--current}'[show current namespace]' \
  '(- *)--mode[show current mode (global/per-shell)]' \
  "1: :(- ${namespaces})"
