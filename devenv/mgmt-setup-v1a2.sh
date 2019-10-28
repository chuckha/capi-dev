#!/usr/bin/env bash

set -o pipefail
set -o errexit
set -o xtrace

unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     machine=linux;;
    Darwin*)    machine=darwin;;
    *)          echo "unknown host type ${unameOut}"; exit 1;;
esac

# Assume KUBECONFIG is set
# Assume default aws profile is good enough for CAPI

# CAPI
CAPI_VERSION=v0.2.6
curl -L https://github.com/kubernetes-sigs/cluster-api/releases/download/${CAPI_VERSION}/cluster-api-components.yaml | kubectl apply -f -

# CABPK
CABPK_VERSION=v0.1.5
curl -L https://github.com/kubernetes-sigs/cluster-api-bootstrap-provider-kubeadm/releases/download/${CABPK_VERSION}/bootstrap-components.yaml | kubectl apply -f -

# CAPA
export AWS_REGION=${AWS_REGION:-us-west-2}
if [ -z ${AWS_B64ENCODED_CREDENTIALS+x} ]; then
    if ! [ -x "$(command -v clusterawsadm)" ]; then
        curl -Lo /tmp/clusterawsadm https://github.com/kubernetes-sigs/cluster-api-provider-aws/releases/download/v0.4.3/clusterawsadm-${machine}-amd64
        chmod +x /tmp/clusterawsadm
    fi
    export AWS_B64ENCODED_CREDENTIALS=$(clusterawsadm alpha bootstrap encode-aws-credentials)
fi

CAPA_VERSION=v0.4.3
curl -L https://github.com/kubernetes-sigs/cluster-api-provider-aws/releases/download/${CAPA_VERSION}/infrastructure-components.yaml | envsubst | kubectl apply -f -
