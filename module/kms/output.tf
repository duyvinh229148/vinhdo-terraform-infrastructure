output "this_key_id" {
  description = "The id of generated key"
  value       = aws_kms_key.this.key_id
}

output "this_key_arn" {
  description = "The arn of generated key"
  value       = aws_kms_key.this.arn
}

output "this_key_alias_names" {
  description = "The aliases of generated key"
  value       = aws_kms_alias.this.*.name
}

output "this_key_alias_arns" {
  description = "The alias arns of generated key"
  value       = aws_kms_alias.this.*.arn
}
