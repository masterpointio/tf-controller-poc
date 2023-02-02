module "ec2_instance" {
  source = "git::https://github.com/masterpointio/terraform-aws-ssm-agent.git?ref=tags/0.15.1"

  context = module.this.context
  tags    = module.this.tags

  stage      = var.stage
  namespace  = var.namespace
  vpc_id     = local.vpc_id
  subnet_ids = local.private_subnet_ids
}