variable "region" {
  description = "OCI region, for example eu-frankfurt-1"
  type        = string
}

variable "tenancy_ocid" {
  description = "OCI tenancy OCID, used to look up availability domains"
  type        = string
}

variable "compartment_ocid" {
  description = "OCI compartment OCID where resources will be created"
  type        = string
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key used for the instance"
  type        = string
}

variable "instance_name" {
  description = "Name for the compute instance"
  type        = string
  default     = "monitoring-server"
}

variable "shape" {
  description = "OCI compute shape"
  type        = string
  default     = "VM.Standard.A1.Flex"
}

variable "ocpus" {
  description = "Number of OCPUs for the Ampere instance"
  type        = number
  default     = 1
}

variable "memory_in_gbs" {
  description = "Memory in GB for the Ampere instance"
  type        = number
  default     = 6
}

variable "vcn_cidr" {
  description = "CIDR block for the VCN"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "allowed_ssh_cidrs" {
  description = "CIDR blocks allowed to SSH into the VPS"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "allowed_web_cidrs" {
  description = "CIDR blocks allowed to reach Kubernetes and Argo CD"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
