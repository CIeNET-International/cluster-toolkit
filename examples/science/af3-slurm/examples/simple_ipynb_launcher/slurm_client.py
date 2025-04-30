import requests
import os
from google.cloud import secretmanager_v1
from google.api_core.exceptions import NotFound
from typing import Optional, Dict
import jinja2
import datetime
import time

def is_valid_path(input_path: str, expected_prefix: str) -> bool:
    input_path = os.path.abspath(input_path)
    return os.path.isabs(input_path) and input_path.startswith(expected_prefix)


class AF3SlurmClient:
    """An AF3 client for interacting with the Slurm API."""

    def __init__(self, remote_host: str, remote_port: int, gcp_project_id: str, gcp_secret_name: str, af3_config: dict):
        self.base_url = f"http://{remote_host}:{remote_port}/slurm/v0.0.41"
        self.gcp_project_id = gcp_project_id
        self.gcp_secret_name = gcp_secret_name
        self.af3_config = af3_config

    def __get_header(self) -> Optional[Dict]:
        client = secretmanager_v1.SecretManagerServiceClient()
        secret_path = f"projects/{self.gcp_project_id}/secrets/{self.gcp_secret_name}/versions/latest"

        try:
            response = client.access_secret_version(name=secret_path)
            token = response.payload.data.decode("UTF-8")
            print("[INFO] Retrieved token from Secret Manager.")
            return {"X-SLURM-USER-TOKEN": token}
        except NotFound:
            print(f"[ERROR] Secret '{self.gcp_secret_name}' not found.")
            raise NotFound(
                f"[ERROR] Secret '{self.gcp_secret_name}' not found.")
        except Exception as e:
            print(f"[ERROR] Failed to retrieve token: {e}")
            raise Exception(f"[ERROR] Failed to retrieve token: {e}")

    def __retrieve_url(self, endpoint):
        return f"{self.base_url}/{endpoint}"

    def ping(self):
        """Pings the Slurm API server."""
        url = self.__retrieve_url("ping")
        try:
            header = self.__get_header()
            response = requests.get(url, headers=header)
            response.raise_for_status()
            print(f"Ping response code : {response.status_code}")
            return response.json()
        except requests.exceptions.RequestException as e:
            print(f"Error pinging Slurm API: {e}")
            return None

    def _render_template(self, config_options: dict) -> str:
        """Renders the Jinja2 template with af3_config values."""
        env = jinja2.Environment(loader=jinja2.FileSystemLoader(
            os.path.dirname(self.af3_config["job_template_path"])))
        template = env.get_template(
            os.path.basename(self.af3_config["job_template_path"]))
        rendered = template.render(config_options)
        return rendered

    def submit_job(self, job_config: dict, job_command: str):
        """Submits a job to Slurm server."""
        url = self.__retrieve_url("job/submit")
        submit_input = {"job": job_config, "script": job_command}
        try:
            header = self.__get_header()
            response = requests.post(url, headers=header, json=submit_input)
            response.raise_for_status()
            return response.json()
        except requests.exceptions.RequestException as e:
            print(f"Error submitting job to Slurm: {e}")
            return None

    def submit_data_pipeline_job(self, job_config: dict, input_file: str, output_path: Optional[str] = None):
        """Submits a data pipeline job to Slurm server."""
        if not is_valid_path(input_file, self.af3_config["default_folder"]):
            raise ValueError(
                f"Input file path '{input_file}' is not valid. It should be absolute and start with '{self.af3_config['input_prefix']}'.")
        if output_path is None:
            # Generate a timestamped output path if not provided
            timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
            output_path = os.path.join(self.af3_config["default_folder"], "datapipeline", f"output_{timestamp}", os.path.splitext(
                os.path.basename(input_file))[0])

        if not is_valid_path(output_path, self.af3_config["default_folder"]):
            raise ValueError(
                f"Output file path '{output_path}' is not valid. It should be absolute and start with '{self.af3_config['input_prefix']}'.")
        script_options = {**self.af3_config, ** {
            "input_path": input_file,
            "output_path": output_path,
            "job-type": "datapipeline",
        }}
        script = self._render_template(script_options)
        return self.submit_job(job_config, script)


    def submit_inference_job(self, job_config: dict, input_file: str, output_path: Optional[str] = None):
        """Submits an inference job to Slurm server."""
        if not is_valid_path(input_file, self.af3_config["default_folder"]):
            raise ValueError(
                f"Input file path '{input_file}' is not valid. It should be absolute and start with '{self.af3_config['input_prefix']}'.")

        if output_path is None:
            timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
            output_path = os.path.join(self.af3_config["default_folder"], "inference", f"output_{timestamp}", os.path.splitext(
                os.path.basename(input_file))[0])
        if not is_valid_path(output_path, self.af3_config["default_folder"]):
            raise ValueError(
                f"Output file path '{output_path}' is not valid. It should be absolute and start with '{self.af3_config['input_prefix']}'.")
        script_options = {**self.af3_config, ** {
            "input_path": input_file,
            "output_path": output_path,
            "job-type": "inference",
        }}
        script = self._render_template(script_options)
        return self.submit_job(job_config, script)

    def cancel_job(self, job_id):
        """Cancels a job on the Slurm server."""
        url = self.__retrieve_url(f"job/{job_id}/cancel")
        try:
            header = self.__get_header()
            response = requests.post(url, headers=header)
            response.raise_for_status()
            return response.json()
        except requests.exceptions.RequestException as e:
            print(f"Error canceling job {job_id} on Slurm: {e}")
            return None

    def get_job(self, job_id):
        """Retrieves information about a specific job."""
        url = self.__retrieve_url(f"job/{job_id}")
        try:
            response = requests.get(url, headers=self.header_token)
            response.raise_for_status()
            return response.json()
        except requests.exceptions.RequestException as e:
            print(f"Error retrieving job {job_id} from Slurm: {e}")
            return None

    def get_all_jobs(self):
        """Retrieves information about all jobs."""
        url = os.path.join(self.base_url, "jobs")
        url = self.__retrieve_url("jobs")
        try:
            response = requests.get(url, headers=self.header_token)
            response.raise_for_status()
            return response.json()
        except requests.exceptions.RequestException as e:
            print(f"Error retrieving all jobs from Slurm: {e}")
            return None
