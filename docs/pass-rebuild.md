# Rebuilding the `pass` credential store

**Status:** live plan as of 2026-09-14. Nothing in it has been run yet.
Supersedes the laptop-to-desktop USB transfer this file used to describe —
see `docs/decisions.org` ADR-048 for why that plan is dead.

## What happened

The passphrase for the desktop GPG key
(`4F6F02436717EE9B823369EAE2F99AE2D3BDF9E1`, generated 2026-08-30) was lost on
2026-09-14. Every entry in `~/.password-store` was encrypted to it and none can
be opened. There is no reset path for a GPG private key without its passphrase.

`~/.local/bin/pass-backup` exists precisely to prevent this and had never been
run — `/data/backups/pass/` does not exist. The only backup that did exist was a
hand-made `password-store-2026-09-08.tar` on the Kingston stick: the encrypted
store, no key. Useless on its own.

The dead store is archived at `~/.password-store.dead-2026-09-14` and the dead
key is still in the keyring. Both are kept deliberately until the rebuild is
confirmed working; neither is recoverable, so neither blocks anything.

## Step 0 — check the laptop first, before re-issuing anything

**Do not skip this.** It was never established which passphrase was lost. Two
cases, and they cost very different amounts of work:

- If the **desktop** key's passphrase is the lost one, the laptop's store is
  untouched. Its key (`859AF991C9EA4396`) still opens the USB tarball, and the
  three values can be read there and re-entered here — no re-issuing, no
  revocation.
- If the **laptop** key's passphrase is the lost one, the USB tarball is dead
  too and the values are genuinely gone. Go to step 1.

On the laptop:

```bash
gpg --list-secret-keys --keyid-format LONG      # expect 859AF991C9EA4396
pass show api/anthropic >/dev/null && echo "readable"
```

`>/dev/null` is deliberate — confirm it decrypts, never print the value
(`.claude/rules/security.md`). If it reads clean, the laptop is the authority
and the job is to carry its values across by hand, then run `pass-backup` on
both machines.

## Step 1 — new desktop key

The dead key shares a UID with the new one, so every command below takes an
explicit fingerprint. Do not let `gpg` or `pass` match on the email address.

```bash
gpg --quick-generate-key "James Cook (PsychedPC) <mrniceguyjames@gmail.com>" \
    ed25519 default never
```

Same shape as the old key: ed25519 primary (`[SC]`) with a cv25519 encryption
subkey (`[E]`). Note the new fingerprint from the output.

**Write the passphrase down somewhere that is not this machine and not the
store it unlocks.** That is the single control that failed on 2026-09-14.

## Step 2 — init the store

The archived store cannot be re-encrypted, since `pass init` decrypts every
entry to do so. Start from empty:

```bash
pass init <NEW_FINGERPRINT>
```

## Step 3 — re-add the three entries

Names and shapes are fixed by `config.org` — the expected-entry list at
`config.org:955` and the `+pass-get-field` call sites at `config.org:2325`.
Getting them wrong is what produced the `oaut2` typo the old store carried.

```bash
pass insert api/anthropic
pass insert api/openai
pass insert -m mail/oauth2-google-client
```

The last is multi-line and the order is load-bearing. `+pass-get-field` is a
`defalias` onto `auth-source-pass-parse-entry`, which reads line 1 as the secret
and splits later lines at the first colon:

```
<client secret>
client_id: <id>.apps.googleusercontent.com
```

End with Ctrl-D. `client_id` is the settled field name — `config.org` also
accepts `client-id`, `login` and `user`, but use `client_id`.

If step 0 sent you to the providers instead, re-issue at the Anthropic console,
the OpenAI platform and the Google Cloud OAuth client screen, and **revoke the
old credentials while you are there** — they cannot be read to confirm they are
unused, so treat them as live.

## Step 4 — back up immediately, before anything else

This is the step whose absence caused the rebuild. Run it in the same sitting
as step 3, not later:

```bash
pass-backup
```

It writes `/data/backups/pass/pass-<date>.tar.gpg` containing the store *and*
the exported secret key, encrypted symmetrically. It prompts twice — once for
the key passphrase, once for the archive passphrase. `/data` is `sda` and
`$HOME` is `sdc`, so the archive survives a homedir wipe.

Use an archive passphrase you can actually remember and have not used
elsewhere. An archive you cannot open is not a backup.

## Step 5 — prove the restore works

Untested recovery is not recovery. This closes the open box in `PROJECT.org`
§7.6:

```bash
restore_dir="$(mktemp -d)"
gpg --decrypt /data/backups/pass/pass-<date>.tar.gpg | tar -C "$restore_dir" -xf -
GNUPGHOME="$restore_dir/gnupg" mkdir -p "$restore_dir/gnupg" && chmod 700 "$restore_dir/gnupg"
GNUPGHOME="$restore_dir/gnupg" gpg --import "$restore_dir/secret-key.asc"
PASSWORD_STORE_DIR="$restore_dir/password-store" GNUPGHOME="$restore_dir/gnupg" \
  pass show api/anthropic >/dev/null && echo "restore ok"
rm -rf "$restore_dir"
```

Scratch `$GNUPGHOME` throughout, so the rehearsal cannot disturb the real
keyring. Discard all output — never print a value.

## Step 6 — implement the ADR-048 guard

`my/pass-check-store` in `config.org` currently warns only about missing
*entries*. ADR-048 extends it to warn about a missing or stale *backup*, which
is the condition that went unnoticed for two weeks. Edit `config.org`, never
`config.el`, then `doom sync` and `doom doctor`.

Full specification, including the mtime-comparison approach and the
no-decrypt constraint, is in `docs/decisions.org` ADR-048 under Decision.

## Step 7 — verify and clean up

```bash
pass ls          # structure only; expect the three entries
```

Restart Emacs: `my/pass-check-store` should fall silent and org-gcal should
reload its client instead of warning.

Once the new store reads cleanly and a restore has been rehearsed:

```bash
rm -rf ~/.password-store.dead-2026-09-14
gpg --delete-secret-keys 4F6F02436717EE9B823369EAE2F99AE2D3BDF9E1
gpg --delete-keys 4F6F02436717EE9B823369EAE2F99AE2D3BDF9E1
shred -u /media/james/KINGSTON/password-store-2026-09-08.tar
```

Both deletions are irreversible, which is fine only after the rebuild is
confirmed — the archived store and dead key are worthless, but worthless is not
the same as safe to delete before the replacement works.

If you ever put a secret-key export on the Kingston, it is protected only by its
own passphrase. Keep the stick physically secure and shred the export off it
once the target machine's keyring has the key.

## Why not the old USB-transfer procedure

That plan copied the laptop store to the desktop and named both keys as
recipients. It assumed a working desktop key to name as the second recipient.
There isn't one, and the store it would have replaced no longer exists. The
LUKS-container advice in it was sound and is worth reviving if a store ever
travels on removable media again: entry *filenames* are not encrypted, so a
plain stick leaks which services have accounts even when every value is safe.
