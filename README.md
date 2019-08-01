# Cluster API Development Environment

This repo houses some tools to make running Cluster API v1alpha2 a little bit easier.

## Setup

Run `./init.sh`. This will clone some basic providers for you to try.

## Get a kubernetes cluster

Use kind, set up a cluster on AWS, GCP, etc. Whatever works. This will be your management cluster.

## Install Tilt

https://docs.tilt.dev/install.html

## Run Tilt

run `tilt up`

# ⚠️ Warnings ⚠️

* This Tiltfile uses live_update but if you are using a `kind` cluster this will not work without some [extra work on your part](https://github.com/windmilleng/rerun-process-wrapper). This holds true for any management cluster using a non docker container runtime.
    - You can disable live_update but updates will be full docker rebuilds
* 
