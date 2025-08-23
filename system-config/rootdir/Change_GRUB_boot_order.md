### 更改自动生成的`grub`选项顺序

### （如输入命令生成，使用`timeshift`和`grub-btrfs`自动生成等）

在目录 `/etc/grub.d/` 下

`README.md`:

```shell
本目录中的所有可执行文件均按Shell扩展顺序处理。

00_：保留给00_header使用
10_：原生启动项
20_*：第三方应用程序（如memtest86+）

中间的数字命名空间可由系统安装程序和/或管理员进行配置。例如，您可以根据期望在菜单中显示的位置，添加01_otheros、11_otheros等条目来启动其他操作系统，随后通过/etc/default/grub文件调整默认设置。
```

要改变生成顺序可以将该目录下文件重命名，顺序为名称前方的编号，从`00~99`的顺序先后调用。

**如**：

```shell
> ls
00_header  10_linux  20_linux_xen  25_bli  30_os-prober  30_uefi-firmware  40_custom  41_custom  41_snapshots-btrfs 
```

可以将 `30_os-prober` 重命名为 `05_os-prober`。

```shell
sudo mv 30_os-prober 05_os-prober #重命名
```

 这个操作会改变该脚本在 GRUB 菜单中的生成顺序和位置。

- **当前状态 (30_)**: `os-prober` 脚本会在 `10_linux`（检测本机 Linux 系统）和 `20_linux_xen` 之后执行。它发现的其他操作系统（如 Windows）的启动项会显示在这些本机 Linux 项之后。
- **更改后 (05_)**: `os-prober` 脚本会在 `00_header` 之后、`10_linux` 之前执行。它发现的其他操作系统的启动项将**显示在**本机 Linux 项之前。