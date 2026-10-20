#!/bin/sh
# Rebuild the APT indexes for every .deb under pool/ and sign them.
# Run from the repository root. The signing key must be in the gpg keyring.
set -eu

dist=dists/stable
mkdir -p "$dist/main/binary-amd64"

apt-ftparchive --arch amd64 packages pool > "$dist/main/binary-amd64/Packages"
gzip -9 --keep --force "$dist/main/binary-amd64/Packages"

apt-ftparchive \
    -o APT::FTPArchive::Release::Origin=bpauli \
    -o APT::FTPArchive::Release::Label=bpauli \
    -o APT::FTPArchive::Release::Suite=stable \
    -o APT::FTPArchive::Release::Codename=stable \
    -o APT::FTPArchive::Release::Architectures=amd64 \
    -o APT::FTPArchive::Release::Components=main \
    release "$dist" > "$dist/Release"

gpg --batch --yes --clearsign --output "$dist/InRelease" "$dist/Release"
gpg --batch --yes --armor --detach-sign --output "$dist/Release.gpg" "$dist/Release"
