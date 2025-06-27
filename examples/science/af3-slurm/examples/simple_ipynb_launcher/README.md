# Simple Ipynb Launcher
The Simple Ipynb Launcher is a Jupyter Notebook-based interface designed to run folding jobs on the Alphafold 3 High Throughput solution. We are using Google's Vertex AI Workbench services to host the Jupyter notebook and configure it to interoperate with the Slurm cluster via the Slurm REST API. For convenience, we provide a Jupyter notebook that can run folding jobs and analyze and visualize the output.

## Setup Guide: Jupyter Notebook with SLURM
Please note that the launcher needs 2 specific setup steps:

- **[Setup AF3 with Simple Ipynb Launcher - PART 1: specific cluster settings](./Setup-pre-cluster-deployment.md)**: Instructions to be followed before bringing up the `af3-slurm.yaml` Slurm cluster.

- **[Setup: Setup AF3 with Simple Ipynb Launcher - PART 2: IPython notebook setup](./Setup-post-cluster-deployment.md)**: Instructions for launching the notebook environment.

## Usage Guide
For usage of the Ipynb Launcher consult the [Step-by-Step Instructions](./Ipynb.md)

## Known Issues
You may encounter the following problems while using the notebook.

### Warning during dependency installation

**Description**:
You may encounter the following warning during dependency installation:

```text
ERROR: pip's dependency resolver does not currently take into account all the packages that are installed. This behaviour is the source of the following dependency conflicts.
google-cloud-bigtable 1.7.3 requires grpc-google-iam-v1<0.13dev,>=0.12.3, but you have grpc-google-iam-v1 0.14.2 which is incompatible
```

**Resolution**: This warning can be **safely ignored**.

The version mismatch does not impact the functionality required by this project. The `google-cloud-bigtable` package is not used in any critical code path, and no issues have been observed during execution.

### Resource Unavailability (Out of Capacity)

**Description**:  
Your job is queued but not executed because the cloud provider (e.g., GCP) can't provision the required compute nodes. This is often due to a temporary lack of available resources in the chosen region or zone.

**Resolution**:
- Check the **Controller Logs**:  
  Log on to the controller machine for your cluster to see detailed error messages like  
  `"GCP Error: Zone does not currently have sufficient capacity for resources"`.
- **Wait and Re-check**:  
  For temporary resource shortages, wait **5–10 minutes** and then re-run the "check job status" cell in your Jupyter notebook. Resources might become available and allow your job to proceed.

### Node Creation In Progress

**Description**:  
After your job is submitted, it takes time for the cluster to spin up new nodes. You might see a `NODE_FAIL` status if nodes are still being created and are not yet ready.

**Resolution**:
- Monitor the **Controller Logs** for status updates.
- **Wait 5–10 minutes**, then recheck your job status to see if nodes have become available.

---

### Runtime-Related Issues

These issues occur once your job attempts to run on the allocated nodes.

### Input File Format Error

**Description**:  
Your job might fail immediately if the input file format is incorrect or if the file is corrupted.

**Resolution**:
- Review the **Job Logs** to identify input file issues.
- Ensure the input file meets the expected format and isn't corrupted.

### Out of Memory (OOM) Issue

**Description**:  
Your job may start but fail during execution because it requires more memory than the allocated node can provide. This can occur in both the **datapipeline** and **inference** stages.

**Resolution**:
- Check the **Job Logs** for OOM errors or memory-related failures.
- Modify your code or input data to reduce memory usage.
- Consider requesting **larger node sizes** with higher memory capacity.
