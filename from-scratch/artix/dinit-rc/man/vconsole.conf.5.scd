vconsole.conf(5) "dinit-rc" "vconsole.conf"

# NAME

vconsole.conf - Configuration file for the virtual console.

# SYNOPSIS

/etc/vconsole.conf

# DESCRIPTION

The /etc/vconsole.conf file configures the virtual console, i.e. keyboard
mapping and console font. It is applied at boot by dinit-rc.

The format of vconsole.conf is a newline-separated list of environment-like
shell-compatible variable assignments, ignoring comments and empty lines.

Note that the kernel command line options _vconsole.keymap=_, _vconsole.font=_,
_vconsole.font_map=_, _vconsole.font_unimap=_ may be used to override the
console settings at boot.

Depending on the operating system other configuration files might be checked for
configuration of the virtual console as well, however only as fallback.

# OPTIONS

The following options are understood:

_KEYMAP=_
	Configures the key mapping table for the keyboard. KEYMAP= defaults to "us"
	if not set. Specially, if "@kernel" is specified, no keymap will be loaded,
	i.e. the kernel's default keymap is used.

_FONT=_, _FONT_MAP=_, _FONT_UNIMAP=_
	Configures the console font, the console map and the unicode font map.

# KERNEL COMMAND LINE

A few configuration parameters from vconsole.conf may be overridden on the
kernel command line:

_vconsole.keymap=_
	Overrides _KEYMAP=_.

_vconsole.font=_, _vconsole.font_map=_, _vconsole.font_unimap=_
	Overrides _FONT=_, _FONT_MAP=_, and _FONT_UNIMAP=_.

# EXAMPLE

*Example 1. German keyboard and console*

/etc/vconsole.conf:

```
    KEYMAP=de-latin1
    FONT=eurlatgr
```

# AUTHOR

This manual page was originally written for systemd v255. It has been modified
to suit Artix's current conditions and rewritten in scdoc format for easier
maintenance.
