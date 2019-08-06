#!/usr/bin/env bash

set -o xtrace
set -o nounset
set -o errexit

INSTANCE_ID=$(aws cloudformation describe-stacks --stack-name ClusterAPIDevEnvironment --query "Stacks[0].Outputs[0].OutputValue" --output=text)
INSTANCE_DNS=$(aws ec2 describe-instances --instance-id $INSTANCE_ID --query "Reservations[0].Instances[0].PublicDnsName" --output text)

ssh "ubuntu@${INSTANCE_DNS}" 'sudo kubeadm reset -f --cri-socket /var/run/containerd/containerd.sock && sudo kubeadm init --config /tmp/kubeadm-config.yaml'
