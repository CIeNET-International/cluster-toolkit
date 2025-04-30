# Simple Ipynb Launcher

The Simple Ipynb Launcher is comprised of a Jupyter Notebook script that automates the data pipeline and inference
workflows by sending request to SLURM Rest API server, trigerring the data
pipeline and/or inference processes on the respective partitions of the AlphaFold 3 blueprint. 



## Service Logic
There are separate directories for the input to the datapipeline stage of the 
AlphaFold 3 workflow and the model inference stage. Any input files that are placed in these folders 
will be independently processed. Unless specified differently at script launch, results from the
datapipeline stage will be copied into the input directory of the inference stage.

Blueprint implementation logic:

1.  **Folder sharing:** Mounting bucket as a shared storage folder, allows user to upload input file (datapipeline or inference input dataa) directly into the notebook.
2.  **Job Submission:** On the controller, file will be assigned from folder sharing location. 
3.  **Data Pipeline Execution:** The data pipeline is executed on the Slurm data pipeline partition from notebook rest api request.
4.  **Result Storage:** Upon successful completion, the data pipeline outputs are stored in the folder sharing directory within the bucket, allows user to validate the output files.
5.  **Inference Execution:** The inference workflow follows the same job submission and result storage logic as the data pipeline.

## Setup Instructions

Follows instructions in the notebook.



