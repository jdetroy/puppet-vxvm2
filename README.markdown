Puppet VXVM2 Module
===================

Provides Veritas Volume Management features for Puppet.

History
-------
2016-08-30 : jdetroy

  * Version 0.1 : initial release

  * Version 0.2: added vxvm2_filesystem type/provider



Usage
-----

This module provides four resource types (and associated providers):
`vxvm2_disk`, `vxvm2_diskgroup`, `vxvm2_volume` and `vxvm2_filesystem`.

The basic dependency graph needed to define a working Veritas volume
looks something like:

    vxvm2_volume -> vxvm2_diskgroup -> vxvm2_disk(s) -> vxvm2_filesystem

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

   vxvm2_filesystem { "my_dg/my_fs":
	ensure => present,
	options => 'bsize=8192,largefiles'
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
