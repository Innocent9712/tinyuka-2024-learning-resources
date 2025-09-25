# Data sources for availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# Networking Module
module "networking" {
  source = "./modules/networking"

  project_name       = var.project_name
  environment        = var.environment
  vpc_cidr           = var.vpc_cidr
  public_subnet_cidr = var.public_subnet_cidr
  app_subnet_cidr    = var.app_subnet_cidr
  db_subnet_cidr     = var.db_subnet_cidr
  availability_zone  = data.aws_availability_zones.available.names[0]
}

# Security Module
module "security" {
  source = "./modules/security"

  project_name    = var.project_name
  environment     = var.environment
  vpc_id          = module.networking.vpc_id
  vpc_cidr        = var.vpc_cidr
  app_subnet_cidr = var.app_subnet_cidr
}

# Storage Module
module "storage" {
  source = "./modules/storage"

  project_name = var.project_name
  environment  = var.environment
}

# IAM Module
module "iam" {
  source = "./modules/iam"

  project_name   = var.project_name
  environment    = var.environment
  vpc_arn        = module.networking.vpc_arn
  public_bucket  = module.storage.public_bucket_name
  private_bucket = module.storage.private_bucket_name
  visible_bucket = module.storage.visible_bucket_name
}
