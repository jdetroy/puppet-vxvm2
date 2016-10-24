Puppet::Type.type(:vxvm2_filesystem).provide :vxvm2 do
    confine :osfamily  => 'redhat'
    desc "Manages VXVM filesystems"

    commands :vxprint  => '/sbin/vxprint',
             :vxinfo => '/usr/sbin/vxinfo',
						 :mkfs    => '/sbin/mkfs',
						 :fstyp  => '/opt/VRTS/bin/fstyp'

    def create
		  dev = '/dev/vx/rdsk/' +  @resource[:name] 
      #mkfs('-t','vxfs','-o bsize=8192',dev)
			opt = 'bsize=8192'
			if resource[:options]
				#opt << resource[:options]
				#mkfs('-t','vxfs','-o',opt, dev)
				mkfs('-t','vxfs','-o', @resource[:options], dev)
			else
				 #mkfs('-t','vxfs','-o', opt, dev)
				 mkfs('-t','vxfs',dev)
			end
      #mkfs('-F','vxfs',@resource[:name])
    end

    def destroy
			# no-op
    end

    def exists?
		  dev = '/dev/vx/rdsk/' +  @resource[:name] 
      /vxfs/.match(fstyp(dev))
		rescue Puppet::ExecutionFailure
			nil
    end

end
