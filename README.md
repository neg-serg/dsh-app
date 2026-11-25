# dsh-app

The DeepSeek Harness (dsh) npm packaging and the terminal-profile data this host
ships, extracted from `/etc/nixos` so the harness can move without touching the
host's history.

## What is here

| path                    | what it is                                                                                                      |
| ----------------------- | --------------------------------------------------------------------------------------------------------------- |
| `package.nix`           | the `buildNpmPackage` recipe: registry tarball, lockfile with the two security overrides, the `dsh-patch` step   |
| `nodejs-official.nix`   | the official Node build the launcher runs on (the harness's native loader cannot find its getter in nixpkgs' Node) |
| `package-lock.json`     | the lockfile the build and `npm ci` share                                                                        |
| `post-install.sh`       | the patch script rendered into the package (`@NODEJS@`, `@NODELIB@`, `@DSHPATCH@`)                               |
| `tui/roster.nix`        | the terminal profile's plugin allow-list and loader rows                                                         |
| `tui/presets.nix`       | the two agent presets (`neg`, `fast`) as declaration rows                                                        |
| `tui/ensure.sh`         | the profile caretaker the host installs as a user unit                                                           |
| `tui/xdg-migrate.sh`    | one-time `~/.dsh` to XDG relocation                                                                              |
| `tui/themes/`, `tui/presets/` | the neg theme, the preset sources and their NOTICEs                                                       |

The host keeps everything machine-specific: systemd units and activation, the
sops-backed wrapper, the free-route smoke test, and the two third-party plugin
forks (`dsh-plugin-recall`, `dsh-plugin-vetting`) that the roster receives as
`localForks`.

## How the host consumes it

```nix
dsh = final.callPackage (inputs.dsh-app + "/package.nix") { inherit (final.neg) dsh-patch; };
```

and imports `tui/roster.nix`, `tui/presets.nix`, `tui/ensure.sh`,
`tui/xdg-migrate.sh` and `tui/themes/neg.json` from the same input.

## Build

```bash
nix build .#default   # the harness, against this pin
nix flake check       # builds the same derivation as checks.build
```

`dsh` itself is MIT; upstream is <https://github.com/deepseek-ai/deepseek-harness>.
