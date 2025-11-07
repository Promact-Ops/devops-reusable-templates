provider "null" {}

resource "null_resource" "setup_docker_vps" {
  provisioner "file" {
    source      = "setup.sh"
    destination = "/tmp/install_docker.sh"

    connection {
      type        = "ssh"
      user        = "azureuser"
      host        = var.vps_ip
      private_key = file(var.private_key_path)
    }
  }

    provisioner "remote-exec" {
    inline = [
        "chmod +x /tmp/install_docker.sh",
        "sudo PROJECT_NAME=${var.project_name} ENVIRONMENT=${var.environment} bash /tmp/install_docker.sh"
    ]
    connection {
        type        = "ssh"
        user        = "azureuser"
        host        = var.vps_ip
        private_key = file(var.private_key_path)
    }
    }
}
