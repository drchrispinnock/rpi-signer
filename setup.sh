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
for file in $(cat softwareurls.txt); do
	wget $file
done
mv *.deb $bootfs/sfw

# Copy rest of stuff
#
cp setupsigner dhcpcd.conf signer.conf $bootfs/signerconfig

#umount $bootfs
#xz --compress $imagefile
#rm -f $imagefile
