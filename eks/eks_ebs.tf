# provider kubernetes에 의해 연결 
################################################################################
# 자동으로 생성되는 gp2 storage class : default class에서 제거
# kubernetes patch api 가 현재 terraform으로 제공되고 있지 않기 때문에, annotation을 엎어치는 방식으로 사용
################################################################################
resource "kubernetes_annotations" "sc_gp2" {
  api_version = "storage.k8s.io/v1"
  kind        = "StorageClass"
  force       = "true"

  metadata {
    name = "gp2"
  }
  annotations = {
    "storageclass.kubernetes.io/is-default-class" = "false"
  }
}

################################################################################
# Create GP3 Storage Class - Default Class 적용
################################################################################
resource "kubernetes_storage_class_v1" "gp3" {
  metadata {
    name   = "gp3"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }

  storage_provisioner = "ebs.csi.aws.com"
  volume_binding_mode = "WaitForFirstConsumer"
  parameters = {
    "type"                      = "gp3"
    "csi.storage.k8s.io/fstype" = "ext4"
  }

  # allow_volume_expansion = true
  # allowed_topologies { 
  #   match_label_expressions {
  #       key = "topology.kubernetes.io/zone"
  #       values = ["${var.region}a"]
  #   } 
  # }
}

# resource "kubernetes_persistent_volume_claim_v1" "deployNode" {
#   metadata {
#     name = "deploy-node-pvc"
#   }
#   spec {
#     access_modes = ["ReadWriteOnce"]
#     resources {
#       requests = {
#         storage = "500Gi"
#       }
#     }
#     volume_name = "sserp-deploy-ebs"
#     storage_class_name = "gp3-a"
#   }
# }

# resource "kubernetes_storage_class_v1" "gp3-c" {
#   metadata {
#     name   = "gp3-c"
#     annotations = {
#       "storageclass.kubernetes.io/is-default-class" = "false"
#     }
#   }

#   storage_provisioner = "ebs.csi.aws.com"
#   volume_binding_mode = "WaitForFirstConsumer"
#   parameters = {
#     "type"                      = "gp3"
#     "csi.storage.k8s.io/fstype" = "ext4"
#   }

#   allow_volume_expansion = true
#   allowed_topologies { 
#     match_label_expressions {
#         key = "topology.kubernetes.io/zone"
#         values = ["${var.region}c"]
#     } 
#   }
# }

# resource "kubernetes_persistent_volume_claim_v1" "settingNode" {
#   metadata {
#     name = "setting-node-pvc"
#   }

#   spec {
#     access_modes = ["ReadWriteOnce"]
#     resources {
#       requests = {
#         storage = "500Gi"
#       }
#     }
#     volume_name = "sserp-setting-ebs"
#     storage_class_name = "gp3-c"
#   }
# }