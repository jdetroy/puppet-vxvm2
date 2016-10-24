Puppet::Type.type(:vxvm2_volume).provide :vxvm2 do
    confine :osfamily  => 'redhat'
    desc "Manages VXVM volumes"

    commands :vxassist  => '/usr/sbin/vxassist',
             :vxinfo => '/usr/sbin/vxinfo',
             :vxprint => '/sbin/vxprint',
             :vxresize => '/opt/VRTS/bin/vxresize',
             :umount  => '/bin/umount',
             :blkid   => '/sbin/blkid',
             :vxvol   => '/usr/sbin/vxvol'

    def create
		  args = ['-g', @resource[:vxvm2_diskgroup], 'make', @resource[:name]]
      if @resource[:size]
        args.push( @resource[:size])
      end
			if @resource[:type]
				args.push( "layout=#{@resource[:type]}")
			end
			if @resource[:vxvm2_disk]
				args.push(@resource[:vxvm2_disk])
			end
      vxassist(*args)
    end

    def destroy
       vxvol('stop', @resource[:name])
       vxassist('remove', 'volume', @resource[:name])
    end

    def exists?
       vxinfo('-g', @resource[:vxvm2_diskgroup]) =~ vxvol_pattern
    end

    def size
        if @resource[:size] =~ /^\d+\.?\d{0,2}([KMGTPE])/i
            unit = $1.downcase
        end

        raw = vxprint('-g', @resource[:vxvm2_diskgroup], '-v', @resource[:name], '-u', unit, '-F  "%{name} - %{len}"')

        if raw =~ /\s+(\d+)\.(\d+)#{unit}/i
            if $2.to_i == 00
                return $1 + unit.capitalize
            else
                return $1 + '.' + $2 + unit.capitalize
            end
        end
    end

    def size=(new_size)
        vxvm_size_units = { "K" => 1, "M" => 1024, "G" => 1048576, "T" => 1073741824, "P" => 1099511627776, "E" => 1125899906842624 }
        vxvm_size_units_match = vxvm_size_units.keys().join('|')

        resizeable = false
        current_size = size()

        if current_size =~ /(\d+\.{0,1}\d{0,2})(#{vxvm_size_units_match})/i
            current_size_bytes = $1.to_i
            current_size_unit  = $2.upcase
        end

        if new_size =~ /(\d+)(#{vxvm_size_units_match})/i
            new_size_bytes = $1.to_i
            new_size_unit  = $2.upcase
        end

        ## Get the extend size from LVM module
        #if lvs('--noheading', '-o', 'vg_extent_size', '--units', 'k', path) =~ /\s+(\d+)\.\d+k/i
        #    vg_extent_size = $1.to_i
        #end

        ## Verify that it's an extension: Reduce is potentially dangerous and should be done manually
        if vxvm_size_units[current_size_unit] < vxvm_size_units[new_size_unit]
            resizeable = true
        elsif vxvm_size_units[current_size_unit] > vxvm_size_units[new_size_unit]
            if (current_size_bytes / vxvm_size_units[current_size_unit]) < (new_size_bytes / vxvm_size_units[new_size_unit])
                resizeable = true
            end
        elsif vxvm_size_units[current_size_unit] == vxvm_size_units[new_size_unit]
            if new_size_bytes > current_size_bytes
                resizeable = true
            end
        end

        if not resizeable
            fail( "Decreasing the size requires manual intervention (#{size} < #{current_size})" )
        else
            ## Check if new size fits the extend blocks - from LVM module
            #if new_size_bytes * vxvm_size_units[new_size_unit] % vg_extent_size != 0
            #    fail( "Cannot extend to size #{size} because VG extent size is #{vg_extent_size} KB" )
            #end
					# check max volume size on diskgroup
					#vxassist -g @resource[:vxvm_diskgroup] maxsize

            vxresize('-F','vxfs','-g',@resource[:vxvm2_diskgroup], size ) || fail( "Cannot resize file system to size #{size} because vxresize failed." )
            #vxassist( '-g',@resource[:vxvm_diskgroup], 'growto', '-L', ,@resource[:name], new_size, ) || fail( "Cannot extend to size #{size} because vxassist failed." )

            #if /TYPE=\"(\S+)\"/.match(blkid(path)) {|m| m =~ /ext[34]/}
            #  vxresize('-F','vxfs','-g',@resource[:vxvm_diskgroup], size ) || fail( "Cannot resize file system to size #{size} because vxresize failed." )
            #end

        end
    end

    private

    def vxvol_pattern
        /#{Regexp.quote @resource[:name]}/
    end

    def path
        "/dev/vx/dsk/#{@resource[:vxvm2_diskgroup]}/#{@resource[:name]}"
    end

end
