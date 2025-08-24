### timeshift 在重复恢复同一快照时会导致系统将快照子卷当作系统子卷
### 此后再也无法恢复任何快照（要么内核崩坏，要么重新回到该快照）

参考[这篇issue](https://github.com/Antynea/grub-btrfs/issues/362)

至今无解且复现率百分比

建议使用`snapper`(快照工具)和 `btrfs-assistant`(GUI界面)

可以不按照教程手动创建`@snapshots`子卷(挂载点：`/.snapshots`)但不太建议。(我也不知道为啥)

一切操作可在其GUI界面设置。
