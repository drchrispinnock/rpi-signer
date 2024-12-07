#!/bin/sh

debug=1 #xxx
[ "$1" = "debug" ] && debug=1

bootfs="/Volumes/bootfs"

url=$(cat raspbianurl.txt)
file=$(basename $url)
tail=rpi-signer
[ "$debug" = "1" ] && tail=rpi-signer-debug

imagefile=$(echo $file | sed -e s/.img.xz$/-$tail.img/)

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
cp post-install.sh $bootfs
chmod +x $bootfs/post-install.sh

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

if [ "$debug" = "1" ]; then
	# Todo. Maybe enable serial console
	echo
#	echo "enable_uart=1" >> $bootfs/config.txt
else
	# Harden - remove logins. etc
	echo
fi


diskutil eject $bootfs
echo "Compressing $imagefile"
xz --compress $imagefile
#rm -f $imagefile
