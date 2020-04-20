# K8s 部署 Redis 集群, 并保持数据持久化

## ConfigMap

```bash
kubectl create configmap redis-conf --from-file=redis-config-map.conf
```


```bash
# error: pod has unbound immediate PersistentVolumeClaims
# ### --set persistentVolume.enabled=false

# error: 0/1 nodes are available: 1 node(s) didn't match pod affinity/anti-affinity, 1 node(s) didn't satisfy existing pods anti-affinity rules.
# ### --set hardAntiAffinity=false

helm install --name=fx-redis \
--set hardAntiAffinity=false \
--set persistentVolume.enabled=false \
--set hostPath.path="/mnt/redis/" \
--set redis.masterGroupName="fx-redis.master" \
stable/redis-ha
```

```
NOTES:
Redis can be accessed via port 6379 and Sentinel can be accessed via port 26379 on the following DNS name from within your cluster:
fx-redis-redis-ha.default.svc.cluster.local

To connect to your Redis server:
1. Run a Redis pod that you can use as a client:

   kubectl exec -it fx-redis-redis-ha-server-0 sh -n default

2. Connect using the Redis CLI:

  redis-cli -h fx-redis-redis-ha.default.svc.cluster.local

```