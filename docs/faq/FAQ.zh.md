# 页面施工中，仍在不断收录问题和解决方案，欢迎Pr

## 欢迎点右上角Star,您的肯定是我们的最大动力

请在 https://gitee.com/GXDE-OS/GXDE/board 看板处追踪我们的开发进度

**[English](./FAQ.md)**



---

Q1: 我已经安装了Debian 12/我在使用Arm/i386/mips64的 Debian 12/loong64架构的debian port,想要安装 GXDE ，我该怎么做？

A1: 加源安装GXDE

加源安装方法

下载deb并安装 https://repo-gxde.gfdgdxi.top/gxde-os/bixie/g/gxde-source/

安装之后 

```bash
sudo apt update

sudo apt install spark-store -y

sudo aptss install gxde-testing-source -y

sudo aptss install gxde-desktop gxde-desktop-extra -y

```

**GXDE与KDE有可能的冲突，请不要同时安装它们，这可能会带来错误**

---

Q2: 如何制作启动盘？

A2: 使用[深度启动盘制作工具](https://www.deepin.org/zh/original/deepin-boot-maker/)即可


---

Q3: `nvidia-driver`包安装失败

A3: 请手动安装闭源驱动，或者安装 `linux-kernel-oldstable-gxde-amd64 
linux-kernel-oldstable-gxde-amd64` 这个包后用此内核启动重新安装

A3: 您也可[手动安装驱动](https://bbs.deepin.org/post/232923)以避免此问题



---

Q4: 什么是内测？ 我想要加入内测该怎么做？

A4: 最新的开发进度会加入内测中，想要体验最新的内容可加入内测，但是内测同样不稳定，建议有一定基础的用户加入

A4: 15.14 开始，可在控制中心一键加入内测， 详见： https://www.bilibili.com/video/BV1FgsvenEjq

A4: 请加入我们的QQ群来反馈: 881201853

---

Q5: 我想开发 GXDE 风格的应用，我该怎么做

A5: 使用bash/python脚本的应用可以使用 [Garma](https://gitee.com/GXDE-OS/garma),使用方法详见： https://help.gnome.org/users/zenity/stable/ 

A5: 原生开发请使用 Qt/Dtk2 相关代码如下： 

可用功能列表： https://gitee.com/GXDE-OS/dtk5core/tree/master/src

可用控件列表： https://gitee.com/GXDE-OS/dtk2widget/tree/master/src/widgets