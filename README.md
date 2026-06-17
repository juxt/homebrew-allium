# homebrew-allium

Homebrew tap for [Allium](https://github.com/juxt/allium-tools), a checker and parser for the Allium specification language.

## Install

```
brew tap juxt/allium
brew install allium
```

## Troubleshooting

### `Permission denied @ rb_check_realpath_internal - .../Documents` on macOS

On macOS Tahoe, installing an **un-bottled** formula makes Homebrew run the
install in its build sandbox, whose `deny_read_home` step calls `realpath` on
TCC-protected home folders (`~/Documents`, …). If the terminal lacks access,
that `realpath` fails and the install aborts (juxt/allium#42). It is unrelated
to the current directory or `HOMEBREW_*` overrides. The fix is to ship bottles
so Homebrew **pours** a prebuilt package instead of building.

`scripts/repro-homebrew-sandbox.sh` reproduces and verifies this:

```
scripts/repro-homebrew-sandbox.sh tier1   # deterministic: un-bottled builds, bottled pours
scripts/repro-homebrew-sandbox.sh tier2   # the literal error (needs a one-time TCC denial)
```

## License

MIT
