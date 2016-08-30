Puppet VXVM2 Module
===================

Provides Veritas Volume Management features for Puppet.

History
-------
2016-08-30 : jdetroy

  * Version 0.1 : 



Usage
-----

This module provides three resource types (and associated providers):
`vxvm2_disk`, `vxvm2_diskgroup` and `vxvm2_volume`.

The basic dependency graph needed to define a working Veritas volume
looks something like:

    vxvm2_volume -> vxvm2_diskgroup -> vxvm2_disk(s)

Here's a simple working example:

    vxvm2_disk { "sdb":
        ensure => present
    }
    vxvm2_diskgroup { "my_dg":
        ensure => present,
        vxvm2_disks => ['sdb'],
	vxvm2_disknames => ['vmdk1']
    }
    vxvm2_volume { "my_fs":
        ensure => present,
        vxvm2_diskgroup => "my_dg",
	vxvm2_disk  => ['vmdk1'],
  	type  => concat,
        size => "20G"
    }

=======

Limitations
-----------

### Namespacing

Due to puppet's lack of composite keys for resources, you currently
cannot define two `vxvm2_volume` resources with the same name but
a different `vxvm2_diskgroup`.


Contributors
=======

Jo De Troy <jo.de.troy@gmail.com>
