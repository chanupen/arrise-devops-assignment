locals {
  protected = { for name, cfg in var.instances : name => cfg if cfg.protect }
  fleet     = { for name, cfg in var.instances : name => cfg if !cfg.protect }
}

resource "aws_instance" "fleet" {
  for_each = local.fleet

  ami                    = var.ami_id
  instance_type          = each.value.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids
  key_name               = each.value.key_name

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    volume_type = each.value.root_volume_type
    volume_size = each.value.root_volume_size
    iops        = contains(["io1", "io2", "gp3"], each.value.root_volume_type) ? each.value.root_iops : null
    encrypted   = true
  }

  tags = {
    Name        = each.key
    Environment = var.environment
    Owner       = var.owner
  }

  lifecycle {
    prevent_destroy = true
  }
}

# Own resource so prevent_destroy can be a literal. Still fed from var.instances.
resource "aws_instance" "protected" {
  for_each = local.protected

  ami                    = var.ami_id
  instance_type          = each.value.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids
  key_name               = each.value.key_name

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    volume_type = each.value.root_volume_type
    volume_size = each.value.root_volume_size
    iops        = each.value.root_iops
    encrypted   = true
  }

  tags = {
    Name        = each.key
    Environment = var.environment
    Owner       = var.owner
  }
}
