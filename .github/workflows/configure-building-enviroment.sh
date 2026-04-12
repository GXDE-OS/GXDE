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
#isUbuntu=$(cat /etc/os-release | grep Ubuntu | wc -l)


if [[ $1 == "" ]] || [[ $1 == "tianlu" ]]; then
    echo "deb [trusted=true] https://repo.gxde.top/gxde-os/tianlu ./" >> /etc/apt/sources.list.d/gxde-os.list
    echo "deb [trusted=true] https://repo.gxde.top/gxde-os/bixie ./" >> /etc/apt/sources.list.d/gxde-os.list
elif [[ $1 == "zhuangzhuang" ]];then
    echo "deb [trusted=true] https://repo.gxde.top/gxde-os/zhuangzhuang ./" >> /etc/apt/sources.list.d/gxde-os.list
    echo "deb [trusted=true] https://repo.gxde.top/gxde-os/lizhi ./" >> /etc/apt/sources.list.d/gxde-os.list
else
    echo "deb [trusted=true] https://repo.gxde.top/gxde-os/$1 ./" >> /etc/apt/sources.list.d/gxde-os.list
fi
#if [[ $(dpkg --print-architecture) == "loong64" ]]; then
#    echo "deb [trusted=true] https://deb.debian.org/debian-ports/ unreleased main" > /etc/apt/sources.list.d/debian-unreleased.list
#fi
apt install -f -y
apt install debian-ports-archive-keyring debian-archive-keyring -y
if [[ -f /sources-list/sources-$1.list ]]; then
    if [[ $(dpkg --print-architecture) == "riscv64" ]]; then
    cp /sources-list/sources-$1-without-backport.list /etc/apt/sources.list.d -v
    else
        cp /sources-list/sources-$1.list /etc/apt/sources.list.d -v
    fi
fi
for i in {1..8};
do
    apt update -o Acquire::Check-Valid-Until=false -y
    if [[ $? == 0 ]]; then
        break
    fi
    sleep 1
done
apt install wget curl dpkg-dev sudo debian-ports-archive-keyring debian-archive-keyring devscripts -y
#neofetch
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
# 解包 gxde-desktop-base

apt download gxde-desktop-base
dpkg -x gxde-desktop-base_*.deb /
rm gxde-desktop-base_*.deb -rfv
if [[ -f /etc/apt/sources.list.d/debian-backports.list ]]; then
    dch --bpo ""
    sed -i "s/~bpo/-bpo/g" debian/changelog
fi
for i in {1..5};
do
    apt build-dep . -y
    if [[ $? == 0 ]]; then
        break
    fi
    sleep 1
done
# 从上游拉源代码
# 从上游拉源代码
./debian/rules get-orig-source

# 收集当前目录和上层目录的所有 .tar* 文件
tar_files=()
if compgen -G "./*.tar*" > /dev/null; then
    tar_files+=( ./*.tar* )
fi
if compgen -G "../*.tar*" > /dev/null; then
    tar_files+=( ../*.tar* )
fi

# 如果找到 tar 文件，则逐个处理
if [ ${#tar_files[@]} -gt 0 ]; then
    for archive in "${tar_files[@]}"; do
        filename=$(basename "$archive")
        echo "处理: $archive"

        # 确定目标目录
        target_dir="."
        if [[ "$filename" =~ -(amd64|arm64)\.tar ]]; then
            arch="${BASH_REMATCH[1]}"
            target_dir="./$arch"
            echo "  架构: $arch → 目标目录: $target_dir"
        else
            echo "  通用包 → 目标目录: 当前目录"
        fi

        mkdir -p "$target_dir"

        # 直接解压到目标目录，去除顶层目录
        if tar -xzvf "$archive" -C "$target_dir" --strip-components=1; then
            echo "  完成: 内容已解压至 $target_dir"
            # （可选）解压成功后删除原始 tar 文件
            # rm "$archive"
        else
            echo "  错误: 解压 $archive 失败，保留原始文件。"
        fi
    done
else
    echo "未找到任何 .tar* 文件，跳过解压步骤。"
fi

exit 0
