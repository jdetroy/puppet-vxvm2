require 'pathname'

Puppet::Type.newtype(:vxvm_disk) do
    ensurable

    newparam(:name) do
        isnamevar
        #validate do |value|
        #    unless Pathname.new(value).relative?
        #        raise ArgumentError, "VXVM disk names must be not fully qualified"
        #    end
        #end
    end
end
