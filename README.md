# Arch Linux 无法启动解决过程记录

(<u>以下均以我的Arch Linux为准</u>)

这一切的起因是`yay -Syu`。（在执行该命令时千万不要手贱关机！！！）

我一共遇到两种情况：

1. 启动`Linux`时一直卡在`clean...files, ...block`界面，当时甚至无法打开`tty2`。
2. 通过`grub`进入`Linux`时，显示`error: file /vmlinuz-linux-lts not found. you need to load the kernel first`  ，然后按下任意键就直接退出。(此情况可以先尝试更新grub配置，具体方法本文不再论述)

`1`当时查看日志没记错的话是内核冲突/出问题了，`2`甚至找不到内核，也试过更新grub，都没用，最后只好重装内核了。

## 一. 安装前的准备

### 1. 下载安装镜像

安装镜像 iso 在开源镜像站（推荐）或者 [archlinux 官方下载页面open in new window](https://archlinux.org/download/) 下载。