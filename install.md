## Dependencies

**bootiso** relies mainly on classic GNU and POSIX command line utilities,
with the exception of the more rencent **systemd** and **wimlib**. 

<table>
  <thead>
    <tr>
      <th rowspan="2" style="text-align: left;">command</th>
      <th colspan="3">package</th>
    </tr>
    <tr>
      <th>Arch Linux</th>
      <th>Debian</th>
      <th>Red Hat</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style="text-align: left;">wimlib-imagex</td>
      <td>wimlib</td>
      <td>wimtools</td>
      <td>wimlib</td>
    </tr>
    <tr>
      <tr>
        <td style="text-align: left;">bash</td>
        <td colspan="3" align="center">bash &ge; 4.0</td>
      </tr>
      <tr>
        <td style="text-align: left;">udevadm</td>
        <td colspan="3" align="center">systemd</td>
      </tr>
      <td style="text-align: left;">
        md5sum, sha1sum, sha256sum, sha512sum, cut, cat, mkdir, chmod, dirname, basename, date, tr
      </td>
      <td colspan="3" align="center">coreutils</td>
    </tr>
    <tr>
    <tr>
      <td style="text-align: left;">
        lsblk, sfdisk, mkfs, blkid, wipefs, blockdev, column, mount, umount, blockdev
      </td>
      <td colspan="3" align="center">util-linux</td>
    </tr>
    <tr>
      <td style="text-align: left;">find, xargs</td>
      <td colspan="3" align="center">findutils</td>
    </tr>
    <tr>
      <td style="text-align: left;">sed</td>
      <td colspan="3" align="center">sed</td>
    </tr>
    <tr>
      <td style="text-align: left;">grep</td>
      <td colspan="3" align="center">grep</td>
    </tr>
    <tr>
      <td style="text-align: left;">file</td>
      <td colspan="3" align="center">file</td>
    </tr>
    <tr>
      <td style="text-align: left;">awk</td>
      <td colspan="3" align="center">gawk</td>
    </tr>
    <tr>
      <td style="text-align: left;">mlabel</td>
      <td colspan="3" align="center">mtools</td>
    </tr>
    <tr>
      <td style="text-align: left;">syslinux, extlinux</td>
      <td colspan="3" align="center">syslinux</td>
    </tr>
    <tr>
      <td style="text-align: left;">rsync</td>
      <td colspan="3" align="center">rsync</td>
    </tr>
    <tr>
      <td style="text-align: left;">partprobe</td>
      <td colspan="3" align="center">parted</td>
    </tr>
    <tr>
      <td style="text-align: left;">curl</td>
      <td colspan="3" align="center">curl</td>
    </tr>
    <tr>
      <td style="text-align: left;">tar</td>
      <td colspan="3" align="center">tar</td>
    </tr>
    <tr>
      <td style="text-align: left;">bc</td>
      <td colspan="3" align="center">bc</td>
    </tr>
  </tbody>
</table>


## Files
