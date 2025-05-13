/**
  * Copyright 2023 Google LLC
  *
  * Licensed under the Apache License, Version 2.0 (the "License");
  * you may not use this file except in compliance with the License.
  * You may obtain a copy of the License at
  *
  *      http://www.apache.org/licenses/LICENSE-2.0
  *
  * Unless required by applicable law or agreed to in writing, software
  * distributed under the License is distributed on an "AS IS" BASIS,
  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  * See the License for the specific language governing permissions and
  * limitations under the License.
  */

module "slurmrestapi_bucket" {
  source        = "./modules/embedded/modules/file-system/pre-existing-network-storage"
  fs_type       = "gcsfuse"
  local_mount   = var.notebook.jupyter_notebook_bucket_local_mount
  mount_options = "defaults,_netdev,implicit_dirs,allow_other,dir_mode=0777,file_mode=777"
  remote_mount  = "gs://${var.af3ipynb_bucket}"
}

module "slurmrestapi_notebook" {
  source          = "./modules/embedded/community/modules/compute/notebook"
  deployment_name = var.deployment_name
  gcs_bucket_path = module.slurmrestapi_bucket.network_storage.remote_mount
  instance_image = {
    family  = "tf-latest-cpu"
    project = "deeplearning-platform-release"
  }
  labels       = var.labels
  machine_type = var.notebook.machine_type
  mount_runner = module.slurmrestapi_bucket.mount_runner
  network_interfaces = [{
    network = var.network_id_af3_network
    subnet  = var.subnetwork_af3_network.id
  }]
  project_id = var.project_id
  zone       = var.zone
}
