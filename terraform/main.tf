# main.tf
provider "aws" {
  region = "ap-northeast-2"
}

resource "aws_vpc" "static_web_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "static-web-vpc"
  }
}

resource "aws_subnet" "public_subnet" {
  count                   = 2
  vpc_id                  = aws_vpc.static_web_vpc.id
  cidr_block              = "10.0.${count.index}.0/24"
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "public-subnet-${count.index}"
  }
}

data "aws_availability_zones" "available" {}

# EKS cluster
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~>21.0"

  name               = "example"
  kubernetes_version = "1.33"

  vpc_id     = aws_vpc.static_web_vpc.id
  subnet_ids = aws_subnet.public_subnet[*].id

  eks_managed_node_groups = {
    example = {
      instance_type = ["t3.micro", "t3.small", "t4g.micro", "t4g.small", "c7i-flex.large", "m7i-flex.large"]
      desired_size  = 1
      max_size      = 3
      min_size      = 1
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }

}