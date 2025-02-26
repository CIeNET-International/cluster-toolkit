# A4 High Blueprints

This document outlines the deployment steps for provisioning A4 High
`a4-highgpu-8g` VMs that use Slurm
as an orchestrator.

## Deployment Instructions

### Build the Cluster Toolkit gcluster binary

Follow instructions
[here](https://cloud.google.com/cluster-toolkit/docs/setup/configure-environment)

### (Optional, but recommended) Create a GCS Bucket for storing terraform state

```bash
#!/bin/bash
TF_STATE_BUCKET_NAME=<your-bucket>
PROJECT_ID=<your-gcp-project>
REGION=<your-preferred-region>

gcloud storage buckets create gs://${TF_STATE_BUCKET_NAME} \
    --project=${PROJECT_ID} \
    --default-storage-class=STANDARD --location=${REGION} \
    --uniform-bucket-level-access
gcloud storage buckets update gs://${TF_STATE_BUCKET_NAME} --versioning
```

### Create/modify the deployment.yaml file with your preferred configuration

For example, set the such as size, reservation to be used, etc, as well as the
name of the bucket that you just created. Below is an example

```yaml
---
terraform_backend_defaults:
  type: gcs
  configuration:
    bucket: TF_STATE_BUCKET_NAME

vars:
  deployment_name: a4h-slurm
  project_id: <PROJECT_ID>
  region: <REGION>
  zone: <ZONE>
  a4h_reservation_name: <RESERVATION_NAME>
  a4h_cluster_size: <RESERVATION_SIZE>
```

### Deploy the cluster

```bash
#!/bin/bash
gcluster deploy -d a4high-slurm-deployment.yaml a4high-slurm-blueprint.yaml
```
