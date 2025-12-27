# Fish completion for kubens-ng

function __fish_kubens_ng_arg_number -a number
    set -l cmd (commandline -opc)
    test (count $cmd) -eq $number
end

function __fish_kubens_ng_needs_command
    set -l cmd (commandline -opc)
    test (count $cmd) -eq 1
end

# Disable file completion
complete -f -c kubens-ng
complete -f -c kns

# Flags
complete -f -c kubens-ng -n '__fish_kubens_ng_needs_command' -s h -l help -d "show help message"
complete -f -c kubens-ng -n '__fish_kubens_ng_needs_command' -s c -l current -d "show current namespace"
complete -f -c kubens-ng -n '__fish_kubens_ng_needs_command' -l mode -d "show current mode (global/per-shell)"

complete -f -c kns -n '__fish_kubens_ng_needs_command' -s h -l help -d "show help message"
complete -f -c kns -n '__fish_kubens_ng_needs_command' -s c -l current -d "show current namespace"
complete -f -c kns -n '__fish_kubens_ng_needs_command' -l mode -d "show current mode (global/per-shell)"

# Namespace names
complete -f -x -c kubens-ng -n '__fish_kubens_ng_arg_number 1' -a "(kubectl get ns -o=custom-columns=NAME:.metadata.name --no-headers 2>/dev/null)"
complete -f -x -c kubens-ng -n '__fish_kubens_ng_arg_number 1' -a "-" -d "switch to the previous namespace"

complete -f -x -c kns -n '__fish_kubens_ng_arg_number 1' -a "(kubectl get ns -o=custom-columns=NAME:.metadata.name --no-headers 2>/dev/null)"
complete -f -x -c kns -n '__fish_kubens_ng_arg_number 1' -a "-" -d "switch to the previous namespace"
