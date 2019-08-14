#!/bin/bash

apt-get update

# install docker for capdctl
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

PUBLIC_IP=$(curl --silent http://169.254.169.254/latest/meta-data/public-ipv4)
LOCAL_IP=$(curl --silent http://169.254.169.254/latest/meta-data/local-ipv4)
cat > /tmp/kubeadm-config.yaml <<EOF
apiVersion: kubeadm.k8s.io/v1beta2
kind: InitConfiguration
nodeRegistration:
    taints: []
    criSocket: /var/run/containerd/containerd.sock
    kubeletExtraArgs:
        cgroup-driver: "systemd"
---
apiVersion: kubeadm.k8s.io/v1beta2
kind: ClusterConfiguration
apiServer:
    certSANs:
    - "${PUBLIC_IP}"
EOF
kubeadm init --config /tmp/kubeadm-config.yaml
sed "s/$LOCAL_IP/$PUBLIC_IP/g" /etc/kubernetes/admin.conf > /home/ubuntu/kubeadm.conf

# install weave for CNI
kubectl --kubeconfig /etc/kubernetes/admin.conf apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl --kubeconfig /etc/kubernetes/admin.conf version | base64 | tr -d '\n')"
