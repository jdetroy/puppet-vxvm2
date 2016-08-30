Puppet::Type.type(:vxvm2_disk).provide(:vxvm2) do
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
        out=vxdisk('list', @resource[:name])
	words = ['format=cdsdisk']
	words.any? { |w| out[w] }	
    end

end
