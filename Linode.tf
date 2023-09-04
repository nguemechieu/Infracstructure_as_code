# Define provider for Linode
provider "linode" {
  token = "YOUR_LINODE_API_TOKEN"
}

# Create a Linode instance for the web server
resource "linode_instance" "web_server" {
  label      = "tradeadviser-web"
  region     = "us-east"
  image      = "linode/ubuntu20.04"
  type       = "g6-standard-2"
  authorized_keys = ["YOUR_SSH_PUBLIC_KEY"]
  root_pass  = "YOUR_ROOT_PASSWORD"
}

# Create a Linode instance for the database server
resource "linode_instance" "db_server" {
  label      = "tradeadviser-db"
  region     = "us-east"
  image      = "linode/ubuntu20.04"
  type       = "g6-standard-2"
  authorized_keys = ["YOUR_SSH_PUBLIC_KEY"]
  root_pass  = "YOUR_ROOT_PASSWORD"
}

# Define Linode StackScript for configuring the web server
resource "linode_stackscript" "web_server_config" {
  label       = "web_server_config"
  script      = file("web_server_setup.sh") # Create a script for web server setup
  description = "Setup TradeAdviser web server"
  is_public   = true
}

# Create a Linode Instance using the StackScript
resource "linode_instance" "web_server_configured" {
  label      = "tradeadviser-web-configured"
  region     = "us-east"
  image      = "linode/ubuntu20.04"
  type       = "g6-standard-2"
  authorized_keys = ["YOUR_SSH_PUBLIC_KEY"]
  stackscript_id = linode_stackscript.web_server_config.id
  stackscript_data = {
    DB_HOST = linode_instance.db_server.ipv4_address
  }
}

# Output the IP addresses for the web and database servers
output "web_server_ip" {
  value = linode_instance.web_server.ipv4_address
}

output "db_server_ip" {
  value = linode_instance.db_server.ipv4_address
}
