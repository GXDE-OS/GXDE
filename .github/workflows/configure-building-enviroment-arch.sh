#!/bin/bash

# Copyright (C) 2026 CharOfString <root@charofstring.cc>
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
# details.
#
# You should have received a copy of the GNU General Public License along with
# this program. If not, see <https://www.gnu.org/licenses/>.
# -----------------------------------------------------------------------------
# 本脚本用于构建GXDE Arch打包环境
#   参数$1 = 架构，可选x86_64/aarch64
#   参数$2 = GXDE仓库地址
#   参数$3 = 源码包仓库地址
#   参数$4 = 当前欲构建的分支
#   参数$5 = GXDE Arch源地址，用于获取GXDE依赖
# -----------------------------------------------------------------------------
# This script is used to configure the packaging environment of GXDE on Arch.
#   $1 = Archtecture required, either x86_64 or aarch64.
#   $2 = GXDE repository address.
#   $3 = Repository path of the software to be built.
#   $4 = The branch that you want to build.
#   $5 = The Arch PACMAN source of GXDE, we'll use it to install dependencies.

set -e
build_arch=$1
bottle_path=./system-bottle
gxde_arch_repo=${5:-https://repo1.gxde.top/gxde-arch}

# 引用/Works Cited: https://patorjk.com/software/taag/#p=display&f=Linguaholic+Shadow+3D
echo '  ██████╗██╗     ██╗██████╗  ████████╗           ████╗                     '
echo '██╔═════╝╚═██╗ ██╔═╝██╔═══██╗██╔═════╝         ██╔═══╝  ████╗  ██╗ ████╗   '
echo '██║ ████╗  ╚═██╔═╝  ██║   ██║██████╗         ██████╗  ██╔═══██╗████╔═══╝   '
echo '██║ ╚═██║  ██╔═██╗  ██║   ██║██╔═══╝         ╚═██╔═╝  ██║   ██║██╔═╝       '
echo '╚═██████║██╔═╝ ╚═██╗██████╔═╝████████╗         ██║    ╚═████╔═╝██║         '
echo '  ╚═════╝╚═╝     ╚═╝╚═════╝  ╚═══════╝         ╚═╝      ╚═══╝  ╚═╝         '
echo '                                                                           '
echo '                                                                           '
echo '  ████╗                    ██╗      ██╗      ██╗                           '
echo '██╔═══██╗██╗ ████╗  ██████╗██████╗  ██║      ╚═╝██████╗  ██╗   ██╗██╗   ██╗'
echo '████████║████╔═══╝██╔═════╝██╔═══██╗██║      ██╗██╔═══██╗██║   ██║╚═████╔═╝'
echo '██╔═══██║██╔═╝    ██║      ██║   ██║██║      ██║██║   ██║██║   ██║  ████║  '
echo '██║   ██║██║      ╚═██████╗██║   ██║████████╗██║██║   ██║╚═██████║██╔═══██╗'
echo '╚═╝   ╚═╝╚═╝        ╚═════╝╚═╝   ╚═╝╚═══════╝╚═╝╚═╝   ╚═╝  ╚═════╝╚═╝   ╚═╝'

# 先安装解压chroot用的依赖 ・ Install the dependencies for extracting chroot first.
sudo apt update
sudo apt install wget zstd git -y

# 根据架构下载解压对应chroot ・ Download & extract corresponding chroot by archtecture needed.
echo '[I] (Chroot) Init: Starting to download chroot for Archlinux...'
if [[ $build_arch == "x86_64" ]]; then
    echo '[I] (Chroot) Init: Archtecture hit >> AMD64.'
    wget -q https://geo.mirror.pkgbuild.com/iso/latest/archlinux-bootstrap-x86_64.tar.zst
    sudo tar --zstd -xpf archlinux-bootstrap-x86_64.tar.zst --numeric-owner
    sudo mv root.x86_64 $bottle_path
    echo 'Server = https://geo.mirror.pkgbuild.com/$repo/os/$build_arch' | sudo tee $bottle_path/etc/pacman.d/mirrorlist
    keyring=archlinux
elif [[ $build_arch == "aarch64" ]]; then
    echo '[I] (Chroot) Init: Archtecture hit >> AARCH64.'
    wget -q http://os.archlinuxarm.org/os/ArchLinuxARM-aarch64-latest.tar.gz
    sudo mkdir -p $bottle_path
    sudo tar -xpf ArchLinuxARM-aarch64-latest.tar.gz -C $bottle_path --numeric-owner
    keyring=archlinuxarm
else
    echo '[E] (Chroot) Init: Unsupportted archtecture $arch, HALTED!'
    exit 1
fi
echo '[I] (Chroot) Init: Done downloading chroot for Archlinux.'

# 挂载chroot ・ Mount chroot.
echo '[I] (Chroot) Mount: Starting to mount target chroot...'
sudo mount --bind $bottle_path $bottle_path
for i in proc sys dev dev/pts; do
    sudo mount --bind /$i $bottle_path/$i
done
sudo cp -L /etc/resolv.conf $bottle_path/etc/resolv.conf
echo '[I] (Chroot) Mount: Done mounting the chroot!'

# Pacman在chroot里无法做沙箱/空间检查
# Pacman is not able to do space check or sandbox in chroot.
echo '[I] (Chroot) PostInit: Disabling sanbox and space check since we are in chroot...'
sudo sed -i 's/^CheckSpace/#CheckSpace/' $bottle_path/etc/pacman.conf
sudo sed -i 's/^#DisableSandbox/DisableSandbox/' $bottle_path/etc/pacman.conf
echo '[I] (Chroot) PostInit: Done disabling unavailable components!'

# 一个小wrapper，在chroot中运行某指令 ・ A wrapper to run certain commands under chroot.
run() {
    sudo chroot $bottle_path bash -c "$*"
}

# 写入GXDE Arch源，以便安装dtk等自身提供的依赖
# 新源刚建立时可能还不存在，因此只做可选信任
# --------------------------------------------
# Add GXDE Archlinux PACMAN source to install dependencies such as DTK.
# It may not exist when as we're just getting started, so we will do a Optional TrustAll.
echo '[I] (Chroot) PACMAN: Configuring GXDE pacman source...'
cat << EOF | sudo tee -a $bottle_path/etc/pacman.conf

[gxde]
SigLevel = Optional TrustAll
Server = $gxde_arch_repo/\$build_arch
EOF
echo '[I] (Chroot) PACMAN: GXDE pacman source has been added to chroot!'
echo '[I] (Chroot) PACMAN: Doing upgrade...'
run pacman-key --init
run pacman-key --populate $keyring
for i in {1..5}; do
    # GXDE 源尚不存在时 -Syu 会失败，此时去掉 GXDE 源再试一次
    if run pacman -Syu --noconfirm --needed base-devel git sudo; then
        break
    fi
    if [[ $i == 3 ]]; then
        echo "GXDE Arch repo unreachable, building without it"
        sudo sed -i '/^\[gxde\]/,/^Server/d' $bottle_path/etc/pacman.conf
    fi
    sleep 2
done
echo '[I] (Chroot) PACMAN: Shall be okay...'

# makepkg不允许以root运行 ・ makepkg require another account other than root.
echo '[I] (Building) AccountCtl: Setting up builder account...'
run useradd -m builder
echo "builder ALL=(ALL) NOPASSWD: ALL" | sudo tee $bottle_path/etc/sudoers.d/builder
echo '[I] (Building) AccountCtl: Builder account is up!'

# 以builder身份克隆仓库 ・ Clone the repo as builder.
echo '[I] (Building) Builder: Cloning target repository...'
run sudo -H -u builder git clone $3 -b $4 /home/builder/$(basename $3)
echo '[I] (Building) Builder: Done cloning target repository.'

echo '[I] (Env) Setup: Setup finished, bye~'
exit 0
