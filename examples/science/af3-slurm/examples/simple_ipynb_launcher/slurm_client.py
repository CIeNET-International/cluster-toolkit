import requests
import json
import os
from google.cloud import secretmanager_v1
from google.api_core.exceptions import NotFound
from typing import Optional,Dict
class SlurmClient:
    def __init__(self, remote_host: str, remote_port: int, gcp_project_id:str, gcp_secret_name:str):
        self.base_url = f"http://{remote_host}:{remote_port}/slurm/v0.0.41"
        self.gcp_project_id = gcp_project_id
        self.gcp_secret_name = gcp_secret_name
        
    def __get_header(self)->Optional[Dict]:
        client = secretmanager_v1.SecretManagerServiceClient()
        secret_path = f"projects/{self.gcp_project_id}/secrets/{self.gcp_secret_name}/versions/latest"

        try:
            response = client.access_secret_version(name=secret_path)
            token = response.payload.data.decode("UTF-8")
            print("[INFO] Retrieved token from Secret Manager.")
            return {"X-SLURM-USER-TOKEN": token}
        except NotFound:
            print(f"[ERROR] Secret '{self.gcp_secret_name}' not found.")
            raise NotFound(f"[ERROR] Secret '{self.gcp_secret_name}' not found.")
        except Exception as e:
            print(f"[ERROR] Failed to retrieve token: {e}")
            raise Exception(f"[ERROR] Failed to retrieve token: {e}")
            
        
    def __get_url(self, endpoint):
        return f"{self.base_url}/{endpoint}"

    def ping(self):
        """Pings the Slurm API server."""
        url = self.__get_url("ping")
        try:
            header = self.__get_header()
            response = requests.get(url, headers=header)
            response.raise_for_status()
            print(f"Ping response code : {response.status_code}")
            return response.json()
        except requests.exceptions.RequestException as e:
            print(f"Error pinging Slurm API: {e}")
            return None

    def submit_job(self, job_config, script_path):
        """Submits a job to Slurm server."""
        url = self.__get_url("job/submit")
        submit_input = {"job": job_config, "script": script_path}
        try:
            header = self.__get_header()
            response = requests.post(url, headers=header, json=submit_input)
            response.raise_for_status()
            return response.json()
        except requests.exceptions.RequestException as e:
            print(f"Error submitting job to Slurm: {e}")
            return None

    def get_job(self, job_id):
        """Retrieves information about a specific job."""
        url = self.__get_url(f"job/{job_id}")
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
        url = self.__get_url("jobs")
        try:
            response = requests.get(url, headers=self.header_token)
            response.raise_for_status()
            return response.json()
        except requests.exceptions.RequestException as e:
            print(f"Error retrieving all jobs from Slurm: {e}")
            return None


def main():
    data = {}
    try:
        with open("slurm_info.json", "r", encoding="utf-8") as f:
            data = json.load(f)
    except FileNotFoundError:
        print("Can't find token file.")
        exit()
    client = SlurmClient(remote_ip=data["external_ip"],gcp_project_id="cienet-549295",gcp_secret_name="af3_slurm_api_token")


    # Example Usage:
    # Ping

    ping_response = client.ping()
    print("Ping Response:")
    print(json.dumps(ping_response))

    job_config = {
        "account": "af3",
        "tasks": 1,
        "name": "af3_job",
        "partition": "c3dhm",
        "current_working_directory": "/home/af3",
        "environment": [
            "PATH=/bin:/usr/bin/:/usr/local/bin/",
            "LD_LIBRARY_PATH=/lib/:/lib64/:/usr/local/lib",
        ],
    }
    script_config = "#!/bin/bash\nsleep 15"
    submit_job_response = client.submit_job(job_config, script_config)
    print("Submit Job Response:", submit_job_response)


if __name__ == "__main__":
    main()