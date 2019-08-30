# Cluster API Development Environment

This repo houses some tools to make running Cluster API v1alpha2 a little bit easier.

## Repo Setup

Run `./init.sh`. This will clone some basic providers for you to try.

## Install Tilt

https://docs.tilt.dev/install.html

## Install Kustomize

https://github.com/kubernetes-sigs/kustomize/blob/master/docs/INSTALL.md

## Get a kubernetes cluster

Use kind, set up a cluster on AWS, GCP, etc. Whatever works. This will be your management cluster.

### AWS (recommended for os x)

Assuming your local environment is set up for AWS access, run:

run `./devenv/setup.sh`.

This will create a single node kubernetes control plane to be used as the management cluster.

This will grab the kubeconfig and put it at `./devenv/dev-kubeconfig`.
 
### kind (recommended for linux)

[Install kind](https://github.com/kubernetes-sigs/kind#please-see-our-documentation-for-more-in-depth-installation-etc)

Run kind with the provided config `kind create cluster --config ./devenv/kind/config.yaml`

Set KUBECONFIG.

## Run Tilt

run `tilt up`

## Iterate

Now you can quickly iterate on Cluster API
