# terraform.tfvars actual values
# Overrides defaults in variables.tf
# Committed to Git (no secrets here)
# ── Environment IPs and DB credentials ──
# db_ip defaults in variables.tf - no override needed
db_name = "fsm_db"
db_user = "flaskapp"
# db_password NOT stored here (never put passwords in files)
# Setup-DevOps-Environment.ps1 populated the password in the appropriate environment
# ─── How Terraform resolves variable values ───
# 1. -var flag on CLI (highest priority)
# 2. terraform.tfvars (this file)
# 3. default in variables.tf (lowest)
# These values feed into resources via:
# var.aws_region
# var.az
# var.db_instance_type
