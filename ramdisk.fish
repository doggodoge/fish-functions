function ramdisk --argument-names size name
    if test -z "$size"
        echo "Usage: ramdisk [size] [name]"
        return 1
    end
    
    set -l name (test -n "$name"; and echo "$name"; or echo "RAMDisk")
    
    # Convert to bytes, then to 512-byte blocks
    set -l bytes (numfmt --from=iec $size)
    set -l blocks (math "$bytes / 512")
    
    echo "Allocating memory for $size RAMDisk..."
    
    # string trim handles extra whitespace from hdiutil output
    set -l device (hdiutil attach -nomount ram://$blocks | string trim)
    
    if test $status -eq 0
        echo "Waiting for $device to initialize..."
        sleep 1 # Give macOS a moment to register the device node
        
        diskutil erasevolume HFS+ "$name" $device
    else
        echo "Failed to allocate RAM"
    end
end
