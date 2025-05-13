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

output "network_id_af3_network" {
  description = "Generated output from module 'af3_network'"
  value       = module.af3_network.network_id
}

output "subnetwork_af3_network" {
  description = "Generated output from module 'af3_network'"
  value       = module.af3_network.subnetwork
}

output "subnetwork_name_af3_network" {
  description = "Automatically-generated output exported for use by later deployment groups"
  value       = module.af3_network.subnetwork_name
  sensitive   = true
}

output "subnetwork_self_link_af3_network" {
  description = "Automatically-generated output exported for use by later deployment groups"
  value       = module.af3_network.subnetwork_self_link
  sensitive   = true
}
