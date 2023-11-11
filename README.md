# Grafana LGTM Stack Setup

## Overview

This repository contains Terraform configurations for setting up a local Kubernetes environment using Minikube to deploy a Grafana LGTM stack. It's designed for users who wish to experiment with or develop on a local instance of the Grafana LGTM stack, providing a convenient way to get the environment up and running.

## Prerequisites

Before using this repository, ensure you have the following tools installed and configured on your system:

1. **Terraform**: Used for automating the deployment of infrastructure. You can download it from [Terraform's website](https://www.terraform.io/downloads.html).

2. **kubectl**: A command-line tool for interacting with the Kubernetes cluster. It's essential for managing the cluster and its resources. Installation instructions can be found on the [Kubernetes website](https://kubernetes.io/docs/tasks/tools/).

3. **Helm**: A Kubernetes package manager. It simplifies deploying applications to Kubernetes clusters. For installation instructions, visit [Helm's documentation](https://helm.sh/docs/intro/install/).

4. **Minikube**: Provides a local Kubernetes cluster, ideal for development and testing. Download and setup instructions are available on the [Minikube GitHub page](https://github.com/kubernetes/minikube).

## Repository Structure

- `main.tf`: This Terraform configuration file sets up Minikube, configures necessary Kubernetes add-ons, and deploys the Grafana LGTM stack using Helm charts.

## Usage

To use this repository, follow these steps:

1. **Clone the Repository**: Clone this repository to your local machine.

2. **Initialize Terraform**: Run `terraform init` in the repository directory to initialize Terraform.

3. **Apply the Terraform Configuration**: Execute `terraform apply` to set up the Minikube cluster and deploy the Grafana LGTM stack.

4. **Accessing Grafana**: Once deployment is complete, access Grafana through the Minikube service.

5. **Tearing Down**: To tear down the environment and delete the Minikube cluster, run `terraform destroy`.

## Notes

- This setup is intended for local development and testing. It's not suitable for production use.
- Modifications to the `main.tf` file may be necessary to suit your specific requirements.
