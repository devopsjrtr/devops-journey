provider "aws" {
  region = var.aws_region
}

resource "aws_security_group" "web_sg" {
  name        = "terraform-web-sg"
  description = "SSH ve HTTP erisimine izin ver"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web_sunucum" {
  ami           = var.ami_id # us-east-1 için Ubuntu 22.04
  instance_type = var.sunucu_tipi
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  # Sunucu ilk açıldığında çalışacak komutlar (Bootstrapping)
  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install nginx -y
              systemctl start nginx
              systemctl enable nginx
              echo "Terraform ile Otomatik Kurulan Web Sunucusuna Hos Geldiniz!" > /var/www/html/index.html
              EOF

  tags = {
    Name = "Terraform-Nginx-Sunucu"
  }
}
