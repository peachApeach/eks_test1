data "aws_caller_identity" "current" { }

locals {
  iam_role_policy_prefix = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy"
}


################################################################################
# EKS Module
################################################################################

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.21.0"

  cluster_name                   = var.cluster_name
  cluster_version = var.cluster_version
  cluster_endpoint_public_access = true
  cluster_endpoint_private_access = true

  create_cluster_security_group = false
  cluster_security_group_id = aws_security_group.sserp-cluster-SG.id

  cluster_addons = {
    coredns = {
      preserve    = true
      most_recent = true

      timeouts = {
        create = "25m"
        delete = "10m"
      }
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      most_recent = true
    }
    #amazon-cloudwatch-observability = true
  }

  vpc_id                   = data.terraform_remote_state.vpc.outputs.vpc_id
  subnet_ids               = data.terraform_remote_state.vpc.outputs.private_subnets
  control_plane_subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnets

  # 관리형 노드 그룹 사용 (기본 설정)
  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    custom_ami = {
      ami_id = var.eks_optimized_ami_id
    }
    instance_types = ["t3.xlarge"]

    attach_cluster_primary_security_group = true
    vpc_security_group_ids                = ["${aws_security_group.sserp-node-SG.id}"]
  
    
    #EBS CSI를 위한 권한, 인스턴스 세션 매니저 접근을 위한 권한 추가
    iam_role_additional_policies = {
      AmazonEBSCSIDriverPolicy  = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
      AmazonEC2RoleforSSM = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
      
    }

    tags = {
        "k8s.io/cluster-autoscaler/enabled" : "true"
        "k8s.io/cluster-autoscaler/${var.cluster_name}" : "true"
        "kubernetes.io/cluster/${var.cluster_name}" : "owned"
        "Service" : "SS-ERP-PROD-EKS"
      }
  }

  # 관리형 노드 그룹 사용
  eks_managed_node_groups = {
    SETTINGS = {
      min_size     = 2
      max_size     = 4
      desired_size = 2

      instance_types = ["c6i.2xlarge"]
      capacity_type  = "ON_DEMAND"

      subnet_ids = [data.terraform_remote_state.vpc.outputs.private_subnets[0], data.terraform_remote_state.vpc.outputs.private_subnets[1]]

      # 배포 노드 그룹을 정하기 위한 label
      # nodeSelector로 맵핑
      labels = {
        Environment = "SETTINGS"
      }
      
      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = 500
            volume_type           = "gp3"
            iops                  = 3000
            throughput            = 150
            delete_on_termination = true
          }
        }
      }
    }

    ERP = {
      min_size     = 2
      max_size     = 4
      desired_size = 2

      instance_types = ["c6i.4xlarge"]
      capacity_type  = "ON_DEMAND"
      subnet_ids = [data.terraform_remote_state.vpc.outputs.private_subnets[0], data.terraform_remote_state.vpc.outputs.private_subnets[1]]
      
      labels = {
        Environment = "ERP"
      }

      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = 500
            volume_type           = "gp3"
            iops                  = 3000
            throughput            = 150
            delete_on_termination = true
          }
        }
      }
    }

    CUSTOMER = {
      min_size     = 2
      max_size     = 4
      desired_size = 2

      instance_types = ["c6i.4xlarge"]
      capacity_type  = "ON_DEMAND"
      subnet_ids = [data.terraform_remote_state.vpc.outputs.private_subnets[2], data.terraform_remote_state.vpc.outputs.private_subnets[3]]
      
      labels = {
        Environment = "CUSTOMER"
      }

      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = 500
            volume_type           = "gp3"
            iops                  = 3000
            throughput            = 150
            delete_on_termination = true
          }
        }
      }

    }
  }

    
  # aws-auth configmap
  manage_aws_auth_configmap = true

  aws_auth_users = [
    {
      userarn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/mia0102"
      username = "mia0102"
      groups   = ["system:masters"]
    },
    {
      userarn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/smpark"
      username = "smpark"
      groups   = ["system:masters"]
    },
  ]
  
}