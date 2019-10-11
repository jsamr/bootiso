FROM ubuntu:18.04
RUN apt-get -qq update ; apt-get install -y \
  extlinux \
  curl \
  file \
  mtools \
  syslinux \
  rsync \
  parted \
  bc \
  udev \
  wimtools
RUN curl -L https://git.io/bootiso -o /bootiso; chmod +x /bootiso
CMD echo USAGE:  docker run -it --rm --privileged  -v /your/iso/dir:/data bootiso /bootiso -d /dev/sdX /data/YOURISOFILE.iso