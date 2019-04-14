#!/bin/bash

# This script is meant for quick & easy setup centos:
# Tested on minimal version of centos 7
#   $ sh initialize_centos.sh

sudo yum -y install net-tools #install ifconfig
sudo yum -y install wget
sudo yum -y install yum-utils #install yum-config-manager
sudo yum -y install unzip

#   添加阿里源：
#	1. 把原来的源文件备份
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
#	2. 从阿里云下载源文件
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
#	3. 清除缓冲
sudo yum clean all
#	4. 生成新缓冲
sudo yum makecache
#	5. 更新源
sudo yum -y update
#   6. 安装git
sudo yum -y install git