data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "smartscoretfstate"
    region = var.region
    key = "vpc/terraform.tfstate"
  }
}

resource "aws_ec2_tag" "private_subnet_cluster_tag" {
  for_each    = toset(data.terraform_remote_state.vpc.outputs.private_subnets)
  resource_id = each.value
  key         = "kubernetes.io/cluster/${var.cluster_name}"
  value       = "shared"
}

resource "aws_ec2_tag" "private_subnet_tag" {
  for_each    = toset(data.terraform_remote_state.vpc.outputs.private_subnets)
  resource_id = each.value
  key         = "kubernetes.io/role/elb"
  value       = "1"
}