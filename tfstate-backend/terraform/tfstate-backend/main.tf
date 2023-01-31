locals {
  enabled = module.this.enabled
}

module "tfstate_backend" {
  source  = "cloudposse/tfstate-backend/aws"
  version = "0.38.1"

  force_destroy                 = false
  prevent_unencrypted_uploads   = true
  enable_server_side_encryption = true
  enable_point_in_time_recovery = false

  context = module.this.context
}
