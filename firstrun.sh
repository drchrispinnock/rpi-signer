#!/bin/bash

echo "Setting up Octez Signer"
cp /boot/signerconf/setupsigner /etc/rc.local
chmod +x /etc/rc.local

