# Use an official Ubuntu as a parent image
FROM ubuntu:latest

# Install required packages
RUN apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository ppa:hashicorp/terraform && \
    apt-get update && \
    apt-get install -y terraform

# Set the working directory
WORKDIR /app

# Copy your Terraform configuration files into the container
COPY . /app

# Entry point command to run Terraform
CMD ["terraform", "init", "&&", "terraform", "apply", "-auto-approve"]
