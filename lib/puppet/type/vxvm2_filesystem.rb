Puppet::Type.newtype(:vxvm2_filesystem) do
    ensurable

    newparam(:name) do
        desc "The name of the VXVM volume.  This is the unqualified name and will be
            automatically added to the volume group's device path (e.g., '/dev/vx/rdsk/$diskgroup/$volume')."
        isnamevar
        validate do |value|
            if value.include?(File::SEPARATOR)
                raise ArgumentError, "diskgroup names must be entirely unqualified"
            end
        end
    end
end
