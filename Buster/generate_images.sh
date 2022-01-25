#!/bin/bash

##RUN THIS AS SUDO OR ROOT

##requires gzip, rsync, wget, cpio, grub2, xorriso, gawk
##sudo apt-get install gzip rsync wget cpio grub2 xorriso gawk -y

distro="buster"

####Prepare output directories####
mkdir debian-files output
rm -r payload/
mkdir -p payload/source

####Clear tempfiles if applicable####
cd debian-files
if [ -d "tmp" ]; then
   rm -r "tmp/"
fi

####Download the latest distro netboot installer ISO####
wget -N "http://ftp.nl.debian.org/debian/dists/$distro/main/installer-amd64/current/images/netboot/mini.iso"
cd ..

####Bring prerequisite files into the payload build directory####
cp preseed.cfg payload/
#cp ../../../*.sh payload/source/
#cp ../../../*.service payload/source/
#cp ../../../it8721.conf payload/source/
#cp -r ../../../micon_scripts payload/source/
#cp ../../../micro-evtd payload/source/
#cp -r ../../../Tools/modules payload/source/

####Extract the netboot installer ISO####
xorriso -osirrox on -indev debian-files/mini.iso -extract / iso/
cp iso/initrd.gz .
if [ $? -ne 0 ]; then
        echo "failed to retrieve initrd.gz, quitting"
        exit
fi

####Get the netboot installer kernel version####
kernel_ver="$(zcat initrd.gz | cpio -t | grep -m 1 lib/modules/ | gawk -F/ '{print $3}')"

####Extract the initial ramdisk of the netboot installer####
gunzip initrd.gz
if [ $? -ne 0 ]; then
        echo "failed to unpack initrd.gz, quitting"
        exit
fi

####Modify the initial ramdisk####
cd payload
find . | cpio -v -H newc -o -A -F ../initrd
if [ $? -ne 0 ]; then
        echo "failed to patch initrd.gz, quitting"
        exit
fi

####Repack the new initial ramdisk####
cd ..
gzip initrd
#cat initrd | xz --check=crc32 -9 > initrd.xz
if [ $? -ne 0 ]; then
        echo "failed to pack initrd, quitting"
        exit
fi

####Remove original GRUB files####
#rm -r iso/boot/grub/*

####Assemble some files for the new ISO####
cp initrd.gz iso/
cp grub.cfg iso/boot/grub/
#mkdir iso/EFI
#cp startup.nsh iso/EFI/

####Clear the final output directory####
rm output/*

####Build the new ISO using GRUB####
#grub-mkrescue -o "output/dx4000-$distro-installer.iso" iso/

####Make a GRUB image####
#BOOT_IMG_DATA=$(mktemp -d)
#BOOT_IMG=$(mktemp -d)/efi.img

#mkdir -p $(dirname $BOOT_IMG)

#truncate -s 8M $BOOT_IMG
#mkfs.vfat $BOOT_IMG
#mount $BOOT_IMG $BOOT_IMG_DATA
#mkdir -p $BOOT_IMG_DATA/efi/boot

#grub-mkimage \
#    -C xz \
#    -O x86_64-efi \
#    -p /boot/grub \
#    -o $BOOT_IMG_DATA/efi/boot/bootx64.efi \
#    boot linux search normal configfile \
#    part_gpt btrfs ext2 fat iso9660 loopback \
#    test keystatus gfxmenu regexp probe \
#    efi_gop efi_uga all_video gfxterm font \
#    echo read ls cat png jpeg halt reboot

#umount $BOOT_IMG_DATA
#cp $BOOT_IMG .
#rm -rf $BOOT_IMG_DATA

####Extract Debian's unused EFI raw image####
mkdir efimount
mount debian-files/mini.iso efimount
cp efimount/boot/grub/efi.img .
umount efimount
rmdir efimount

####Assemble ISO####
xorriso -as mkisofs \
    -iso-level 3 \
    -r -V "dx4000-$distro-installer" \
    -J -joliet-long \
    -append_partition 2 0xef efi.img \
    -partition_cyl_align all \
    -o "output/dx4000-$distro-installer.iso" \
    iso/

####Delete byproducts####
rm -r iso/
rm efi.img
rm initrd.gz
