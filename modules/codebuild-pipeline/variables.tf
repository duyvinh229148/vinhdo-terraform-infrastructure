### Required variables
variable "project_name" {
  description = "Name of project"
  type = string
}

### Optional variables
variable "aws_account_id" {
  description = "Alternative AWS Account ID"
  type = string
  default = null
}

variable "tags" {
  type = map(string)
  description = "Common AWS Tags for resources"
  default = {}
}

### AWS IAM Role for Codebuild project
variable "create_iam_role" {
  type = bool
  default = true
}

variable "iam_role_name_override" {
  type  = string
  default = null
}

variable "use_existing_iam_role" {
  type = bool
  default = false
}

variable "codebuild_project_name_override" {
  type    = string
  default = null
}

variable "codebuild_source_buildspec" {
  type = string
  default = null
}

variable "s3_buckets" {
  type = list(string)
  default = []
}


