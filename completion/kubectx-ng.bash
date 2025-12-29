#!/bin/bash

# Bash completion for kubectx-ng

_kubectx_ng()
{
  local curr_arg prev_arg flags contexts
  curr_arg=${COMP_WORDS[COMP_CWORD]}
  prev_arg=${COMP_WORDS[COMP_CWORD-1]}

  # Available flags
  flags="-h --help -c --current -u --unset --mode -d"

  # Get contexts from the original config file (not per-shell config)
  local orig_kubeconfig="${KUBECONFIG_ORIG:-$HOME/.kube/config}"
  contexts=$(KUBECONFIG="$orig_kubeconfig" kubectl config get-contexts --output='name' 2>/dev/null)

  # Handle -d flag (delete contexts)
  if [[ "$prev_arg" == "-d" ]]; then
    COMPREPLY=( $(compgen -W "$contexts" -- "$curr_arg") )
    return 0
  fi

  # If starts with -, complete flags
  if [[ "$curr_arg" == -* ]]; then
    COMPREPLY=( $(compgen -W "$flags" -- "$curr_arg") )
    return 0
  fi

  # Complete with contexts and '-' for previous context
  COMPREPLY=( $(compgen -W "- $contexts" -- "$curr_arg") )
}

complete -F _kubectx_ng kubectx-ng kctx
