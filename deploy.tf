resource "local_file" "ansible_inventory" {
    content     = "[web]\n${element(var.domains, 0)}.devops.srwx.net ansible_ssh_user=ubuntu  letsencrypt_email=denergym@mail.ru  domain_name1=${element(var.domains, 0)}.devops.srwx.net domain_name2=${element(v$
     filename = "inventory/calc"
}

resource "null_resource" "deploy" {

 provisioner "local-exec" {
    command = "ansible-playbook -i inventory/calc --private-key ${var.ssh_key_path} pre.yml"
  }


  provisioner "local-exec" {
    command = "ansible-playbook -i inventory/calc --private-key ${var.ssh_key_path} front.yml"
  }

  provisioner "local-exec" {
    command = "ansible-playbook -i inventory/calc --private-key ${var.ssh_key_path} back.yml"

 }
}
