#!/bin/sh

# Prerequisites: 3 nodes
#   $ vi /etc/hosts 
# eg:
# 10.168.141.7 k8s-master
# 10.168.141.8 node01
# 10.168.141.9 node02

yum update

# dissable SELinux
setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

# dissable off swap
sed -i 's%^/dev/mapper/rootvg-swap swap%#&%g' /etc/fstab
swapoff -a

# load module
modprobe br_netfilter
# set iptables
echo '1' > /proc/sys/net/bridge/bridge-nf-call-iptables
echo '1' > /proc/sys/net/bridge/bridge-nf-call-ip6tables
# To make it persistent it is better to change the sysctl configuration. For example in Centos 7 you have to change /usr/lib/sysctl.d/00-system.conf 

# add yum source
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kube*
EOF

yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

systemctl start kubelet && systemctl enable kubelet

# check if docker is using  "cgroupfs"
#   $ docker info | grep -i cgroup
# update config
#   $ sed -i 's/cgroup-driver=systemd/cgroup-driver=cgroupfs/g' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
#   $ systemctl daemon-reload
#   $ systemctl restart kubelet

# setup master (replace XXX with host IP)
#   $ kubeadm init --apiserver-advertise-address=XXX.XXX.XXX.XXX --pod-network-cidr=10.244.0.0/16 
# Copy the 'kubeadm join ... ... ...' command to your text editor. The command will be used to register new nodes to the kubernetes cluster.
