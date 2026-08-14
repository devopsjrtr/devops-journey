variable "aws_region" {
  description = "AWS'de calisacagimiz bolge"
  default     = "us-east-1"
}

variable "sunucu_tipi" {
  description = "EC2 instance tipi"
  default     = "t3.small"
}

variable "ami_id" {
  description = "EC2 AMI id'si"
  default     = "ami-0b6d9d3d33ba97d99"
}
