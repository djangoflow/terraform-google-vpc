terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

data "google_client_config" "google" {}

resource "google_compute_network" "vpc_network" {
  name                     = var.name
  auto_create_subnetworks  = true
  enable_ula_internal_ipv6 = var.enable_ula_internal_ipv6
  description              = var.description
}

module "cloud-nat" {
  source        = "terraform-google-modules/cloud-nat/google"
  version       = "~> 1.2"
  project_id    = data.google_client_config.google.project
  region        = data.google_client_config.google.region
  router        = "${var.name}-nat-router"
  create_router = true
  network       = google_compute_network.vpc_network.id
  nat_ips       = var.nat_ips
}

resource "google_compute_firewall" "ingress-nginx-controller-admission" {
  name    = "${var.name}-ingress-nginx-controller-admission"
  network = google_compute_network.vpc_network.id

  allow {
    protocol = "tcp"
    ports    = ["8443"]
  }

  source_ranges = [
    "172.0.0.0/8"
  ]
}

resource "google_compute_global_address" "private_ip_address" {
  name          = "${var.name}-private-ip-range"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc_network.id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.vpc_network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}
