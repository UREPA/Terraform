terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 3.5.0"
    }
  }
}

provider "google" {
  credentials = file("account.json")
  project     = var.project
  region      = var.region
  zone        = var.zone
}

variable "project" {}
variable "region" { default = "europe-west4" }
variable "zone" { default = "europe-west4-a" }
variable "instance_name" { default = "wordpress-vm" }
variable "machine_type" { default = "e2-micro" }
variable "disk_size_gb" { default = 10 }

resource "google_compute_instance" "wordpress" {
  name         = var.instance_name
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      size  = var.disk_size_gb
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata_startup_script = file("startup.sh")

  tags = ["http-server", "https-server"]
}

resource "google_compute_firewall" "default" {
  name    = "allow-http-https"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  target_tags = ["http-server", "https-server"]
}

output "wordpress_ip" {
  value = google_compute_instance.wordpress.network_interface[0].access_config[0].nat_ip
}
