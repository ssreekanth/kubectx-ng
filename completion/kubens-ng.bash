#!/bin/bash

# Bash completion for kubens-ng

_kubens_ng()
{
  local curr_arg flags namespaces
  curr_arg=${COMP_WORDS[COMP_CWORD]}

  # Available flags
  flags="-h --help -c --current --mode"

  # If starts with -, complete flags
  if [[ "$curr_arg" == -* ]]; then
    COMPREPLY=( $(compgen -W "$flags" -- "$curr_arg") )
    return 0
  fi

  # Get namespaces
  namespaces=$(kubectl get namespaces -o=jsonpath='{range .items[*].metadata.name}{@}{"\n"}{end}' 2>/dev/null)

  # Complete with namespaces and '-' for previous namespace
  COMPREPLY=( $(compgen -W "- $namespaces" -- "$curr_arg") )
}

complete -F _kubens_ng kubens-ng kns
