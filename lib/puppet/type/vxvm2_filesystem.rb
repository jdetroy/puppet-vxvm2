Puppet::Type.newtype(:vxvm2_filesystem) do
    ensurable

    newparam(:name) do
        desc "The name of the VXVM volume.  This is the  groupname/name and will be
            automatically added to the VXFS volume device path (e.g., '/dev/vx/rdsk/$name')."
        isnamevar
        #validate do |value|
        #    if value.include?(File::SEPARATOR)
        #        raise ArgumentError, "diskgroup names must be entirely unqualified"
        #    end
        #end
    end

		newparam(:options) do
			desc "Params for the mkfs.vxfs command"
		end

end
