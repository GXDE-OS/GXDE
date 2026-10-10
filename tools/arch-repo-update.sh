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
# 本脚本用于向GXDE Arch源上传包并更新数据库，由building-pkg.yml自动调用
#   用法：
#     arch-repo-update.sh <x86_64|aarch64> <arch-xxx.tar>
#   依赖：
#     repo-add (Archlinux自带；Debian上需要安装pacman-package-manager)
#   环境变量：
#     GXDE_ARCH_REPO_ROOT  源根目录，对外地址为 https://repo1.gxde.top/gxde-arch/$arch
#     GXDE_ARCH_GPG_KEY    可选，设置后对包和数据库进行签名
# -----------------------------------------------------------------------------
# This script updates the artifacts in GXDE pacman source and is invoked by
# building-pkg.yml automatically.
# Usage:
#   arch-repo-update.sh <x86_64|aarch64> <arch-xxx.tar>
# Dependencies:
#   repo-add (Archlinux built-in; on Debian, install pacman-package-manager)
# Environment variables:
#   GXDE_ARCH_REPO_ROOT  The root directory of the source, externally accessible at
#                        https://repo1.gxde.top/gxde-arch/$arch
#   GXDE_ARCH_GPG_KEY    Optional, if set, will sign the packages and database.

set -e
arch=$1
tar_path=$2
repo_root=${GXDE_ARCH_REPO_ROOT:-/var/www/repo/gxde-arch}
repo_name=gxde

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

case $arch in
    x86_64|aarch64) ;;
    *) echo "Unsupported arch: $arch"; exit 1 ;;
esac

if [[ ! -f $tar_path ]]; then
    echo "$tar_path not found"
    exit 1
fi

repoDir=$repo_root/$arch
mkdir -p $repoDir
exec 9> $repoDir/.lock
flock 9

tmpDir=$(mktemp -d)
trap "rm -rf $tmpDir" EXIT
tar -xf $tar_path -C $tmpDir

newPackages=()
for pkg in $tmpDir/*.pkg.tar.*; do
    [[ $pkg == *.sig ]] && continue
    name=$(basename $pkg)
    mv -f $pkg $repoDir/$name
    if [[ -n $GXDE_ARCH_GPG_KEY ]]; then
        rm -f $repoDir/$name.sig
        gpg --batch --yes -u $GXDE_ARCH_GPG_KEY --detach-sign --no-armor $repoDir/$name
    fi
    newPackages+=($repoDir/$name)
done

if [[ ${#newPackages[@]} == 0 ]]; then
    echo "No package in $tar_path"
    exit 1
fi

signArgs=()
if [[ -n $GXDE_ARCH_GPG_KEY ]]; then
    signArgs=(--sign --key $GXDE_ARCH_GPG_KEY)
fi

repo-add -R "${signArgs[@]}" $repoDir/$repo_name.db.tar.gz "${newPackages[@]}"
rm -f $tar_path