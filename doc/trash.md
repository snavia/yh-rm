# yh-posix-kits

posix系统工具箱，主要功能

- 文件归档
- 文件误删除预防，类回收站功能

---
# yh-rm.sh yh-rmctl.sh yh-ar.sh
## 场景
- 主要解决**rm**手抖，导致80%误删除问题
- **mv**
- **rm** 删除时，部分文件未解除锁定，导致删除不彻底问题
```bash

# rm -rvf /var/log/nginx/*.log



```

## 组件介绍
- yh-rm.sh  对标rm替换命令
- yh-rm-ctl.sh #
- yh-archive.sh


## 安装使用
- 全局安装(推荐): /usr/local/yh-posix-kits/
- 当前用户(尝鲜): ~/opt/yh-posix-kits/

```bash
# 全局安装
sudo make install

# 当前用户only
make install

# 更新(自动检测安装目录)
make update

# 移除(自动检测安装目录)
make uninstall
```

---
## Quick Started
**1. 文件归档**
**2. 文件删除**
```bash
# 先检查一下 rm 是否已经被　置换成了 yh-rm.sh
# 此时rm应该是个符号链接: [ -h $(which rm) ]
which rm && ls -lh $(which rm)
[ -h $(which rm) ] && rm -rvf ~/log/*.log ~/backup/*.bak
```


---
## 实现思路
#### 角色划分
涉及到3个用户
- sudo/root 权限 用户，简单期间，root就好了
- User 普通用户
- Trash 回收站用户

#### 工作流程
**单一职责、权限解藕、工作队列模型**
```bash
# 普通用户: 删除数据 => 生成tarball; 执行删除操作
#  ＝> ~/.trash/inbox
rm -rvf ~/log/*.log
# 预期: ~/.trash/inbox/home-foobar-log-dot-log-2019-11-16-10-10-59.foobar.tar

# root权限用户(低频触发): 变更owner所有权　foobar -> trash
# 通过 crontab 比如: 每60分钟，check一次

# trash用户(低频触发): crontab定期清理
# 通过 crontab 比如: 每天凌晨2点，执行: 删除30天之前的数据
```

**优点**
- 最小权限: trash用户，仅可以删除其目录下,且**owner为trash**的文件(一般就是tarball)
- 最小权限: foobar(普通)用户，一旦变更所有权，就进入了**安全隔离带**，文件只可被foobar读，但不可被修改，防止再次**误杀**
- 最小权限: ~/.trash　是一块**飞地**，foobar用户，只可查看，不可修改
- 快速通道: ~/.trash 对于sudo权限，可以做几乎所有的事，这里方便查看

**注:**
> - 保证事务，如果生成tarball出错了，那就不进行下一步删除了
> - 如果直接使用sudo chmod可能没有sudo权限
> - 直接使用`/home/trash/foobar.trash`可写权限,很难保证用户在里边，做些其它事
> - ~/.trash

#### 回收站目录结构
以foobar用户为例
- /home/trash/foobar.trash
- /home/trash/user2.trash
- /home/trash/inbox # 收集箱
- /home/foobar/.trash -> /home/trash/foobar.trash
- /home/foobar/.trash/201911 # 按年月集结归档

#### 回收站权限划分
- /home/trash `trash:trash` `-rwxr--r--`
- /home/trash/xx.trash `trash:trash` `-rwxr--r--`
- /home/trash/inbox `trash:trash` **`-rwxr--rwx`**

#### 文件命名
```bash
# rm -rvf /var/log/nginx
var-log-nginx-2019-11-16-10-10-59.foobar.tar

# rm -rvf /var/log/nginx/*.log
# rm -rvf /var/log/nginx/*.log*
var-log-nginx-dot-log-2019-11-16-10-10-59.foobar.tar

# rm -rvf /var/log/nginx/*.gz
var-log-nginx-dot-gz-2019-11-16-10-10-59.foobar.tar

# rm -rvf *.log -> ./*.log -> /path1/path2/*.log
var-log-nginx-dot-log-2019-11-16-10-10-59.foobar.tar
```

#### 安全第一，黑名单列表
```bash
# 黑名单目录不支持，不带过滤参数的,野蛮清除
BLACK_LIST="/ /home $(ls /home) /root /var /bin /usr"
# rm -rvf /home -- 直接保错
# 
# rm -rvf /home/*.bak 谨慎使用

# Danger: 高危(这种情况，锅都端了，直接保错)
# rm -rvf
# rm -rvf /
# rm -rvf / a/b/c # 这里有个空格
# cd ${变量不存在} && rm -rvf *

# 关于纠错，吃力不讨好，难免会养成依赖，持有侥幸心理，实现起来还麻烦
# 这里不支持
# e.g. rm -rvf /var/log/nginx/*.log -> rm -rvf / var/log/nginx/*.log
# 这里支持报错哈，毕竟tar一遍/，也很耗时,还自包含了
```
