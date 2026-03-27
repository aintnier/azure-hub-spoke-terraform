# -----------------------------------------------------------------------------
# General
# -----------------------------------------------------------------------------
variable "location" {
  description = "Azure region for all resources"
  type        = string
  default     = "westeurope"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    project     = "hub-spoke-portfolio"
    layer       = "layer1-manual-peering"
    managed_by  = "terraform"
    environment = "dev"
  }
}

# -----------------------------------------------------------------------------
# Networking — Address Spaces
# -----------------------------------------------------------------------------
variable "hub_vnet_address_space" {
  description = "Address space for the Hub VNet"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "hub_firewall_subnet_prefix" {
  description = "Address prefix for the AzureFirewallSubnet (min /26)"
  type        = list(string)
  default     = ["10.0.0.0/26"]
}

variable "hub_bastion_subnet_prefix" {
  description = "Address prefix for the AzureBastionSubnet (min /26)"
  type        = list(string)
  default     = ["10.0.1.0/26"]
}

variable "spoke1_vnet_address_space" {
  description = "Address space for Spoke 1 VNet"
  type        = list(string)
  default     = ["10.1.0.0/16"]
}

variable "spoke1_workload_subnet_prefix" {
  description = "Address prefix for the workload subnet in Spoke 1"
  type        = list(string)
  default     = ["10.1.1.0/24"]
}

variable "spoke2_vnet_address_space" {
  description = "Address space for Spoke 2 VNet"
  type        = list(string)
  default     = ["10.2.0.0/16"]
}

variable "spoke2_workload_subnet_prefix" {
  description = "Address prefix for the workload subnet in Spoke 2"
  type        = list(string)
  default     = ["10.2.1.0/24"]
}

# -----------------------------------------------------------------------------
# Compute — Test VMs
# -----------------------------------------------------------------------------
variable "vm_size" {
  description = "Size of the test virtual machines"
  type        = string
  default     = "Standard_B2s"
}

variable "admin_username" {
  description = "Admin username for the test VMs"
  type        = string
  default     = "azureadmin"
}

variable "admin_ssh_public_key_path" {
  description = "Path to the SSH public key for VM authentication"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}
