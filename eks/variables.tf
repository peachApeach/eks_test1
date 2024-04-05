variable "region" {
  description = "region"
  type        = string
}

variable "cluster_name" {
  description = "sserp clustername"
  type        = string
}

variable "cluster_version" {
  description = "EKS cluster version"
  type        = string
  default = "1.28"
}

variable "sserpSGInbound-http-1" {
  description = "sserp EKS cluster SG HTTP 1"
  type        = string
}

variable "sserpSGInbound-http-2" {
  description = "sserp EKS cluster SG HTTP 2"
  type        = string
}

variable "sserpSGInbound-DB" {
  description = "sserp EKS cluster SG DB"
  type        = list(string)
}

variable "eks_optimized_ami_id" {
  description = "Set on EKS managed node group base image"
  type        = string
}