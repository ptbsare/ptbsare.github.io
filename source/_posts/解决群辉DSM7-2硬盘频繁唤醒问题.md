---
title: 解决群晖DSM7.2硬盘频繁唤醒问题
date: '2025-04-16 09:51:58'
updated: '2025-04-16 09:51:58'
tags: 
- Tips
- DSM
---
## 前言
&emsp;群晖的nas系统一直以用户界面易用著称，但是有个问题一直困扰便是群晖的硬盘休眠唤醒问题，个人认为对于机械硬盘来讲应要么禁用唤醒功能，要么应保持长时间休眠状态，频繁的休眠唤醒启动对硬盘故障率可能有一定影响。本文考虑在**家用**条件下应尽可能让硬盘保持休眠以获得最低的功耗和耗电量。我的群晖型号是`DS918+`，已经是几年前的型号了，平时只用来做资料储存，仅安装了`Synology Photos`套件作为全家家庭相册和`HyperBackup`套件作为备份实现资料的321多重备份储存。并无安装docker，即便在仅仅安装两个套件的情况下出现频繁唤醒问题，足以看出官方系统对于硬盘的休眠是完全不重视的状态。下面只能自行hack解决。
## 大前提
&emsp;个人的nas安装了两个`nvme`的固态硬盘创建存储区专门存储应用数据、安装套件位置；想要实现机械硬盘休眠的一个大前提便是你需要将docker应用数据、套件等安装在一个固态储存介质的储存区上，这样做有增加应用套件数据库文件等随机读写性能和实现机械硬盘休眠两个好处；首先应实现机械硬盘可以休眠的大前提，我们再来讨论减少唤醒频率以实现长时间的连续休眠。本人利用[007revad/Synology_HDD_db](https://github.com/007revad/Synology_HDD_db)实现`nvme`硬盘创建存储区。
## 问题根源
&emsp;群晖频繁唤醒问题简单来讲根源在于其`md0`阵列的结构，群晖默认在每个硬盘上划分出一块分区组`raid1`即`/dev/md0`挂载为根分区，这一设计当然有其优点，即任一单硬盘即可保存配置完整的启动系统，但是缺点是对于任意根分区的读写都会即刻同步到所有硬盘造成读写，这样的读写多数时间是在写一些例如日志文件、临时的数据库文件等等，绝大多数读写都是不必要的读写，提高了功耗；这些临时文件重要性不能说完全没有，只能说微乎其微，甚至根分区上的系统文件本身的重要性都是微乎其微，绝大多数家用环境人们只会在意数据存储区的数据，至于系统配置文件可以通通过定期备份解决，日志、临时文件我估计许多人几年都不会看一下，我只在排查休眠问题的时候才看下`/var/log`里面的日志，把系统提到这样高的重要等级以至于每份硬盘都存一份系统这样的设计我个人认为是意义不明的设计。完全可以找两个ssd介质的硬盘组`raid1`储存系统，可靠性足矣；或者可以给用户以选项选择系统是否需要在每个硬盘上存一份或者可选在哪个硬盘上存。
## 主流做法
&emsp;遇到这样的问题，网络上的主流做法无非是定期将机械硬盘从`/dev/md0`剔除，然后再指定时间定期同步，这么做系统可能会提示系统分区异常（未测试），不太优雅；那么本文此次详细找出到底是什么读写在阻止长时间休眠。
## 排查休眠日志
&emsp;首先应在群晖的技术支持中心套件里面启用硬盘休眠日志，关闭所有网页和网络文件共享静置一段时间，通常是一天左右，然后ssh登录nas，正常会在`/var/log`目录下生成`hibernationFull.log`，此文件相当长，我们需要先过滤无关读写。
### 无关读写1
&emsp; 对于`tmpfs`和`proc`的读写不会唤醒磁盘，可以剔除。
### 无关读写2
&emsp; 对于`nvme`磁盘的读写一般不会唤醒磁盘，可以剔除。
### 无关读写3
&emsp; 对于`dm-x`设备的读写，区分讨论，我的nas有一个两个`nvme`组`raid1`的存储区，它在群晖里面的结构是device mapper（`dm-x`）的格式，首先找到存储区编号，我的是`volume3`，使用`mount`命令输出所有挂载，找到`volume3`对应的是什么设备，我的是`cachedev_0`，使用`lvdisplay`找到对应的`dm-x`（最后冒号后面的数字），我的是`dm-2`。因此，日志里面所有对于`dm-2`的读写一般不会唤醒硬盘，可以剔除。
### 无关读写4
&emsp; 对于硬盘唤醒后硬盘唤醒本身触发的读写应忽略，一个经典的例子是硬盘唤醒后，`scemd`进程会实时调整指示灯等并将相关事件写入日志，这样的读写是硬盘唤醒本身导致的，并不是硬盘唤醒的原因，应该忽略这些日志。
### 无关读写5
&emsp; 硬盘唤醒之后相关一系列的读写可以不必多关注，我们重点一般只关注造成硬盘唤醒的首次读写分析其来源即可。
### 日志过滤总结
&emsp; 用以下脚本过滤以上这些无关日志到新日志文件(把`dm-2`替换成你对应纯SSD的存储区`dm-x`)：
```bash
sudo awk '!/tmpfs|proc|loop|dm-2|sysfs|nvme/' /var/log/hibernationFull.log > /tmp/hibernationFullslim.log && vim /tmp/hibernationFullslim.log
```
### 日志分析
&emsp; 剩余日志大致可以分为两类，一类是对于`/dev/md0`的读写，另一类是除了以上纯SSD设备的`dm-x`设备（机械硬盘存储区）（挂载设备`/dev/mapper/cachedev_N`）的读写，日志里面写明了文件系统（并非设备本身例如`sdx`设备的那条读写记录）读写的`block`号，我个人用的是`ext4`文件系统，可以用以下脚本找到对应读写的文件(有可能当时读写的文件已经删除显示找不到)。
```bash
#!/bin/bash

# slim hibernation.log 
# sudo awk '!/tmpfs|proc|loop|dm-2|sysfs|nvme/' /var/log/hibernationFull.log > /tmp/hibernationFullslim.log && vim /tmp/hibernationFullslim.log

#./showblock rev.02 rewritten for question/answer from: https://stackoverflow.com/q/52058914/10239615

#----
bytes_per_sector=512 #assumed that dmesg block numbers are 512 bytes each (ie. 512 bytes per sector; aka block size is 512)!
#----

#use `sudo` only when not already root
if test "`id -u`" != "0"; then
    sudo='sudo'
else
    sudo=''
fi

if ! test "$#" -ge "2"; then
  echo "Usage: $0 <device> <dmesgblocknumber> [dmesgblocknumber ...]"
  echo "Examples:"
  echo "$0 /dev/xvda3 5379184"
  echo "$0 /dev/xvda3 5379184 5129952 7420192"
  exit 1
fi

within_exit() {
  echo -e "\nSkipped current instruction within on_exit()"
}
on_exit() {
  #trap - EXIT SIGINT SIGQUIT SIGHUP  #will exit by skipping the rest of all instrunction from on_exit() eg. if C-c
  trap within_exit EXIT SIGINT SIGQUIT SIGHUP #skip only current instruction from on_exit() eg. when C-c is pressed
  #echo "first sleep"
  #sleep 10
  #echo "second sleep"
  #sleep 10
  if test "${#remaining_args[@]}" -gt 0; then
    echo -n "WARNING: There are '${#remaining_args[@]}' remaining args not processed, they are: " >&2
    for i in `seq 0 1 "$(( "${#remaining_args[@]}" - 1 ))"`; do  #seq is part of coreutils package
      echo -n "'${remaining_args[${i}]}' " >&2
    done
    echo >&2
  fi
}

trap on_exit EXIT SIGINT SIGQUIT SIGHUP

dev="$1"
shift 1

if test -z "$dev" -o ! -b "$dev"; then
  echo "Bad device name or not a device: '$dev'" >&2
  exit 1
fi

blocksize="`$sudo blockdev --getbsz "$dev"`"
if test "${blocksize:-0}" -le "0"; then #handles empty arg too
  echo "Failed getting block size for '$dev', got '$blocksize'" >&2
  exit 1
fi
#TODO: check and fail if not a multiplier
divider="$(( $blocksize / $bytes_per_sector ))"
if ! test "${divider:-0}" -gt "0"; then
  echo "Failed computing divider from: '$blocksize' / '$bytes_per_sector', got '$divider'" >&2
  exit 1
fi

# for each passed-in dmesg block number do
while test "$#" -gt "0"; do
dmesgblock="$1"
shift
remaining_args=("$@") #for on_exit() above
echo '--------'
echo "Passed-in dmesg block($bytes_per_sector bytes per block) number: '$dmesgblock'"
#have to handle the case when $dmesgblock is empty and when it's negative eg. "-1" so using a default value(of 0) when unset in the below 'if' block will help not break the 'test' expecting an integer while also allowing negative numbers ("0$dmesgblock" would otherwise yield "0-1" a non-integer):
if test "${dmesgblock:-0}" -le "0"; then
  echo "Bad passed-in dmesg block number: '$dmesgblock'" >&2
  exit 1
fi

#TODO: check and fail(or warn? nah, it should be fail!) if not a multiplier (eg. use modullo? is it "%" ?)
block=$(( $dmesgblock / 8 ))
if ! test "${block:--1}" -ge "0"; then
  echo "Badly computed device block number: '$block'" >&2
  exit 1
fi

echo "Actual block number(of $blocksize bytes per block): $block"
inode="$(echo "open ${dev}"$'\n'"icheck ${block}"$'\n'"close" | $sudo debugfs -f - 2>/dev/null | tail -n2|head -1|cut -f2 -d$'\t')"
if test "<block not found>" == "$inode"; then
  echo "No inode was found for the provided dmesg block number '$dmesgblock' which mapped to dev block number '$block'" >&2
  exit 1
else
    #assuming number TODO: check for this!
    echo "Found inode: $inode"
    fpath="$(echo "open ${dev}"$'\n'"ncheck ${inode}"$'\n'"close" | $sudo debugfs -f - 2>/dev/null | tail -n2|head -1|cut -f2- -d$'\t')"
  #fpath always begins with '/' right?
    if test "$fpath" != "Pathname"; then
        echo "Found path : $fpath"
    else
        echo "not found"
    fi
fi
done

```
脚本使用示例：
```bash
#run as root
#chmod +x showblock first
./showblock.sh /dev/mapper/cachedev_2 3000000128 #block number
./showblock.sh /dev/md0 123668 #block number
```

## 唤醒原因
&emsp; 以下是我找到的一些唤醒原因及解决方法，这些修正脚本可直接写进`/etc/rc.local`
### `/var/log` 目录内的日志读写和滚动
绝大多数日志对我用处不大，直接挂载为`tmpfs`，只要`tmpfs`足够大，压根不需要频繁滚动日志唤醒硬盘，也可计划任务定期清理日志即可。

```bash
# rc.local
mount -t tmpfs -o nosuid,noexec,nodev,mode=0755,size=100M transientlog /var/log
mkdir -p /var/log/nginx/ && touch /var/log/nginx/error_default.log #避免nginx启动报错找不到日志文件

systemctl stop synologrotated #会频繁产生/var/lib/logrotate.status文件唤醒测盘
```

### SMB服务读写临时文件
这部分有待验证，`Samba`服务会读写`/var/lib/samba`，无论启动`Samba`文件服务与否，都会有`nmbd`服务唤醒硬盘，我这边直接关闭nmbd服务(我已经在界面禁用了samba服务)。

```bash
mount -t tmpfs -o nosuid,noexec,nodev,mode=0755,size=100M transientlog /var/cache/samba
vmtouch -dl /var/lib/samba/
systemctl stop pkg-synosamba-nmbd
```
### FTP服务定期读数据文件
一个是读取`ftpd`二进制本身，另一个是`ftpd`程序会读取`/usr/share/icu/64.2/icudt64l.dat`，尝试用`vmtouch`直接加载进内存。
```bash
vmtouch -dl /bin/ftpd
vmtouch -dl /usr/share/icu/64.2/icudt64l.dat
```
### 群晖内置及安装应用的计划任务
使用[这个脚本：007revad/synology_hibernation_fixer](https://github.com/007revad/synology_hibernation_fixer)解决，建议拉长间隔或删除一些没用的计划任务，我这边内置了大概34个计划任务。分布在这三个目录：
```bash
 /usr/syno/share/synocron.d/
 /usr/syno/etc/synocron.d/
 /usr/local/etc/synocron.d/
```
而且群晖的内置服务使用`crontab`的格式，触发时间使用了随机数，不在固定时间触发，无疑加大了唤醒排查难度，意义不明的设计。
### 群晖的意义不明的唤醒机制
休眠时仅SSD有读写活动`scemd`也会一并唤醒所有机械硬盘
同使用[这个脚本：007revad/synology_hibernation_fixer](https://github.com/007revad/synology_hibernation_fixer)解决，它会patch `scemd`和`synocached`。
### IPv6/IPv4地址变化
IPv6/IPv4地址变化会触发一些根分区hook脚本执行，可以用`vmtouch`把这些hook加载进内存，我这边是ipv6动态，ipv4静态，未测试ipv4的变化情况:
```bash
vmtouch -dl /usr/syno/plugin/net/*
vmtouch -dl /etc/iproute2/script/policy_routing
vmtouch -dl /usr/local/packages/@appstore/SMBService/usr/bin/testparm
```

### snmpd定期执行
无论在界面启用与否，snmpd都定期执行，看了service文件界面的snmpd启用与否只会影响是否监听外部连接。
一种办法是直接停止服务（会导致界面没办法看到CPU/MEM使用）
```bash
systemctl stop snmpd
```
另一种办法是尝试加载二进制进内存:
```bash
vmtouch -dl /bin/snmpd
vmtouch -dl /bin/snmpwalk
```
### AME定期读取授权文件
这个授权文件许久都不会变化，加载进内存
```bash
vmtouch -dl /usr/syno/etc/license/*
```
### 可能频繁的磁盘信息收集与测试
磁盘数据也可以挂载`tmpfs`
```bash
mount -t tmpfs -o nosuid,noexec,nodev,mode=0755,size=100M transientlog /var/lib/diskutil
mount -t tmpfs -o nosuid,noexec,nodev,mode=0755,size=10M transientlog /var/lib/drive
mount -t tmpfs -o nosuid,noexec,nodev,mode=0755,size=100M transientlog /var/lib/synosmartblock
```
### Photos设备不定期上传照片(正常)
貌似即便没有照片上传也会不断读api.so，可以加载进内存减少唤醒
```bash
vmtouch -dl /usr/lib/libwebapi-DSM5.so
vmtouch -dl /usr/syno/synoman/webapi/lib/SYNO.API.Info.so
vmtouch -dl /usr/syno/synoman/webapi/query.api
```

### 界面设置的计划任务执行(正常)
无论你的计划任务本身涉及不涉及磁盘读写，它执行后都会记录执行结果到`.sqlite`（根分区）。
### 界面设置的配置文件自动备份功能（正常）
如果你设置了定期备份系统配置的话。
### 其他应用及docker
如果你还安装了其他套件或docker，请使用以上方法自行排查对应的程序。
### 其他杂项
群晖开机会尝试启动一个叫`syno-nic-supported-check.serviced`的服务，这个服务会去执行`/usr/syno/bin/syno_check_nic_supported`这个文件，但是这个文件压根不存在，导致服务`failed`，进而导致`systemctl is-system-running`返回`degraded`而不是`running`，意义不明的设计。
## 总结
以上，如有错误欢迎指正。


















