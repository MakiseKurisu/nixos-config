locals {
  vcn_name    = "protoducer"
  primary_subnet_name = "subnet"
  secondary_subnet_name = "secondary"
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

  ipv4cidr_blocks   = [
    cidrsubnet(oci_core_vcn.vcn.cidr_blocks[0], 8, 0),
  ]
  ipv6cidr_blocks   = [
    cidrsubnet(oci_core_vcn.vcn.ipv6cidr_blocks[0], 8, 0),
  ]
  vcn_id            = oci_core_vcn.vcn.id
  security_list_ids = [oci_core_vcn.vcn.default_security_list_id]
  route_table_id    = oci_core_vcn.vcn.default_route_table_id
  dhcp_options_id   = oci_core_vcn.vcn.default_dhcp_options_id
  display_name      = local.primary_subnet_name
  dns_label         = local.primary_subnet_name
}

resource oci_core_subnet secondary_subnet {
  compartment_id    = local.tenancy_ocid

  ipv4cidr_blocks   = [
    cidrsubnet(oci_core_vcn.vcn.cidr_blocks[0], 8, 1),
  ]
  ipv6cidr_blocks   = [
    cidrsubnet(oci_core_vcn.vcn.ipv6cidr_blocks[0], 8, 1),
  ]
  vcn_id            = oci_core_vcn.vcn.id
  security_list_ids = [oci_core_vcn.vcn.default_security_list_id]
  route_table_id    = oci_core_vcn.vcn.default_route_table_id
  dhcp_options_id   = oci_core_vcn.vcn.default_dhcp_options_id
  display_name      = local.secondary_subnet_name
  dns_label         = local.secondary_subnet_name
}

resource oci_core_default_security_list default_security_list {
  compartment_id = local.tenancy_ocid
  manage_default_resource_id = oci_core_vcn.vcn.default_security_list_id

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

  ingress_security_rules {
    protocol = "6"
    source   = oci_core_vcn.vcn.cidr_blocks[0]
  }

  ingress_security_rules {
    protocol = "6"
    source   = oci_core_vcn.vcn.ipv6cidr_blocks[0]
  }
}

resource oci_core_default_route_table default_route_table {
  compartment_id = local.tenancy_ocid
  manage_default_resource_id = oci_core_vcn.vcn.default_route_table_id

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.internet_gateway.id
  }

  route_rules {
    destination       = "::/0"
    network_entity_id = oci_core_internet_gateway.internet_gateway.id
  }
}
