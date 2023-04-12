provider "aws" {
  # profile = var.profile
  access_key = var.access_key
  secret_key = var.secret_key
  region  = var.region
}

module "vpc" {
  source = "./modules/vpc"
}

module "public_subnet" {
  source = "./modules/public-subnet"

  vpc_id = module.vpc.vpc_id
}

module "internet_gateway" {
  source = "./modules/internet-gateway"

  vpc_id = module.vpc.vpc_id
}

module "route_table" {
  source = "./modules/route-table"

  vpc_id              = module.vpc.vpc_id
  internet_gateway_id = module.internet_gateway.internet_gateway_id
  public_subnet_id    = module.public_subnet.public_subnet_id
}

module "ec2" {
  source = "./modules/ec2"

  vpc_id                  = module.vpc.vpc_id
  public_subnet_id        = module.public_subnet.public_subnet_id

  ec2_ssh_key_name        = var.ec2_ssh_key_name
  ec2_ssh_public_key = var.ec2_ssh_public_key
}

terraform {
  cloud {
    organization = "PHackers"

    workspaces {
      name = "proto-hackers"
    }
  }
}
