
# Raspberry Remote Signer

Aim: 

- provide an image containing Raspbian 64-bit and octez-signer
- on first boot, the image rearranges itself, encrypts the disc to 
  a password (that is supplied on boot) and copies any keys into the 
  right place
- Designed to be headless, but a keyboard will be needed to type in the
  passphrase at boot. No sshd.
- Simple point to point network configuration so that it can be used with
  another machine (e.g. baker) on a spare network port

To use, put files in the /boot/tezos directory:

- authkey - the public key (Base58) of the authentication key
- key1, key2, ... - the secret key of the keys you want to sign with
- encryptpass - the passphrase used to encrypt the keystore. This needs to
     be supplied at each boot. MUST BE SUPPLIED ON THE FIRST BOOT
- donotdelete - if present, don't shred and delete the files (dangerous)
- rebootafter - reboot after configuration (used for testing)

On subsequent boots, new software can be put in /boot/sfw & more keys can 
be added in /boot/tezos.

In /boot/signerconfig, you can supply a signer.conf file which will be copied
to disc at boot. In here you can change options to block operations. e.g.
stop the system, put the SD card into another computer, edit the file and 
return it to the Raspberry Pi.

Additionally the dhcpcd.conf file is copied as well and this has a static
configuration. The Pi has IP address 10.0.230.2 (netmask /30) and expects
to talk to 10.0.230.1. This means the Pi can be attached to another 
machine with a network cross-over cable.


[] https://www.howtoraspberry.com/2020/12/how-to-make-your-own-raspberry-pi-img-files/
