################################################################################
# Cluster Security Group
################################################################################
resource "aws_security_group" "sserp-node-SG" {
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id
  name = "sserp-node-SG"
  description = "sserp EKS cluster SecuritiyGroup"

  tags = {
        "Name"="sserp-node-SG"
        "kubernetes.io/cluster/${var.cluster_name}" = "owned"
        "aws:eks:cluster-name" = "${var.cluster_name}"
      }
}

resource "aws_security_group_rule" "sserpNodeSGInbound-https-1" {
  security_group_id = aws_security_group.sserp-node-SG.id
  type = "ingress"
  from_port = 443
  to_port = 443
  protocol = "TCP"
  cidr_blocks = ["${var.sserpSGInbound-http-1}"]
  description = "SMATSCORE OFFICE DEV"
}

resource "aws_security_group_rule" "sserpNodeSGInbound-https-2" {
  security_group_id = aws_security_group.sserp-node-SG.id
  type = "ingress"
  from_port = 443
  to_port = 443
  protocol = "TCP"
  cidr_blocks = ["${var.sserpSGInbound-http-2}"]
  description = "SMATSCORE OFFICE DEV"
}

resource "aws_security_group_rule" "sserpNodeSGInbound-http-1" {
  security_group_id = aws_security_group.sserp-node-SG.id
  type = "ingress"
  from_port = 80
  to_port = 80
  protocol = "TCP"
  cidr_blocks = ["${data.terraform_remote_state.vpc.outputs.vpc_cidr_block}"]
  description = "Follow ELB"
}

resource "aws_security_group_rule" "sserpNodeSGInbound-DB-1" {
  security_group_id = aws_security_group.sserp-node-SG.id
  type = "ingress"
  from_port = 13306
  to_port = 13306
  protocol = "TCP"
  cidr_blocks = var.sserpSGInbound-DB
  description = "Connect smartscore-erp-dev-dbserver"
}