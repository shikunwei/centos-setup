#!/bin/sh

set -e
# Prerequisites: 3 nodes
#   $ vi /etc/hosts 
# eg:
# 10.168.141.7 k8s-master
# 10.168.141.8 node01
# 10.168.141.9 node02

#yum -y update

# dissable SELinux
setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

# dissable off swap
sed -i 's%^/dev/mapper/centos.*swap%#&%g' /etc/fstab
swapoff -a

# load module
modprobe br_netfilter
# set iptables
echo '1' > /proc/sys/net/bridge/bridge-nf-call-iptables && echo '1' > /proc/sys/net/bridge/bridge-nf-call-ip6tables
# To make it persistent it is better to change the sysctl configuration. For example in Centos 7 you have to change /usr/lib/sysctl.d/00-system.conf 

# add yum source
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
exclude=kube*
EOF

yum install -y kubelet-1.15.1-0 kubeadm-1.15.1-0 kubectl-1.15.1-0 --disableexcludes=kubernetes

systemctl start kubelet && systemctl enable kubelet

# check if docker is using  "cgroupfs"
#   $ docker info | grep -i cgroup
# update config
#   $ sed -i 's/cgroup-driver=systemd/cgroup-driver=cgroupfs/g' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
#   $ systemctl daemon-reload
#   $ systemctl restart kubelet

#images=(kube-apiserver:v1.15.1 kube-controller-manager:v1.15.1 kube-scheduler:v1.15.1 kube-proxy:v1.15.1 pause:3.1 etcd:3.3.10 coredns:1.3.1)
#for imageName in ${images[@]} ; do
#docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/$imageName
#docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/$imageName k8s.gcr.io/$imageName
#docker rmi registry.cn-hangzhou.aliyuncs.com/google_containers/$imageName
#done

# setup master (replace XXX with host IP)
#   $ kubeadm init --apiserver-advertise-address=XXX.XXX.XXX.XXX --pod-network-cidr=10.244.0.0/16 
# Copy the 'kubeadm join ... ... ...' command to your text editor. The command will be used to register new nodes to the kubernetes cluster.
#   kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
