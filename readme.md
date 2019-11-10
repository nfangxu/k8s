## 阿里云 Ubuntu 服务器安装 k8s 全记录

- 前期准备

    * 一台服务器, 开放了 80 / 443 端口 (可以多准备几台节点服务器, 内网互通的那种)
    
    * 一个域名, 与之相对应的 ssl 证书 (kubernetes-dashboard 需要 https 才能登陆, http 会出问题, 具体问题请自己踩坑)

- 参考文档

    * [阿里云镜像加速](https://cr.console.aliyun.com/cn-beijing/instances/mirrors)

    * [官方文档](https://kubernetes.io/zh/docs/)
    
- 注意

    * 以下会安装 `asciinema` 这个东西, 可以记录下你在命令行操作的所有步骤, 可以用来查错, 如果不需要, 可以不用装
    
    * 设置 `PS1` 环境变量, 只是看起来舒服一点, 跟 k8s 没一毛钱关系
    
    * 本文所使用的服务器配置为 `1c2G` 配置, 环境为 `ubuntu`, 新装的系统 干净的不要不要的, 如果你不是干净的系统, 自己掂量着办吧

## 准备工作

```bash

# vim 设置行号
cat <<EOF > ~/.vimrc
set nu
EOF

# 设置默认 PS1
echo 'export PS1="\[\033[33m\]\u\[\033[0m\]@\[\033[36m\]k8s\[\033[0m\]:\[\033[32m\]\W \[\033[0m\]$ "' >> ~/.bashrc

source ~/.bashrc

# 基础依赖包
apt update && apt -y install apt-transport-https ca-certificates curl software-properties-common

# asciinema 镜像源
apt-add-repository ppa:zanchey/asciinema

# docker 和 k8s 镜像源
curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | apt-key add -
curl -fsSL https://mirrors.aliyun.com/kubernetes/apt/doc/apt-key.gpg | apt-key add -

cat <<EOF >/etc/apt/sources.list.d/docker-k8s.list
deb https://mirrors.aliyun.com/kubernetes/apt/ kubernetes-xenial main
deb [arch=amd64] http://mirrors.aliyun.com/docker-ce/linux/ubuntu $(lsb_release -cs) stable
EOF

# 安装基础软件
apt update && apt install -y asciinema docker-ce kubelet kubeadm kubectl

# 关闭 swap, 不关闭的话, k8s 会报错
swapoff -a
vim /etc/fstab # 注释掉 # /swapfile none swap sw 0 0

# 前期准备完成

# 主节点初始化
# 如果你可以科学上网, 可以不用设置 --image-repository 
# 如果你服务器的 CPU >= 2 可以不用设置 --ignore-preflight-errors=NumCPU
kubeadm config images pull --image-repository=registry.aliyuncs.com/google_containers
kubeadm init --pod-network-cidr=10.244.0.0/16 --ignore-preflight-errors=NumCPU --image-repository=registry.aliyuncs.com/google_containers

# 设置环境变量并使其生效
echo 'export KUBECONFIG=/etc/kubernetes/admin.conf' >> ~/.bashrc
source ~/.bashrc

# 主节点不允许部署node, 如果有多台服务器, 请忽略这个命令
kubectl taint nodes --all node-role.kubernetes.io/master-

# 查看相关状态 # --all-namespaces 可以替换为 -n <namespaces>
kubectl get nodes --all-namespaces 
kubectl get pods --all-namespaces 
kubectl get services --all-namespaces 
kubectl get svc --all-namespaces 
kubectl get deployments --all-namespaces 

```

## 对外访问

```bash

# 安装网络插件, 网络插件有好多种, 这里使用的是 kube-flannel
# 官方配置: https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
# 这个文件直接复制过来的
kubectl apply -f kube-flannel.yml

# 安装 nginx-ingress, ingress 有好多个, 这里使用 nginx-ingress
# 官方配置: https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/mandatory.yaml
# 直接复制过来的, 加了一个 hostNetwork: true 配置, 不加这个配置, 不会监听主机的 80/443 端口
kubectl apply -f nginx-ingress-controller.yml

# 从这块开始往下, 建议使用 2.0 版本

# 安装dashboard
# 使用自己的ssl证书, 创建 secret , 给 kubernetes-dashboard 用, 路径建议使用 绝对路径
kubectl -n kube-system create secret tls kubernetes-dashboard-certs \
  --key /certs/k8s.nfangxu.cn.key \
  --cert /certs/k8s.nfangxu.cn.pem

# 这里会报一个 secret 已存在的错, 忽略掉就行了
kubectl apply -f kubernetes-dashboard.yaml
# 使用 ingress 转发 dashboard
kubectl apply -f dashboard-ingress.yaml

# 获取登录 Token
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep kubernetes-dashboard | awk '{print $1}')

# 登录成功, 会提示没有权限, 使用下面两个命令, 将 kubernetes-dashboard 用户给管理权限
kubectl delete -f dashboard-admin.yaml
kubectl create -f dashboard-admin.yaml

# 查看账户状态
kubectl get serviceaccounts kubernetes-dashboard -o yaml -n kube-system
```

## dashboard 2.0-beta

```bash

cd dashboard-2.0.0-beta1

kubectl create -f 0.kubernetes-namespaces.yaml

kubectl -n kubernetes-dashboard create secret tls kubernetes-dashboard-certs \
  --key /certs/k8s.nfangxu.cn.key \
  --cert /certs/k8s.nfangxu.cn.pem

kubectl create -f 1.kubernetes-dashboard.yaml

kubectl create -f 2.dashboard-ingress.yaml

kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep kubernetes-dashboard | awk '{print $1}')

kubectl delete -f 3.dashboard-admin.yaml
kubectl create -f 3.dashboard-admin.yaml
```

## 补充

```bash
# 手动拉取 flannel 相关镜像
docker pull quay.mirrors.ustc.edu.cn/coreos/flannel:v0.11.0-amd64
docker pull quay.mirrors.ustc.edu.cn/coreos/flannel:v0.11.0-arm64
docker pull quay.mirrors.ustc.edu.cn/coreos/flannel:v0.11.0-arm
docker pull quay.mirrors.ustc.edu.cn/coreos/flannel:v0.11.0-ppc64le
docker pull quay.mirrors.ustc.edu.cn/coreos/flannel:v0.11.0-s390x
```
