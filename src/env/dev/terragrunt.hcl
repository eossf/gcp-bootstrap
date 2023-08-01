include "root" {
  path   = find_in_parent_folders()
  expose = true
  merge_strategy = "deep"
}

locals { 
  env = read_terragrunt_config("env.hcl")
  deployment_environment = local.env.locals.deployment_environment
}

# root level variables 
inputs = merge(
  local.env.locals,
)

include "provision-gcp-infra" {
  path = "${get_repo_root()}/terragrunt.hcl"
  expose = true
}