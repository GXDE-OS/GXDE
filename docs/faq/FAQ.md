# Page Under Construction, Continuously Adding Issues and Solutions, PRs Welcome

## Please Click the Star in the Upper Right Corner, Your Support is Our Greatest Motivation

You can track our development progress at https://gitee.com/GXDE-OS/GXDE/board

**[中文](./FAQ.zh.md)**



---

Q1: I have installed Debian 12/I am using Debian 12 on Arm/i386/mips64/loong64 architecture. How can I install GXDE?

A1: Install GXDE by adding repositories.

Repository installation method:

Download the deb file and install it from https://pan.huang1111.cn/s/k2nRvuB.

After installation, run:

```bash
sudo apt update

sudo apt install spark-store -y

sudo aptss install gxde-testing-source -y

sudo aptss install gxde-desktop gxde-desktop-extra -y

```
**There are potential conflict between GXDE and KDE. Don't install them both or maybe something will crash**
---


Q2: How to create a bootable disk?

A2: You can use the [Deepin Boot Maker](https://www.deepin.org/zh/original/deepin-boot-maker/).


---

Q3: NVIDIA driver installation failed by using `sudo aptss install nvidia-driver`

A3: Please manually install the proprietary driver or install the package `linux-kernel-oldstable-gxde-amd64` and boot with this kernel to reinstall.



---
 Q4: What is beta testing? How can I join the beta test?
 
 A4: The latest development progress will be included in the beta test. If you want to experience the latest content, you can join the beta, but it is also unstable. It is recommended that users with some experience join.
 

---

 Q5: I want to develop GXDE-style applications. How do I do that?
 
 A5: Bash/Python script-based applications can use [Garma](https://gitee.com/GXDE-OS/garma). For detailed usage, see: https://help.gnome.org/users/zenity/stable/
 
 A5: For native development, please use Qt/Dtk2. Related code is as follows:
 
 Available feature list: https://gitee.com/GXDE-OS/dtk5core/tree/master/src
 
 Available widget list: https://gitee.com/GXDE-OS/dtk2widget/tree/master/src/widgets

