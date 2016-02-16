Puppet::Type.type(:vxvm_disk).provide(:vxvm) do
    confine :osfamily  => 'redhat'
    desc "Manages VXVM disks"

    commands :vxdisksetup  => 'vxdisksetup', :vxdiskunsetup => 'vxdiskunsetup', :vxdisk => 'vxdisk'

    def create
        vxdisksetup('-i',@resource[:name])
    end

    def destroy
        vxdiskunsetup(@resource[:name])
    end

    def exists?
        vxdisk('list',@resource[:name])
    rescue Puppet::ExecutionFailure
        false
    end

end
