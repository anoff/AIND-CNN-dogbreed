variable "location" {
  description = "Datacenter location to deploy the VM into"
  default     = "westeurope"
}

variable "vm_name" {
  description = "Name of the virtual machine (acts as prefix for all generated resources)"
  default     = "dlvm"
}

variable "admin_user" {
  description = "Admin username"
  default     = "andreas"
}

variable "admin_key" {
  description = "Public SSH key of the admin user"
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCxvL17DDs92kFEeVLscYWdQOUvd1+ir4tEcLxWg4g11vjIlnX4ldwBxTyDpL1NB1K0ESe92cY64c7CX+9jLOao5NKzAcL+AR+hDfXbFJuCZmlgmZ3SiETPpLu3N7Mmax1sk22Jwr1hXhVrxm6veS9Alv4xtwnAhnY/18dKH6y1ocUX150/IthhP0AxMG8Us49JqMUToeiwhlVTyjWUcRdw3JayRpwMuoZV/R80bpoMOnNKA6sP/ZyWf87nPqGfehQE48S0GirIb6mkzUcKVR+SAxjejuIobdsGhkfg5xWGBNd3ax8QCmF/Vw6XJwXt/K4ABSeTHygkmgTTMxYCVF/4jpoxUwidHRDcyg8wEcNX0vqoqacbgW2Kw3oIwkYEexYPsJu8bbXXQAm7vN4sByLgZGTNbCYRCY+XBxzVGeBSE79LupU+ZBYodZCNuM6kJo8EzBHx2AUa685HSSLFcU2tbb1dNqk+hhwU+Ksgm98BlCtTKzpYXR7tV9FSwkk6NvIG34npc0UWqvBVGsmsSY2c3/7Ua/ZDj/Huux/Apt1msL16UMy20i+BPJg/kuzxjMoDbBqMDIgHbIuW8FL8pnfYHLTHOxwrHzhcGmAkNSohv8Q5jfz/5D58nuIpOrnIq/e1aFoan5oeavtCFOfMXjtJYm02NK7UjjnhN9jEFYgGkQ== offenhaeuser@gmail.com"
}

resource "azurerm_resource_group" "ds" {
  name     = "anoff"
  location = "${var.location}"
}

resource "azurerm_virtual_network" "ds" {
  name                = "${var.vm_name}-network"
  address_space       = ["10.0.0.0/16"]
  location            = "${azurerm_resource_group.ds.location}"
  resource_group_name = "${azurerm_resource_group.ds.name}"
}

resource "azurerm_subnet" "ds" {
  name                 = "${var.vm_name}-subnet"
  resource_group_name  = "${azurerm_resource_group.ds.name}"
  virtual_network_name = "${azurerm_virtual_network.ds.name}"
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_network_interface" "ds" {
  name                = "${var.vm_name}-ni"
  location            = "${azurerm_resource_group.ds.location}"
  resource_group_name = "${azurerm_resource_group.ds.name}"

  ip_configuration {
    name                          = "${var.vm_name}-cfg"
    subnet_id                     = "${azurerm_subnet.ds.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${azurerm_public_ip.ds.id}"
  }
}

resource "azurerm_virtual_machine" "ds" {
  name                             = "${var.vm_name}-vm"
  location                         = "${azurerm_resource_group.ds.location}"
  resource_group_name              = "${azurerm_resource_group.ds.name}"
  network_interface_ids            = ["${azurerm_network_interface.ds.id}"]
  vm_size                          = "Standard_NC6"
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  plan {
    name      = "linuxdsvmubuntu"
    publisher = "microsoft-ads"
    product   = "linux-data-science-vm-ubuntu"
  }

  storage_image_reference {
    publisher = "microsoft-ads"
    offer     = "linux-data-science-vm-ubuntu"
    sku       = "linuxdsvmubuntu"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.vm_name}-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  # Optional data disks
  storage_data_disk {
    name              = "${var.vm_name}-data"
    managed_disk_type = "Standard_LRS"
    create_option     = "FromImage"
    lun               = 0
    disk_size_gb      = "120"
  }

  os_profile {
    computer_name  = "${var.vm_name}"
    admin_username = "${var.admin_user}"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys = [{
      path     = "/home/${var.admin_user}/.ssh/authorized_keys"
      key_data = "${var.admin_key}"
    }]
  }

  tags {
    environment = "datascience-vm, ${var.vm_name}"
  }
}

# create a public IP to bind against the VM
resource "azurerm_public_ip" "ds" {
  name                         = "${var.vm_name}-ip"
  location                     = "${azurerm_resource_group.ds.location}"
  resource_group_name          = "${azurerm_resource_group.ds.name}"
  public_ip_address_allocation = "static"

  tags {
    environment = "datascience-vm, ${var.vm_name}"
  }
}

# dump reference to public IP and VM ID to local files; if anything changes just re-run terraform apply to re-generate the files locally
resource "null_resource" "ds" {
  triggers = {
    vm_id      = "${azurerm_virtual_machine.ds.id}"
    ip_address = "${azurerm_public_ip.ds.ip_address}"
  }

  provisioner "local-exec" {
    command = "echo ${azurerm_virtual_machine.ds.id} > .vm-id"
  }

  provisioner "local-exec" {
    command = "echo ${var.admin_user}@${azurerm_public_ip.ds.ip_address} > .vm-ip"
  }
}
