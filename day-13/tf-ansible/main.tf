provider "aws" {
  region = "us-east-1"
}

# 1. Ürettiğimiz public anahtarı AWS'ye yüklüyoruz
resource "aws_key_pair" "ansible_key" {
  key_name   = "ansible-ssh-key"
  public_key = file("~/.ssh/ansible_rsa.pub")
}

# 2. Güvenlik Grubu (SSH ve HTTP açık)
resource "aws_security_group" "web_sg" {
  name = "tf-ansible-sg"

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

# 3. Yeni EC2 Sunucumuz
resource "aws_instance" "hedef_sunucu" {
  ami                    = "ami-0b6d9d3d33ba97d99"
  instance_type          = "t3.small"
  key_name               = aws_key_pair.ansible_key.key_name
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  
  tags = { 
    Name = "Ansible-Hedef-Sunucu" 
  }
}

output "hedef_ip" {
  value = aws_instance.hedef_sunucu.public_ip
}
