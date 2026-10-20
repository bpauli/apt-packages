# apt-packages

Signed APT repository for Debian and Ubuntu, updated on each release via GitHub Actions. It is served from GitHub Pages at https://bpauli.de/apt-packages.

## Packages

- **gccli** - CLI for Garmin Connect
- **zwift-bootstrap** - Unofficial native Linux launcher for Zwift

## Use the repository

Supported systems: Debian 12 and later, Ubuntu 22.04 and later. gccli is available for amd64 and arm64, zwift-bootstrap for amd64.

```sh
curl -fsSL https://bpauli.de/apt-packages/key.gpg | sudo tee /usr/share/keyrings/bpauli-apt.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/bpauli-apt.gpg] https://bpauli.de/apt-packages stable main" | sudo tee /etc/apt/sources.list.d/bpauli.list
sudo apt update
sudo apt install gccli zwift-bootstrap
```

`sudo apt upgrade` then installs new releases.

## Signing key

The repository is signed with this key:

```text
Burkhard Pauli APT repository <burkhard@pauli.tech>
1A35 8FDB 847D 8E60 CCE8  B121 3168 A763 883F 7A7F
```

## How it works

A release of a package starts `.github/workflows/update-package.yml`. The workflow runs `scripts/fetch-package.sh`, which takes the `.deb` files of the GitHub release. A release without `.deb` files gets them built with nfpm from its linux tarballs and `packages/<name>/nfpm.yaml`. Every download is checked against the release's `checksums.txt`. Then `scripts/update-repo.sh` rebuilds and signs the indexes in `dists/`.
