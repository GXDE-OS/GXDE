# 页面施工中，仍在不断收录问题和解决方案，欢迎Pr

## 欢迎点右上角Star,您的肯定是我们的最大动力

请在 https://gitee.com/GXDE-OS/GXDE/board 看板处追踪我们的开发进度

[English](./FAQ.md)

---

Q1: 我正在使用古老的电脑/虚拟机，需要使用 Legacy BIOS 启动，而使用 GXDE 安装盘进行安装时报错grub安装失败

A1: 对于 15.13 及以下版本的ISO, Legacy BIOS 暂时只支持用Debian安装器进行安装，在引导界面选择Advanced options后选择Install进行安装

A1: 此问题将会在 15.14 解决

---

Q2: 我已经安装了Debian 12/我在使用Arm/i386/mips64的 Debian 12/loong64架构的debian port,想要安装 GXDE ，我该怎么做？

A2: 加源安装GXDE

加源安装方法

下载deb并安装 https://pan.huang1111.cn/s/k2nRvuB

安装之后 

```bash
sudo apt update

sudo apt install spark-store -y

sudo aptss install gxde-testing-source -y

sudo aptss install gxde-desktop gxde-desktop-extra -y

```

---

Q3: 如何制作启动盘？

A3: Legacy启动推荐rufus用dd模式写入，EFI则使用[深度启动盘制作工具](https://www.deepin.org/zh/original/deepin-boot-maker/)即可


---

Q4: `nvidia-driver`包安装失败

A4: 请手动安装闭源驱动，或者安装 `linux-kernel-oldstable-gxde-amd64 
linux-kernel-oldstable-gxde-amd64` 这个包后用此内核启动重新安装

A4: 您也可[手动安装驱动](https://bbs.deepin.org/post/232923)以避免此问题

---

Q5: 因特尔/螃蟹网卡 安装后无法打开无线网络

A5: `sudo aptss install firmware-iwlwifi firmware-realtek -y`  

A5: 此问题将在 15.14 解决
