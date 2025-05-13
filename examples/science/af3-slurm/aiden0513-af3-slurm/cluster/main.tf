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

module "database_bucket" {
  source        = "./modules/embedded/modules/file-system/pre-existing-network-storage"
  fs_type       = "gcsfuse"
  local_mount   = "/mnt/databases"
  mount_options = "defaults,_netdev,implicit_dirs,allow_other,dir_mode=0555,file_mode=555"
  remote_mount  = var.database_bucket
}

module "login_startup" {
  source          = "./modules/embedded/modules/scripts/startup-script"
  deployment_name = var.deployment_name
  labels          = var.labels
  project_id      = var.project_id
  region          = var.region
  runners         = flatten([var.login_runners, var.af3_service_user_runner, var.slurm_restapi_user_runner, var.slurm_restapi_token_runner])
}

module "datapipeline_startup" {
  source          = "./modules/embedded/modules/scripts/startup-script"
  deployment_name = var.deployment_name
  labels          = var.labels
  project_id      = var.project_id
  region          = var.region
  runners         = flatten([var.datapipeline_runners, var.af3_service_user_runner, var.slurm_restapi_user_runner])
}

module "inference_startup" {
  source          = "./modules/embedded/modules/scripts/startup-script"
  deployment_name = var.deployment_name
  labels          = var.labels
  project_id      = var.project_id
  region          = var.region
  runners         = flatten([var.inference_runners, var.af3_service_user_runner, var.slurm_restapi_user_runner])
}

module "controller_startup" {
  source          = "./modules/embedded/modules/scripts/startup-script"
  deployment_name = var.deployment_name
  labels          = var.labels
  project_id      = var.project_id
  region          = var.region
  runners         = flatten([var.controller_runners, var.af3_job_launcher_runner, var.af3_service_user_runner, var.af3_service_runners, var.slurm_restapi_user_runner, var.slurm_restapi_service_runner])
}

module "datapipeline_c3dhm_nodeset" {
  source = "./modules/embedded/community/modules/compute/schedmd-slurm-gcp-v6-nodeset"
  advanced_machine_features = {
    threads_per_core = null
  }
  allow_automatic_updates = false
  bandwidth_tier          = "tier_1_enabled"
  disk_size_gb            = var.disk_size_gb
  disk_type               = "pd-balanced"
  instance_image          = var.instance_image
  instance_image_custom   = true
  labels                  = var.labels
  machine_type            = var.datapipeline_c3dhm_partition.machine_type
  name                    = "datapipeline_c3dhm_nodeset"
  node_count_dynamic_max  = var.datapipeline_c3dhm_partition.node_count_dynamic
  node_count_static       = var.datapipeline_c3dhm_partition.node_count_static
  project_id              = var.project_id
  region                  = var.region
  reservation_name        = "aiden-c3d-highmem-reservation"
  startup_script          = module.datapipeline_startup.startup_script
  subnetwork_self_link    = var.subnetwork_self_link_af3_network
  zone                    = var.zone
}

module "datapipeline_c3dhm_partition" {
  source         = "./modules/embedded/community/modules/compute/schedmd-slurm-gcp-v6-partition"
  exclusive      = false
  nodeset        = flatten([module.datapipeline_c3dhm_nodeset.nodeset])
  partition_name = "datac3d"
}

module "inference_g2_nodeset" {
  source = "./modules/embedded/community/modules/compute/schedmd-slurm-gcp-v6-nodeset"
  advanced_machine_features = {
    threads_per_core = null
  }
  allow_automatic_updates = false
  bandwidth_tier          = "gvnic_enabled"
  disk_size_gb            = var.disk_size_gb
  disk_type               = "pd-balanced"
  instance_image          = var.instance_image
  instance_image_custom   = true
  labels                  = var.labels
  machine_type            = var.inference_g2_partition.machine_type
  name                    = "inference_g2_nodeset"
  node_count_dynamic_max  = var.inference_g2_partition.node_count_dynamic
  node_count_static       = var.inference_g2_partition.node_count_static
  project_id              = var.project_id
  region                  = var.region
  reservation_name        = "aiden0416-g2-12"
  startup_script          = module.inference_startup.startup_script
  subnetwork_self_link    = var.subnetwork_self_link_af3_network
  zone                    = var.zone
}

module "inference_g2_partition" {
  source         = "./modules/embedded/community/modules/compute/schedmd-slurm-gcp-v6-partition"
  exclusive      = false
  nodeset        = flatten([module.inference_g2_nodeset.nodeset])
  partition_name = "infg2"
}

module "slurm_login" {
  source                  = "./modules/embedded/community/modules/scheduler/schedmd-slurm-gcp-v6-login"
  disk_size_gb            = var.disk_size_gb
  enable_login_public_ips = true
  instance_image          = var.instance_image
  instance_image_custom   = true
  labels                  = var.labels
  machine_type            = "n2-standard-4"
  name_prefix             = "login"
  project_id              = var.project_id
  region                  = var.region
  subnetwork_self_link    = var.subnetwork_self_link_af3_network
  zone                    = var.zone
}

module "slurm_controller" {
  source                             = "./modules/embedded/community/modules/scheduler/schedmd-slurm-gcp-v6-controller"
  compute_startup_scripts_timeout    = 2000
  controller_startup_script          = module.controller_startup.startup_script
  controller_startup_scripts_timeout = 2000
  deployment_name                    = var.deployment_name
  disk_size_gb                       = var.disk_size_gb
  enable_external_prolog_epilog      = true
  instance_image                     = var.instance_image
  instance_image_custom              = true
  labels                             = var.labels
  login_nodes                        = flatten([module.slurm_login.login_nodes])
  login_startup_script               = module.login_startup.startup_script
  login_startup_scripts_timeout      = 2000
  machine_type                       = "c2-standard-8"
  network_storage                    = flatten([module.database_bucket.network_storage])
  nodeset                            = flatten([module.inference_g2_partition.nodeset, flatten([module.datapipeline_c3dhm_partition.nodeset])])
  nodeset_dyn                        = flatten([module.inference_g2_partition.nodeset_dyn, flatten([module.datapipeline_c3dhm_partition.nodeset_dyn])])
  nodeset_tpu                        = flatten([module.inference_g2_partition.nodeset_tpu, flatten([module.datapipeline_c3dhm_partition.nodeset_tpu])])
  partitions                         = flatten([module.inference_g2_partition.partitions, flatten([module.datapipeline_c3dhm_partition.partitions])])
  project_id                         = var.project_id
  region                             = var.region
  subnetwork_self_link               = var.subnetwork_self_link_af3_network
  zone                               = var.zone
}

module "hpc_dashboard" {
  source          = "./modules/embedded/modules/monitoring/dashboard"
  deployment_name = var.deployment_name
  labels          = var.labels
  project_id      = var.project_id
}
