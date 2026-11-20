data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

data "oci_core_images" "ubuntu" {
  compartment_id           = var.compartment_ocid
  operating_system         = "Canonical Ubuntu"
  shape                    = var.shape
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
  state                    = "AVAILABLE"
}

locals {
  image_id = data.oci_core_images.ubuntu.images[0].id
}

resource "oci_core_virtual_network" "vcn" {
  compartment_id = var.compartment_ocid
  cidr_block     = var.vcn_cidr
  display_name   = "${var.instance_name}-vcn"
  dns_label      = "monvcn"
}

resource "oci_core_internet_gateway" "igw" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.vcn.id
  display_name   = "${var.instance_name}-igw"
  enabled        = true
}

resource "oci_core_route_table" "public" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.vcn.id
  display_name   = "${var.instance_name}-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.igw.id
  }
}

resource "oci_core_security_list" "public" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.vcn.id
  display_name   = "${var.instance_name}-sl"

  dynamic "ingress_security_rules" {
    for_each = var.allowed_ssh_cidrs
    content {
      protocol = "6"
      source   = ingress_security_rules.value

      tcp_options {
        min = 22
        max = 22
      }
    }
  }

  dynamic "ingress_security_rules" {
    for_each = var.allowed_web_cidrs
    content {
      protocol = "6"
      source   = ingress_security_rules.value

      tcp_options {
        min = 80
        max = 80
      }
    }
  }

  dynamic "ingress_security_rules" {
    for_each = var.allowed_web_cidrs
    content {
      protocol = "6"
      source   = ingress_security_rules.value

      tcp_options {
        min = 443
        max = 443
      }
    }
  }

  dynamic "ingress_security_rules" {
    for_each = var.allowed_web_cidrs
    content {
      protocol = "6"
      source   = ingress_security_rules.value

      tcp_options {
        min = 6443
        max = 6443
      }
    }
  }

  dynamic "ingress_security_rules" {
    for_each = var.allowed_web_cidrs
    content {
      protocol = "6"
      source   = ingress_security_rules.value

      tcp_options {
        min = 30443
        max = 30443
      }
    }
  }

  egress_security_rules {
    protocol    = "all"
    destination  = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
  }
}

resource "oci_core_subnet" "public" {
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_virtual_network.vcn.id
  cidr_block                 = var.subnet_cidr
  display_name               = "${var.instance_name}-subnet"
  dns_label                  = "monsubnet"
  route_table_id             = oci_core_route_table.public.id
  security_list_ids          = [oci_core_security_list.public.id]
  prohibit_public_ip_on_vnic = false
}

resource "oci_core_instance" "vps" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_ocid
  display_name        = var.instance_name
  shape               = var.shape

  shape_config {
    ocpus         = var.ocpus
    memory_in_gbs = var.memory_in_gbs
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.public.id
    assign_public_ip = true
    display_name     = "${var.instance_name}-vnic"
    hostname_label   = "monitoring"
  }

  metadata = {
    ssh_authorized_keys = file(pathexpand(var.ssh_public_key_path))
    user_data           = base64encode(templatefile("${path.module}/cloud-init.yaml.tftpl", {}))
  }

  source_details {
    source_type = "image"
    source_id   = local.image_id
  }
}

data "oci_core_vnic_attachments" "primary" {
  compartment_id = var.compartment_ocid
  instance_id    = oci_core_instance.vps.id
}

data "oci_core_vnic" "primary" {
  vnic_id = data.oci_core_vnic_attachments.primary.vnic_attachments[0].vnic_id
}
