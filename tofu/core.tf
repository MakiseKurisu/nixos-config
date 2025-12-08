locals {
  vcn_name    = "protoducer"
  subnet_name = "subnet"
  amd0_name   = "amd0"
  amd1_name   = "amd1"
  arm0_name   = "arm0"
  arm1_name   = "arm1"
  arm0_name2  = "arm0-2"
  arm1_name2  = "arm1-2"
  if0_name    = "eth0"
  if1_name    = "eth1"
}

resource oci_core_vcn vcn {
  compartment_id = local.tenancy_ocid

  cidr_blocks    = ["10.0.0.0/16"]
  is_ipv6enabled = true
  display_name   = local.vcn_name
  dns_label      = local.vcn_name
}

resource oci_core_internet_gateway internet_gateway {
  compartment_id = local.tenancy_ocid
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "gateway"
}

resource oci_core_subnet subnet {
  compartment_id    = local.tenancy_ocid

  cidr_block        = cidrsubnet(oci_core_vcn.vcn.cidr_blocks[0], 8, 0)
  ipv6cidr_blocks   = [
    cidrsubnet(oci_core_vcn.vcn.ipv6cidr_blocks[0], 8, 0),
  ]
  vcn_id            = oci_core_vcn.vcn.id
  security_list_ids = [oci_core_security_list.security_list.id]
  route_table_id    = oci_core_route_table.route_table.id
  dhcp_options_id   = oci_core_vcn.vcn.default_dhcp_options_id
  display_name      = local.subnet_name
  dns_label         = local.subnet_name
}

resource oci_core_security_list security_list {
  compartment_id = local.tenancy_ocid
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "security_list"

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }

  egress_security_rules {
    protocol    = "all"
    destination = "::/0"
  }

  ingress_security_rules {
    protocol = "1"
    source   = "0.0.0.0/0"
  }

  ingress_security_rules {
    protocol = "58"
    source   = "::/0"
  }

  ingress_security_rules {
    protocol = "17"
    source   = "0.0.0.0/0"

    udp_options {
      max = "51820"
      min = "51820"
    }
  }

  ingress_security_rules {
    protocol = "17"
    source   = "::/0"

    udp_options {
      max = "51820"
      min = "51820"
    }
  }
}

resource oci_core_route_table route_table {
  compartment_id = local.tenancy_ocid
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "route_table"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.internet_gateway.id
  }

  route_rules {
    destination       = "::/0"
    network_entity_id = oci_core_internet_gateway.internet_gateway.id
  }
}

resource oci_core_instance amd0 {
  availability_domain = local.availability_domain.name
  compartment_id      = local.tenancy_ocid
  shape               = "VM.Standard.E2.1.Micro"
  display_name        = local.amd0_name
  is_pv_encryption_in_transit_enabled = true

  metadata = {
    ssh_authorized_keys = file("~/.ssh/id_rsa.pub")
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.subnet.id
    assign_ipv6ip    = true
    assign_private_dns_record = true
    assign_public_ip = true
    display_name     = local.if0_name
    hostname_label   = local.amd0_name
    private_ip       = "${substr(oci_core_subnet.subnet.cidr_block, 0, length(oci_core_subnet.subnet.cidr_block) - length("0/24"))}10"
    ipv6address_ipv6subnet_cidr_pair_details {
      ipv6subnet_cidr = oci_core_subnet.subnet.ipv6cidr_blocks[0]
      ipv6address = "${substr(oci_core_subnet.subnet.ipv6cidr_blocks[0], 0, length(oci_core_subnet.subnet.ipv6cidr_blocks[0]) - length("0000/64"))}10"
    }
  }

  instance_options {
    are_legacy_imds_endpoints_disabled = true
  }

  source_details {
    source_type = "image"
    source_id   = local.ubuntu_images.amd64.id
    boot_volume_size_in_gbs = 50
    boot_volume_vpus_per_gb = 120
  }
}

resource oci_core_instance amd1 {
  availability_domain = local.availability_domain.name
  compartment_id      = local.tenancy_ocid
  shape               = "VM.Standard.E2.1.Micro"
  display_name        = local.amd1_name
  is_pv_encryption_in_transit_enabled = true

  metadata = {
    ssh_authorized_keys = file("~/.ssh/id_rsa.pub")
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.subnet.id
    assign_ipv6ip    = true
    assign_private_dns_record = true
    assign_public_ip = true
    display_name     = local.if0_name
    hostname_label   = local.amd1_name
    private_ip       = "${substr(oci_core_subnet.subnet.cidr_block, 0, length(oci_core_subnet.subnet.cidr_block) - length("0/24"))}11"
    ipv6address_ipv6subnet_cidr_pair_details {
      ipv6subnet_cidr = oci_core_subnet.subnet.ipv6cidr_blocks[0]
      ipv6address = "${substr(oci_core_subnet.subnet.ipv6cidr_blocks[0], 0, length(oci_core_subnet.subnet.ipv6cidr_blocks[0]) - length("0000/64"))}11"
    }
  }

  instance_options {
    are_legacy_imds_endpoints_disabled = true
  }

  source_details {
    source_type = "image"
    source_id   = local.ubuntu_images.amd64.id
    boot_volume_size_in_gbs = 50
    boot_volume_vpus_per_gb = 120
  }
}

resource oci_core_instance arm0 {
  availability_domain = local.availability_domain.name
  compartment_id      = local.tenancy_ocid
  shape               = "VM.Standard.A1.Flex"
  display_name        = local.arm0_name
  is_pv_encryption_in_transit_enabled = true

  metadata = {
    ssh_authorized_keys = file("~/.ssh/id_rsa.pub")
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.subnet.id
    assign_ipv6ip    = true
    assign_private_dns_record = true
    assign_public_ip = true
    display_name     = local.if0_name
    hostname_label   = local.arm0_name
    private_ip       = "${substr(oci_core_subnet.subnet.cidr_block, 0, length(oci_core_subnet.subnet.cidr_block) - length("0/24"))}20"
    ipv6address_ipv6subnet_cidr_pair_details {
      ipv6subnet_cidr = oci_core_subnet.subnet.ipv6cidr_blocks[0]
      ipv6address = "${substr(oci_core_subnet.subnet.ipv6cidr_blocks[0], 0, length(oci_core_subnet.subnet.ipv6cidr_blocks[0]) - length("0000/64"))}20"
    }
  }

  instance_options {
    are_legacy_imds_endpoints_disabled = true
  }

  shape_config {
    ocpus               = 2
    memory_in_gbs       = 12
  }

  source_details {
    source_type = "image"
    source_id   = local.ubuntu_images.arm64.id
    boot_volume_size_in_gbs = 50
    boot_volume_vpus_per_gb = 120
  }
}

resource "oci_core_vnic_attachment" arm0_eth1 {
  instance_id  = oci_core_instance.arm0.id

  create_vnic_details {
    subnet_id        = oci_core_subnet.subnet.id
    assign_ipv6ip    = true
    assign_private_dns_record = true
    assign_public_ip = true
    display_name     = local.if1_name
    hostname_label   = local.arm0_name2
    private_ip       = "${substr(oci_core_subnet.subnet.cidr_block, 0, length(oci_core_subnet.subnet.cidr_block) - length("0/24"))}30"
    ipv6address_ipv6subnet_cidr_pair_details {
      ipv6_subnet_cidr = oci_core_subnet.subnet.ipv6cidr_blocks[0]
      ipv6_address = "${substr(oci_core_subnet.subnet.ipv6cidr_blocks[0], 0, length(oci_core_subnet.subnet.ipv6cidr_blocks[0]) - length("0000/64"))}30"
    }
  }
}

resource oci_core_instance arm1 {
  availability_domain = local.availability_domain.name
  compartment_id      = local.tenancy_ocid
  shape               = "VM.Standard.A1.Flex"
  display_name        = local.arm1_name
  is_pv_encryption_in_transit_enabled = true

  metadata = {
    ssh_authorized_keys = file("~/.ssh/id_rsa.pub")
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.subnet.id
    assign_ipv6ip    = true
    assign_private_dns_record = true
    assign_public_ip = true
    display_name     = local.if0_name
    hostname_label   = local.arm1_name
    private_ip       = "${substr(oci_core_subnet.subnet.cidr_block, 0, length(oci_core_subnet.subnet.cidr_block) - length("0/24"))}21"
    ipv6address_ipv6subnet_cidr_pair_details {
      ipv6subnet_cidr = oci_core_subnet.subnet.ipv6cidr_blocks[0]
      ipv6address = "${substr(oci_core_subnet.subnet.ipv6cidr_blocks[0], 0, length(oci_core_subnet.subnet.ipv6cidr_blocks[0]) - length("0000/64"))}21"
    }
  }

  instance_options {
    are_legacy_imds_endpoints_disabled = true
  }

  shape_config {
    ocpus               = 2
    memory_in_gbs       = 12
  }

  source_details {
    source_type = "image"
    source_id   = local.ubuntu_images.arm64.id
    boot_volume_size_in_gbs = 50
    boot_volume_vpus_per_gb = 120
  }
}

resource "oci_core_vnic_attachment" arm1_eth1 {
  instance_id  = oci_core_instance.arm1.id

  create_vnic_details {
    subnet_id        = oci_core_subnet.subnet.id
    assign_ipv6ip    = true
    assign_private_dns_record = true
    assign_public_ip = true
    display_name     = local.if1_name
    hostname_label   = local.arm1_name2
    private_ip       = "${substr(oci_core_subnet.subnet.cidr_block, 0, length(oci_core_subnet.subnet.cidr_block) - length("0/24"))}31"
    ipv6address_ipv6subnet_cidr_pair_details {
      ipv6_subnet_cidr = oci_core_subnet.subnet.ipv6cidr_blocks[0]
      ipv6_address = "${substr(oci_core_subnet.subnet.ipv6cidr_blocks[0], 0, length(oci_core_subnet.subnet.ipv6cidr_blocks[0]) - length("0000/64"))}31"
    }
  }
}
