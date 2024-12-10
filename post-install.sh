#!/bin/bash

# Setup routines for custom Raspberry Pi image
#
bootdir=/boot

initdir=$bootdir/tezos
sfwdir=$bootdir/sfw
configdir=$bootdir/signerconfig
keydir=/home/tzsigner
user="tzsigner"
reboot=no
donotdelete=yes


echo "Tezos Signer Postinstaller"
echo ""

[ -f "$initdir/donotdelete" ] && donotdelete=yes

if [ -d $sfwdir ]; then
	if [ -f $sfwdir/order ]; then
		for file in $(cat $sfwdir/order); do
			echo "Installing $file"
			dpkg -i $sfwdir/$file
		done
	else
		(cd $sfwdir && apt install -y *deb)
	fi
	rm -rf $sfwdir
fi

[ -f $initdir/rebootafter ] && reboot=yes

# Put the configuration in place (this should happen on each boot)
#
if [ -d $configdir ]; then
	cp $configdir/signer.conf /etc/octez
#	cp $configdir/dhcpcd.conf /etc
fi

if [ -f "$initdir/encryptpass" ]; then 

	grep "^$keydir" /etc/fstab >/dev/null 2>&1
	if [ "$?" = "0" ]; then
		echo "Warn: encryptpass supplied but filesystem encrypted already?" >&2
	else
		echo "Encrypting filesystem" >&2
		_pass=$(cat "$initdir/encryptpass")
		mount -t ecryptfs -o "ecryptfs_cipher=aes,key=passphrase:passphrase_passwd=$_pass,ecryptfs_passthrough,ecryptfs_key_bytes=16,ecryptfs_enable_filename_crypto=n" $keydir $keydir
		echo "$keydir $keydir ecryptfs rw,relatime,ecryptfs_cipher=aes,ecryptfs_key_bytes=16,ecryptfs_passthrough,ecryptfs_unlink_sigs,key=passphrase,ecryptfs_enable_filename_crypto=n 0 0" >> /etc/fstab

		reboot=yes
	fi

else
	grep "^$keydir" /etc/fstab >/dev/null 2>&1
	if [ "$?" != "0" ]; then
		echo "Encryption pass not supplied!"
		echo "Halting!"
		sleep 120
		halt
	fi
fi

# Ensure that signer starts
#
systemctl enable octez-signer

# Import keys into the signer
#
stub=`date +%Y%m%d%H%M%S`
keys="$initdir/key*"
if [ ! -z "$keys" ]; then

	for file in $keys; do
		_alias="${stub}-$(basename $file)"
		_key=$(cat $file)
		echo "Importing $_alias" >&2
		su $user -c "octez-signer import secret key $_alias $_key"
		[ "$?" != "0" ] && echo "WARN: cannot import $_alias" >&2
	done
fi

if [ -f "$initdir/authkey" ]; then 
	_pk=$(cat $initdir/authkey)
	su $user -c "octez-signer add authorized key authkey $_pk"
	[ "$?" != "0" ] && echo "WARN: cannot import authkey" >&2
fi

if [ "$donotdelete" = "no" ]; then
	# Scramble the files and delete
	#
	(cd $initdir && shred -n 20 * && cd && rm -rf $initdir)
fi

echo "Exiting"

[ "$reboot" = "yes" ] && shutdown -r now


