require 'pathname'

Puppet::Type.newtype(:vxvm2_disk) do
    ensurable

    newparam(:name) do
        isnamevar
        #validate do |value|
        #    unless Pathname.new(value).relative?
        #        raise ArgumentError, "VXVM disk names must be not fully qualified"
        #    end
        #end
    end

		#newparam(:diskname) do
		#	desc "Name given to the device"
		#end

end
