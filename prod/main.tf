provider "azurerm" { features {
    subscription_id = var.subscription_id
    tenant_id       = var.tenant_id
  }
}

module "network" {
  source              = "../modules/network"
  rg_location         = "EastUS"
  vnet_name           = "ProdVNET"
  rg_name             = "ProdRG"
  nsg_name            = "ProdNSG"
  env_name            = "Prod"
}

module "firewall" {
  source        = "./modules/firewall"
  vnet_name     = module.network.vnet_name
  subnet_name   = module.network.firewall_subnet_name
  resource_group = module.network.resource_group
}

module "bastion" {
  source        = "./modules/bastion"
  vnet_name     = module.network.vnet_name
  subnet_name   = module.network.management_subnet_name
  resource_group = module.network.resource_group
}

module "gateway" {
  source          = "./modules/gateway"
  vnet_name       = module.network.vnet_name
  subnet_name     = module.network.gateway_subnet_name
  resource_group  = module.network.resource_group
  gw_subnet_id    = module.network.gateway_subnet_id
}

module "app_gateway" {
  source             = "./modules/app_gateway"
  vnet_name          = module.network.vnet_name
  subnet_name        = module.network.frontend_subnet_name
  resource_group     = module.network.resource_group
}

module "sql_managed_instance" {
  source              = "./modules/sql_managed_instance"
  vnet_name           = module.network.vnet_name
  subnet_name         = module.network.backend_subnet_name
  resource_group      = module.network.resource_group
}

module "virtual_machines" {
  source           = "./modules/virtual_machines"
  vnet_name        = module.network.vnet_name
  subnet_name      = module.network.backend_subnet_name
  resource_group   = module.network.resource_group
}
