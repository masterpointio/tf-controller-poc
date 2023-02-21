module "vpc" {
  source  = "cloudposse/vpc/aws"
  version = "2.0.0"

  context = module.this.context

  namespace = var.namespace
  stage     = var.stage
  name      = var.name

  ipv4_primary_cidr_block = var.ipv4_primary_cidr_block

  assign_generated_ipv6_cidr_block = false
}

module "dynamic_subnets" {
  source  = "cloudposse/dynamic-subnets/aws"
  version = "2.0.4"

  context = module.this.context

  namespace = var.namespace
  stage     = var.stage
  name      = var.name

  availability_zones = var.availability_zones
  vpc_id             = module.vpc.vpc_id
  igw_id             = [module.vpc.igw_id]
  ipv4_cidr_block    = [module.vpc.vpc_cidr_block]
}