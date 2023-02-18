variable "description" {
  description = "The description of the key as viewed in AWS Console"
  type        = string
  default     = null
}

variable "key_usage" {
  description = "Specifies the intended use of the key"
  type        = string
  default     = "ENCRYPT_DECRYPT"
}

variable "customer_master_key_spec" {
  description = "Specifies whether the key contains a symmetric key or an asymmetric key pair"
  type        = string
  default     = "SYMMETRIC_DEFAULT"
}

variable "policy" {
  description = "A valid policy JSON document"
  type        = string
  default     = null
}

variable "deletion_window_in_days" {
  description = "Duration in days after which the key is deleted after destruction of the resource. Must be between 7 and 30 days"
  type        = number
  default     = 30
}

variable "is_enabled" {
  description = "Specifies whether the key is enabled"
  type        = bool
  default     = true
}

variable "enable_key_rotation" {
  description = "Specifies whether key rotation is enabled"
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of tags to assign to the object"
  type        = map(string)
  default     = {}
}

variable "aliases" {
  description = "A list of aliases to assign to the key. Must starts with `alias/`"
  type        = list(string)
  default     = []
}