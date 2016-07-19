Puppet::Type.type(:vxvm_filesystem).provide :vxvm do
    confine :osfamily  => 'redhat'
    desc "Manages VXVM filesystems"

    commands :vxprint  => 'vxprint',
             :vxinfo => 'vxinfo',
						 :mkfs    => 'mkfs'

    def create
		  dev = '/dev/vx/rdsk/' + @resource[:vxvm_diskgroup] + '/' + @resource[:name] 
      mkfs('-F','vxfs',dev)
      #mkfs('-F','vxfs',@resource[:name])
    end

    def destroy
			# no-op
    end

    def exists?
		  #dev = '/dev/vx/rdsk/' + @resource[:vxvm_diskgroup] + '/' + @resource[:name] 
      vxprint('-qv', @resource[:name]) 
    end

end
