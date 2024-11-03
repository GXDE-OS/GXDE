#!/bin/bash
export DEBIAN_FRONTEND=noninteractive  # 防止卡 tzdate
#mkdir -p /etc/apt/sources.list.d/
#cp /etc/apt/sources.list /etc/apt/sources.list.d/sources.list
#sed -i "s/deb /deb-src /g" /etc/apt/sources.list.d/sources.list
#cat /etc/apt/sources.list
#cat /etc/apt/sources.list.d/sources.list
# 判断系统版本
#cat /etc/issue | grep 12
#if [[ $? == 0 ]]; then  
#    echo "deb-src http://deb.debian.org/debian bookworm main" > /etc/apt/sources.list.d/debian-sources.list
#fi
#cat /etc/issue | grep sid
#if [[ $? == 0 ]]; then  
#    echo "deb-src http://deb.debian.org/debian sid main" > /etc/apt/sources.list.d/debian-sources.list
#fi
# 写入 GXDE 源
# 判断是否是 Ubuntu
isUbuntu=$(cat /etc/os-release | grep Ubuntu | wc -l)
if [[ $isUbuntu -gt 1 ]]; then
    echo "deb [trusted=true] https://repo1.gxde.top/gxde-os/hetao ./" >> /etc/apt/sources.list.d/gxde-os.list
else
    echo "deb [trusted=true] https://repo1.gxde.top/gxde-os/tianlu ./" >> /etc/apt/sources.list.d/gxde-os.list
    echo "deb [trusted=true] https://repo1.gxde.top/gxde-os/bixie ./" >> /etc/apt/sources.list.d/gxde-os.list
fi
if [[ $(dpkg --print-architecture) == "loong64" ]]; then
    echo "deb [trusted=true] https://packages.gxde.org/debian-loong64/ unreleased main" > /etc/apt/sources.list.d/debian-unreleased.list
fi
apt install debian-ports-archive-keyring debian-archive-keyring -y
for i in {1..8};
do
    apt update -o Acquire::Check-Valid-Until=false -y
    if [[ $? == 0 ]]; then
        break
    fi
    sleep 1
done
apt install dpkg-dev sudo neofetch debian-ports-archive-keyring debian-archive-keyring -y
neofetch
#if [[ `arch` != "x86_64" ]]; then
#    apt source qemu
#    cd qemu-*/
#    sed -i "s/gcc-s390x-linux-gnu,//g" debian/control
#    sed -i "s/gcc-alpha-linux-gnu,//g" debian/control
#    sed -i "s/gcc-sparc64-linux-gnu,//g" debian/control
#    sed -i "s/gcc-powerpc64-linux-gnu,//g" debian/control
#    sed -i "s/gcc-hppa-linux-gnu,//g" debian/control
#    sed -i "s/gcc-riscv64-linux-gnu,//g" debian/control
#    apt build-dep . -y
#    cd ..
#fi
#apt build-dep qemu -y
# 如果是 Debian10 就需要安装 Python3 的依赖
#apt build-dep python3.7 -y
for i in {1..5};
do
    apt build-dep . -y
    if [[ $? == 0 ]]; then
        break
    fi
    sleep 1
done
exit 0
