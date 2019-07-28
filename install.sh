# 关闭 swap
swapoff -a

# 主节点初始化
kubeadm init --pod-network-cidr=10.244.0.0/16 --ignore-preflight-errors=NumCPU --image-repository=registry.aliyuncs.com/google_containers

# 设置环境变量并使其生效
echo 'export KUBECONFIG=/etc/kubernetes/admin.conf' >> ~/.bashrc
source ~/.bashrc

# 主节点不允许部署node
kubectl taint nodes --all node-role.kubernetes.io/master-

# 安装网络插件
kubectl apply -f kube-flannel.yml

# 安装dashboard
#kubectl apply -f kubernetes-dashboard-http.yaml
