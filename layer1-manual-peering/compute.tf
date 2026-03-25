# -----------------------------------------------------------------------------
# Network Interface — Spoke 1 VM
# -----------------------------------------------------------------------------
resource "azurerm_network_interface" "spoke1_vm" {
  name                = "nic-vm-spoke1-${var.environment}"
  location            = azurerm_resource_group.layer1.location
  resource_group_name = azurerm_resource_group.layer1.name
  tags                = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.spoke1_workload.id
    private_ip_address_allocation = "Dynamic"
  }
}

# -----------------------------------------------------------------------------
# Network Interface — Spoke 2 VM
# -----------------------------------------------------------------------------
resource "azurerm_network_interface" "spoke2_vm" {
  name                = "nic-vm-spoke2-${var.environment}"
  location            = azurerm_resource_group.layer1.location
  resource_group_name = azurerm_resource_group.layer1.name
  tags                = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.spoke2_workload.id
    private_ip_address_allocation = "Dynamic"
  }
}

# -----------------------------------------------------------------------------
# Linux VM — Spoke 1 (Connectivity Test)
# -----------------------------------------------------------------------------
resource "azurerm_linux_virtual_machine" "spoke1" {
  name                            = "vm-spoke1-${var.environment}"
  location                        = azurerm_resource_group.layer1.location
  resource_group_name             = azurerm_resource_group.layer1.name
  size                            = var.vm_size
  admin_username                  = var.admin_username
  disable_password_authentication = true
  network_interface_ids           = [azurerm_network_interface.spoke1_vm.id]
  tags                            = var.tags

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.admin_ssh_public_key_path)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

# -----------------------------------------------------------------------------
# Linux VM — Spoke 2 (Connectivity Test)
# -----------------------------------------------------------------------------
resource "azurerm_linux_virtual_machine" "spoke2" {
  name                            = "vm-spoke2-${var.environment}"
  location                        = azurerm_resource_group.layer1.location
  resource_group_name             = azurerm_resource_group.layer1.name
  size                            = var.vm_size
  admin_username                  = var.admin_username
  disable_password_authentication = true
  network_interface_ids           = [azurerm_network_interface.spoke2_vm.id]
  tags                            = var.tags

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.admin_ssh_public_key_path)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}
