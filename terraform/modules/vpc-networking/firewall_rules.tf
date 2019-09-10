# Module: vpc-networking/
# File: filewall_rules.tf



data "http" "local-public-ip" {
  url = "http://ifconfig.co/ip"
}


resource "google_compute_firewall" "allow-ssh-kubernetes" {
  depends_on = [
    "data.http.local-public-ip"
  ]
  name    = "allow-ssh-kubernetes"
  network = "${google_compute_network.vpc-network.name}"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = [ "${chomp("${data.http.local-public-ip.body}")}/32" ]
  target_tags = [ "kubernetes" ]
}


