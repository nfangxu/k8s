## 阿里云 Ubuntu 服务器安装 k8s 全记录

```bash
# 更新一下
apt update

# 关闭 swap
swapoff -a
vim /etc/fstab

# 主节点初始化
kubeadm init --pod-network-cidr=10.244.0.0/16 --ignore-preflight-errors=NumCPU --image-repository=registry.aliyuncs.com/google_containers

# 设置环境变量并使其生效
echo 'export KUBECONFIG=/etc/kubernetes/admin.conf' >> ~/.bashrc
source ~/.bashrc

# 主节点不允许部署node
kubectl taint nodes --all node-role.kubernetes.io/master-

# 安装网络插件
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

# 安装dashboard
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta1/aio/deploy/recommended.yaml

# 断开客户端 重新连接一下

# 获取用户Token
kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep kubernetes-dashboard | awk '{print $1}')

# 查看账户状态
kubectl get serviceaccounts kubernetes-dashboard -o yaml -n kubernetes-dashboard

# 开启代理测试访问
kubectl proxy --address='172.17.146.223' --accept-hosts='^*$'

```