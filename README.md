# Terraform GCP INLB with GCE MIG backend

This module creates an Network Internal Load Balancer (with regional Access enabled that forwards traffic on port a specific TCP to a GCE Managed instance Gropu with Autoscaler. The options for this MIG such as  machine type, OS, min and max instances can be specified as variables. Also the startup script should be declared as variable in order to install the proper proxy software.

## Overview

The module provisions the following resources:
- GCE Instance template
- GCE Managed instance Group (using the previous template)
- Autoscaler for the previous MIG
- Health Check on specified TCP port
- Forwarding rule
- Backend service


## Usage

To use this module, include it in your Terraform configuration:

```hcl
module "psc_endpoint" {
  source = "./path/to/module"

  project_id                  = "your-gcp-project-id"
  region                      = "your-gcp-region"
  subnetwork                  = "your-subnetwork"
  network                     = "your-network"
  machine_type                = "n1-standard-1"
  source_image                = "debian-cloud/debian-11"
  tags                        = ["tag1", "tag2"]
  min_size                    = 1
  max_size                    = 3
  cpu_utilization             = 0.7
  source_ranges               = ["0.0.0.0/0"]
  target_service_attachment   = "your-target-service-attachment"
  ip_address                  = google_compute_address.inlb_ip.self_link
  port                        = 8888
  startup_script  = <<-EOT
    #!/bin/bash
    YOUR BASH COMMANDS
  EOT
}
```

## Inputs

The module requires the following input variables:

| Name                       | Description                                         | Type   | Required |
|----------------------------|-----------------------------------------------------|--------|----------|
| `project_id`               | The GCP project ID                                  | string | Yes      |
| `region`                   | The GCP region                                      | string | Yes      |
| `subnetwork`               | The subnetwork to use for the instances             | string | Yes      |
| `network`                  | The network to use for the load balancer            | string | Yes      |
| `machine_type`             | Machine type for MIG instances                      | string | Yes      |
| `source_image`             | OS image for MIG instances                          | string | No       |
| `tags`                     | Network tags to apply to VMs                        | list   | Yes      |
| `min_size   `              | Minimal quantity of instances running in the MIG    | number | Yes      |
| `man_size   `              | Maximum quantity of instances running in the MIG    | number | Yes      |
| `cpu_utilization`          | CPU utilization threshold to scale up (default 0.5) | number | No       |
| `source_ranges`            | CIDR source ranges to access MIG instances          | list   | Yes      |
| `startup_script`           | Bash script to excecute after VM creation           | string | Yes      |

## Outputs

The module provides the following output:

| Name                 | Description                             |
|----------------------|-----------------------------------------|
| `forwarding_rule_id` | The ID of the forwarding rule created.  |

## Prerequisites

- Ensure you have set up the necessary GCP credentials and have access to the specified project.
- Enable the required APIs: Compute Engine API.
- A reserved IP address

## Notes

- This modules does not create the required firewall rules to access the instances. Is recommended to use specific tags.
