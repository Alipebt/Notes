### SDDM导致黑屏

对于 SDDM 显示管理器（SDDM 是 KDE 的默认 DM）：

在文件`/usr/share/sddm/scripts/Xsetup`中添加：

```shell
xrandr --setprovideroutputsource mode
setting NVIDIA-0 
xrandr --auto
```
