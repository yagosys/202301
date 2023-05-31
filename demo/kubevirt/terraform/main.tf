provider "azurerm" {
  features {}
}
variable cloudinit_file { 
   type = string
   default = "install.ps1"
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "West US"
}

resource "azurerm_virtual_network" "example" {
  name                = "example-network"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "example" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "example" {
  name                = "example-public-ip"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "example" {
  name                = "example-nic"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.example.id
  }
}

resource "azurerm_linux_virtual_machine" "example" {
  name                = "example-machine"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  size                = "Standard_D4_v4"
  admin_username      = "adminuser"
  admin_password      = "W_e_l_c_o_m_e_1_2_3!"
  network_interface_ids = [azurerm_network_interface.example.id]
  custom_data = base64encode(file("${path.module}/cloud-init.yaml")) 

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 200
  }

source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
}

admin_ssh_key {
  username   = "adminuser"
  public_key = file("~/.ssh/id_rsa.pub")
}

provisioner "local-exec" {
# command = "ssh -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa adminuser@${self.public_ip_address} 'tail -f /var/log/cloud-init-output.log --retry | sed '/deploymentcompleted/q'"
  command = "ssh -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa adminuser@${self.public_ip_address} 'tail -f /var/log/cloud-init-output.log --retry | sed \"/deploymentcompleted/q\" '"

}

#provisioner "remote-exec" {
#     inline = [
#      "tail -f /var/log/cloud-init-output.log --retry | sed '/deploymentcompleted/q' ",
#    ]
#   }
#connection {
#    host = self.public_ip_address
#    type = "ssh"
#    port = "22"
#    user = "adminuser"
#    timeout = "120s"
#    password = "W_e_l_c_o_m_e_1_2_3!"
#    #private_key = file("~/.ssh/id_rsa")
#    agent= false
#  }

}


output "public_ip" {
  value = azurerm_linux_virtual_machine.example.public_ip_address
}


output "check_shell_log" {
  value = "Check the shell log at: ssh adminuser@${azurerm_linux_virtual_machine.example.public_ip_address} 'tail -f /var/log/cloud-init-output.log'"
}
