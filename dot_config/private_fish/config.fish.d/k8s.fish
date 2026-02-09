alias kevents='kubectl get events --sort-by=.metadata.creationTimestamp'
alias kpfw='kubectl port-forward'
alias k='kubectl'


function kswitch --wraps switcher
    kubeswitch $argv
end


function kns --wraps switcher
    kubeswitch namespace $argv
end




function kprom --description "Finds a Prometheus service in any namespace and port-forwards to it using jq."
    # Check required commands
    if not command -v kubectl >/dev/null
        echo (set_color red)"Error: kubectl is not installed or not in your PATH."(set_color normal)
        return 1
    end
    if not command -v jq >/dev/null
        echo (set_color red)"Error: jq is not installed or not in your PATH."(set_color normal)
        echo "Please install it (e.g., 'brew install jq')."
        return 1
    end

    echo "🔍 Finding Prometheus service across all namespaces..."

    # Get all services from all namespaces as JSON
    set service_json (kubectl get svc -A -o json)
    if test $status -ne 0
        echo (set_color red)"❌ Failed to get services from the cluster."(set_color normal)
        return 1
    end

    # Find the first service whose name matches (kube-)?prometheus-*-prometheus
    # Output the name and namespace as space-separated
    set service_info (echo $service_json | jq -r '
        .items[]
        | select(.metadata.name | test("^(kube-)?prometheus-.*-prometheus$"))
        | "\(.metadata.name) \(.metadata.namespace)"
        ' | head -n 1)

    if test -z "$service_info"
        echo (set_color yellow)"⚠️ Could not find any service matching the pattern '\'(kube-)?prometheus-*-prometheus\''."(set_color normal)
        return 1
    end

    # Split service_info into name and namespace
    set parts (string split " " -- $service_info)
    set prometheus_svc $parts[1]
    set prometheus_ns $parts[2]

    # Find the port named 'http-web' or port 9090 within the chosen service
    set prometheus_port (echo $service_json | jq -r --arg name "$prometheus_svc" --arg ns "$prometheus_ns" '
        .items[]
        | select(.metadata.name == $name and .metadata.namespace == $ns)
        | .spec.ports[]
        | select(.name == "http-web" or .port == 9090)
        | .port
        ' | head -n 1)

    if test -z "$prometheus_port"
        echo (set_color red)"❌ Found service '$prometheus_svc' in namespace '$prometheus_ns', but could not find a port named 'http-web' or port 9090."(set_color normal)
        return 1
    end

    echo (set_color green)"✅ Found Prometheus service:"(set_color normal)" $prometheus_svc"
    echo (set_color green)"✅ In Namespace:"(set_color normal)" $prometheus_ns"
    echo (set_color green)"✅ On Port:"(set_color normal)" $prometheus_port"
    echo

    echo "🚀 Starting port-forward..."
    echo "➡️  Access Prometheus at: "(set_color blue)"http://localhost:$prometheus_port"(set_color normal)
    echo "(Press Ctrl+C to stop)"
    echo

    # Execute the port-forward command
    kubectl port-forward -n "$prometheus_ns" "svc/$prometheus_svc" "$prometheus_port:$prometheus_port"
end


function tfyaml --description "Decode a YAML file via terraform console yamldecode(file(...))"
    # Usage:
    #   tfyaml path/to/file.yaml
    #   tfyaml path/to/file.yaml '.spec.config'
    
    if test (count $argv) -lt 1
        echo "Usage: tfyaml <yaml-file> [extra-console-expr]" >&2
        return 2
    end

    set -l yaml_file (realpath -- $argv[1] 2>/dev/null)
    if not test -f "$yaml_file"
        echo "Error: file not found: $argv[1]" >&2
        return 1
    end

    # Optional extra console expression to pipe into
    set -l extra ""
    if test (count $argv) -ge 2
        set extra $argv[2]
    end

    # Build the console expression
    if test -n "$extra"
        set -l expr "yamldecode(file(\"$yaml_file\"))$extra"
        echo $expr | terraform console
    else
        set -l expr "yamldecode(file(\"$yaml_file\"))"
        echo $expr | terraform console
    end
end
