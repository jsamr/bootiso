[![License: GPLv3](https://badgen.net/badge/license/GPLv3/blue)](https://www.gnu.org/licenses/gpl-3.0.html)
[![Version](https://badgen.net/github/tag/jsamr/bootiso?label=version)](https://github.com/jsamr/bootiso/releases/latest)
[![Codacy grade](https://img.shields.io/codacy/grade/9f441cf6a1d6475484a9bb3ec2ed9713.svg)](https://app.codacy.com/app/jsamr/bootiso?utm_source=github.com&utm_medium=referral&utm_content=jsamr/bootiso&utm_campaign=badger)

**Create a USB bootable device from an image file easily and securely.**

Because of its reliance on GNU and POSIX tools, **bootiso** primarly targets GNU/Linux systems.

## Install

### Package managers

This list might be out of date (please report). Check [repology.org](https://repology.org/project/bootiso/versions).

| System family    | URL                                                                     |
| :--------------- | ----------------------------------------------------------------------- |
| Arch Linux (AUR) | https://aur.archlinux.org/packages/bootiso/                             |
| Void Linux       | https://github.com/void-linux/void-packages/tree/master/srcpkgs/bootiso |
| openSUSE (OBS)   | https://build.opensuse.org/package/show/utilities/bootiso               |

### Manual install

Check [Install Instructions](install.md) document. Please also read the [distro tweaks](#distro-tweaks) section.

## Reference Manual

The official manual is available at [jsamr.github.io/bootiso](https://jsamr.github.io/bootiso/).
The reference should also be available as a man page via `man bootiso`.
If you are in a hurry, jump to the [EXAMPLES](https://jsamr.github.io/bootiso/#EXAMPLES) section.

|                             Highlights                              |
| :-----------------------------------------------------------------: |
|        [SYNOPSIS](https://jsamr.github.io/bootiso/#SYNOPSIS)        |
|     [DESCRIPTION](https://jsamr.github.io/bootiso/#DESCRIPTION)     |
|   [INSTALL MODES](https://jsamr.github.io/bootiso/#INSTALL_MODES)   |
|      [GUARDRAILS](https://jsamr.github.io/bootiso/#GUARDRAILS)      |
|     [EXIT STATUS](https://jsamr.github.io/bootiso/#EXIT_STATUS)     |
|     [ENVIRONMENT](https://jsamr.github.io/bootiso/#ENVIRONMENT)     |
|        [EXAMPLES](https://jsamr.github.io/bootiso/#EXAMPLES)        |
| [TROUBLESHOOTING](https://jsamr.github.io/bootiso/#TROUBLESHOOTING) |

<a name="action"></a>

## See it in action

### Probing

`--probe` (shorten `-p`) gives you details about ISO boot capabilities and list available USB drives.

<a href="https://asciinema.org/a/eWbZtAXVKIzVYEMMCt5kmT5cq?speed=2&autoplay=1&size=medium&rows=20">
<img src="https://asciinema.org/a/eWbZtAXVKIzVYEMMCt5kmT5cq.svg" height="350">
</a>

### Using `--assume-yes` + `--autoselect`

`--assume-yes` (shorten `-y`) bypass prompting the user for overwritting USB device, and `--autoselect` (shorten `-a`) allow automatic selection of USB device when exactly one device is connected in combination with `--assume-yes`.

<a href="https://asciinema.org/a/Jwy5DTgcEJSCKJlY1SgsfiWc1?speed=3&autoplay=1&size=medium&rows=20" target="_blank"><img src="https://asciinema.org/a/Jwy5DTgcEJSCKJlY1SgsfiWc1.svg" height="350"/></a>

### No-USB device failure

In the below example, the selected device with `--device` (shorten `-d`) flag is not connected through USB and `bootiso` fails.

<a href="https://asciinema.org/a/EUg7jUwdwM4KdABClIK1NjGlY?speed=3&autoplay=1&size=medium&rows=20" target="_blank"><img src="https://asciinema.org/a/EUg7jUwdwM4KdABClIK1NjGlY.svg" height="350"/></a>

<a name="distro-tweaks"></a>

## Distros tweaks

- On Fedora, set `BOOTISO_SYSLINUX_LIB_ROOT` environment to `/usr/share/syslinux`.
- Take a look at the [by-distribution dependency table](install.md#deps) to make sure you have all required dependencies installed.

## Contributing

Read the [Code Style and Conventions](style.md) document.
