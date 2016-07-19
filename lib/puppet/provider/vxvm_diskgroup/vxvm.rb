Puppet::Type.type(:vxvm_diskgroup).provide :vxvm do
    confine :osfamily => 'redhat'
    desc "Manages VXVM diskgroups"

    commands :vxdg      => 'vxdg', :vxdisk => 'vxdisk'

    def create
        vxdg('-g',@resource[:name],'adddisk', *@resource.should(:vxvm_disks))
    end

    def destroy
        vxdg('destroy',@resource[:name])
    end

    def exists?
        vxdg('list',@resource[:name])
    rescue Puppet::ExecutionFailure
        false
    end

    def vxvm_disks=(new_disks = [])
        existing_disks = vxvm_disks
        extraneous = existing_disks - new_disks
        extraneous.each { |volume| reduce_with(volume) }
        missing = new_disks - existing_disks
        missing.each { |volume| extend_with(volume) }
    end

    def vxvm_disks
        lines = vxdisk('list', '-g', @resource[:name])
        lines.split(/\n/).grep(/#{@resource[:name]}/).map { |s|
            s.split(/ /)[0].strip
        }
    end

    private

    def reduce_with(volume)
        vxdg('-g', @resource[:name], 'rmdisk',  volume)
    rescue Puppet::ExecutionFailure => detail
        raise Puppet::Error, "Could not remove vxvm_disk #{volume} from vxvm_diskgroup '#{@resource[:name]}'; this vxvm disk may be in use and may require a manual data migration before it can be removed (#{detail.message})"
    end

    def extend_with(volume)
        vxdg('-g', @resource[:name],'adddisk', volume)
    rescue Puppet::ExecutionFailure => detail
        raise Puppet::Error, "Could not extend vxvm_diskgroup  '#{@resource[:name]}' with vxdisk #{volume} (#{detail.message})"
    end
end
