terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.0"
    }
  }
}

provider "docker" {}

# Ubuntu imajını lokalimize indiriyoruz
resource "docker_image" "ubuntu" {
  name         = "ubuntu:latest"
  keep_locally = true
}

# EC2 yerine geçecek olan Docker Container'ımız
resource "docker_container" "hedef_sunucu" {
  image = docker_image.ubuntu.image_id
  name  = "local-target-server"
  
  # Container'ın hemen kapanmaması için sonsuz bir uyku döngüsüne sokuyoruz
  command = ["tail", "-f", "/dev/null"]
}

# Container oluştuktan sonra Ansible'ı tetikleyen entegrasyon bloğu
resource "null_resource" "run_ansible" {
  # Önce container'ın ayağa kalkmasını bekle
  depends_on = [docker_container.hedef_sunucu]

  provisioner "local-exec" {
    # Container hazır olduğunda playbook'u çalıştır
    command = "ansible-playbook -i inventory.ini playbook.yml"
  }
}
