# == Define: vxvm::vxvm_volume
#
# This defined type will create a <code>vxvm_volume</code> with the name of the define and ensure a <code></code>,
# <code>vxvm_diskgroup</code>, and <code>vxvm_filesystem</code> resource have been created on the block device supplied.
#
# === Parameters
#
# [*ensure*]
#   Can only be set to <code>cleaned</code>, <code>absent</code> or <code>present</code>. A value of <code>present</code> will
#   ensure that the <code>physical_volume</code>, <code>volume_group</code>, <code>logical_volume</code>, and
#   <code>filesystem</code> resources are present for the volume. A value of <code>cleaned</code> will ensure that all of the
#   resources are <code>absent</code> <b>Warning this has a high potential for unexpected harm</b> use it with caution. A value of
#   <code>absent</code> will remove only the <code>logical_volume</code> resource from the system.
# [*pv*]
#   The block device to ensure a <code>physical_volume</code> has been created on.
# [*vg*]
#   The <code>volume_group</code> to ensure is created on the <code>physical_volume</code> provided by the <code>pv</code>
#   parameter.
# [*fstype*]
#   The type of <code>filesystem</code> to create on the logical volume.
# [*size*]
#   The size the <code>logical_voluem</code> should be.
#
# === Examples
#
# Provide some examples on how to use this type:
#
#   lvm::volume { 'lv_example0':
#     vg     => 'vg_example0',
#     pv     => '/dev/sdd1',
#     fstype => 'ext4',
#     size => '100GB',
#   }
#
# === Copyright
#
# See README.markdown for the module author information.
#
# === License
#
# This file is part of the puppetlabs/lvm puppet module.
#
# puppetlabs/lvm is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by the
# Free Software Foundation, version 2 of the License.
#
# puppetlabs/lvm is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
# Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with puppetlabs/lvm. If not, see http://www.gnu.org/licenses/.
#
define vxvm::vxvm_volume (
  $ensure,
  $disk,
  $diskgroup,
  $fstype = vxfs,
  $size   = undef
) {
  case $ensure {
    #
    # Clean up the whole chain.
    #
    cleaned: {
      # This may only need to exist once
      if ! defined(Vxvm_volume[$pv]) {
        vxvm_volume { $disk: ensure => present }
      }
      # This may only need to exist once
      if ! defined(Vxvm_diskgroup[$diskgroup]) {
        vxvm_diskgroup { $diskgroup:
          ensure           => present,
          vxvm_disk => $disk,
          before           => Vxvm_disk[$disk]
        }

        vxvm_volume { $name:
          ensure       => present,
          vxvm_diskgroup => $diskgroup,
          size         => $size,
          before       => Vxvm_diskgroup[$diskgroup]
        }
      }
    }
    #
    # Just clean up the logical volume
    #
    absent: {
      vxvm_volume { $name:
        ensure       => absent,
        vxvm_diskgroup => $diskgroup,
        size         => $size
      }
    }
    #
    # Create the whole chain.
    #
    present: {
      # This may only need to exist once
      if ! defined(Vxvm_disk[$disk]) {
        vxvm_disk { $disk: ensure => present }
      }

      # This may only need to exist once
      if ! defined(Vxvm_diskgroup[$diskgroup]) {
        vxxvm_diskgroup { $diskgroup:
          ensure           => present,
          vxvm_disk => $disk,
          require          => Vxvm_disk[$disk]
        }
      }

      vxvm_volume { $name:
        ensure       => present,
        vxvm_diskgroup => $diskgroup,
        size         => $size,
        require      => Vxvm_diskgroup[$diskgroup]
      }

      if $fstype != undef {
        filesystem { "/dev/vx/dsk/${diskgroup}/${name}":
          ensure  => present,
          fs_type => 'vxfs',
          require => Vxvm_volume[$name]
        }
      }

    }
    default: {
      fail ( 'puppet-vxvm::vxvm_volume: ensure parameter can only be set to cleaned, absent or present' )
    }
  }
}
