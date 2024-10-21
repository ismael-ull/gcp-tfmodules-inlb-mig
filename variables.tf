variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region"
  type        = string
}

variable "subnetwork" {
  description = "The subnetwork to use for the instances"
  type        = string
}

variable "network" {
  description = "The network to use for the load balancer"
  type        = string
}

variable "machine_type" {
  description = "Machine type for MIG instances"
  type        = string
}

variable "tags" {
  description = "Network tags for MIG instances"
  type        = list
}

variable "source_image" {
  description = "Source image for VMS"
  type        = string
  default     = "debian-cloud/debian-11"
}

variable "min_size" {
  description = "Minimal quantity of instances running in the MIG"
  type        = number
}

variable "max_size" {
  description = "Maximmun quantity of instances running in the MIG"
  type        = number
}

variable "cpu_utilization" {
  description = "Target CPU utilization value to scale up. From 0.0 to 1.0"
  type        = number
  default     = 0.5
}

variable "ip_address" {
  description = "Internal IP address reserved for this forwarding rule"
  type        = string
}

variable "port" {
  description = "Proxy port to listen to"
  type        = number
}

variable "startup_script" {
  description = "The startup script for the instance"
  type        = string
}
