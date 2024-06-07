---
title: 记SSD挂掉后ESXI及DSM虚拟机的数据拯救
date: 2018-04-17 11:23:31
updated: 2018-04-17 06:15:02
tags: 
- Linux
- ESXI
- DSM
- "GNU Tools"
---
## 情景
　　2018年3月22日(星期四) 晚上11:05，收到跑在ESXI上的DSM虚拟机ptbsare-nas发来的邮件通知如下：
```
亲爱的用户：

ptbsare-nas 上的 RAID Group 2 (Basic, ext4) 已损毁。系统可能无法启动。

欲取得进一步的帮助，请联络 Synology 在线支持中心：http://www.synology.com。

您诚挚的，
Synology DiskStation
```
　　紧接着又收到邮件通知：
```
亲爱的用户：

ptbsare-nas 上的系统卷（Swap）已进入堪用模式。（硬盘驱动器总数：12；活动的硬盘驱动器数：1）

请重新启动系统，系统将在启动时自动修复。

您诚挚的，
Synology DiskStation
```
　　当时虚拟机的硬件配置如下：
```
CPU:INTEL J3455 (vt-d)
SSD:SANDISK Z400S 128GB
PCIE-STORAGE-CONTROLLER:ASMEDIA 1062 SATA X2 (paththrough ptbsare-nas)
```
　　`ESXI`上的一块`SANDISK SSD`做主存储池放置若干虚拟机的虚拟硬盘，机械硬盘全部通过`PCIE`扩展直通连接`DSM`虚拟机`ptbsare-nas`。
## 拆下磁盘
　　由于虚拟机的`RAID Group 2`是运行在`ESXI`上的虚拟硬盘而并非实际做备份数据主存储的机械硬盘，因此大概知道是`ESXI`的数据存储区介质`SSD`出了问题。果不其然，使用`Watchlist`登入`ESXI`在`EVENT`里面发现了这么一条：
```
Device or filesystem with identifier device_ID has entered All Paths Down state.
```
　　并且此时`ESXI`反应异常的慢，过了一会儿，`Watchlist`被迫退出；尝试`ping`上面跑的虚拟机，完全`ping`不通，`ESXI`管理网络端口暂时还能`ping`通，但网页端已经无法登入(`Connection Refused`)。
　　无奈强制硬重启主机，启动后`ESXI`网页端可以进入了，但是发现主储存区已经消失，系统没有存储区，上面的若干台虚拟机全部失效。`SSH`进去也未发现该`SSD`磁盘，那么此时只能断定`SSD`是挂掉不认盘了，关机，关电源，点开机键放电后取下`SSD`插到自己另一台PC主机上，开机进入PC主机的`Manjaro`系统，好在还能看到该磁盘，赶紧使用`dd`镜像下来：
```bash
sudo dd if=/dev/sdd of=esxi_123.img bs=8M
```
　　那么就得到了一个大小为`120GB`的磁盘镜像`esxi_123.img`。（咦，为何是120GB，该磁盘标称128GB，当时觉得奇怪，疑似假盘。）
　　然后就可以安心关机取下该硬盘放到一边了。
## 数据拯救
### VMFS数据拯救
　　由于`ESXI`的存储池使用的是专有文件系统`VMFS`，在`Linux`下无法通过`mount`命令直接挂载：
```bash
~/下载 >>> fdisk -l -u esxi_123.img
Disk esxi_123.img：111.8 GiB，120034123776 字节，234441648 个扇区
单元：扇区 / 1 * 512 = 512 字节
扇区大小(逻辑/物理)：512 字节 / 512 字节
I/O 大小(最小/最佳)：512 字节 / 512 字节
磁盘标签类型：gpt
磁盘标识符：67550ED7-A3AF-47BA-AA47-8B5558C26392

设备          起点      末尾      扇区   大小 类型
esxi_123.img2  128 234441608 234441481 111.8G VMware VMFS
```
　　需要首先安装`vmfs-tools`这个工具进行文件系统挂载，`Archlinux`或`Manjaro`下可以用如下命令安装：
```bash
yaourt -S vmfs-tools
```
　　安装后，首先计算该磁盘第一个`VMFS`分区的起点偏移量，即拿单元字节`512`乘以分区起点单元号`128`：
```bash
~/下载 >>> expr 128 \* 512
65536
```
　　然后可以使用`losetup`进行虚拟设备挂载，使用`-o`选项指定偏移量`offset`：
```bash
sudo losetup -o 65536  /dev/loop1 esxi_123.img
```
　　然后挂载文件系统（同时注意`vmfs-tools`只是`vmfs`的一个开源实现，目前只能支持只读挂载，并不能写入`VMFS`分区）：
```bash
sudo vmfs-fuse /dev/loop1 /mnt
```
　　接着，我们以`root`进入`/mnt`就可以看到大量文件及虚拟机磁盘：
```bash
~/下载 >>> su                                                                         [1]
密码：
[root@ptbsare-pc506 下载]# cd /mnt
[root@ptbsare-pc506 /mnt]# ls
 backup   DSM6	    ptbsare-manjs   ptbsare-win10    XPEnology
 DSM	  Manjaro   ptbsare-nas    'Ubuntu Server'
```
　　先将这些虚拟机目录及磁盘拷贝出来再做恢复吧。
### 虚拟磁盘数据拯救
#### 打包服务器
　　由于拷贝出来的是若干个`vmdk`文件，因此还是一样的思路，首先用`fdisk`判断磁盘分区信息，然后计算偏移量挂载。这里以`ptbsare-manjs`为例，该虚拟机是一个用来做`Archlinux`编译打包服务器的虚拟机，主磁盘用的是`ext4`文件系统
```bash
sudo umount /mnt
fdisk -l -u ptbsare-manjs_0-flat.vmdk
sudo mount -o rw,loop,offset=537919488 ptbsare-manjs_0-flat.vmdk /mnt
sudo cp -a /mnt/* ptbsare-manjs_root/
```
　　后来这个磁盘绝大多数数据都能拷贝出来，有几个无关紧要的系统文件提示丢失，算是万幸没有数据损失。
#### 壁纸服务器BTRFS数据恢复
##### DSM的RAID一致性检查
　　另一个做`SMB`共享的壁纸服务器就不妙了，里面有若干千张壁纸，使用的文件系统是`BTRFS`，在拷贝的时候发现大量`Input/Output Error`，遂停止拷贝，先行恢复文件系统。首先做好原`vmdk`的备份，由于这个时候已经到货了一个新的固态硬盘，所以就新建虚拟机带着这个`vmdk`使用`Manjaro`的`LiveCD`启动做恢复了。
　　倘若该`BTRFS`分区是阵列的一部分（例如`DSM`的默认行为），在系统启动后，倘若是比较新的内核可以用如下命令进行`RAID`一致性检查并修复错误：
```bash
sudo echo check > /sys/block/mdX/md/sync_action
```
　　并且使用如下命令确定是否检查完毕：
```bash
echo cat /sys/block/mdX/md/sync_completed
```
##### BTRFS文件系统错误恢复
　　如果直接挂载成功那么可以下一步了。如果默认挂载不成功的话，我们首先尝试recovery挂载：
```
sudo mount -t btrfs -o recovery,ro /dev/<device_name> /<mount_point>
```
　　使用`btrfs restore`先尝试恢复出来文件：
```bash
sudo btrfs restore /dev/<device_name> ~/btrfs_data_restore
```
   在可写挂载后，可以尝试修复文件系统错误（直接写入磁盘，慎用，先做好备份）：
```bash
sudo btrfs check --repair /dev/<device_name>
sudo btrfs scrub start -Bf /dev/<device_name>
sudo btrfs rescue zero-log /dev/<device_name>
```
　　最后觉得修复效果并不理想，索性放弃，该卷最终永久损失了`33`张壁纸。
## 题外后记
　　后经查证发现售卖损坏`SSD`的淘宝店铺改为卖衣服的了，无任何售后，官网查证为假冒产品。
## 经验教训
* 重要数据不能放到`SSD`里面，因为`SSD`在挂掉之前毫无征兆且挂掉之后很有可能即全盘皆丢失，难以恢复。放`SSD`的数据即做好随时丢失的心理准备。重要数据必须放`SSD`的觉得应该组建`RAID1`以保证可靠性。
* 重要数据还是尽量不要用`BTRFS`文件系统，使用更成熟的`ext4`，实测相比之下`BTRFS`虽然有快照、子卷等花哨功能，但数据恢复难度极大，很容易丢数据，`ext4`就好许多。
* 购买`SSD`还是要在官网真伪验证，购买联保品牌如`SanDisk`、`INTEL`等，店保一点不可靠。
