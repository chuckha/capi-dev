# Cluster API Development Environment

This repo houses some tools to make running Cluster API v1alpha2 a little bit easier.

## Repo Setup

Run `./init.sh`. This will clone some basic providers for you to try.

## Install Tilt

https://docs.tilt.dev/install.html

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

## Update config.json 

Make sure you update the values in `config.json ` to point to your registry

```json
{
  "default_registry": "gcr.io/<your project>",
  "default_core_image": "gcr.io/k8s-staging-cluster-api/cluster-api-controller:latest",
  "default_bootstrap_image": "gcr.io/<your project>/cluster-api-bootstrap-provider:latest",
  "default_infrastructure_image": "gcr.io/<your project>/manager:dev"
}
```

## Modify the Tiltfile

Set the `infrastructure_provider` in the _Tiltfile_

### Using the AWS provider
 
 Please note the `Tiltfile` assumes `clusterawsadm` is in the _bin_ directory of the AWS provider repo cloned 
 in the `init.sh` phase.  Before running `tilt up`, make sure you have `clusterawsadm` in the relevant path. 
 If you don't, run `make clusterawsadm` from the AWS provider repo or update the `Tiltfile`. 

## Run Tilt

run `tilt up`

## Iterate

Now you can quickly iterate on Cluster API

