#!/usr/bin/env bash
set -eo pipefail

# AOSP envsetup.sh is not nounset-safe (ZSH_VERSION etc.), keep set -u off.

SRC=/workspace/src
DEVICE_SRC=/workspace/device/droi/p80pro
DEVICE_DST="$SRC/device/droi/p80pro"

export DEBIAN_FRONTEND=noninteractive
export LC_ALL=C
export ALLOW_MISSING_DEPENDENCIES=true

echo "== disk before =="
df -h /workspace | tail -1

echo "== installing build dependencies =="
# GitHub runners sit in Azure; the default archive.ubuntu.com is often
# throttled to a crawl there, so use the in-cloud mirror.
sed -i 's|//archive.ubuntu.com|//azure.archive.ubuntu.com|g; s|//security.ubuntu.com|//azure.archive.ubuntu.com|g' /etc/apt/sources.list
apt-get -o Acquire::Retries=5 -o Acquire::http::Timeout=60 update
PKGS="bc bison build-essential curl flex g++-multilib gcc-multilib git gnupg gperf \
    imagemagick lib32ncurses5-dev lib32readline-dev lib32z1-dev libelf-dev liblz4-tool \
    libncurses5 libncurses5-dev libsdl1.2-dev libssl-dev libxml2 libxml2-utils lzop \
    openjdk-11-jdk-headless pngcrush rsync schedtool squashfs-tools unzip xsltproc zip \
    zlib1g-dev python3 python-is-python3"
for attempt in 1 2 3; do
    apt-get install -y --no-install-recommends --fix-missing \
        -o Acquire::Retries=5 -o Acquire::http::Timeout=60 $PKGS && break
    echo "apt install attempt $attempt failed"
    if [ "$attempt" = 3 ]; then
        exit 1
    fi
    apt-get -o Acquire::Retries=5 -o Acquire::http::Timeout=60 update
done

git config --global user.name "p80pro-ci"
git config --global user.email "p80pro-ci@localhost"
git config --global --add safe.directory '*'

echo "== installing repo =="
curl -fsSL --retry 3 https://storage.googleapis.com/git-repo-downloads/repo -o /usr/local/bin/repo \
    || curl -fsSL --retry 3 https://mirrors.tuna.tsinghua.edu.cn/git/git-repo -o /usr/local/bin/repo
chmod +x /usr/local/bin/repo

echo "== repo init =="
mkdir -p "$SRC"
cd "$SRC"
repo init -u https://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp.git \
    -b twrp-11 --depth=1
mkdir -p "$SRC/.repo/local_manifests"
cp /workspace/ci/local_manifest.xml "$SRC/.repo/local_manifests/"

echo "== repo sync =="
for i in 1 2 3; do
    if repo sync -c -j"$(nproc)" --force-sync --no-clone-bundle --no-tags; then
        break
    fi
    echo "repo sync attempt $i failed"
    if [ "$i" = 3 ]; then
        exit 1
    fi
done

echo "== copying device tree =="
mkdir -p "$SRC/device/droi"
rm -rf "$DEVICE_DST"
cp -a "$DEVICE_SRC" "$DEVICE_DST"

echo "== building boot.img (recovery-as-boot) =="
source build/envsetup.sh
lunch twrp_p80pro-eng
mka bootimage -j"$(nproc)"

OUT="$SRC/out/target/product/p80pro"
ls -l "$OUT/boot.img"
cp -f "$OUT/boot.img" /workspace/boot.img
chmod 644 /workspace/boot.img
# Pad to the full 32 MiB partition so a stale AVB footer from the previous
# image cannot be read by the bootloader.
BOOT_PART_SIZE=33554432
BOOT_SIZE=$(stat -c%s /workspace/boot.img)
if [ "$BOOT_SIZE" -lt "$BOOT_PART_SIZE" ]; then
    truncate -s "$BOOT_PART_SIZE" /workspace/boot.img
fi
sha256sum /workspace/boot.img | tee /workspace/boot.img.sha256
if [ -f "$OUT/recovery.img" ]; then
    cp -f "$OUT/recovery.img" /workspace/recovery.img
    chmod 644 /workspace/recovery.img
fi

echo "== done =="