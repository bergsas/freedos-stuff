#!/bin/bash

# http://www.chtaube.eu/computers/freedos/bootable-usb/

# listing=http://www.ibiblio.org/pub/micro/pc-stuff/freedos/files/distributions/1.1/repos/listing.txt
repo_1_1=http://www.ibiblio.org/pub/micro/pc-stuff/freedos/files/distributions/1.1/repos/

# base:
#   command
#   kernel

#packages="base/command base/kernel base/edit base/display base/mode base/cpidos base/keyb base/keyb_lay base/fdapm util/elvis util/xfdisk base/fdisk util/4dos util/bootfix net/mtcp net/ethtools devel/lua"
packages="base/command base/kernel base/edit base/display base/mode base/cpidos base/keyb base/keyb_lay base/fdapm base/choice base/devload util/dosidle util/less util/pcisleep"

output_image_size_mb=6
output_image=fdos-$(date +%Y%m%d).img

syslinux_version=6.03
syslinux_modules="libcom32 chain libutil menu ls"
other_packages="https://www.kernel.org/pub/linux/utils/boot/syslinux/syslinux-$syslinux_version.tar.gz"

tmp="$PWD/tmp"
mnt="$PWD/mnt"
add="$PWD/add"
# Get and extract freedos packages.

mkdir -p "$tmp" "$mnt" 

for n in $packages
do
  # I <3 bashisms like the following:
  tmpzip="$tmp/${n//\//_}.zip"
  [ -e "$tmpzip" ] || (set -x; curl -Lo "$tmpzip" "$repo_1_1/$n.zip")
done

# Get other packages.
for n in $other_packages
do
  tmpfile="$tmp/${n##*/}"
  [ -e "$tmpfile" ] || (set -x; curl -Lo "$tmpfile" "$n")
done

# Syslinux. :(
#   Requires nasm uuid-dev build-essential
if [ ! -e "$tmp/syslinux-$syslinux_version/bios/linux/syslinux" ]
then
  set -x
  tar xzf "$tmp/syslinux-$syslinux_version.tar.gz" -C "$tmp"
  cd "$tmp/syslinux-$syslinux_version"
  make
fi
(
  set -x
  dd if=/dev/zero of="$output_image" bs=1M count="$output_image_size_mb"
)
for command in "mklabel msdos" "mkpart primary fat16 1 -1" "set 1 boot on"
do
(
  set -x
  parted "$output_image" "$command"
)
done
(
  set -x
  dd bs=440 count=1 conv=notrunc if=$tmp/syslinux-$syslinux_version/bios/mbr/mbr.bin of="$output_image"
)

# Ugh. :)
loopdev="$((set -x; sudo kpartx -av "$output_image") | awk '/add map/{print $3}')"

if [ ! -n "$loopdev" ]
then
  echo No loop device created.
  exit 1
fi

(
  set -ex
  sudo mkfs.msdos -vn freedos "/dev/mapper/$loopdev"
  sudo mount "/dev/mapper/$loopdev" "$mnt"
  sudo mkdir "$mnt/fdos"
  sudo mkdir "$mnt/syslinux"
  sudo "$tmp/syslinux-$syslinux_version/bios/linux/syslinux" -i /dev/mapper/$loopdev 
  sudo cp -v "files/autoexec.bat" "$mnt"
  sudo cp -v "files/config.sys" "$mnt"
  sudo cp -v "files/syslinux.cfg" "$mnt/syslinux"
  [ -e "$add" ] && (set -x; sudo cp -vr "$add" "$mnt")
)

for n in $packages
do
  # I <3 bashisms like the following:
  tmpzip="$tmp/${n//\//_}.zip"
  (
    set -x
    sudo unzip -jo "$tmpzip" "bin/*" -d "$mnt/fdos"
    sudo unzip -jo "$tmpzip" "BIN/*" -d "$mnt/fdos"
    sudo unzip -jo "$tmpzip" "cpi/*" -d "$mnt/cpi"
  )
done
  #find "$tmp/syslinux-$syslinux_version/bios/" -iname "*c32" -exec sudo cp -v {} "$mnt" \;
for n in $syslinux_modules
do
(
  set -x 
  find "$tmp/syslinux-6.03/bios" -name "$n.c32" -print -exec sudo cp -v {} "$mnt/syslinux" \;
)
done

(
  set -x
  sudo umount "/dev/mapper/$loopdev"
  sudo kpartx -vd "$output_image"
)
