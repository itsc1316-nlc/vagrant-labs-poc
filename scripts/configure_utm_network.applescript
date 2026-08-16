-- Configure the QEMU socket NIC used by the UTM dual profile.
-- Arguments: <VM UUID> <netdev argument> <device argument>
--
-- vagrant_utm's add_qemu_additional_args script appends on every boot. This
-- script first removes this project's labnet arguments, so halt/reload/up does
-- not accumulate duplicate QEMU device ids.

on run argv
    if (count of argv) is not 3 then
        error "Expected VM UUID, netdev argument, and device argument"
    end if

    set vmId to item 1 of argv
    set managedNetdev to item 2 of argv
    set managedDevice to item 3 of argv

    tell application "UTM"
        set vm to virtual machine id vmId
        set config to configuration of vm
        set qemuArgs to qemu additional arguments of config
        set cleanedArgs to {}

        repeat with i from 1 to (count of qemuArgs)
            set currentArgument to argument string of item i of qemuArgs
            set keepArgument to true

            if currentArgument starts with "-netdev " and currentArgument contains "id=labnet" then
                set keepArgument to false
            else if currentArgument contains "netdev=labnet" then
                set keepArgument to false
            else if currentArgument is "-device" and i < (count of qemuArgs) then
                set nextArgument to argument string of item (i + 1) of qemuArgs
                if nextArgument contains "netdev=labnet" then
                    set keepArgument to false
                end if
            end if

            if keepArgument then
                set end of cleanedArgs to {argument string:currentArgument}
            end if
        end repeat

        set end of cleanedArgs to {argument string:managedNetdev}
        set end of cleanedArgs to {argument string:"-device"}
        set end of cleanedArgs to {argument string:managedDevice}
        set qemu additional arguments of config to cleanedArgs
        update configuration of vm with config
    end tell
end run
