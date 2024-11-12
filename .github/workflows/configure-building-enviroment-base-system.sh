#!/bin/bash
# $1=arm64
# $2=buster

function getd23debootstrap() {
    git clone https://github.com/deepin-community/debootstrap --depth=1
    cd debootstrap
    sudo apt build-dep . -y
    dpkg-buildpackage -b
    sudo apt install ../*.deb -y --allow-downgrades
    cd ..
    sudo cp deepin-archive-camel-keyring.gpg /etc/apt/trusted.gpg.d/deepin-archive-camel-keyring.gpg -rv
}
function useDebianPort() {
    sudo apt install debian-ports-archive-keyring -y
    sudo cp /usr/share/keyrings/debian-archive-keyring.gpg /usr/share/keyrings/debian-ports-archive-keyring.gpg -v
}

sudo apt update
sudo apt install debootstrap binfmt-support qemu-user qemu-user-static git -y
ls /usr/bin/qemu-*
bottlePath=./system-bottle
if [[ $2 == "beige" ]]; then
    getd23debootstrap
else
    if [[ $1 == "loong64" ]]; then
        useDebianPort
    fi
fi
sudo debootstrap --arch=$1 $2 $bottlePath $5
if [[ $? != 0 ]] && [[ $1 == loong64 ]]; then
    sudo apt install squashfs-tools git -y
    wget https://github.com/GXDE-OS/GXDE/releases/download/resources/debian-base-loong64.squashfs
    sudo unsquashfs debian-base-loong64.squashfs
    sudo rm -rf $bottlePath/
    sudo mv squashfs-root $bottlePath -v
fi
sudo bash .github/workflows/pardus-chroot $bottlePath
if [[ $6 == "backport" ]]; then
    sudo cp -rv .github/workflows/debian-backports.list $bottlePath/etc/apt/sources.list.d
    sudo mkdir -p $bottlePath/etc/apt/preferences.d/
    sudo cp -rv .github/workflows/90bookworm-backports $bottlePath/etc/apt/preferences.d/
fi
# 配置 git
#echo "deb [trusted=true] https://deb.debian.org/debian-ports/ unreleased main" | sudo tee $bottlePath/etc/apt/sources.list.d/debian-unreleased.list
sudo chroot $bottlePath apt update
sudo chroot $bottlePath apt full-upgrade -y
sudo chroot $bottlePath apt install git -y
sudo chroot $bottlePath git clone $3 #--depth=1
sudo chroot $bottlePath git clone $4 #--depth=1
sudo mv $bottlePath/$(basename $3)/.github/workflows/* $bottlePath/$(basename $4)/.github/workflows -v
# 修改版本号
#sudo sed -i "s/) UNRELEASED; urgency=medium/~$2) UNRELEASED; urgency=medium/g" $bottlePath/deep-wine-runner-qemu-system/debian/changelog
env gitPath=$(basename $4) bash .github/workflows/run-command-in-chroot.sh .github/workflows/configure-building-enviroment.sh
exit 0