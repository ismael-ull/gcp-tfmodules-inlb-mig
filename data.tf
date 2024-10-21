data "google_compute_address" "ip_address" {
  project = var.project_id
  region  = var.region
  name    = var.ip_address
}
