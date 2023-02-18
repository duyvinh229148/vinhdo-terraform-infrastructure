include "root" {
  path = find_in_parent_folders()
}

include "env" {
  path   = "${get_terragrunt_dir()}/../../_env/eks.hcl"
  expose = true
}

#inputs = {
#  env = "qa"
#}