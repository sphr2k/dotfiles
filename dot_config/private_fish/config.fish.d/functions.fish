function manp
    man -t $argv | ps2pdf - - | open -g -f -a Preview
end

function rand
    openssl rand -hex $argv
end


function knslookup --description 'run nslookup in an alpine container in current namespace'
    kubectl delete pod knslookup-jw &>/dev/null
    kubectl run knslookup-jw --image=docker.io/library/alpine --rm -it --restart=Never -- nslookup $argv
    kubectl delete pod knslookup-jw --wait=false &>/dev/null
end

function ktempshell --description 'run a kubernetes temp shell in current namespace'
    echo $argv[1]
    if test -n "$argv[1]"
        set image_name $argv[1]
    else
        set image_name docker.io/library/ubuntu:22.04
    end
    echo $image_name
    set pod_name temp-shell-$(LC_ALL=C tr -dc a-z0-9 </dev/urandom | head -c 6)
    kubectl run $pod_name --image=$image_name --rm -it --restart=Never -- sh -c "bash || sh"
    kubectl delete pod $pod_name --wait=false &>/dev/null
end


function krestart
    read -l -P "Restart all Deployments, StatefulSets and DaemonSets in current namespace? (y/n): " confirm
    if string match -q -r '^[yY]' $confirm
        kubectl rollout restart deployments,statefulsets,daemonsets
    end
end



# function knodeshell
#   kubectl debug -it node/$argv --image ubuntu:22.04 -- chroot /host bash
# end

function fish-config
    code --wait ~/.config/fish ~/.config/fish/config.fish
    source ~/.config/fish/config.fish
    for file in $HOME/.config/fish/config.fish.d/*.fish
        source $file
    end
end

function git-private --description 'git author: mail@janwerner.de'
    set -gx GIT_AUTHOR_NAME "Jan Werner"
    set -gx GIT_AUTHOR_EMAIL "mail@janwerner.de"
    set -gx GIT_COMMITTER_NAME $GIT_AUTHOR_NAME
    set -gx GIT_COMMITTER_EMAIL $GIT_AUTHOR_EMAIL
    set -gx GITLAB_HOST gitlab.com
end

function git-aok --description 'git author: jan.werner@ext.sys.aok.de'
    set -gx GIT_AUTHOR_NAME "Jan Werner"
    set -gx GIT_AUTHOR_EMAIL "jan.werner@ext.sys.aok.de"
    set -gx GIT_COMMITTER_NAME $GIT_AUTHOR_NAME
    set -gx GIT_COMMITTER_EMAIL $GIT_AUTHOR_EMAIL
    set -gx GITLAB_HOST gitlab.com
end

function git-skillbyte --description 'git author: jan.werner@skillbyte.de'
    set -gx GIT_AUTHOR_NAME "Jan Werner"
    set -gx GIT_AUTHOR_EMAIL "jan.werner@skillbyte.de"
    set -gx GIT_COMMITTER_NAME $GIT_AUTHOR_NAME
    set -gx GIT_COMMITTER_EMAIL $GIT_AUTHOR_EMAIL
    set -gx GITLAB_HOST gitlab.com
end

function watch --description 'modern watch'
    viddy -d -n 2 --shell fish $argv[1..-1]
end

function b64d --description 'base64 decode'
    echo $argv[1] | base64 -d
end


function transfer --description 'Easy file sharing from the command line using http://transfer.janwerner.de'
    if test (count $argv) -eq 0
        echo -e "No arguments specified. Usage:\necho transfer /tmp/test.md\ncat /tmp/test.md | transfer test.md"
        return 1
    end
    set tmpfile ( mktemp -t transferXXX )
    set url https://werner:Ekelfernsehen@transfer.janwerner.de
    if tty -s
        set basefile (basename $argv[1] | sed -e 's/[^a-zA-Z0-9._-]/-/g')
        curl --progress-bar --upload-file $argv[1] "$url/$basefile" >>$tmpfile
    else
        curl --progress-bar --upload-file - "$url/$argv[1]" >>$tmpfile
        echo
    end
    cat $tmpfile
    echo
    rm -f $tmpfile
end



function bashrun
    if test (count $argv) -eq 0
        echo "Please provide a URL."
        return 1
    end

    set url $argv[1]
    curl -s $url | bash
end

function sanitize-history
    set -l patterns ".mp4" ".m4v" "yt-dlp"

    for arg in $argv
        set patterns $patterns $arg
    end

    for pattern in $patterns
        echo all | history delete --contains "$pattern" &>/dev/null
    end
end

function curl-socks
    curl --socks5-hostname admin:admin@dock.lan:1080 $argv
end


function fftranscode
    set input_file $argv[1]
    set output_file (basename -s . $input_file)".transcoded.mp4"

    ffmpeg -i $input_file -c:a copy -c:v h264_videotoolbox -b:v 2190k $output_file
end


function a2 --description "Download files with aria2c, with options for setting a proxy and an output file name."
    # Define the option spec for argparse with default proxy value
    set --local options 'p/proxy=http://dock.lan:1080' 'o/outfile='

    # Call argparse
    argparse $options -- $argv

    # If help is requested, display usage information
    if set --query _flag_help
        printf "Usage: a2 [OPTIONS] URL\n\n"
        printf "Options:\n"
        printf "  -p/--proxy [PROXY]    Set the proxy server (default: http://dock.lan:1080)\n"
        printf "  -o/--outfile [FILE]   Set the output file name (optional)\n"
        printf "  URL                   URL of the file to download\n"
        return 0
    end

    # Proxy option is already set by default, but can be overridden by user input
    set --local proxy_option "--all-proxy=$_flag_proxy"

    # Outfile option
    set --local outfile_option
    if set --query _flag_outfile
        set outfile_option "-o $_flag_outfile"
    end

    # Call aria2c with the parsed options and any additional arguments
    aria2c --file-allocation=falloc $proxy_option $outfile_option $_flag_args
end


function bass2
    set tmp_dir (mktemp -d)
    set tmp_file $tmp_dir/tmp.sh

    touch $tmp_file
    chmod +x $tmp_file

    code --wait $tmp_file

    bash -c $tmp_file

    rm $tmp_file
end


function color --description 'Run rg with color and passthru for multiple patterns'
    set -l patterns
    for arg in $argv
        if test -f $arg
            set -a patterns --files $arg
        else
            set -a patterns -e $arg
        end
    end
    rg --color always --passthru $patterns
end


function fdt -d "Search for text in files using fd and rg"
    set -l pattern
    set -l extension
    set -l help_msg "Usage: fdt [OPTIONS] PATTERN

Options:
  -e, --extension EXT  Search files with the specified extension.
  -h, --help           Show this help message.

Examples:
  fdt 'text to search'          Search all files for 'text to search'.
  fdt -e md 'text to search'    Search all Markdown (.md) files for 'text to search'."

    # Create a copy of the arguments
    set -l args $argv

    # Iterate over the arguments
    while count $args > 0
        switch $args[1]
            case '-h' '--help'
                echo "$help_msg"
                return 0
            case '-e' '--extension'
                if count $args > 1
                    set extension $args[2]
                    set args $args[3..-1] # Remove the two arguments
                else
                    echo "Error: No extension specified for -e/--extension."
                    return 1
                end
            case '*'
                set pattern $args[1]
                set args $args[2..-1] # Remove the pattern from the arguments
                break # Break the loop after finding the pattern
        end
    end

    if test -z "$pattern"
        echo "Error: No search pattern provided."
        echo "$help_msg"
        return 1
    end

    if test -n "$extension"
        fd --extension $extension | xargs rg --with-filename --hidden "$pattern"
    else
        fd | xargs rg --with-filename --hidden "$pattern"
    end
end

function "aws-switch" -d "Switch AWS CLI profile"
    # List AWS profiles
    set -l profiles (aws configure list-profiles)

    # Ensure profiles are available
    if not count $profiles > /dev/null
        echo "No AWS profiles found."
        return 1
    end

    # Select profile with fzf
    set -l selected_profile (printf "%s\n" $profiles | fzf)

    # Check if a profile was selected
    if test -z "$selected_profile"
        echo "No profile selected."
        return 1
    end

    # Set AWS_PROFILE environment variable
    set -gx AWS_PROFILE $selected_profile
    echo "AWS profile set to '$selected_profile'"
end

function "jw" -d "flarectl for janwerner.de"
    set -x CF_API_TOKEN (cat ~/.config/tokens/cloudflare-dns)
    flarectl $argv
end


# function fddl  -d "fd in dl* subfolders (ignore case) and open with fzf"
#     set -l folders ~/dl* "/Users/jan.werner/Library/Application Support/Mountain Duck/Volumes.noindex/OneDrive.localized/prn1/"
    
#     set -l selected (fd --ignore-case $argv $folders | while read -l fullpath
#         set -l filename (basename $fullpath)
#         set -l segments (string split / $fullpath)
#         set -l last_dir $segments[-2]
#         set -l display
#         if test (string length $last_dir) -eq 1
#             set display $segments[-3]/$last_dir/$filename
#         else
#             set display $last_dir/$filename
#         end
#         echo "$display\t$fullpath"
#     end | fzf --with-nth=1 | string split -f2 "\t")

#     if test -n "$selected"
#         open -R "$selected"
#     end
# end

# function fddl  -d "fd in dl* subfolders (ignore case) and open with fzf"
#     set -l folders ~/dl* "/Users/jan.werner/Library/Application Support/Mountain Duck/Volumes.noindex/OneDrive.localized/prn1/"
    
#     set files (fd --ignore-case $argv $folders | fzf)

#     if test -n "$files"
#         open -R "$files"
#     end
# end


function "fdplay" -d "Play file from fd search results"
    set dest_dir "/Users/jan.werner/Library/Application Support/Mountain Duck/Volumes.noindex/OneDrive.localized/My Files/prn1"

    # Ensure at least one argument is provided
    if not set -q argv[1]
        echo "Usage: mvdl <search-term>"
        return 1
    end

    # Use fd to search in ~/dl* with the arguments given
    set found (fd --ignore-case $argv ~/dl*)

    # Show fzf multi-select if results exist
    if test (count $found) -eq 0
        echo "No files found matching '$argv'"
        return
    end

    set to_move (printf '%s\n' $found | fzf --multi --prompt="Select files to move: ")

    if test -z "$to_move"
        echo "No files selected."
        return
    end

    for file in $to_move
        mv "$file" "$dest_dir/"
        set_color cyan; echo -n "📦 "
        set_color yellow; echo -n (basename "$file")
        set_color normal; echo -n " → "
        set_color green; echo -n "🗂 "
        set_color magenta; echo (basename "$dest_dir")
        set_color normal; echo " ✅"
    end

end


function "fdplay" -d "Play file from combined fd search results"
    # Ensure at least one argument is provided
    if not set -q argv[1]
        echo "Usage: mvdl <search-term>"
        return 1
    end

    set prn1_dir "/Users/jan.werner/Library/Application Support/Mountain Duck/Volumes.noindex/OneDrive.localized/My Files/prn1"
    
    # Search both locations
    set found (fd --ignore-case $argv ~/dl*; and fd --ignore-case $argv "$prn1_dir")

    if test (count $found) -eq 0
        echo "No files found matching '$argv'"
        return
    end

    # Select single file with fzf
    set to_open (printf '%s\n' $found | fzf --height 40% --prompt="Select file to open: ")

    if test -n "$to_open"
        open "$to_open"
        echo "Opening: $to_open"
    end
end
