## 阿里云 Ubuntu 服务器安装 k8s 全记录
- 参考文档

    * [阿里云镜像加速](https://cr.console.aliyun.com/cn-beijing/instances/mirrors)

    * [官方文档](https://kubernetes.io/zh/docs/)

    * [创建单个用户](https://github.com/kubernetes/dashboard/wiki/Creating-sample-user)

    * [网络插件 kube-flannel](https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml)

    * [kubernetes dashboard Yaml 文件](https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta1/aio/deploy/recommended.yaml)

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

# 关闭 swap
swapoff -a
vim /etc/fstab # 注释掉 # /swapfile none swap sw 0 0

# 前期准备完成

# 主节点初始化
kubeadm config images pull --image-repository=registry.aliyuncs.com/google_containers

kubeadm init --pod-network-cidr=10.244.0.0/16 --ignore-preflight-errors=NumCPU --image-repository=registry.aliyuncs.com/google_containers

# 设置环境变量并使其生效
echo 'export KUBECONFIG=/etc/kubernetes/admin.conf' >> ~/.bashrc
source ~/.bashrc

# 主节点不允许部署node
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

# 安装网络插件
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

# 安装 nginx-ingress
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/mandatory.yaml

# 安装dashboard
kubectl -n kube-system create secret tls kubernetes-dashboard-certs \
  --key /certs/k8s.nfangxu.cn.key \
  --cert /certs/k8s.nfangxu.cn.pem

kubectl apply -f kubernetes-dashboard.yaml
kubectl apply -f dashboard-ingress.yaml

# 获取用户Token
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep kubernetes-dashboard | awk '{print $1}')

# 权限问题
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

# 权限问题
kubectl delete -f 3.dashboard-admin.yaml
kubectl create -f 3.dashboard-admin.yaml
```