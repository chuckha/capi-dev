#!/usr/bin/env bash

# Core Provider
git clone git@github.com:kubernetes-sigs/cluster-api.git

# Bootstrap Providers
git clone git@github.com:kubernetes-sigs/cluster-api-bootstrap-provider-kubeadm.git

# Infrastructure Providers
git clone git@github.com:kubernetes-sigs/cluster-api-provider-aws.git
