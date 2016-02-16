Puppet::Type.type(:vxvm_diskgroup).provide :vxvm do
    confine :osfamily => 'redhat'
    desc "Manages VXVM diskgroups"

    commands :vxdiskadd => 'vxdg',
             :vxgremove => 'vxgremove',
             :vxdg      => 'vxdg'

    def create
        vxdg('-g',@resource[:name],'adddisk', *@resource.should(:disk))
    end

    def destroy
        vxdg('destroy',@resource[:name])
    end

    def exists?
        vxdg('list',@resource[:name])
    rescue Puppet::ExecutionFailure
        false
    end

    def disk=(new_volumes = [])
        existing_volumes = disk
        extraneous = existing_volumes - new_volumes
        extraneous.each { |volume| reduce_with(volume) }
        missing = new_volumes - existing_volumes
        missing.each { |volume| extend_with(volume) }
    end

    def disk
        lines = pvs('-o', 'pv_name,vg_name', '--separator', ',')
        lines.split(/\n/).grep(/,#{@resource[:name]}$/).map { |s|
            s.split(/,/)[0].strip
        }
    end

    private

    def reduce_with(volume)
        vgreduce(@resource[:name], volume)
    rescue Puppet::ExecutionFailure => detail
        raise Puppet::Error, "Could not remove vxvm_disk #{volume} from VXVM diskgroup '#{@resource[:name]}'; this physical volume may be in use and may require a manual data migration (using pvmove) before it can be removed (#{detail.message})"
    end

    def extend_with(volume)
        vxdg(@resource[:name], volume)
    rescue Puppet::ExecutionFailure => detail
        raise Puppet::Error, "Could not extend volume group '#{@resource[:name]}' with physical volume #{volume} (#{detail.message})"
    end
end
