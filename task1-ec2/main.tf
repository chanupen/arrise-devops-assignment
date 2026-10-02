data "aws_availability_zones" "available" {
  state = "available"

  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Lab VPC. Default VPC is gone in most accounts I work in, so don't depend on it.
resource "aws_vpc" "lab" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "arrise-lab"
  }
}

resource "aws_subnet" "lab" {
  vpc_id                  = aws_vpc.lab.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, 1)
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = false

  tags = {
    Name = "arrise-lab-a"
  }
}

resource "aws_security_group" "lab" {
  name        = "arrise-lab"
  description = "No ingress. Lab boxes are not logged into."
  vpc_id      = aws_vpc.lab.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "arrise-lab"
  }
}

locals {
  key_names = toset([for _, v in var.instances : v.key_name])
}

# Lab only. Private key lands in state — I would not do this for a real key.
# At work the key already exists and we just pass key_name.
resource "tls_private_key" "lab" {
  for_each  = local.key_names
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "lab" {
  for_each   = local.key_names
  key_name   = each.value
  public_key = tls_private_key.lab[each.key].public_key_openssh
}

resource "local_sensitive_file" "pem" {
  for_each        = local.key_names
  filename        = "${path.module}/../.keys/${each.value}.pem"
  content         = tls_private_key.lab[each.key].private_key_pem
  file_permission = "0600"
}

module "fleet" {
  source = "./modules/ec2_fleet"

  instances          = var.instances
  ami_id             = data.aws_ami.al2023.id
  subnet_id          = aws_subnet.lab.id
  security_group_ids = [aws_security_group.lab.id]
  environment        = var.environment
  owner              = var.owner

  # key_name is only a string. Without this, the instance can be requested
  # before the key pair exists and AWS rejects the run.
  depends_on = [aws_key_pair.lab]
}
