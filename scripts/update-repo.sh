#!/bin/sh
# Rebuild the APT indexes for every .deb under pool/ and sign them.
# Run from the repository root. The signing key must be in the gpg keyring.
set -eu

dist=dists/stable
archs="amd64 arm64"

for arch in $archs; do
    mkdir -p "$dist/main/binary-$arch"
    apt-ftparchive --arch "$arch" packages pool > "$dist/main/binary-$arch/Packages"
    gzip -9 --keep --force "$dist/main/binary-$arch/Packages"
done

apt-ftparchive \
    -o APT::FTPArchive::Release::Origin=bpauli \
    -o APT::FTPArchive::Release::Label=bpauli \
    -o APT::FTPArchive::Release::Suite=stable \
    -o APT::FTPArchive::Release::Codename=stable \
    -o APT::FTPArchive::Release::Architectures="$archs" \
    -o APT::FTPArchive::Release::Components=main \
    release "$dist" > "$dist/Release"

gpg --batch --yes --clearsign --output "$dist/InRelease" "$dist/Release"
gpg --batch --yes --armor --detach-sign --output "$dist/Release.gpg" "$dist/Release"
