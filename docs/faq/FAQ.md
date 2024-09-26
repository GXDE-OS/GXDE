# Page Under Construction, Continuously Adding Issues and Solutions, PRs Welcome

## Please Click the Star in the Upper Right Corner, Your Support is Our Greatest Motivation

You can track our development progress at https://gitee.com/GXDE-OS/GXDE/board

**[中文](./FAQ.zh.md)**

---

Q1: I am using an old computer/virtual machine that requires Legacy BIOS booting, but I encounter a grub installation failure when installing with the GXDE installation disk.

A1: For ISO versions 15.13 and below, Legacy BIOS currently only supports installation using the Debian installer. Select "Advanced options" on the boot screen and then choose "Install."

A1: This issue will be resolved in version 15.14.

---

Q2: I have installed Debian 12/I am using Debian 12 on Arm/i386/mips64/loong64 architecture. How can I install GXDE?

A2: Install GXDE by adding repositories.

Repository installation method:

Download the deb file and install it from https://pan.huang1111.cn/s/k2nRvuB.

After installation, run:

```bash
sudo apt update

sudo apt install spark-store -y

sudo aptss install gxde-testing-source -y

sudo aptss install gxde-desktop gxde-desktop-extra -y

```

---


Q3: How to create a bootable disk?

A3: For Legacy boot, it is recommended to use Rufus in DD mode. For EFI, you can use the [Deepin Boot Maker](https://www.deepin.org/zh/original/deepin-boot-maker/).


---

Q4: NVIDIA driver installation failed by using `sudo aptss install nvidia-driver`

A4: Please manually install the proprietary driver or install the package `linux-kernel-oldstable-gxde-amd64` and boot with this kernel to reinstall.

--

Q5: Intel/Crab network card cannot enable wireless after installation.

A5: Run sudo aptss install firmware-iwlwifi firmware-realtek -y.

A5: This issue will be resolved in version 15.14.

---
 Q6: What is beta testing? How can I join the beta test?
 
 A6: The latest development progress will be included in the beta test. If you want to experience the latest content, you can join the beta, but it is also unstable. It is recommended that users with some experience join.
 
 A6: Starting from version 15.14, you can join the beta test with one click in the Control Center. For details, see: https://www.bilibili.com/video/BV1FgsvenEjq
 
 A6: For versions 15.13 and below, please run `sudo aptss install gxde-testing-source -y`

---

 Q7: I want to develop GXDE-style applications. How do I do that?
 
 A7: Bash/Python script-based applications can use [Garma](https://gitee.com/GXDE-OS/garma). For detailed usage, see: https://help.gnome.org/users/zenity/stable/
 
 A7: For native development, please use Qt/Dtk2. Related code is as follows:
 
 Available feature list: https://gitee.com/GXDE-OS/dtk5core/tree/master/src
 
 Available widget list: https://gitee.com/GXDE-OS/dtk2widget/tree/master/src/widgets

