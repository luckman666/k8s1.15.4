#!/bin/bash
#source ./base.config
bash_path=$(cd "$(dirname "$0")";pwd)
source $bash_path/base.config

log="./setup.log"  #操作日志存放路径
fsize=2000000
exec 2>>$log  #如果执行过程中有错误信息均输出到日志文件中

yum_config(){
  yum install wget epel-release -y
  if [[ $aliyun == "1" ]];then
  test -d /etc/yum.repos.d/bak/ || yum install wget epel-release -y && cd /etc/yum.repos.d/ && mkdir bak && mv -f *.repo bak/ && wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo && wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo && yum clean all && yum makecache
  fi
}

ntp(){

num=0
while true ; do
let num+=1
yum -y install chrony
if [[ $? -eq 0 ]] ; then

grep "$masterip" /etc/chrony.conf
if [[  $? == 0  ]];then
echo "NTP配置完毕"
else
sed -i "7i server  $masterip iburst\nallow $cluster_network" /etc/chrony.conf
echo "NTP配置完毕"
fi
systemctl start chronyd.service && systemctl enable chronyd.service
systemctl restart chronyd.service

break;
else
if [[ num -gt 3 ]];then
echo "你登录 "$masterip" 瞅瞅咋回事？一直无法安装chrony包"
break
fi
echo "FK!~没成功？哥再来一次！！"
fi
done


}
main(){
yum_config
ntp
}

main > ./setup.log 2>&1
