## helm install nextcloud

```bash
# 创建一个mysql用户
grant all privileges on nextcloud.* to 'nextcloud'@'%' identified by 'nextcloud' with grant option;
# 刷新权限
flush privileges;

# 使用 helm 创建
helm install --name fx-cloud \
    --nextcloud.username nfangxu \
    --nextcloud.password changeme \
    -f values.yaml \
    stable/nextcloud
```