
# Raspberry Remote Signer

Aim: 

- to provide an image containing Raspbian 64-bit and octez-signer
- on first boot, the image rearranges itself, encrypts the disc to 
a password (that is supplied on boot) and copies any keys into the right
place
- Designed to be headless, but a keyboard will be needed to type in the
passphrase at boot. No SSHD.
- A keyboard will allow you to shutdown with CTRL-ALT-DEL

To use, put files in the /boot/tezos directory:

- authkey - the public key (Base58) of the authentication key
- key1, key2, ... - the secret key of the keys you want to sign with
- encryptpass - the passphrase used to encrypt the keystore. This needs to
     be supplied at each boot. MUST BE SUPPLIED ON THE FIRST BOOT
- ipconfig - XXX the configuration (static)
- donotdelete - if present, don't shred and delete the files (dangerous)
- rebootafter - reboot after configuration (used for testing)

More keys can be added on subsequent boots. donotdelete is only there
for testing. 

In /boot/signerconfig, you can supply a signer.conf file which will be copied
to disc at boot. In here you can change options to block operations. e.g.
stop the system, put the SD card into another computer, edit the file and 
return it to the Raspberry Pi.


