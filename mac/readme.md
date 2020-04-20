# Mac 上安装 K8s 记录

- helm 3

## 国内镜像源

|国外源|国内源|格式|
|:----|:----|:----|
|dockerhub (docker.io)|dockerhub.azk8s.cn|`dockerhub.azk8s.cn/<repo-name>/<image-name>:<version>`|
|gcr.io|gcr.azk8s.cn|`gcr.azk8s.cn/<repo-name>/<image-name>:<version>`|
|quay.io|quay.azk8s.cn|`quay.azk8s.cn/<repo-name>/<image-name>:<version>`|
|k8s.grc.io|gcr.azk8s.cn/google-containers|`gcr.azk8s.cn/google-containers/<image-name>:<version>`|

## 安装 docker-for-mac

## 配置 ingress

```bash

# 安装 nginx-ingress @see https://github.com/helm/charts/tree/master/stable/nginx-ingress
helm install stable/nginx-ingress --generate-name -f helm-ingress-values.yaml

```