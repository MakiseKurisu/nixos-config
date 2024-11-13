# Source from https://registry.terraform.io/providers/oracle/oci/latest/docs/data-sources/identity_availability_domains

# Tenancy is the root or parent to all compartments.
# For this tutorial, use the value of <tenancy-ocid> for the compartment OCID.

data oci_core_images images {
  compartment_id = local.tenancy_ocid
}

locals {
  ubuntu_images = {
    amd64 = [
      for i in data.oci_core_images.images.images : i
      if i.operating_system == "Canonical Ubuntu" &&
        i.operating_system_version == "24.04" &&
        !strcontains(i.display_name, "aarch64")
    ][0]
    arm64 = [
      for i in data.oci_core_images.images.images : i
      if i.operating_system == "Canonical Ubuntu" &&
        i.operating_system_version == "24.04" &&
        strcontains(i.display_name, "aarch64")
    ][0]
  }
}
