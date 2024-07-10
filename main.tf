module "networking" {
  source = "./modules/networking"

  vpc_id            = var.vpc_id
  priv_subnet_count = var.priv_subnet_count
}

module "security" {
  source = "./modules/security"
}

module "compute" {
  source = "./modules/compute"

  user_data_path           = var.user_data_path
  instance_security_groups = [module.security.instance_sg_id]
  lb_security_groups       = [module.security.lb_sg_id]
  vpc_id                   = var.vpc_id

  priv_subnet_count = var.priv_subnet_count
  priv_subnet_ids   = module.networking.priv_subnet_ids
  pub_subnet_ids    = module.networking.pub_subnet_ids
}