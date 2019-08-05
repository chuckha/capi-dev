#!/usr/bin/env bash

set -o xtrace
set -o nounset
set -o errexit

aws cloudformation delete-stack --stack-name ClusterAPIDevEnvironment
aws cloudformation wait stack-delete-complete --stack-name ClusterAPIDevEnvironment
