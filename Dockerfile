FROM lachlanevenson/k8s-kubectl:v1.16.2
 
MAINTAINER nfangxu <nfangxu@gmail.com>
 
ENV KUBE_LATEST_VERSION="v1.16.2"

ADD /etc/kubernetes/admin.conf /root/.kube/config

WORKDIR /root