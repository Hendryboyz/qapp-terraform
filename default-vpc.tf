resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

resource "aws_default_subnet" "default" {
  for_each          = var.subnets
  availability_zone = each.value

  tags = {
    Name = "Default subnet for ${each.value}"
  }
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [aws_default_vpc.default.id]
  }
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_default_vpc.default.id

  ingress = [
    {
      protocol         = -1
      description      = "Default inbound rule"
      from_port        = 0
      to_port          = 0
      self             = true
      security_groups  = []
      cidr_blocks      = []
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
    },
    {
      protocol         = "tcp"
      description      = "Free tier PostgreSQL inbound rule"
      from_port        = 5432
      to_port          = 5432
      self             = false
      security_groups  = []
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
    }
  ]

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    description = "Default outbound rule"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
