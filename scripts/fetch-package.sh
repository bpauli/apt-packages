#!/bin/bash
# Put the .deb files of one release into pool/. Usage: fetch-package.sh PACKAGE TAG REPOSITORY
# A release .deb is used as is. Without one, the .deb is built with nfpm from the linux
# tarball and packages/PACKAGE/nfpm.yaml. Every download is checked against checksums.txt.
set -euo pipefail

package=$1 tag=$2 repo=$3
version=${tag#v}
root=$(pwd)
pool="$root/pool/main/${package:0:1}/${package}"
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

gh release download "$tag" --repo "$repo" --dir "$work" --pattern checksums.txt
mkdir -p "$pool"
added=0

for arch in amd64 arm64; do
    deb_line=$(grep -E "  ${package}_[^ ]*_${arch}\.deb$" "$work/checksums.txt" || true)
    tarball="${package}_${version}_linux_${arch}.tar.gz"
    if [ -n "$deb_line" ]; then
        deb=${deb_line##* }
        gh release download "$tag" --repo "$repo" --dir "$work" --pattern "$deb"
        (cd "$work" && sha256sum --check <<< "$deb_line")
        mv "$work/$deb" "$pool/"
    elif [ -f "$root/packages/$package/nfpm.yaml" ] && grep -q "  ${tarball}$" "$work/checksums.txt"; then
        gh release download "$tag" --repo "$repo" --dir "$work" --pattern "$tarball"
        (cd "$work" && grep "  ${tarball}$" checksums.txt | sha256sum --check)
        mkdir "$work/$arch"
        tar -xzf "$work/$tarball" -C "$work/$arch"
        (cd "$work/$arch" && VERSION=$version ARCH=$arch \
            nfpm package --config "$root/packages/$package/nfpm.yaml" --packager deb --target "$pool/")
    else
        continue
    fi
    added=$((added + 1))
done

if [ "$added" -eq 0 ]; then
    echo "No .deb and no buildable tarball for ${package} ${tag}" >&2
    exit 1
fi
