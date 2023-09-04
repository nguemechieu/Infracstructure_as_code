provider "google" {
  credentials = file("<path-to-your-service-account-key.json>")
  project     = "your-project-id"
  region      = "us-central1"  # Change to your desired region
}

resource "google_compute_network" "vpc_network" {
  name                    = "my-vpc-network"
  auto_create_subnetworks = true
}

resource "google_compute_instance" "tradeadviser_vm" {
  name         = "tradeadviser-vm"
  machine_type = "n1-standard-2"
  zone         = "us-central1-a"  # Change to your desired zone
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
  }
  network_interface {
    network = google_compute_network.vpc_network.self_link
  }
}

resource "google_compute_firewall" "allow-http" {
  name    = "allow-http"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
}