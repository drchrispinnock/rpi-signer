#!/bin/bash

# Run at startup Raspberry Pi image

initdir=/boot/tezos
configdir=/boot/signerconfig
keydir=/home/tzsigner
user="tzsigner"
reboot=no

if [ ! -d $initdir ]; then
	echo "Cannot find tezos initialisation directory" 2>&1
	exit 1
fi

[ -f $initdir/rebootafter ] && reboot=yes

# Put the configuration in place (this should happen on each boot)
#
if [ ! -d $configdir ]; then
	mkdir -p $configdir
	cp /etc/octez/signer.conf $configdir
else
	cp $configdir/signer.conf /etc/octez
	cp $configdir/dhcpcd.conf /etc
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
for file in $initdir/key*; do
	_alias="${stub}-$(basename $file)"
	_key=$(cat $file)
	echo "Importing $_alias" >&2
	su $user -c "octez-signer import secret key $_alias $_key"
	[ "$?" != "0" ] && echo "WARN: cannot import $_alias" >&2
done

if [ -f "$initdir/authkey" ]; then 
	_pk=$(cat $initdir/authkey)
	octez-signer add authorized key authkey $_pk
fi

if [ ! -f "$initdir/donotdelete" ]; then
	# Scramble the files and delete
	#
	(cd $initdir && shred -n 20 * && cd && rm -rf $initdir)
fi



[ "$reboot" = "yes" ] && shutdown -r now

