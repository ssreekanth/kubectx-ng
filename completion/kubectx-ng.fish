# Fish completion for kubectx-ng

function __fish_kubectx_ng_arg_number -a number
    set -l cmd (commandline -opc)
    test (count $cmd) -eq $number
end

function __fish_kubectx_ng_needs_command
    set -l cmd (commandline -opc)
    test (count $cmd) -eq 1
end

function __fish_kubectx_ng_using_command -a current_command
    set -l cmd (commandline -opc)
    test (count $cmd) -gt 1 -a "$cmd[2]" = "$current_command"
end

# Disable file completion
complete -f -c kubectx-ng
complete -f -c kctx

# Flags
complete -f -c kubectx-ng -n '__fish_kubectx_ng_needs_command' -s h -l help -d "show help message"
complete -f -c kubectx-ng -n '__fish_kubectx_ng_needs_command' -s c -l current -d "show current context name"
complete -f -c kubectx-ng -n '__fish_kubectx_ng_needs_command' -s u -l unset -d "unset current context"
complete -f -c kubectx-ng -n '__fish_kubectx_ng_needs_command' -l mode -d "show current mode (global/per-shell)"
complete -f -c kubectx-ng -n '__fish_kubectx_ng_needs_command' -s d -d "delete context" -r

complete -f -c kctx -n '__fish_kubectx_ng_needs_command' -s h -l help -d "show help message"
complete -f -c kctx -n '__fish_kubectx_ng_needs_command' -s c -l current -d "show current context name"
complete -f -c kctx -n '__fish_kubectx_ng_needs_command' -s u -l unset -d "unset current context"
complete -f -c kctx -n '__fish_kubectx_ng_needs_command' -l mode -d "show current mode (global/per-shell)"
complete -f -c kctx -n '__fish_kubectx_ng_needs_command' -s d -d "delete context" -r

# Context names (read from original config file, not per-shell config)
set -l orig_kubeconfig "$HOME/.kube/config"
if set -q KUBECONFIG_ORIG
    set orig_kubeconfig $KUBECONFIG_ORIG
end

complete -f -x -c kubectx-ng -n '__fish_kubectx_ng_arg_number 1' -a "(env KUBECONFIG=$orig_kubeconfig kubectl config get-contexts --output='name' 2>/dev/null)"
complete -f -x -c kubectx-ng -n '__fish_kubectx_ng_arg_number 1' -a "-" -d "switch to the previous context"

complete -f -x -c kctx -n '__fish_kubectx_ng_arg_number 1' -a "(env KUBECONFIG=$orig_kubeconfig kubectl config get-contexts --output='name' 2>/dev/null)"
complete -f -x -c kctx -n '__fish_kubectx_ng_arg_number 1' -a "-" -d "switch to the previous context"

# Context names for -d flag
complete -f -x -c kubectx-ng -n '__fish_kubectx_ng_using_command -d' -a "(env KUBECONFIG=$orig_kubeconfig kubectl config get-contexts --output='name' 2>/dev/null)"
complete -f -x -c kctx -n '__fish_kubectx_ng_using_command -d' -a "(env KUBECONFIG=$orig_kubeconfig kubectl config get-contexts --output='name' 2>/dev/null)"
