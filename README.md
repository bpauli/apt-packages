# apt-packages

Signed APT repository for Debian and Ubuntu, updated on each release via GitHub Actions. It is served from GitHub Pages at https://bpauli.de/apt-packages.

## Packages

- **zwift-bootstrap** - Unofficial native Linux launcher for Zwift

## Use the repository

Supported systems: Debian 12 and later, Ubuntu 22.04 and later, on amd64.

```sh
curl -fsSL https://bpauli.de/apt-packages/key.gpg | sudo tee /usr/share/keyrings/bpauli-apt.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/bpauli-apt.gpg] https://bpauli.de/apt-packages stable main" | sudo tee /etc/apt/sources.list.d/bpauli.list
sudo apt update
sudo apt install zwift-bootstrap
```

`sudo apt upgrade` then installs new releases.

## Signing key

The repository is signed with this key:

```text
Burkhard Pauli APT repository <burkhard@pauli.tech>
1A35 8FDB 847D 8E60 CCE8  B121 3168 A763 883F 7A7F
```

## How it works

A release of a package starts `.github/workflows/update-package.yml`. The workflow downloads the `.deb` from the GitHub release, checks it against `checksums.txt`, puts it in `pool/`, and runs `scripts/update-repo.sh` to rebuild and sign the indexes in `dists/`.
