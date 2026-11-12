function btool
    argparse 'd/decompress' 'r/remove' 'o/output=' -- $argv
    or return
    
    if test -z "$argv"
        echo "Usage: btool [-d] [-r] [-o <output_name>] <path...>"
        echo ""
        echo "Options:"
        echo "  -d, --decompress    Extract a .tar.zst archive"
        echo "  -r, --remove        Remove source file/directory after successful operation"
        echo "  -o, --output        Specify custom archive name (default: <path>.tar.zst)"
        echo ""
        echo "Examples:"
        echo "  btool .                     # Archive current directory to functions.tar.zst"
        echo "  btool src -o my_code.zst    # Archive 'src' to 'my_code.zst'"
        echo "  btool -d archive.tar.zst    # Decompress archive"
        echo "  btool -r my_folder          # Archive and delete 'my_folder'"
        return 1
    end

    for path in $argv
        set -l base (string trim -r -c / $path)
        
        if set -q _flag_d
            # DECOMPRESS
            if not test -f "$base"
                echo "Error: File '$base' not found."
                continue
            end
            
            if tar --use-compress-program=unzstd -xvf "$base"
                if set -q _flag_r
                    rm "$base"
                end
            else
                echo "Error: Failed to decompress '$base'."
            end
        else
            # COMPRESS
            if not test -e "$base"
                echo "Error: Path '$base' not found."
                continue
            end
            
            set -l archive_name "$base.tar.zst"
            if set -q _flag_o
                set archive_name $_flag_o
            else if test "$base" = "."
                set archive_name (basename (pwd))".tar.zst"
            end
            
            set -l success 0
            if git -C "$base" rev-parse --is-inside-work-tree >/dev/null 2>&1
                # If it's a git repo, use git to list files (respecting .gitignore)
                if git -C "$base" ls-files --cached --others --exclude-standard -z | \
                   tar --use-compress-program='zstd -19 -T0' --null --exclude="$archive_name" -cf "$archive_name" -C "$base" -T -
                    echo "Archived '$base' to '$archive_name' (Git-aware)"
                    set success 1
                end
            else
                # Fallback for non-git folders
                if tar --use-compress-program='zstd -19 -T0' --exclude="$archive_name" -cf "$archive_name" "$base"
                    echo "Archived '$base' to '$archive_name' (Standard)"
                    set success 1
                end
            end
            
            if test $success -eq 1; and set -q _flag_r
                if test "$base" = "."
                    echo "Warning: Refusing to remove current directory '.' even with -r flag"
                else
                    rm -rf "$base"
                end
            end
        end
    end
end
