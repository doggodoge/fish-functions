function odoc --description 'Open Odin package documentation in Zed (e.g. odoc core:strings)'
    set -l documentation (command odin doc $argv)
    or return $status

    printf '%s\n' $documentation | command zed --existing -
end
