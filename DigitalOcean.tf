

# Configure the DigitalOcean provider
provider "digitalocean" {
  token = "YOUR_DIGITALOCEAN_API_TOKEN"
}

# Create a Virtual Network
resource "digitalocean_vpc" "trade_adviser_vpc" {
  name = "trade-adviser-vpc"
}

# Create a Virtual Network Firewall Rule (allow SSH)
resource "digitalocean_firewall" "allow_ssh" {
  name    = "allow-ssh"
  vpc_id  = digitalocean_vpc.trade_adviser_vpc.id
  inbound_rule {
    protocol           = "tcp"
    port_range         = "22"
    source_addresses  = ["0.0.0.0/0"]
  }
}

# Create a Droplet (App Server)
resource "digitalocean_droplet" "trade_adviser_app" {
  name      = "trade-adviser-app"
  region    = "nyc1" # Replace with your desired region
  image     = "ubuntu-20-04-x64" # Replace with your desired OS image
  size      = "s-1vcpu-1gb" # Replace with your desired Droplet size
  vpc_uuid  = digitalocean_vpc.trade_adviser_vpc.id

  connection {
    type        = "ssh"
    user        = "your-ssh-username"
    private_key = file("~/.ssh/id_rsa") # Replace with your SSH private key path
    timeout     = "2m"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y <your-app-dependencies>",
      # Add more setup and deployment commands here
    ]
  }
}

# Create a DigitalOcean managed database
resource "digitalocean_database_cluster" "trade_adviser_db" {
  name        = "trade-adviser-db"
  engine      = "mysql"
  version     = "13"
  node_count  = 1 # Adjust based on your needs
  size        = "db-s-1vcpu-1gb" # Adjust based on your needs
  region      = "nyc1" # Replace with your desired region

  tags = ["trade_adviser"]

  private_network_uuids = [digitalocean_vpc.trade_adviser_vpc.id]

  maintenance_window {
    day_of_week = "sunday"
    start_time  = "06:00:00"
  }
}

# Output the IP address of the App Server
output "app_server_ip" {
  value = digitalocean_droplet.trade_adviser_app.ipv4_address
}














