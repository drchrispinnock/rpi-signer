#!/bin/sh

#date=`date +%Y%m%d%H%M%S`
#imagefile=rpi-signer-$date.img
bootfs="/Volumes/bootfs"

url=$(cat raspbianurl.txt)
file=$(basename $url)
imagefile=$(echo $file | sed -e s/.img.xz$/-rpi-signer.img/)

echo "Fetching Raspbian"
wget -q -O $imagefile.xz $url
echo "Decompressing"
xz --decompress $imagefile.xz
rm -f $imagefile.xz
echo "Mounting image"
open -W $imagefile

echo "Adjusting image"
# Make and setup directories
#
mkdir -p "$bootfs/tezos"
rm -rf $bootfs/sfw $bootfs/signerconfig

# Copy rest of stuff
#
cp -pR signerconfig $bootfs/signerconfig

# First run script
#
cp firstrun.sh $bootfs
chmod +x $bootfs/firstrun.sh

# Software
#
mkdir -p sfw
sfwfiles=$(cat softwareurls.txt)
cd sfw
rm -f order
for file in $sfwfiles; do
	_base=$(basename $file)
	echo "Fetching $_base"
	wget -q $file
	echo $_base >> order
done
cd ..
mv sfw $bootfs/sfw

echo "Adjusting boot tools"
# Adjust cmdline.txt
sed -i.orig '1s|$| systemd.run=/boot/firstrun.sh systemd.run_success_action=reboot systemd.unit=kernel-command-line.target|' "$bootfs/cmdline.txt"
# config
echo "enable_uart=1" >> $bootfs/config.txt

diskutil eject $bootfs
echo "Compressing $imagefile"
xz --compress $imagefile
#rm -f $imagefile
