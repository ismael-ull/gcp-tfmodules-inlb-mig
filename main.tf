resource "google_compute_instance_template" "instance_template" {
  project      = var.project_id
  name_prefix  = "egress-nlb-"
  machine_type = var.machine_type
  region       = var.region

  disk {
    source_image = var.source_image
    auto_delete  = true
    boot         = true
  }
  tags = var.tags
  network_interface {
    subnetwork = var.subnetwork
  }

  metadata = {
    startup-script = var.startup_script
  }
}

resource "google_compute_region_instance_group_manager" "mig" {
  project            = var.project_id
  name               = "egress-nlb-mig"
  base_instance_name = "egress-proxy"
  region             = var.region
  version {
    instance_template = google_compute_instance_template.instance_template.id
  }
}

resource "google_compute_health_check" "health_check" {
  project             = var.project_id
  name                = "egress-health-check"
  check_interval_sec  = 10
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 3

  tcp_health_check {
    port = var.port
  }
}

resource "google_compute_region_backend_service" "backend_service" {
  project               = var.project_id
  region                = var.region
  name                  = "egress-nlb-backend-service"
  load_balancing_scheme = "INTERNAL"
  protocol              = "TCP"
  health_checks         = [google_compute_health_check.health_check.id]
  backend {
    balancing_mode = "CONNECTION"
    group          = google_compute_region_instance_group_manager.mig.instance_group
  }
}

resource "google_compute_forwarding_rule" "forwarding_rule" {
  region                = var.region
  project               = var.project_id
  name                  = "egress-nlb"
  load_balancing_scheme = "INTERNAL"
  backend_service       = google_compute_region_backend_service.backend_service.id
  ip_protocol           = "TCP"
  ports                 = ["${var.port}"]
  subnetwork            = var.subnetwork
  network               = var.network
  allow_global_access   = true
  ip_address            = data.google_compute_address.ip_address.address
}

resource "google_compute_region_autoscaler" "egress-mig-autoscaler" {
  project = var.project_id
  region  = var.region
  name    = "eggres-mig-autoscaler"
  target  = google_compute_region_instance_group_manager.mig.id

  autoscaling_policy {
    max_replicas    = var.max_size
    min_replicas    = var.min_size
    cooldown_period = 60

    cpu_utilization {
      target = var.cpu_utilization
    }
  }
}
