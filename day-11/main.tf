# Sağlayıcı (Provider) Ayarı: Hangi bulut platformunu kullanacağız?
provider "aws" {
  region = "us-east-1" # Kendi çalıştığın bölgeyi buraya yaz (örn: eu-central-1)
}

# 1. Yeni Güvenlik Grubu (Security Group) Oluşturuyoruz
resource "aws_security_group" "ssh_izni" {
  name        = "terraform-ssh-sg"
  description = "SSH baglantisina izin ver"

  # İçeriye giriş (Inbound) kuralları
  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # İnternetteki herkese açık (Eğitim amaçlı)
  }

  # Dışarıya çıkış (Outbound) kuralları
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Tüm protokollere izin ver
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 2. Kaynak (Resource) Ayarı: Ne oluşturacağız?
resource "aws_instance" "ilk_sunucum" {
  # ami değeri bölgeye göre değişir. Aşağıdaki us-east-1 için bir Ubuntu 22.04 AMI'sidir.
  ami           = "ami-0b6d9d3d33ba97d99" 
  instance_type = "t3.small" # Ücretsiz katman (Free Tier)

  # YENİ EKLENEN SATIR: Sunucuyu yukarıdaki güvenlik grubuna bağlıyoruz
  vpc_security_group_ids = [aws_security_group.ssh_izni.id]

  tags = {
    Name = "Terraform-Ile-Gelen-Sunucu"
  }
}
