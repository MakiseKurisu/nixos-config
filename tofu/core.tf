resource oci_core_vcn primary {
  compartment_id = local.tenancy_ocid

  cidr_blocks    = ["10.0.0.0/16"]
  display_name   = "primary"
  is_ipv6enabled = true
}

resource oci_core_internet_gateway gateway {
  compartment_id = local.tenancy_ocid
  display_name   = "gateway"
  vcn_id         = oci_core_vcn.primary.id
}

resource oci_core_subnet subnet {
  compartment_id    = local.tenancy_ocid

  cidr_block        = "10.0.0.0/24"
  display_name      = "subnet"
  vcn_id            = oci_core_vcn.primary.id
  security_list_ids = [oci_core_security_list.security_list.id]
  route_table_id    = oci_core_route_table.route.id
  dhcp_options_id   = oci_core_vcn.primary.default_dhcp_options_id
}

resource oci_core_security_list security_list {
  compartment_id = local.tenancy_ocid
  vcn_id         = oci_core_vcn.primary.id
  display_name   = "security"

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
    stateless = true
  }

  ingress_security_rules {
    protocol = "58"
    source   = "::/0"
    stateless = true
  }

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    stateless = true

    tcp_options {
      max = "51820"
      min = "51820"
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = "::/0"
    stateless = true

    tcp_options {
      max = "51820"
      min = "51820"
    }
  }

  ingress_security_rules {
    protocol = "17"
    source   = "0.0.0.0/0"
    stateless = true

    udp_options {
      max = "51820"
      min = "51820"
    }
  }

  ingress_security_rules {
    protocol = "17"
    source   = "::/0"
    stateless = true

    udp_options {
      max = "51820"
      min = "51820"
    }
  }
}

resource oci_core_route_table route {
  compartment_id = local.tenancy_ocid
  vcn_id         = oci_core_vcn.primary.id
  display_name   = "route"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.gateway.id
  }

  route_rules {
    destination       = "::/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.gateway.id
  }
}

resource oci_core_instance amd01 {
  display_name        = "amd01"
  availability_domain = local.availability_domain.name
  compartment_id      = local.tenancy_ocid
  shape               = "VM.Standard.E2.1.Micro"

  create_vnic_details {
    subnet_id        = oci_core_subnet.subnet.id
    display_name     = "eth0"
    assign_public_ip = true
  }

  source_details {
    source_type = "image"
    source_id   = local.ubuntu_images.amd64.id
    boot_volume_size_in_gbs = 50
    boot_volume_vpus_per_gb = 120
  }

  metadata = {
    ssh_authorized_keys = file("~/.ssh/id_rsa.pub")
  }
}

resource oci_core_instance arm01 {
  display_name        = "arm01"
  availability_domain = local.availability_domain.name
  compartment_id      = local.tenancy_ocid
  shape               = "VM.Standard.A1.Flex"

  shape_config {
    ocpus               = 2
    memory_in_gbs       = 12
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.subnet.id
    display_name     = "eth0"
    assign_public_ip = true
  }

  source_details {
    source_type = "image"
    source_id   = local.ubuntu_images.arm64.id
    boot_volume_size_in_gbs = 50
    boot_volume_vpus_per_gb = 120
  }

  metadata = {
    ssh_authorized_keys = file("~/.ssh/id_rsa.pub")
  }
}

resource oci_core_instance arm02 {
  display_name        = "arm02"
  availability_domain = local.availability_domain.name
  compartment_id      = local.tenancy_ocid
  shape               = "VM.Standard.A1.Flex"

  shape_config {
    ocpus               = 2
    memory_in_gbs       = 12
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.subnet.id
    display_name     = "eth0"
    assign_public_ip = true
  }

  source_details {
    source_type = "image"
    source_id   = local.ubuntu_images.arm64.id
    boot_volume_size_in_gbs = 50
    boot_volume_vpus_per_gb = 120
  }

  metadata = {
    ssh_authorized_keys = file("~/.ssh/id_rsa.pub")
  }
}
