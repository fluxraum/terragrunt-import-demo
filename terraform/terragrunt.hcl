#####################
# Editable parameters
# ---------------------------------------------------------------------------------------------------------------------
# GLOBAL PARAMETERS
# These variables apply to all configurations in this subfolder. These are automatically merged into the child `terragrunt.hcl` config via the include block.
# ---------------------------------------------------------------------------------------------------------------------

terraform {
  extra_arguments "disable_input" {
    commands  = get_terraform_commands_that_need_input()
    arguments = ["-input=false"]
  }
}

# Configure root level variables that all resources can inherit. This is especially helpful with multi-account configs
# where terraform_remote_state data sources are placed directly into the modules.

inputs = merge(
  local.region_vars.locals,
  local.global_vars.locals
)

# S3 Remote-state and DynamoDB lock
remote_state {
  backend      = "s3"
  disable_init = tobool(get_env("TERRAGRUNT_DISABLE_INIT", "false"))

  generate = {
    path      = "_backend.tf"
    if_exists = "overwrite"
  }

  config = {
    encrypt                     = true
    region                      = "${local.aws_region}"
    key                         = format("terragrunt/%s/terraform.tfstate", path_relative_to_include())
    bucket                      = "tfstatesdemo-${local.aws_region}-${local.environment}-${local.aws_account_id}"
    dynamodb_table              = "tfstatesdemo-${local.aws_region}-${local.environment}-${local.aws_account_id}"
    skip_metadata_api_check     = true
    skip_credentials_validation = true
  }
}

# Locals that are included into this terragrunt.hcl through sub-folder hcl's
locals {
  # Automatically load region variables
  region_vars = read_terragrunt_config(find_in_parent_folders("region_vars.hcl"))

  # Automatically load global variables
  global_vars = read_terragrunt_config(find_in_parent_folders("global_vars.hcl"))

  # Extract the variables we need for easy access within this terragrunt.hcl
  aws_account_id = local.global_vars.locals.aws_account_id
  aws_region     = local.region_vars.locals.aws_region
  environment    = local.global_vars.locals.environment
}

# Generate terraform provider configuration only once to keep configuration DRY.
generate "main_providers" {
  path      = "main_providers.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "aws" {
  region                      = "${local.aws_region}"
  allowed_account_ids         = [${local.aws_account_id}]
  skip_get_ec2_platforms      = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_credentials_validation = true
}

EOF
}
