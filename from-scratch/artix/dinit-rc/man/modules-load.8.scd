modules-load(8) "dinit-rc"

# NAME

modules-load - Configure kernel modules to load at boot

# SYNOPSIS

*modules-load* [*-nv*]

# DESCRIPTION

*modules-load* reads files which contain kernel modules to load during boot from
the list of locations below.

*-n*
	dry-run mode.  This option does everything but actually insert or delete the
	modules.

*-v*
	verbose mode.  Print messages about what the program is doing.

# FILES

Configuration files are read from the following locations:
- /etc/modules-load.d/\*.conf
- /run/modules-load.d/\*.conf
- /usr/lib/modules-load.d/\*.conf

The configuration files should simply contain a list of kernel module names to
load, separated by newlines.  Empty lines and lines whose first non-whitespace
character is # or ; are ignored.

# EXAMPLES
_/etc/modules-load.d/virtio-net.conf_:

```
    # Load virtio-net.ko at boot
    virtio-net
```

# SEE ALSO
*modprobe*(8)

# HISTORY
This program is a replacement for the modules-load utility provided by *systemd*.

# AUTHOR
This manual page was written by Leah Neukirchen (_leah@vuxu.org_) in a
troff-compatible format. It has been rewritten in scdoc format for easier
maintenance.
