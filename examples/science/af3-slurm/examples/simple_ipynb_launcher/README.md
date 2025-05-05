# Simple Ipynb Launcher

The Simple Ipynb Launcher is comprised of a Jupyter Notebook script that allows you to upload and submit AlpaFold3 input files ([AlphaFold 3 Input Documentation](https://github.com/google-deepmind/alphafold3/blob/main/docs/input.md)) to the Jupyter Notebook, and automates data pipeline and/or inference operation of the AlphaFold 3 blueprint by using SLURM REST API.


## Launcher Logic
1.  **Folder sharing:** Mounting bucket as a shared storage folder, allows user to upload input file (datapipeline or inference input data) directly into the notebook.
2.  **Job Execution:** The job, datapipeline or inference process, is executed on the Slurm partition through SLURM REST API request.
3.  **Result Storage:** Upon successful completion, the data pipeline or inference outputs are stored in the folder sharing directory within the bucket, allows user to validate the output files.
4. **Secret Manager:** Upon successful deployment, we will automatically upload a secret token retrieved from Slurm Controller, which will be used by user to operate Slurm REST API operation, into Google Secreat Manager. Allows user sensitive token to be securely saved.

## Getting started
The Simple Ipynb Launcher is preinstalled by the AlphaFold 3 solution if you set `af3slurmrestapi_activate` as `true` . It enables you to upload an input file and submit data pipeline and/or inference process interactively through Jupyter Notebook.


### Access Jupyter Notebook

After you have finished the deployment of the Alphafold 3 blueprint, you can access Jupyter Notebook from AI Vertex Workbench

<img src="../../adm/ipynb_launcher/workbench-page.png" alt="Jupyter notebook Workbench Page" width="700">

In case the deployment works normally, you will be able to see the notebook with the similar file structure below
<img src="../../adm/ipynb_launcher/notebook.png" alt="Jupyter notebook Workbench Page" width="700">


### Assign Slurm Job

After you open the Notebook, you will see different sections with its related information. In the first section, you will be required to install dependencies from `requirements.txt` file which will be used on the next steps. Most of the settings/configurations come from initial blueprint setting.

For example, there is a `Datapipeline` section which contains payload or settings required to send data pipeline job into working node. 

<img src="../../adm/ipynb_launcher/datapipeline.png" alt="Jupyter notebook Workbench Page" width="700">



## Custom configuration

It is suggested for user to change the settings on the Notebook from the first time before deployment through blueprint variables. In case there is any changes required, make sure to validate your changes and required resources are available.

