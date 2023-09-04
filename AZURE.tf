# Define your provider (Azure)
provider "azurerm" {
  features {}
}

# Define variables for customization
variable "resource_group_name" {
  description = "Name of the Azure resource group"
}

variable "location" {
  description = "Azure region where resources will be deployed"
  default     = "East US"  # Change to your desired region
}

# Create an Azure App Service Plan
resource "azurerm_app_service_plan" "tradeadviser_app_service_plan" {
  name                = "tradeadviser-app-service-plan"
  location            = var.location
  resource_group_name = var.resource_group_name
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "Standard"
    size = "S1"
  }
}

# Create an Azure Web App
resource "azurerm_app_service" "tradeadviser_web_app" {
  name                = "tradeadviser-web-app"
  location            = var.location
  resource_group_name = var.resource_group_name
  app_service_plan_id = azurerm_app_service_plan.tradeadviser_app_service_plan.id
  site_config {
    linux_fx_version = "DOCKER|your-container-registry/tradeadviser-app:latest"  # Replace with your container registry and image details
  }
}

# Define an Azure SQL Database
resource "azurerm_sql_server" "tradeadviser_sql_server" {
  name                         = "tradeadviser-sql-server"
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = "your-admin-username"
  administrator_login_password = "your-admin-password"  # Use a secure method for storing secrets

  tags = {
    environment = "production"
  }
}

resource "azurerm_sql_database" "tradeadviser_sql_db" {
  name                = "tradeadviser-db"
  resource_group_name = var.resource_group_name
  location            = var.location
  server_name         = azurerm_sql_server.tradeadviser_sql_server.name
  edition             = "Standard"
  collation           = "SQL_Latin1_General_CP1_CI_AS"
  max_size_gb         = 2
  requested_service_objective_id = "your-desired-performance-tier"  # E.g., "S0"

  tags = {
    environment = "production"
  }
}

# Output the important information
output "app_service_url" {
  value = azurerm_app_service.tradeadviser_web_app.default_site_hostname
}

output "sql_server_fqdn" {
  value = azurerm_sql_server.tradeadviser_sql_server.fully_qualified_domain_name
}

output "sql_database_name" {
  value = azurerm_sql_database.tradeadviser_sql_db.name
}