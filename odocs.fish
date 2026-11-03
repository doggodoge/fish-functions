function odocs --description 'Search Odin signatures and open selected documentation in Zed'
    set -l package_args $argv
    if test (count $package_args) -eq 0
        set package_args .
    end

    set -l documentation (command odin doc $package_args)
    or return $status

    set -l signatures
    for line_number in (seq (count $documentation))
        if string match -rq '^\t\t[^\t].* :: proc(\(|\{)' -- $documentation[$line_number]
            set -a signatures (printf '%s\t%s' $line_number (string trim -- $documentation[$line_number]))
        end
    end

    if test (count $signatures) -eq 0
        echo 'odocs: No procedure signatures found.' >&2
        return 1
    end

    set -l selected (printf '%s\n' $signatures | command fzf --delimiter=\t --with-nth=2.. --no-multi --layout=reverse --prompt='Signature> ')
    set -l selection_status $status
    switch $selection_status
        case 1 130
            return 0
        case 0
        case '*'
            return $selection_status
    end

    set -l start (string split -m 1 \t -- $selected)[1]
    set -l finish $start
    for line_number in (seq (math $start + 1) (count $documentation))
        set -l line $documentation[$line_number]
        if test -n "$line"; and not string match -rq '^\t\t\t' -- $line
            break
        end
        set finish $line_number
    end

    printf '%s\n' $documentation[$start..$finish] | command zed --existing -
end
