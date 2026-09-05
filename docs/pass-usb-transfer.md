# Transferring `pass` entries to the desktop via USB

Offline transfer of the GPG-encrypted password store (`pass`) from one
machine to another, using a USB drive as the carrier. Two things must travel
together — the encrypted entries *and* the GPG key that decrypts them.
Backing up one without the other makes the transfer useless.

This is the procedure `PROJECT.org` §7.7 refers to: the laptop holds the store
that the Phase 3 credential work actually built, and the desktop (`PsychedPC`)
holds a smaller store rebuilt from empty on 2026-08-30. The laptop's store is
the authority, so this transfer *replaces* the desktop's rather than merging
into it.

**Two carriers, pick one.** Steps 1–3 below use a LUKS container plus a plain
copy. The alternative is `~/.local/bin/pass-backup`, which this repo tangles
from `config.org` (see ADR-038): it tars the store together with the exported
secret key and encrypts the whole thing with `gpg --symmetric`, so the archive
is safe on an unencrypted stick and steps 1–3 collapse to one command:

```bash
PASS_BACKUP_DIR=/media/james/<stick> pass-backup
```

Unpack it on the far side with the recipe the script prints on its way out,
then continue from step 4. The LUKS route below is the one to use if you want
the store browsable on the stick rather than sealed in an archive.

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
gpg --export-secret-keys --armor <LAPTOP-KEYID> > /mnt/usb/gpg-private-key.asc
gpg --export --armor <LAPTOP-KEYID> > /mnt/usb/gpg-public-key.asc
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
```

Back the desktop's existing store up before overwriting it — it is not empty,
and an API key entered there on 2026-08-30 may be newer than the laptop's copy:

```bash
pass-backup    # writes an encrypted archive to /data/backups/pass/
```

Then replace the store. `--delete` is what makes this a replacement rather
than a merge; without it the desktop's own entries survive alongside the
laptop's, including the misspelled `mail/oaut2-google-client` that §7.7
records:

```bash
rsync -av --delete /mnt/usb/password-store/ ~/.password-store/
```

## 5. Re-encrypt to both machines' keys

The store that just arrived carries the laptop's `.gpg-id`, so every future
`pass insert` on the desktop encrypts to the laptop key alone — readable
there, not here. Name both keys as recipients, which also re-encrypts every
existing entry:

```bash
pass init <LAPTOP-KEYID> 4F6F02436717EE9B823369EAE2F99AE2D3BDF9E1
```

That second fingerprint is the desktop key made on 2026-08-30 (fingerprints
are public by design). Running the same pair on the laptop later keeps the two
machines symmetric.

## 6. Verify

```bash
pass ls                                   # structure only
pass show mail/oauth2-google-client >/dev/null && echo "decrypt ok"
```

An entry that decrypts cleanly confirms both the key import and the store copy
worked. Discard the output — never print a secret value to a terminal, a log,
or an agent transcript (`.claude/rules/security.md`). Expect three entries:
`api/anthropic`, `api/openai`, `mail/oauth2-google-client`.

Then wipe the private-key file off the USB
(`shred -u /mnt/usb/gpg-private-key.asc`) once the desktop's own key
management (agent, keyring) has it — don't leave a bare copy of the secret
key sitting on removable media longer than the transfer takes.

Restart Emacs afterwards: `my/pass-check-store` should fall silent, and
org-gcal should reload its client instead of warning.

## 7. Clean up

```bash
sudo umount /mnt/usb
sudo cryptsetup close usbxfer
```
