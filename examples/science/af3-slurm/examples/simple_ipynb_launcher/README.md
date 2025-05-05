# Simple Ipynb Launcher

The Simple Ipynb Launcher is comprised of a Jupyter Notebook script that allows you to upload and submit AlpaFold3 input files  to the Jupyter Notebook, and automates data pipeline and/or inference operation of the AlphaFold 3 blueprint by using SLURM REST API.
The Simple Ipynb Launcher consists of a Jupyter Notebook script that enables users to upload and submit AlphaFold 3 input files (see [AlphaFold 3 Input Documentation](https://github.com/google-deepmind/alphafold3/blob/main/docs/input.md)) to the notebook. It automates the data pipeline and/or inference operations of the AlphaFold 3 blueprint using the SLURM REST API.

## Launcher Logic
1.  **Folder sharing:** Mounts a bucket as a shared storage folder, allowing users to upload input files (for data pipeline or inference) directly to the notebook.
2.  **Job Execution:** The data pipeline or inference job is executed on the SLURM partition via a SLURM REST API request.
3.  **Result Storage:** Upon successful completion, the outputs are stored in the shared folder within the bucket, enabling users to validate the result files.
4. **Secret Manager:** After deployment, a secret token retrieved from the SLURM Controller is automatically uploaded to Google Secret Manager. This securely stores the token required for SLURM REST API operations.


## Getting started
The Simple Ipynb Launcher is preinstalled with the AlphaFold 3 solution if the `af3slurmrestapi_activate` flag is set to `true`. It allows users to upload input files and submit data pipeline and/or inference jobs interactively through the Jupyter Notebook.


### Access Jupyter Notebook

After deploying the AlphaFold 3 blueprint, you can access the Jupyter Notebook through AI Vertex Workbench.
<img src="../../adm/ipynb_launcher/workbench-page.png" alt="Jupyter notebook Workbench Page" width="700">

If the deployment is successful and Slurm nodes startup-scripts are finished, you will see the notebook with a file structure similar to the one shown on the Jupyter Notebook Workbench page.
<img src="../../adm/ipynb_launcher/notebook.png" alt="Jupyter notebook Workbench Page" width="700">


### Assign Slurm Job

When you open the notebook, you’ll find different sections containing relevant information. In the first section, you are required to install dependencies from the requirements.txt file, which the libraries will be used in subsequent steps. Also for the settings and configurations, most of them are derived from the initial blueprint configuration.

For example, the `Datapipeline` section includes the payload and settings needed to send a data pipeline job to the working node.


<img src="../../adm/ipynb_launcher/datapipeline.png" alt="Jupyter notebook Workbench Page" width="700">


## Custom configuration

It is recommended that users customize the notebook settings before deployment via blueprint variables. If any changes are required later, ensure they are validated and that all necessary resources are available.

