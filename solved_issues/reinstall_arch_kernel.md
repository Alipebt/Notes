# Arch Linux 重新安装内核

(<u>以Arch Linux为准</u>)

我一共遇到两种情况：

1. 启动`Linux`时一直卡在`clean...files, ...block`界面，当时甚至无法打开`tty2`。
2. 通过`grub`进入`Linux`时，显示`error: file /vmlinuz-linux-lts not found. you need to load the kernel first`  ，然后按下任意键就直接退出。(此情况可以先尝试更新grub配置，具体方法本文不再论述)

（懒得找具体原因，所以直接重装内核好了）

## 一. 安装前的准备

### 1. 下载安装镜像

安装镜像 `iso` 在开源镜像站（推荐）或者 [archlinux官方下载页面](https://archlinux.org/download/) 下载。

下面是国内常用的提供 archlinux 安装镜像的开源镜像站（选一个即可）：

- [中国科学技术大学开源镜像站](http://mirrors.ustc.edu.cn/)
- [清华大学开源软件镜像站](https://mirrors.tuna.tsinghua.edu.cn/)
- [华为开源镜像站](https://repo.huaweicloud.com/archlinux/)
- [兰州大学开源镜像站](https://mirror.lzu.edu.cn/archlinux/)

### 2. 刻录安装U盘

`Windows`下推荐使用 [Ventoy](https://www.ventoy.net/cn/doc_start.html)、[Rufus](https://rufus.ie/) 进行U盘刻录。

`Linux`下推荐使用`Ventoy`。

### 3. 挂载，启动U盘，进入硬盘系统

U盘启动进去后挂载根分区和启动分区，然后`arch-chroot`到根分区。

以下操作均在启动盘执行：

```shell
lsblk 
#或
fdisk -l
#查看分区情况
```

找到`/boot`和`/`所在的分区，并挂载

```shell
mount /dev/${/} /mnt	#挂载根分区
mount /dev/${/boot} /mnt/boot	#挂载boot分区
```

> `/boot`大小一般是在`260MB~300MB`之间，`/`一般是磁盘大小的`1/4`，最初安装`arch`的时候分出来的分区一般编号是较大的，如我的机器上：`/`和`/boot`分区磁盘号分别为`nvme0n1p5`和`nvme0n1p6`。

挂载好后进入硬盘系统：

```shell
arch-chroot /mnt
```

### 3. 安装内核，生成grub

可以通过以下命令查看内核是否存在：

```shell
ls /boot
#检查是否有以下文件：
#initramfs-linux.img
#vmlinuz-linux
```

如果没有，则重装`Linux`：

```shell
pacman -S linux #或linux-lts
```

对于有安装其他系统，还需执行：

```shell
pacman -S os-prober
sudo os-prober #查找系统
```

重新生成引导区：

```shell
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg
```

回到启动盘：

```shell
exit
```

重新生成分区挂载配置文件，否则系统无法启动：

```shell
rm -rf /mnt/etc/fstab
genfstab -U /mnt >> /mnt/etc/fstab
```

关机，拔掉U盘，重启。

```shell
poweroff
```

