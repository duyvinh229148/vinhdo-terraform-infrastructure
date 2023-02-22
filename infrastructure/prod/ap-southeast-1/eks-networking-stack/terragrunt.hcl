include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "common_generate_provider" {
  path   = "${dirname(find_in_parent_folders("root.hcl"))}/_env_common/_common_generate_provider.hcl"
  expose = true
}

include "env" {
  path   = "${dirname(find_in_parent_folders("root.hcl"))}/_env_common/eks-networking-stack.hcl"
  expose = true
}