# Simple Ipynb Launcher
The Simple Ipynb Launcher is a Jupyter Notebook-based interface designed to run folding jobs on the Alphafold 3 High Throughput solution. We are using Google's Vertex AI Workbench services to host the Jupyter notebook and configure it to interoperate with the Slurm cluster via the Slurm REST API. For convenience, we provide a Jupyter notebook that can run folding jobs and analyze and visualize the output.

## Setup Guide: Jupyter Notebook with SLURM
Please note that the launcher needs 2 specific setup steps:

- **[Setup AF3 with Simple Ipynb Launcher - PART 1: specific cluster settings](./Setup-pre-cluster-deployment.md)**: Instructions to be followed before bringing up the `af3-slurm.yaml` Slurm cluster.

- **[Setup: Setup AF3 with Simple Ipynb Launcher - PART 2: IPython notebook setup](./Setup-post-cluster-deployment.md)**: Instructions for launching the notebook environment.

## Usage Guide
For usage of the Ipynb Launcher consult the [Step-by-Step Instructions](./Ipynb.md)

## Known Limitations
You may encounter the following problems while using the notebook.

### Warning during dependency installation
You may encounter the following warning during dependency installation:

```text
ERROR: pip's dependency resolver does not currently take into account all the packages that are installed. This behaviour is the source of the following dependency conflicts.
google-cloud-bigtable 1.7.3 requires grpc-google-iam-v1<0.13dev,>=0.12.3, but you have grpc-google-iam-v1 0.14.2 which is incompatible
```

**Resolution**: This warning can be **safely ignored**.

The version mismatch does not impact the functionality required by this project. The `google-cloud-bigtable` package is not used in any critical code path, and no issues have been observed during execution.
