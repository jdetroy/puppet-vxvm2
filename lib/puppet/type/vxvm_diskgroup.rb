Puppet::Type.newtype(:vxvm_diskgroup) do
    ensurable

    newparam(:name) do
        desc "The name of the VXVM diskgroup."
        isnamevar
    end

    newproperty(:disks, :array_matching => :all) do
        desc "The list of VMXM disks to be included in the diskgroup; this
             will automatically set these as dependencies, but they must be defined elsewhere
             using the vxvm_disk resource type."
    end

end
