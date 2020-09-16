# Lab: Vault on K8S
## With an init container

## Introduction
This will take a while. I've done some of the work for you, to get you started, but there's a long way to go and a lot of stuff to understand.
We will cover more of the theory behind this lab next week.

## What will we do?
1. Install vault in K3D
2. Configure vault
2.1 Create an SA and a ClusterResourceBinding
2.2 Enable and configure k8s auth method
2.4 Create a policy for reading a secret and create a secret
2.5 Create a role bound to the SA
2.6 Verify that there is connectivity, etc.
3. Configure an init container to provide secrets to your app
4. Finally, run a sample app (nginx) and pass a secret into it

## What you will learn
1. How to install vault in K8S
2. How to configure a basic policy and bind it to a role and service-account
3. How to configure an init-container
4. How to use that init-container to provide secrets to your app
5. Some cool stuff about using colours in your bash output :)

## How to get started
Most of the interesting code is either in the Makefile or in platform/vault. I think you should start by reading the makefile, then the config.sh file (which does most of the hard work for you).


---
# Extension
## [Vault Agent Sidecar](https://learn.hashicorp.com/tutorials/vault/kubernetes-sidecar#set-a-secret-in-vault)
If you get through all of that then you can extend this by removing the code that configures and uses the init container from the config script and replacing it with code that uses a sidecar to do the same thing, only better.

The subtitle above is a link to the docs. The docs above the anchor I've linked to aren't important.
