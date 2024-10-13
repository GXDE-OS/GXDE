# How to Install GXDE?
## Image Installation

**[中文](./Install.zh.md)**

Multiline download(Recommended): https://repo-gxde.gfdgdxi.top/ISO/15.14/amd64/GXDE-OS_15.14_amd64.iso.torrent

huang111: https://pan.huang1111.cn/s/laonjFL

Sourceforge: https://sourceforge.net/projects/gxde-os/files

GXDE is not perfect，please confirm [FAQ](faq.md) before installation，containing Nvidia Graphic Card driver installation help. 

---

For Beginners: If you don't know how to partition, leave some space on a disk and select to install on the whole disk during installation.

EFI Installation: You must create a partition formatted as vfat/fat32 with the mount point set to /boot/efi. The remaining space can be partitioned as needed.

## APT Repository Installation
> For amd64, arm64, etc., where ISO installation images are available, it is recommended to use ISO installation.  
> Currently supports amd64, arm64, mips64, and loong64, but loong64 has not been tested.

Download the deb file and install it from https://pan.huang1111.cn/s/k2nRvuB.

After installation, run:

```bash
sudo apt update

sudo apt install spark-store -y

sudo aptss install gxde-testing-source -y

sudo aptss install gxde-desktop gxde-desktop-extra -y
```

Then restart.

## Install on Termux PRoot or other Android devices

Check: https://bbs.deepin.org.cn/post/279414