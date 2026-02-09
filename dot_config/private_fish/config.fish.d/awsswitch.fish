function awsswitch
    # Run embedded Python script and capture output
    set -l selected_profile (python3 -c '
import sys
import boto3
from iterfzf import iterfzf

# Get all AWS profiles
try:
    profiles = boto3.Session().available_profiles
except Exception as e:
    print(f"Error: {e}", file=sys.stderr)
    sys.exit(1)

if not profiles:
    print("No profiles found", file=sys.stderr)
    sys.exit(1)

# Let user select with fzf
selected = iterfzf(profiles, prompt="AWS Profile> ")

if selected:
    print(selected)
else:
    sys.exit(1)
')

    # Check if a profile was selected
    if test $status -eq 0 -a -n "$selected_profile"
        # Export the AWS_PROFILE variable
        set -gx AWS_PROFILE $selected_profile
        echo "✓ Switched to profile: $AWS_PROFILE"
    else
        echo "✗ No profile selected" >&2
        return 1
    end
end

