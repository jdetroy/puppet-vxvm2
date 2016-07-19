Puppet::Type.newtype(:vxvm_volume) do
    ensurable

    newparam(:name) do
        desc "The name of the VXVM volume.  This is the unqualified name and will be
            automatically added to the volume group's device path (e.g., '/dev/vx/dsk/$diskgroup/$volume')."
        isnamevar
        validate do |value|
            if value.include?(File::SEPARATOR)
                raise ArgumentError, "diskgroup names must be entirely unqualified"
            end
        end
    end

    newparam(:vxvm_diskgroup) do
        desc "The VXVM diskgroup name associated with this VXVM volume.  This will automatically
            set this diskgroup as a dependency, but it must be defined elsewhere using the
            vxvm_diskgroup type."
    end

    newproperty(:size) do
        desc "The size of the volume. Set to undef to use all available space"
        validate do |value|
            unless value =~ /^[0-9]+[KMGTPE]/i
                raise ArgumentError , "#{value} is not a valid logical volume size"
            end
        end
    end

		newparam(:type) do
			desc "The type of volume: stripe/concat/mirror "
			defaultto :concat
			newvalues(:concat, :stripe, :mirror)
		end
end
