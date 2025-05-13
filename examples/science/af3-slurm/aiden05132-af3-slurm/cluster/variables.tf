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

variable "af3_job_launcher_runner" {
  description = "Toolkit deployment variable: af3_job_launcher_runner"
  type        = list(any)
}

variable "af3_service_runners" {
  description = "Toolkit deployment variable: af3_service_runners"
  type        = list(any)
}

variable "af3_service_user_runner" {
  description = "Toolkit deployment variable: af3_service_user_runner"
  type        = list(any)
}

variable "controller_runners" {
  description = "Toolkit deployment variable: controller_runners"
  type        = list(any)
}

variable "database_bucket" {
  description = "Toolkit deployment variable: database_bucket"
  type        = string
}

variable "datapipeline_c3dhm_partition" {
  description = "Toolkit deployment variable: datapipeline_c3dhm_partition"
  type        = any
}

variable "datapipeline_runners" {
  description = "Toolkit deployment variable: datapipeline_runners"
  type        = list(any)
}

variable "deployment_name" {
  description = "Toolkit deployment variable: deployment_name"
  type        = string
}

variable "disk_size_gb" {
  description = "Toolkit deployment variable: disk_size_gb"
  type        = number
}

variable "inference_g2_partition" {
  description = "Toolkit deployment variable: inference_g2_partition"
  type        = any
}

variable "inference_runners" {
  description = "Toolkit deployment variable: inference_runners"
  type        = list(any)
}

variable "instance_image" {
  description = "Toolkit deployment variable: instance_image"
  type        = any
}

variable "labels" {
  description = "Toolkit deployment variable: labels"
  type        = any
}

variable "login_runners" {
  description = "Toolkit deployment variable: login_runners"
  type        = list(any)
}

variable "project_id" {
  description = "Toolkit deployment variable: project_id"
  type        = string
}

variable "region" {
  description = "Toolkit deployment variable: region"
  type        = string
}

variable "slurm_restapi_service_runner" {
  description = "Toolkit deployment variable: slurm_restapi_service_runner"
  type        = list(any)
}

variable "slurm_restapi_token_runner" {
  description = "Toolkit deployment variable: slurm_restapi_token_runner"
  type        = list(any)
}

variable "slurm_restapi_user_runner" {
  description = "Toolkit deployment variable: slurm_restapi_user_runner"
  type        = list(any)
}

variable "subnetwork_self_link_af3_network" {
  description = "Automatically generated input from previous groups (gcluster import-inputs --help)"
  type        = any
}

variable "zone" {
  description = "Toolkit deployment variable: zone"
  type        = string
}
