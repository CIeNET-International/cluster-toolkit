# Setup
This guide explains how to properly set up and launch the Simple Ipynb Launcher environment
## Prerequisites

### Set up Jobs Bucket

If you want to use the simple service launcher, you need to create an additional bucket, that should
be located in the region where you stand up your cluster:

```bash
#!/bin/bash

UNIQUE_JOB_BUCKET=<your-bucket>
PROJECT_ID=<your-gcp-project>
REGION=<your-preferred-region>

gcloud storage buckets create gs://${UNIQUE_JOB_BUCKET} \
    --project=${PROJECT_ID} \
    --default-storage-class=STANDARD --location=${REGION} \
    --uniform-bucket-level-access
```

## Deploying a Jupyter Notebook for AlphaFold

You can deploy a Jupyter Notebook environment to run AlphaFold step-by-step. This is useful for interactive exploration and making custom modifications to the AlphaFold pipeline.

> **Important:** To enable the Jupyter Notebook deployment, you **must provide a cloud storage bucket**. If no bucket is specified, the notebook environment will not be created.

### Steps to Deploy

1. Ensure you have provided a valid cloud storage bucket in your `af3-slurm-deployment.yaml`:

    ```yaml
    af3ipynb_bucket: "<your-pre-existing-bucket-name>"
    ```

2. If you have already deployed the cluster (see [Deploy the Cluster](#deploy-the-cluster)) **without specifying** the `af3ipynb_bucket` in your `af3-slurm-deployment.yaml` file and now wish to enable the Jupyter Notebook functionality, you must [**tear down the existing cluster**](#teardown-instructions) and [**redeploy a new cluster**](#deploy-the-cluster) with the correct `af3ipynb_bucket` value. Could follow `--skip image` command while deploying to reduce deployment time.
Note that the Jupyter Notebook will not function properly if added to an already deployed cluster without this configuration.

3. Build the Jupyter notebook with `af3-slurm-ipynb.yaml`:

    ```bash
    ~$ cd cluster-toolkit  
    cluster-toolkit$ ./gcluster deploy -d examples/science/af3-slurm/af3-slurm-deployment.yaml examples/science/af3-slurm/examples/simple_ipynb_launcher/af3-slurm-ipynb.yaml --auto-approve
    ```

### Activate Ipynb Launcher

To start the Simple Ipynb Launcher, ensure that the following settings are present in your `af3-slurm-deployment.yaml` file:

```yaml
af3ipynb_bucket: "<your-pre-existing-bucket>"
```

### Configuring the SLURM REST API Token Secret Name

Replace <your-secret-name> with the actual name of a secret you have created in Secret Manager that currently exists without a token value. Alternatively, you can provide the secret name that does not yet exist in Secret Manager. If the specified secret name is new, this blueprint will automatically create it for you.

> This setting allows you to specify the name of a Google Cloud Secret Manager secret that holds your SLURM authentication token. Using Secret Manager is a secure way to manage sensitive credentials.

```yaml
slurm_rest_token_secret_name: "<your-secret-name>"
```

### Startup Script Completion Before Slurm API Requests

To ensure proper cluster initialization, please wait for the startup scripts to complete successfully on all relevant nodes (including login and controller nodes) **before submitting any Slurm API requests from the notebook**.

**How to Verify Startup Script Completion:**

You can check the `/var/log/slurm/setup.log` file on each node to confirm the successful execution of the startup script. Look for one of the following log entries, indicating completion for the respective node type:

- **Login Node Completion:**

  ```text
  INFO: Done setting up login
  ```

  This message confirms that the startup script on a login node has finished its configuration.

- **Controller Node Completion:**

  ```text
  INFO: Done setting up controller
  ```
  
  This message confirms that the startup script on a controller node has finished its configuration.

Make sure you submitting Slurm API requests only after the appropriate "Done setting up" message is observed on all necessary login and controller nodes. Monitoring these log files allows you to track the initialization process of your cluster.

## Upload Notebook to Bucket

To upload the Jupyter notebook to the cloud storage bucket so it can be accessed via JupyterLab:

1. **SSH into controller node** in the cluster.

2. **Navigate to the setup directory**:

   ```bash
   cd /home/af3ipynb/ipynb_setup
   ```

3. Run the Ansible playbook to upload the Jupyter notebook and its required library files to the designated bucket:

    ```bash
    ansible-playbook ipynb-upload-config.yml
    ```

This playbook will upload `slurm-rest-api-notebook.ipynb` along with its associated scripts and library files to the target bucket (`af3ipynb_bucket`).
Once the upload is complete, you can access the notebook from the JupyterLab interface via:

> Cloud Console → Vertex AI → Workbench → Instances

## Custom configuration

You can customize settings via blueprint variables before deployment. If modifications are needed later, ensure:

- All required resources are available
- Configuration changes within the notebook are validated before submitting new jobs.

## Teardown Jupyter Notebook

If you would like to tear down the notebook deployment, use the command below.

```bash
./gcluster destroy af3-slurm-ipynb --auto-approve
```

> [!WARNING]
> If you do not destroy all three deployment groups and/or the notebook deployment, then there may be continued
> associated costs. Also, the buckets you may have created via the cloud console or CLI will
> not be destroyed by the above command (they would be, however, destroyed if you deleted the project).
> For deleting the buckets consult [Delete buckets](https://cloud.google.com/storage/docs/deleting-buckets).
