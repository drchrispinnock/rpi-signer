#!/bin/bash

echo "Setting up Octez Signer"
cp /boot/signerconfig/rc.local /etc/rc.local
chmod +x /etc/rc.local
mv /boot/cmdline.txt.orig /boot/cmdline.txt

