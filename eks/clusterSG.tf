################################################################################
# Cluster Security Group
################################################################################
resource "aws_security_group" "sserp-cluster-SG" {
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id
  name = "sserp-cluster-SG"
  description = "sserp EKS cluster SecuritiyGroup"

  tags = {
        "Name"="sserp-cluster-SG"
        "kubernetes.io/cluster/${var.cluster_name}" = "owned"
        "aws:eks:cluster-name" = "${var.cluster_name}"
      }
}

resource "aws_security_group_rule" "sserpSGInbound-https-1" {
  security_group_id = aws_security_group.sserp-cluster-SG.id
  type = "ingress"
  from_port = 443
  to_port = 443
  protocol = "TCP"
  cidr_blocks = ["${var.sserpSGInbound-http-1}"]
  description = "SMATSCORE OFFICE DEV"
}

resource "aws_security_group_rule" "sserpSGInbound-https-2" {
  security_group_id = aws_security_group.sserp-cluster-SG.id
  type = "ingress"
  from_port = 443
  to_port = 443
  protocol = "TCP"
  cidr_blocks = ["${var.sserpSGInbound-http-2}"]
  description = "SMATSCORE OFFICE DEV"
}

resource "aws_security_group_rule" "sserpSGOutbound" {
  security_group_id = aws_security_group.sserp-cluster-SG.id
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = -1
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "sserpSGInbound-http-1" {
  security_group_id = aws_security_group.sserp-cluster-SG.id
  type = "ingress"
  from_port = 80
  to_port = 80
  protocol = "TCP"
  cidr_blocks = ["${var.sserpSGInbound-http-1}"]
  description = "SMATSCORE OFFICE DEV"
}

resource "aws_security_group_rule" "sserpSGInbound-http-2" {
  security_group_id = aws_security_group.sserp-cluster-SG.id
  type = "ingress"
  from_port = 80
  to_port = 80
  protocol = "TCP"
  cidr_blocks = ["${var.sserpSGInbound-http-2}"]
  description = "SMATSCORE OFFICE DEV"
}
