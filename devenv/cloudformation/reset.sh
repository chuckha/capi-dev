#!/usr/bin/env bash

set -o xtrace
set -o nounset
set -o errexit

alias ssh='ssh -o "StrictHostKeyChecking no'

INSTANCE_ID=$(aws cloudformation describe-stacks --stack-name ClusterAPIDevEnvironment --query "Stacks[0].Outputs[0].OutputValue" --output=text)
INSTANCE_IP=$(aws ec2 describe-instances --instance-id $INSTANCE_ID --query "Reservations[0].Instances[0].PublicIpAddress" --output text)

ssh "ubuntu@${INSTANCE_IP}" 'sudo kubeadm reset -f --cri-socket /var/run/containerd/containerd.sock && sudo kubeadm init --config /tmp/kubeadm-config.yaml'
ssh "ubuntu@${INSTANCE_IP}" 'sudo docker rm -f -v $(sudo docker ps -a -q) || echo "no containers to clean up"'
ssh "ubuntu@${INSTANCE_IP}" 'sudo -s cat /etc/kubernetes/admin.conf' > dev-kubeconfig


sed -i '' -E 's/([0-9]{1,3}\.){3}[0-9]{1,3}/'$INSTANCE_IP'/' dev-kubeconfig
kubectl --kubeconfig dev-kubeconfig apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl --kubeconfig dev-kubeconfig version | base64 | tr -d '\n')"
