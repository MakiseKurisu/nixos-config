data oci_identity_availability_domain availability_domain {
  compartment_id = local.tenancy_ocid
  ad_number      = "1"
}

locals {
  availability_domain = data.oci_identity_availability_domain.availability_domain
}
