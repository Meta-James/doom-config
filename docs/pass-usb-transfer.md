# Transferring `pass` entries to the desktop via USB

Offline transfer of the GPG-encrypted password store (`pass`) from one
machine to another, using a USB drive as the carrier. Two things must travel
together — the encrypted entries *and* the GPG key that decrypts them.
Backing up one without the other makes the transfer useless.

## 1. Encrypt the USB itself

`pass` entries are GPG-encrypted already, but filenames (entry paths) are
not — those leak which services you have accounts for. Put a LUKS
(Linux) or VeraCrypt container on the drive first:

```bash
# format USB as LUKS (destroys existing data on that partition — confirm
# the device node with `lsblk` before running this)
sudo cryptsetup luksFormat /dev/sdX1
sudo cryptsetup open /dev/sdX1 usbxfer
sudo mkfs.ext4 /dev/mapper/usbxfer
sudo mount /dev/mapper/usbxfer /mnt/usb
```

**Warning:** `luksFormat` destroys all existing data on that partition and
cannot be undone. Double-check `/dev/sdX1` is the USB, not a system disk.

## 2. Copy the password store

```bash
rsync -av --delete ~/.password-store/ /mnt/usb/password-store/
```

Check `echo $PASSWORD_STORE_DIR` first if the store lives somewhere other
than the default `~/.password-store`.

## 3. Copy the GPG key that decrypts it

Find the key ID `pass` uses (in `~/.password-store/.gpg-id`), then:

```bash
gpg --export-secret-keys --armor <KEYID> > /mnt/usb/gpg-private-key.asc
gpg --export --armor <KEYID> > /mnt/usb/gpg-public-key.asc
```

The `.asc` secret-key file is as sensitive as the password store itself —
that's fine inside the LUKS container. Never let a copy of it land outside
the encrypted volume (no `/tmp`, no cloud sync folder, no plain USB
partition).

## 4. Move the USB to the desktop and import

Unmount/close the container on the source machine, physically move the
drive, then on the desktop:

```bash
sudo cryptsetup open /dev/sdX1 usbxfer
sudo mount /dev/mapper/usbxfer /mnt/usb

gpg --import /mnt/usb/gpg-public-key.asc
gpg --import /mnt/usb/gpg-private-key.asc

rsync -av /mnt/usb/password-store/ ~/.password-store/
```

## 5. Verify

```bash
pass show <some-entry>
```

An entry that decrypts cleanly confirms both the key import and the store
copy worked. Then wipe the private-key file off the USB
(`shred -u /mnt/usb/gpg-private-key.asc`) once the desktop's own key
management (agent, keyring) has it — don't leave a bare copy of the secret
key sitting on removable media longer than the transfer takes.

## 6. Clean up

```bash
sudo umount /mnt/usb
sudo cryptsetup close usbxfer
```
