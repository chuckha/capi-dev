#!/usr/bin/env bash

set -o xtrace
set -o nounset
set -o errexit

cd "$(dirname "$0")"
pwd

MY_IP=$(curl --silent https://checkip.amazonaws.com)
KEY_PAIR_NAME=${KEY_PAIR_NAME:-default}

aws ec2 describe-key-pairs --key-names "${KEY_PAIR_NAME}" --query 'KeyPairs[*].KeyName' && rc=$? || rc=$?
if [[ $rc != 0 ]]; then
    echo "key-pair '${KEY_PAIR_NAME}' does not exist, override by setting KEY_PAIR_NAME. These are the existing key-pairs"
    aws ec2 describe-key-pairs --query 'KeyPairs[*].KeyName'
    exit 1
fi

aws cloudformation create-stack --stack-name ClusterAPIDevEnvironment \
    --template-body file://cloudformation/dev-environment.yaml \
    --parameters \
    ParameterKey=UserData,ParameterValue="$(base64 -i cloudformation/user-data.sh)" \
    ParameterKey=DevMachineCidr,ParameterValue="${MY_IP}/32" \
    ParameterKey=KeyPairName,ParameterValue="${KEY_PAIR_NAME}"

aws cloudformation wait stack-create-complete --stack-name ClusterAPIDevEnvironment
INSTANCE_ID=$(aws cloudformation describe-stacks --stack-name ClusterAPIDevEnvironment --query "Stacks[0].Outputs[0].OutputValue" --output=text)
aws ec2 wait instance-status-ok --instance-id "${INSTANCE_ID}"
INSTANCE_DNS=$(aws ec2 describe-instances --instance-id ${INSTANCE_ID} --query "Reservations[0].Instances[0].PublicDnsName" --output text)

ssh -o "StrictHostKeyChecking no" "ubuntu@${INSTANCE_DNS}" 'sudo -s cat /home/ubuntu/kubeadm.conf' > dev-kubeconfig

# make an xl instance
# add security group allowing traffic from this IP
# run kind
# get kubeconfig
# sed kubeconfig
