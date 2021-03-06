resource "azurerm_subnet" "demo" {
  name                 = "${var.aks-name}-subnet"
  virtual_network_name = var.aks-vnet
  resource_group_name  = var.mgmt-rg
  address_prefixes     = [var.aks-subnet-cidr]
  service_endpoints    = ["Microsoft.KeyVault","Microsoft.ContainerRegistry","Microsoft.AzureCosmosDB"]
}

resource "azurerm_kubernetes_cluster" "demo" {
  name                = var.aks-name
  location            = var.location
  resource_group_name = var.rg-name
  dns_prefix          = var.aks-name
  depends_on          = [azurerm_resource_group.demo]
  kubernetes_version  = var.k8-version

  default_node_pool {
    name           = "pool1"
    node_count     = 1
    //availability_zones = ["1", "2", "3"]
    vm_size        = "Standard_DS2_v2"
    vnet_subnet_id = azurerm_subnet.demo.id
  }

  identity {
    type = "SystemAssigned"
  }

  addon_profile {
    aci_connector_linux {
      enabled = false
    }


    http_application_routing {
      enabled = false
    }

    azure_policy {
      enabled = true
    }

    kube_dashboard {
      enabled = true
    }

    oms_agent {
      enabled = false
    }
  }
  
  role_based_access_control {
    enabled = true 
    azure_active_directory {
      managed = true
      admin_group_object_ids = [var.admin_group_object_id]
    }
  }


  private_cluster_enabled = false

  network_profile {
    network_plugin = "kubenet"
    network_policy = "calico"
    load_balancer_sku = "Standard"
  }

  tags = var.tags
}



output kube_id {
  value = azurerm_kubernetes_cluster.demo.identity[0]
}
