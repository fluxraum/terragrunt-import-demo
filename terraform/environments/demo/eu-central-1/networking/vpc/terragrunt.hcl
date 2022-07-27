terraform {
  source = "git::git@github.com:terraform-aws-modules/terraform-aws-vpc.git?ref=v3.14.0"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  create_vpc      = true
  name            = "demo-vpc"
  cidr            = "10.25.0.0/16"
  azs             = ["eu-central-1a","eu-central-1b","eu-central-1c"]
  private_subnets = ["10.25.0.0/19", "10.25.32.0/19", "10.25.64.0/19"]
  public_subnets  = ["10.25.101.0/24", "10.25.102.0/24", "10.25.103.0/24"]
}