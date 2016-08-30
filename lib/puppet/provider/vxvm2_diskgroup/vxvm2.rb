Puppet::Type.type(:vxvm2_diskgroup).provide :vxvm2 do
    confine :osfamily => 'redhat'
    desc "Manages VXVM diskgroups"

    commands :vxdg      => 'vxdg', :vxdisk => 'vxdisk'

    def create
				#puts "Inside create function of provider vxvm2_diskgroup"
				#puts "check disks"
				#puts  *@resource.should(:vxvm2_disks)
				di = *@resource.should(:vxvm2_disks)
				#puts  *@resource[:vxvm2_disknames]
				na = *@resource.should(:vxvm2_disknames)
				comb = Hash[na.zip(di)]
				#puts comb
				h=comb.map{ |el| el.join("=") }
				#puts h
			  vxdg('init', @resource[:name], h)
			  #vxdg('init', @resource[:name], *@resource.should(:vxvm2_disks))
        #vxdg('-g',@resource[:name],'adddisk', *@resource.should(:vxvm_disks))
    end

    def destroy
        vxdg('destroy',@resource[:name])
    end

    def exists?
        vxdg('list',@resource[:name])
    rescue Puppet::ExecutionFailure
        false
    end

		# pass 2 arrays to this with disk and diskname 
    def vxvm2_disks=(new_disks = [], new_disknames = [] )
        existing_disks = vxvm2_disks
        existing_disknames = vxvm2_disknames
				new_disknames = *@resource.should(:vxvm2_disknames)
				#puts "existing disks: #{existing_disks} "
				#puts "existing disknames: #{existing_disknames} "
				#puts "new disks: #{new_disks} "
				#puts "new disknames: #{new_disknames} "
        extraneous = existing_disks - new_disks
        extraneous_names = existing_disknames - new_disknames
			  extraneous_hash=Hash[extraneous.zip(extraneous_names)]
        extraneous_hash.each { |volume,name| reduce_with(volume,name) }
        missing = new_disks - existing_disks
        missing_names = new_disknames - existing_disknames
				# missing* are arrays, combine both arrays to single hash
			  missingvolume_hash=Hash[missing.zip(missing_names)]
				#hash_volume = Hash[ missing.collect { |v| [v, new_disks[v] ]} ]
        #missing.each { |volume| extend_with(hash_volume) }
				#puts "missing: #{missing} "
				#puts "missing_names: #{missing_names} "
				#puts missingvolume_hash
        missingvolume_hash.each { |volume,name| extend_with(volume,name) }
				# call extend_with() to use diskname=devname where devname=volume 
				# need hash with device => diskname
    end

    def vxvm2_disks
        lines = vxdisk('list', '-g', @resource[:name])
				# create hash here
        lines.split(/\n/).grep(/#{@resource[:name]}/).map { |s|
        #lines.split(/\n/).grep(/#{@resource[:name]}/).each { |s|
            s.split(/\s+/)[0].strip
            #Hash[ s.collect { |v| [v.split(/\s+/)[0], v.split(/\s+/)[2] ] } ] 
        }
    end

    def vxvm2_disknames
        lines = vxdisk('list', '-g', @resource[:name])
        lines.split(/\n/).grep(/#{@resource[:name]}/).map { |s|
            s.split(/\s+/)[2].strip
        }
    end

    private

    def reduce_with(volume,name)
				# combine volume and volumename, afterwards convert this array into string
			  #newvolume=volume.zip(volumename).map{ |el| el.join("=") }.join(" ")
				 newvolume = String.new()
			   newvolume = volume + '=' + name
         vxdg('-g', @resource[:name], 'rmdisk',  newvolume)
    rescue Puppet::ExecutionFailure => detail
        raise Puppet::Error, "Could not remove vxvm_disk #{volume} from vxvm_diskgroup '#{@resource[:name]}'; this vxvm disk may be in use and may require a manual data migration before it can be removed (#{detail.message})"
    end

    def extend_with(volume,name)
				# combine volume and volumename, afterwards convert this array into string
			  #newvolume=volume.zip(volumename).map{ |el| el.join("=") }.join(" ")
				 newvolume = String.new()
			   newvolume = name + '=' + volume
         vxdg('-g', @resource[:name],'adddisk', newvolume)
    rescue Puppet::ExecutionFailure => detail
        raise Puppet::Error, "Could not extend vxvm_diskgroup  '#{@resource[:name]}' with vxdisk #{volume} (#{detail.message})"
    end
end
