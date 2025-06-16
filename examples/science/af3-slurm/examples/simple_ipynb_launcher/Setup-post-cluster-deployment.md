# Setup: Post-Cluster Deployment

This guide explains how to deploy and access the Jupyter Notebook environment for AlphaFold **after the af3-slurm.yaml cluster has already been deployed** with SLURM REST support enabled.

## Prerequisites

Before proceeding, ensure the following configuration values were set correctly in your `af3-slurm-deployment.yaml` file **prior to deploying the SLURM cluster**:

```yaml
slurm_rest_server_activate: true
slurm_rest_token_secret_name: "<your-secret-name>"            # Name of your Secret Manager secret
af3ipynb_bucket: "<your-pre-existing-bucket-name>"           # Existing Cloud Storage bucket name
```

> [!WARNING]
> This guide assumes that the SLURM cluster is already deployed with REST API support enabled—i.e., the values above were correctly set before deployment.
> If any of the values above were omitted or misconfigured, you must destroy the cluster, update the deployment configuration, and redeploy. These settings are essential for enabling SLURM REST-based notebook functionality.
> This document focuses exclusively on deploying and accessing the Jupyter Notebook environment **after** the cluster is running and properly configured. It does not cover modifying or redeploying the cluster.

If you have **not yet deployed** the cluster, or if you need help setting the appropriate variables prior to deployment, refer to [Setup-pre-cluster-deployment.md](./Setup-pre-cluster-deployment.md) guide.

## Deploying the Jupyter Notebook Blueprint

### 1. Upload the required Notebook to the Cloud Storage Bucket

First, access the controller node of your deployed SLURM cluster. Replace placeholders `<controller-node-name>` and `<your-zone>` with your actual node and zone.

```bash
gcloud compute ssh <controller-node-name> --zone=<your-zone>
```

On the controller node, run the following command (assuming the `slurm_rest_user` value in `af3-slurm-deployment.yaml` has not changed):

```bash
cd /home/af3ipynb/ipynb_setup
ansible-playbook ipynb-upload-config.yml
```

This step uploads the notebook (`slurm-rest-api-notebook.ipynb`) along with its required scripts and libraries to the bucket defined in the `af3ipynb_bucket` variable in `af3-slurm-deployment.yaml` file.
Make sure that this bucket was created and specified during the SLURM cluster deployment process.

### 2. Grant Secret Access to the Notebook's Service Account

This setting ensures that the notebook server can successfully retrieve the specified secret by name.
Make sure the service account running the Jupyter Notebook instance (typically the Compute Engine default service account) has permission to access the Secret Manager secret that stores your SLURM REST token.

The following command grants the Compute Engine default service account the `roles/secretmanager.secretAccessor` role, allowing it to access the specified secret in Secret Manager. The attached condition always evaluates to true, ensuring access is consistently granted.

```bash
gcloud secrets add-iam-policy-binding <your-secret-name> \
--member="serviceAccount:$(gcloud projects describe <your-project-id> --format='value(projectNumber)')-compute@developer.gserviceaccount.com" \
--role="roles/secretmanager.secretAccessor" \
--condition="expression=true,title=AlwaysTrue,description=Allow access to Secret Manager"
```

You can verify this configuration in the Secret Manager section of the Google Cloud Console.

<img src="adm/secret-manager.png" alt="secret-manager" width="1000">

### 4. Launch the Notebook Environment

Deploy the Jupyter Notebook environment using the following command:

```bash
# Move to cluster-toolkit root folder
cd cluster-toolkit
./gcluster deploy -d examples/science/af3-slurm/af3-slurm-deployment.yaml \
examples/science/af3-slurm/examples/simple_ipynb_launcher/af3-slurm-ipynb.yaml --auto-approve
```

This brings up the Jupyter Notebook deployment.

### 5. Access the Notebook via Vertex AI Workbench

In the Google Cloud Console:

1. Navigate to `Vertex AI` → `Workbench` → `Instances`

2. Open the JupyterLab interface for the newly deployed instance

3. Locate and open the `slurm-rest-api-notebook.ipynb` file. If you haven't modified the default value of `af3ipynb_bucket_local_mount` in the `af3-slurm-deployment.yaml`, the notebook should be available at `/home/jupyter/alphafold` folder.

### 6. Verify REST Token Access

To verify that Secret Manager access is properly configured, open a terminal within JupyterLab and run the following command:

```bash
gcloud secrets versions access latest --secret=<your-secret-name>
```

If the command returns the secret value successfully, it confirms that the notebook environment can securely access the SLURM REST API—just as in the image below:

<img src="adm/rest_api.png" alt="slrum rest api" width="1000">

## Teardown

To remove the Jupyter Notebook deployment when it is no longer needed, run the following command:

```bash
./gcluster destroy af3-slurm-ipynb --auto-approve
```

> [!WARNING]
> If you do not destroy the Jupyter Notebook deployment, it may continue to incur costs.
> Additionally, any Cloud Storage buckets you created (via the CLI or console) will not be automatically deleted. You are responsible for cleaning them up manually to avoid unnecessary charges.
> For deleting the buckets consult [Delete buckets](https://cloud.google.com/storage/docs/deleting-buckets).

## Notes and Customization
You can adjust the notebook setup behavior using blueprint variables in the deployment YAML.
All configurations should be validated before running jobs.
If further modifications to SLURM REST/API Server behavior are required, you must destroy and redeploy the cluster with the updated settings.
