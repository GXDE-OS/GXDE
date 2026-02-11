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
function useLoongnix() {
    sudo cp .github/workflows/loongnix-stable /usr/share/debootstrap/scripts/ -v
}
function useDeepin25() {
    sudo cp .github/workflows/crimson /usr/share/debootstrap/scripts/ -v
}

sudo apt update
sudo apt install debootstrap rename binfmt-support qemu-user qemu-user-static git -y
ls /usr/bin/qemu-*
bottlePath=./system-bottle
if [[ $2 == "beige" ]]; then
    getd23debootstrap
else
    if [[ $1 == "loong64" ]] && [[ $2 != "loongnix-stable" ]]; then
        useDebianPort
    else
        useLoongnix
    fi
fi
if [[ $2 == "crimson" ]]; then
    useDeepin25
    sudo debootstrap --no-check-gpg --include=git,deepin-keyring,gcc,make,g++,dpkg-dev,qtbase5-dev,ca-certificates --arch=$1 $2 $bottlePath $5
else
    sudo debootstrap --no-check-gpg --include=git,gcc,make,debian-ports-archive-keyring,debian-archive-keyring,g++,dpkg-dev,qtbase5-dev,ca-certificates --arch=$1 $2 $bottlePath $5
fi

if [[ $2 == "crimson" ]]; then
    sudo sed -i "s/main/main commercial community/g" $bottlePath/etc/apt/sources.list
fi
#if [[ $? != 0 ]]; then
#    sudo debootstrap --foreign --include=git,gcc,make,debian-ports-archive-keyring,debian-archive-keyring,g++,dpkg-dev,qtbase5-dev,ca-certificates --arch=$1 $2 $bottlePath $5 
#fi
if [[ $? != 0 ]] && [[ $1 == loong64 ]] && [[ $2 != "loongnix" ]]; then
    sudo apt install squashfs-tools git -y
    wget https://github.com/GXDE-OS/GXDE/releases/download/resources/debian-base-loong64.squashfs
    sudo unsquashfs debian-base-loong64.squashfs
    sudo rm -rf $bottlePath/
    sudo mv squashfs-root $bottlePath -v
fi
sudo bash .github/workflows/pardus-chroot $bottlePath
if [[ $7 == "backport" ]]; then
    sudo cp -rv .github/workflows/debian-backports.list $bottlePath/etc/apt/sources.list.d
    sudo mkdir -p $bottlePath/etc/apt/preferences.d/
    sudo cp -rv .github/workflows/90bookworm-backports $bottlePath/etc/apt/preferences.d/
    echo "deb [trusted=true] https://repo.gxde.top/gxde-os/tianlu-bpo ./" >> $bottlePath/etc/apt/sources.list.d/gxde-os-bpo.list
fi
sudo mkdir -p $bottlePath/sources-list
sudo cp -v .github/workflows/sources-*.list $bottlePath/sources-list
# 配置 git
#echo "deb [trusted=true] https://deb.debian.org/debian-ports/ unreleased main" | sudo tee $bottlePath/etc/apt/sources.list.d/debian-unreleased.list
sudo chroot $bottlePath apt update
sudo chroot $bottlePath apt full-upgrade -y
sudo chroot $bottlePath apt install git -y
sudo chroot $bottlePath git clone $3 #--depth=1
sudo chroot $bottlePath git clone $4 -b $6 #--depth=1
sudo mv $bottlePath/$(basename $3)/.github/workflows/* $bottlePath/$(basename $4)/.github/workflows -v
# 修改版本号
#sudo sed -i "s/) UNRELEASED; urgency=medium/~$2) UNRELEASED; urgency=medium/g" $bottlePath/deep-wine-runner-qemu-system/debian/changelog
case $2 in
    "trixie")
        env gitPath=$(basename $4) bash .github/workflows/run-command-in-chroot.sh .github/workflows/configure-building-enviroment.sh zhuangzhuang
    ;;
    "sid")
        env gitPath=$(basename $4) bash .github/workflows/run-command-in-chroot.sh .github/workflows/configure-building-enviroment.sh zhuangzhuang
    ;;
    "loongnix-stable")
        env gitPath=$(basename $4) bash .github/workflows/run-command-in-chroot.sh .github/workflows/configure-building-enviroment.sh meimei
    ;;
    "crimson")
        env gitPath=$(basename $4) bash .github/workflows/run-command-in-chroot.sh .github/workflows/configure-building-enviroment.sh hetao
    ;;
    *)
        env gitPath=$(basename $4) bash .github/workflows/run-command-in-chroot.sh .github/workflows/configure-building-enviroment.sh
    ;;
esac

exit 0
