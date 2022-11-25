resource "vault_audit" "file" {
  type = "file"
  options = {
    file_path = var.vault_audit_path
  }
}
