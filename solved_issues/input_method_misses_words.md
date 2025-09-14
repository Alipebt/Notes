## 输入法漏字问题解决

跑在Xwayland下的闭源旧式GTK程序，例如Electron应用，会有漏字问题，

可以为每一个程序添加环境变量来解决，不过太麻烦

可以直接修改GTK的配置文件

对于GTK3应用，在`~/.config/gtk-3.0/settings.ini`中添加以下内容：

```shell

gtk-im-module=fcitx

```

GTK4路径为`~/.config/gtk-4.0/settings.ini`,添加内容相同
