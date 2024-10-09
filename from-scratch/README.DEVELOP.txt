/* $Id$ */
dinit Version 0.19.0
Using SlackBuild from symlink to build and run test.
This SlackBuild for now dont build dinit as system init but 0xBOBF not ran tests and missing 40-dinit probably because 0.17.0 version didnt have it.

TODO-DEVELOP
1.Edit SlackBuild to build dinit systeminit as 0xBOBF/dinit-slackware suggest. Its more KISS and easy everything to be in etc/dinit.d/* than /usr/lib/ etc as chimera suggest.
2. create services for remaining Slackware scripts.
3. check if all rc.S funcitons are supported, speciall:
# Mount /proc if it is not already mounted:
if [ ! -d /proc/sys -a -z "$container" ]; then
  /sbin/mount -v proc /proc -t proc 2> /dev/null
fi







############-INFOS-################
From Artix https://gitea.artixlinux.org/artix/dinit-rc:
Artix's dinit stage 1.

Adapted from s6-scripts, runit-rc, Chimera Linux, and dinit's own
configuration.

Since 0.3.0, to manage dependencies better, most services have been
reconfigured around new service targets lifted from Chimera Linux to
replace the existing mess like "setup", "loginready", or "misc", which
by now I can't even make sense of.

This is the list of targets, lifted directly from dinit-chimera's
README, some differences may apply with our current implementation but
the gist should remain the same:

* `early-prepare.target` - early pseudo-filesystems have been mounted
* `early-modules.target` - kernel modules from `/etc/modules` have been loaded
* `early-devices.target` - device events have been processed
  * This means `/dev` is fully populated with quirks applied and so on.
* `early-keyboard.target` - console keymap has been set
  * This has no effect when `setupcon` from `console-setup` is not available.
* `early-fs-pre.target` - filesystems are ready to be checked and mounted
  * This means encrypted disks, RAID, LVM and so on is up.
* `early-root-rw.target` - root filesystem has been re-mounted read/write.
  * That is, unless `fstab` explicitly specifies it should be read-only.
* `early-fs-fstab.target` - non-network filesystems in `fstab` have been mounted
* `early-fs-local.target` - non-network filesystems have finished mounting
  * This includes the above plus non-`fstab` filesystems such as ZFS.
* `early-console.target` - follow-up to `early-keyboard.target` (console font, etc.)
  * This has no effect when `setupcon` from `console-setup` is not available.
* `pre-local.target` - most important early oneshots have run.
  * Temporary/volatile files/dirs managed with `tmpfiles.d` are not guaranteed yet.
  * Most services should prefer `local.target` as their sentinel.
  * Typically only for services that should guarantee being up before `rc.local` is run.
  * All targets above this one are guaranteed to have been reached.
* `local.target` - `/etc/rc.local` has run and temp/volatile files/dirs are created
  * Implies `pre-local.target`.
  * Most regular services should depend on at least this one (or `pre-local.target`).
* `pre-network.target` - networking daemons may start.
  * This means things such as firewall have been brought up.
* `network.target` - networking daemons have started.
  * Networking daemons should use this as `before`.
  * Things depending on network being up should use this as a dependency.
* `login.target` - the system is ready to run gettys, launch display manager, etc.
  * Typically to be used as a `before` sentinel for things that must be up before login.
* `time-sync.target` - system date/time should be set by now.
  * Things such as NTP implementations should wait and use this as `before`.
  * Things requiring date/time to be set should use this as a dependency.
  * This may take a while, so pre-login services depending on this may stall the boot.


In a Chimera system we found services:
Dependencies in directory: /usr/lib/dinit.d

Processing: bash.sh
Processing: boot
│   ├── depends-on: = system (in /usr/lib/dinit.d/boot)
│   ├── waits-for: .d = /etc/dinit.d/boot.d (in /usr/lib/dinit.d/boot)
Processing: early-binfmt
│   ├── depends-on: = early-fs-local.target (in /usr/lib/dinit.d/early-binfmt)
Processing: early-bless-boot
│   ├── depends-on: = pre-local.target (in /usr/lib/dinit.d/early-bless-boot)
Processing: early-cgroups
│   ├── depends-on: = early-env (in /usr/lib/dinit.d/early-cgroups)
│   ├── depends-on: = early-pseudofs (in /usr/lib/dinit.d/early-cgroups)
Processing: early-console.target
│   ├── depends-on: = early-devices.target (in /usr/lib/dinit.d/early-console.target)
│   ├── depends-on: = early-fs-local.target (in /usr/lib/dinit.d/early-console.target)
│   ├── depends-on: = early-keyboard.target (in /usr/lib/dinit.d/early-console.target)
Processing: early-cryptdisks
│   ├── depends-on: = early-devices.target (in /usr/lib/dinit.d/early-cryptdisks)
│   ├── depends-on: = early-cryptdisks-early (in /usr/lib/dinit.d/early-cryptdisks)
│   ├── depends-on: = early-dmraid (in /usr/lib/dinit.d/early-cryptdisks)
│   ├── depends-on: = early-lvm (in /usr/lib/dinit.d/early-cryptdisks)
│   ├── depends-ms: = early-root-fsck (in /usr/lib/dinit.d/early-cryptdisks)
│   ├── waits-for: = early-mdadm (in /usr/lib/dinit.d/early-cryptdisks)
Processing: early-cryptdisks-early
│   ├── depends-on: = early-devices.target (in /usr/lib/dinit.d/early-cryptdisks-early)
│   ├── depends-on: = early-keyboard.target (in /usr/lib/dinit.d/early-cryptdisks-early)
│   ├── depends-ms: = early-root-fsck (in /usr/lib/dinit.d/early-cryptdisks-early)
│   ├── waits-for: = early-dmraid (in /usr/lib/dinit.d/early-cryptdisks-early)
│   ├── waits-for: = early-mdadm (in /usr/lib/dinit.d/early-cryptdisks-early)
Processing: early-dev-settle
│   ├── depends-on: = early-devd (in /usr/lib/dinit.d/early-dev-settle)
│   ├── depends-on: = early-dev-trigger (in /usr/lib/dinit.d/early-dev-settle)
Processing: early-dev-trigger
│   ├── depends-on: = early-devd (in /usr/lib/dinit.d/early-dev-trigger)
Processing: early-devd
│   ├── depends-on: = early-prepare.target (in /usr/lib/dinit.d/early-devd)
│   ├── depends-on: = early-modules-early (in /usr/lib/dinit.d/early-devd)
│   ├── depends-on: = early-tmpfiles-dev (in /usr/lib/dinit.d/early-devd)
Processing: early-devices.target
│   ├── depends-on: = early-devd (in /usr/lib/dinit.d/early-devices.target)
│   ├── depends-ms: = early-dev-settle (in /usr/lib/dinit.d/early-devices.target)
Processing: early-dmraid
│   ├── depends-on: = early-devices.target (in /usr/lib/dinit.d/early-dmraid)
│   ├── depends-ms: = early-root-fsck (in /usr/lib/dinit.d/early-dmraid)
Processing: early-env
Processing: early-fs-btrfs
│   ├── depends-on: = early-fs-pre.target (in /usr/lib/dinit.d/early-fs-btrfs)
Processing: early-fs-fsck
│   ├── depends-on: = early-fs-pre.target (in /usr/lib/dinit.d/early-fs-fsck)
│   ├── waits-for: = early-fs-btrfs (in /usr/lib/dinit.d/early-fs-fsck)
Processing: early-fs-fstab.target
│   ├── depends-on: = early-fs-pre.target (in /usr/lib/dinit.d/early-fs-fstab.target)
│   ├── waits-for: = early-fs-zfs (in /usr/lib/dinit.d/early-fs-fstab.target)
│   ├── waits-for: = early-fs-btrfs (in /usr/lib/dinit.d/early-fs-fstab.target)
│   ├── depends-ms: = early-fs-fsck (in /usr/lib/dinit.d/early-fs-fstab.target)
│   ├── waits-for: = early-root-rw.target (in /usr/lib/dinit.d/early-fs-fstab.target)
Processing: early-fs-local.target
│   ├── depends-on: = early-fs-pre.target (in /usr/lib/dinit.d/early-fs-local.target)
│   ├── waits-for: = early-fs-btrfs (in /usr/lib/dinit.d/early-fs-local.target)
│   ├── waits-for: = early-fs-zfs (in /usr/lib/dinit.d/early-fs-local.target)
│   ├── waits-for: = early-root-rw.target (in /usr/lib/dinit.d/early-fs-local.target)
│   ├── waits-for: = early-fs-fstab.target (in /usr/lib/dinit.d/early-fs-local.target)
Processing: early-fs-pre.target
│   ├── depends-on: = early-devices.target (in /usr/lib/dinit.d/early-fs-pre.target)
│   ├── depends-on: = early-cryptdisks (in /usr/lib/dinit.d/early-fs-pre.target)
│   ├── waits-for: = early-dmraid (in /usr/lib/dinit.d/early-fs-pre.target)
│   ├── waits-for: = early-mdadm (in /usr/lib/dinit.d/early-fs-pre.target)
Processing: early-fs-zfs
│   ├── depends-on: = early-fs-pre.target (in /usr/lib/dinit.d/early-fs-zfs)
Processing: early-hostname
│   ├── depends-on: = early-devices.target (in /usr/lib/dinit.d/early-hostname)
Processing: early-hwclock
│   ├── depends-on: = early-devd (in /usr/lib/dinit.d/early-hwclock)
│   ├── depends-on: = early-prepare.target (in /usr/lib/dinit.d/early-hwclock)
│   ├── depends-on: = early-root-rw.target (in /usr/lib/dinit.d/early-hwclock)
Processing: early-kdump
│   ├── depends-on: = early-devices.target (in /usr/lib/dinit.d/early-kdump)
│   ├── depends-on: = early-fs-local.target (in /usr/lib/dinit.d/early-kdump)
Processing: early-keyboard.target
│   ├── depends-on: = early-devices.target (in /usr/lib/dinit.d/early-keyboard.target)
Processing: early-lvm
│   ├── depends-on: = early-devices.target (in /usr/lib/dinit.d/early-lvm)
│   ├── depends-on: = early-cryptdisks-early (in /usr/lib/dinit.d/early-lvm)
│   ├── depends-ms: = early-root-fsck (in /usr/lib/dinit.d/early-lvm)
│   ├── waits-for: = early-dmraid (in /usr/lib/dinit.d/early-lvm)
│   ├── waits-for: = early-mdadm (in /usr/lib/dinit.d/early-lvm)
Processing: early-machine-id
│   ├── depends-on: = early-rng (in /usr/lib/dinit.d/early-machine-id)
│   ├── depends-on: = early-swclock (in /usr/lib/dinit.d/early-machine-id)
│   ├── waits-for: = early-root-rw.target (in /usr/lib/dinit.d/early-machine-id)
Processing: early-mdadm
│   ├── depends-on: = early-devices.target (in /usr/lib/dinit.d/early-mdadm)
│   ├── depends-ms: = early-root-fsck (in /usr/lib/dinit.d/early-mdadm)
Processing: early-modules
│   ├── depends-ms: = early-modules-early (in /usr/lib/dinit.d/early-modules)
Processing: early-modules-early
│   ├── depends-on: = early-prepare.target (in /usr/lib/dinit.d/early-modules-early)
Processing: early-modules.target
│   ├── depends-ms: = early-modules (in /usr/lib/dinit.d/early-modules.target)
Processing: early-net-lo
│   ├── depends-on: = early-devices.target (in /usr/lib/dinit.d/early-net-lo)
Processing: early-prepare.target
│   ├── depends-on: = early-env (in /usr/lib/dinit.d/early-prepare.target)
│   ├── depends-on: = early-pseudofs (in /usr/lib/dinit.d/early-prepare.target)
│   ├── depends-on: = early-tmpfs (in /usr/lib/dinit.d/early-prepare.target)
│   ├── depends-on: = early-cgroups (in /usr/lib/dinit.d/early-prepare.target)
Processing: early-pseudofs
│   ├── depends-on: = early-env (in /usr/lib/dinit.d/early-pseudofs)
│   ├── depends-on: = early-root-remount (in /usr/lib/dinit.d/early-pseudofs)
Processing: early-rng
│   ├── depends-on: = early-devices.target (in /usr/lib/dinit.d/early-rng)
│   ├── waits-for: = early-modules.target (in /usr/lib/dinit.d/early-rng)
│   ├── waits-for: = early-root-rw.target (in /usr/lib/dinit.d/early-rng)
Processing: early-root-fsck
│   ├── depends-on: = early-prepare.target (in /usr/lib/dinit.d/early-root-fsck)
│   ├── depends-ms: = early-devd (in /usr/lib/dinit.d/early-root-fsck)
│   ├── waits-for: = early-dev-trigger (in /usr/lib/dinit.d/early-root-fsck)
Processing: early-root-remount
│   ├── depends-on: = early-env (in /usr/lib/dinit.d/early-root-remount)
Processing: early-root-rw.target
│   ├── depends-ms: = early-root-fsck (in /usr/lib/dinit.d/early-root-rw.target)
Processing: early-swap
│   ├── depends-on: = early-fs-local.target (in /usr/lib/dinit.d/early-swap)
Processing: early-swclock
│   ├── depends-on: = early-devd (in /usr/lib/dinit.d/early-swclock)
│   ├── depends-on: = early-prepare.target (in /usr/lib/dinit.d/early-swclock)
│   ├── depends-on: = early-root-rw.target (in /usr/lib/dinit.d/early-swclock)
│   ├── waits-for: = early-hwclock (in /usr/lib/dinit.d/early-swclock)
Processing: early-sysctl
│   ├── depends-on: = early-devices.target (in /usr/lib/dinit.d/early-sysctl)
│   ├── depends-on: = early-fs-local.target (in /usr/lib/dinit.d/early-sysctl)
Processing: early-tmpfiles
│   ├── depends-on: = early-fs-local.target (in /usr/lib/dinit.d/early-tmpfiles)
│   ├── depends-on: = pre-local.target (in /usr/lib/dinit.d/early-tmpfiles)
Processing: early-tmpfiles-dev
│   ├── depends-on: = early-modules-early (in /usr/lib/dinit.d/early-tmpfiles-dev)
│   ├── depends-on: = early-tmpfs (in /usr/lib/dinit.d/early-tmpfiles-dev)
│   ├── depends-on: = early-root-remount (in /usr/lib/dinit.d/early-tmpfiles-dev)
Processing: early-tmpfs
│   ├── depends-on: = early-env (in /usr/lib/dinit.d/early-tmpfs)
│   ├── depends-on: = early-root-remount (in /usr/lib/dinit.d/early-tmpfs)
Processing: local.target
│   ├── depends-on: = pre-local.target (in /usr/lib/dinit.d/local.target)
│   ├── depends-on: = early-tmpfiles (in /usr/lib/dinit.d/local.target)
│   ├── waits-for: = early-bless-boot (in /usr/lib/dinit.d/local.target)
Processing: login.target
│   ├── depends-on: = local.target (in /usr/lib/dinit.d/login.target)
Processing: network.target
│   ├── depends-on: = pre-network.target (in /usr/lib/dinit.d/network.target)
Processing: pre-local.target
│   ├── depends-on: = early-fs-local.target (in /usr/lib/dinit.d/pre-local.target)
│   ├── depends-on: = early-console.target (in /usr/lib/dinit.d/pre-local.target)
│   ├── depends-on: = early-net-lo (in /usr/lib/dinit.d/pre-local.target)
│   ├── depends-on: = early-hostname (in /usr/lib/dinit.d/pre-local.target)
│   ├── waits-for: = early-swap (in /usr/lib/dinit.d/pre-local.target)
│   ├── waits-for: = early-rng (in /usr/lib/dinit.d/pre-local.target)
│   ├── waits-for: = early-machine-id (in /usr/lib/dinit.d/pre-local.target)
│   ├── waits-for: = early-sysctl (in /usr/lib/dinit.d/pre-local.target)
│   ├── waits-for: = early-binfmt (in /usr/lib/dinit.d/pre-local.target)
│   ├── waits-for: = early-kdump (in /usr/lib/dinit.d/pre-local.target)
Processing: pre-network.target
│   ├── depends-on: = local.target (in /usr/lib/dinit.d/pre-network.target)
Processing: recovery
Processing: single
Processing: system
│   ├── depends-on: = login.target (in /usr/lib/dinit.d/system)
│   ├── depends-on: = network.target (in /usr/lib/dinit.d/system)
│   ├── waits-for: .d = /usr/lib/dinit.d/boot.d (in /usr/lib/dinit.d/system)
Processing: time-sync.target
│   ├── depends-on: = local.target (in /usr/lib/dinit.d/time-sync.target)
└── (End of tree)


Dependencies in directory: /etc/dinit.d

Processing: agetty
│   ├── depends-on: = login.target (in /etc/dinit.d/agetty)
Processing: agetty-console
│   ├── depends-on: = login.target (in /etc/dinit.d/agetty-console)
Processing: agetty-hvc0
│   ├── depends-on: = login.target (in /etc/dinit.d/agetty-hvc0)
Processing: agetty-hvc1
│   ├── depends-on: = login.target (in /etc/dinit.d/agetty-hvc1)
Processing: agetty-hvsi0
│   ├── depends-on: = login.target (in /etc/dinit.d/agetty-hvsi0)
Processing: agetty-hvsi1
│   ├── depends-on: = login.target (in /etc/dinit.d/agetty-hvsi1)
Processing: agetty-tty1
│   ├── depends-on: = login.target (in /etc/dinit.d/agetty-tty1)
Processing: agetty-tty2
│   ├── depends-on: = login.target (in /etc/dinit.d/agetty-tty2)
Processing: agetty-tty3
│   ├── depends-on: = login.target (in /etc/dinit.d/agetty-tty3)
Processing: agetty-tty4
│   ├── depends-on: = login.target (in /etc/dinit.d/agetty-tty4)
Processing: agetty-tty5
│   ├── depends-on: = login.target (in /etc/dinit.d/agetty-tty5)
Processing: agetty-tty6
│   ├── depends-on: = login.target (in /etc/dinit.d/agetty-tty6)
Processing: agetty-tty7
│   ├── depends-on: = login.target (in /etc/dinit.d/agetty-tty7)
Processing: agetty-tty8
│   ├── depends-on: = login.target (in /etc/dinit.d/agetty-tty8)
Processing: agetty-ttyAMA0
│   ├── depends-on: = login.target (in /etc/dinit.d/agetty-ttyAMA0)
Processing: agetty-ttyAMA1
│   ├── depends-on: = login.target (in /etc/dinit.d/agetty-ttyAMA1)
Processing: agetty-ttyS0
│   ├── depends-on: = login.target (in /etc/dinit.d/agetty-ttyS0)
Processing: agetty-ttyS1
│   ├── depends-on: = login.target (in /etc/dinit.d/agetty-ttyS1)
Processing: agetty-ttyS2
│   ├── depends-on: = login.target (in /etc/dinit.d/agetty-ttyS2)
Processing: agetty-ttyS3
│   ├── depends-on: = login.target (in /etc/dinit.d/agetty-ttyS3)
Processing: agetty-ttyS4
│   ├── depends-on: = login.target (in /etc/dinit.d/agetty-ttyS4)
Processing: agetty-ttySIF0
│   ├── depends-on: = login.target (in /etc/dinit.d/agetty-ttySIF0)
Processing: agetty-ttySIF1
│   ├── depends-on: = login.target (in /etc/dinit.d/agetty-ttySIF1)
Processing: agetty-ttyUSB0
│   ├── depends-on: = login.target (in /etc/dinit.d/agetty-ttyUSB0)
Processing: agetty-ttyUSB1
│   ├── depends-on: = login.target (in /etc/dinit.d/agetty-ttyUSB1)
Processing: agetty-ttymxc0
│   ├── depends-on: = login.target (in /etc/dinit.d/agetty-ttymxc0)
Processing: agetty-ttymxc1
│   ├── depends-on: = login.target (in /etc/dinit.d/agetty-ttymxc1)
Processing: agetty-ttymxc2
│   ├── depends-on: = login.target (in /etc/dinit.d/agetty-ttymxc2)
Processing: agetty-ttymxc3
│   ├── depends-on: = login.target (in /etc/dinit.d/agetty-ttymxc3)
Processing: bash.sh
Processing: bluetoothd
│   ├── before: = login.target (in /etc/dinit.d/bluetoothd)
│   ├── depends-on: = local.target (in /etc/dinit.d/bluetoothd)
│   ├── depends-on: = dbus (in /etc/dinit.d/bluetoothd)
Processing: chrony
│   ├── depends-on: = chronyd (in /etc/dinit.d/chrony)
│   ├── before: = time-sync.target (in /etc/dinit.d/chrony)
Processing: chronyd
│   ├── depends-on: = network.target (in /etc/dinit.d/chronyd)
│   ├── depends-on: = local.target (in /etc/dinit.d/chronyd)
Processing: colord
│   ├── depends-on: = login.target (in /etc/dinit.d/colord)
│   ├── depends-on: = dbus (in /etc/dinit.d/colord)
Processing: dbus
│   ├── before: = login.target (in /etc/dinit.d/dbus)
│   ├── depends-on: = local.target (in /etc/dinit.d/dbus)
Processing: dhcpcd
│   ├── before: = network.target (in /etc/dinit.d/dhcpcd)
│   ├── depends-on: = pre-network.target (in /etc/dinit.d/dhcpcd)
Processing: dmeventd
│   ├── before: = pre-local.target (in /etc/dinit.d/dmeventd)
│   ├── depends-on: = early-fs-pre.target (in /etc/dinit.d/dmeventd)
Processing: ead
│   ├── before: = network.target (in /etc/dinit.d/ead)
│   ├── depends-on: = pre-network.target (in /etc/dinit.d/ead)
│   ├── depends-on: = dbus (in /etc/dinit.d/ead)
Processing: elogind
│   ├── depends-ms: = polkitd (in /etc/dinit.d/elogind)
│   ├── depends-on: = dbus (in /etc/dinit.d/elogind)
│   ├── depends-on: = local.target (in /etc/dinit.d/elogind)
│   ├── before: = login.target (in /etc/dinit.d/elogind)
Processing: gdm
│   ├── depends-on: = login.target (in /etc/dinit.d/gdm)
│   ├── depends-on: = dbus (in /etc/dinit.d/gdm)
│   ├── depends-ms: = elogind (in /etc/dinit.d/gdm)
│   ├── depends-ms: = openrc-settingsd (in /etc/dinit.d/gdm)
Processing: iwd
│   ├── before: = network.target (in /etc/dinit.d/iwd)
│   ├── depends-on: = pre-network.target (in /etc/dinit.d/iwd)
│   ├── depends-on: = dbus (in /etc/dinit.d/iwd)
Processing: lvmetad
│   ├── before: = pre-local.target (in /etc/dinit.d/lvmetad)
│   ├── depends-on: = early-fs-pre.target (in /etc/dinit.d/lvmetad)
Processing: networkmanager
│   ├── before: = network.target (in /etc/dinit.d/networkmanager)
│   ├── depends-on: = dbus (in /etc/dinit.d/networkmanager)
│   ├── depends-on: = pre-network.target (in /etc/dinit.d/networkmanager)
Processing: openrc-settingsd
│   ├── before: = login.target (in /etc/dinit.d/openrc-settingsd)
│   ├── depends-on: = local.target (in /etc/dinit.d/openrc-settingsd)
│   ├── depends-on: = dbus (in /etc/dinit.d/openrc-settingsd)
│   ├── depends-ms: = polkitd (in /etc/dinit.d/openrc-settingsd)
Processing: pcscd
│   ├── depends-on: = local.target (in /etc/dinit.d/pcscd)
Processing: polkitd
│   ├── before: = login.target (in /etc/dinit.d/polkitd)
│   ├── depends-on: = local.target (in /etc/dinit.d/polkitd)
│   ├── depends-on: = dbus (in /etc/dinit.d/polkitd)
Processing: power-profiles-daemon
│   ├── before: = login.target (in /etc/dinit.d/power-profiles-daemon)
│   ├── depends-on: = local.target (in /etc/dinit.d/power-profiles-daemon)
│   ├── depends-on: = dbus (in /etc/dinit.d/power-profiles-daemon)
│   ├── waits-for: = polkitd (in /etc/dinit.d/power-profiles-daemon)
Processing: rtkit
│   ├── before: = login.target (in /etc/dinit.d/rtkit)
│   ├── depends-on: = dbus (in /etc/dinit.d/rtkit)
│   ├── waits-for: = polkitd (in /etc/dinit.d/rtkit)
Processing: saned
│   ├── depends-on: = local.target (in /etc/dinit.d/saned)
Processing: ssh-keygen
│   ├── depends-on: = local.target (in /etc/dinit.d/ssh-keygen)
Processing: sshd
│   ├── depends-on: = ssh-keygen (in /etc/dinit.d/sshd)
│   ├── depends-on: = network.target (in /etc/dinit.d/sshd)
Processing: syslog-ng
│   ├── before: = local.target (in /etc/dinit.d/syslog-ng)
│   ├── depends-on: = pre-local.target (in /etc/dinit.d/syslog-ng)
Processing: tmpfiles-clean
│   ├── depends-on: = local.target (in /etc/dinit.d/tmpfiles-clean)
│   ├── depends-on: = time-sync.target (in /etc/dinit.d/tmpfiles-clean)
Processing: turnstiled
│   ├── before: = login.target (in /etc/dinit.d/turnstiled)
│   ├── depends-on: = local.target (in /etc/dinit.d/turnstiled)
Processing: udevd
│   ├── before: = pre-local.target (in /etc/dinit.d/udevd)
│   ├── depends-on: = early-devices.target (in /etc/dinit.d/udevd)
Processing: uuidd
│   ├── before: = pre-local.target (in /etc/dinit.d/uuidd)
│   ├── depends-on: = early-devices.target (in /etc/dinit.d/uuidd)
Processing: zed
│   ├── depends-on: = early-fs-local.target (in /etc/dinit.d/zed)
│   ├── before: = pre-local.target (in /etc/dinit.d/zed)
└── (End of tree)
