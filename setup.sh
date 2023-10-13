#!/bin/sh

#date=`date +%Y%m%d%H%M%S`
#imagefile=rpi-signer-$date.img

#url=$(cat raspbianurl.txt)
#wget -O $imagefile.xz $url
#xz --decompress $imagefile.xz
#rm -f $imagefile.xz
#open $imagefile
#
#bootfs="/Volumes/bootfs"

[ -z "$1" ] && echo "Usage: $0 path-to-bootfs" && exit 1
bootfs="$1"

# Make directories
#
mkdir -p "$bootfs/tezos" "$bootfs/signerconfig" "$bootfs/sfw" 

# First run script
#
cp firstrun.sh $bootfs
chmod +x $bootfs/firstrun.sh

# Software
#
rm -f order
for file in $(cat softwareurls.txt); do
	wget $file
	basename $file >> order
done
mv *.deb order $bootfs/sfw

# Copy rest of stuff
#
cp setupsigner dhcpcd.conf signer.conf $bootfs/signerconfig

# Adjust cmdline.txt
sed -i.orig '1s|$| systemd.run=/boot/firstrun.sh systemd.run_success_action=reboot systemd.unit=kernel-command-line.target|' "$bootfs/cmdline.txt"


#umount $bootfs
#xz --compress $imagefile
#rm -f $imagefile
