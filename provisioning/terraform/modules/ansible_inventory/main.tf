resource "local_file" "ansible_inventory" {
	content = templatefile("${path.module}/inventory.tpl",
		{
			ip_address = var.ip_address,
			user = var.user,
		}
	)
	filename = "../../../ansible/inventory/hosts"
}
