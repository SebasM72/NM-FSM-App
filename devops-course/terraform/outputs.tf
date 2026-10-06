# outputs.tf — values that exist only AFTER apply
output "ecr_repository_url" {
  description = "Push Docker images here in Module 5"
  value       = local.ecr_repository_url
}
output "db_private_ip" {
  description = "MySQL IP for the current workspace"
  value       = aws_instance.mysql_db.private_ip
}
# ── Rule of thumb ────────────────────────────────
# Output what AWS generated or Terraform discovered.
# Never output what you typed into terraform.tfvars
# — you already know that value.
# ── What you see after terraform apply ───────────
# Outputs:
# db_private_ip = "172.31.133.10"
# ecr_repository_url = "123456789012.dkr.ecr.us-
# east-1.amazonaws.com/nm-fsm-app"
