require 'pathname'

Puppet::Type.newtype(:vxvmfs) do

    desc "The VXVM filesystem "

    ensurable

    newparam(:name) do
        isnamevar
        validate do |value|
            unless Pathname.new(value).absolute?
                raise ArgumentError, "Filesystem names must be fully qualified"
            end
        end
    end

    newparam(:options) do
        desc "Params for the mkfs.vxfs command. eg. -l internal,agcount=x"
    end

end
