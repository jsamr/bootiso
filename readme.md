[![License: GPLv3](https://badgen.net/badge/license/GPLv3/blue)](https://www.gnu.org/licenses/gpl-3.0.html)
[![Version](https://badgen.net/github/tag/jsamr/bootiso?label=version)]()
[![Codacy grade](https://img.shields.io/codacy/grade/9f441cf6a1d6475484a9bb3ec2ed9713.svg)](https://app.codacy.com/app/jsamr/bootiso?utm_source=github.com&utm_medium=referral&utm_content=jsamr/bootiso&utm_campaign=badger)

**Create a USB bootable device from an image file easily and securely.**

Because of its reliance on GNU and POSIX tools, **bootiso** primarly targets GNU/Linux systems.

## Install

### Package managers

| System family    | URL                                            |
|:-----------------|------------------------------------------------|
| Arch Linux (AUR) | https://aur.archlinux.org/packages/bootiso/    |

### Manual install

Check [install.md](install.md) for detailed instructions.

## Reference Manual

The official manual is available at [jsamr.github.io/bootiso](https://jsamr.github.io/bootiso/).
The reference should also be available as a man page via `man bootiso`.
If you are in a hury, jump to the [EXAMPLES](https://jsamr.github.io/bootiso/#EXAMPLES) section.

| Highlights                                                          |
|:-------------------------------------------------------------------:|
| [SYNOPSIS](https://jsamr.github.io/bootiso/#SYNOPSIS)               |
| [DESCRIPTION](https://jsamr.github.io/bootiso/#DESCRIPTION)         |
| [INSTALL MODES](https://jsamr.github.io/bootiso/#INSTALL_MODES)     |
| [GUARDRAILS](https://jsamr.github.io/bootiso/#GUARDRAILS)           |
| [EXIT STATUS](https://jsamr.github.io/bootiso/#EXIT_STATUS)         |
| [ENVIRONMENT](https://jsamr.github.io/bootiso/#ENVIRONMENT)         |
| [EXAMPLES](https://jsamr.github.io/bootiso/#EXAMPLES)               |
| [TROUBLESHOOTING](https://jsamr.github.io/bootiso/#TROUBLESHOOTING) |

<a name="action"></a>

## See it in action

### Probing

`--probe` (shorten `-p`) gives you details about ISO boot capabilities and list available USB drives.

<a href="https://webmshare.com/play/JZrVW">
<img src="images/bootiso-p.png" width="500">
</a>

### Using `--assume-yes` + `--autoselect`

`--assume-yes` (shorten `-y`) bypass prompting the user for overwritting USB device, and `--autoselect` (shorten `-a`) allow automatic selection of USB device when exactly one device is connected in combination with `--assume-yes`.

<a href="https://webmshare.com/play/mw7Q4">
<img src="images/bootiso-ay.png" width="500">
</a>

### No-USB device failure

In the bellow example, the selected device with `--device` (shorten `-d`) flag is not connected through USB and `bootiso` fails.

<a href="https://webmshare.com/play/36rRn">
<img src="images/bootiso-d-no-usb.png" width="500">
</a>

<a name="distro-tweaks"></a>

## Distros tweaks

- On Fedora, set `BOOTISO_SYSLINUX_LIB_ROOT` env to `/usr/share/syslinux`
- On Fedora, wimlib is packaged under wimlib-utils
- On Debian-based systems, wimlib is packaged under wimtools

## Contributing

Read the [Code Style and Conventions](style.md) document.
